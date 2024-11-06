const encryption = require("../utils/encrypt.util");
const ERROR = require("../constants/error.json");
const jwt = require("jsonwebtoken");
const query = require("../repositories/query.json");
const queryExecutor = require("../utils/queryExecutor.util");
const PRE_LOGIN_ROUTES = require("../constants/routes");
const AppError = require("../utils/AppError.util");
const JWT = require("../constants/jwt.json");

const auth = (req, res, next) => {
  const { headers } = req;
  console.log(req.url);
  var isPreLogin = false;
  PRE_LOGIN_ROUTES.forEach((route) => {
    if (route === req.url) {
      isPreLogin = true;
      return;
    }
  });
  if (isPreLogin) {
    next();
  } else {
    const token = headers.authorization
      ? headers.authorization.split(" ")
        ? headers.authorization.split(" ")[1]
        : ""
      : "";
    if (token && token !== "" && token !== undefined) {
      jwt.verify(token, process.env.JWT_SECRET_KEY, async (err, decoded) => {
        if (err) {
          if (err.name === "TokenExpiredError") {
            await queryExecutor(query.preLogin.findSessionByToken, [token])
              .then((response) => {
                if (response && response?.data[0] && response?.data[0][0]) {
                  let users = response?.data[0][0];
                  if (users.userFound === 1) {
                    res.status(401).json(
                      encryption.encryptResponse(
                        JSON.stringify({
                          status: false,
                          message: ERROR[400].tokenExpired,
                          details: {
                            tokenExpired: true,
                            isTokenInvalid: false,
                          },
                        }),
                        req.headers
                      )
                    );
                  } else {
                    res.status(401).json(
                      encryption.encryptResponse(
                        JSON.stringify({
                          status: false,
                          message: ERROR[400].tokenNotAuthenticated,
                          details: {
                            isTokenInvalid: true,
                            tokenExpired: false,
                          },
                        }),
                        req.headers
                      )
                    );
                  }
                } else {
                  res.status(500).json(
                    encryption.encryptResponse(
                      JSON.stringify({
                        status: false,
                        message: ERROR[500].afterQuery,
                      }),
                      req.headers
                    )
                  );
                }
              })
              .catch((err) => {
                console.log("db try catch error", err);
                res.status(500).json(
                  encryption.encryptResponse(
                    JSON.stringify({
                      status: false,
                      message: ERROR.messages.unExpectedError,
                    }),
                    req.headers
                  )
                );
              });
          } else {
            res.status(401).json(
              encryption.encryptResponse(
                JSON.stringify({
                  status: false,
                  message: ERROR.messages.tokenMalformed,
                  details: {
                    tokenExpired: false,
                    isTokenInvalid: true,
                  },
                }),
                req.headers
              )
            );
          }
        } else {
          const userId = decoded.userId;
          console.log("token", token);
          queryExecutor(query.preLogin.findSessionById, [
            userId,
            token,
            "verifyToken",
          ])
            .then((response) => {
              if (response && response?.data[0] && response?.data[0][0]) {
                const userDetails = response?.data[0][0];
                if (userDetails.message === "User not found") {
                  console.log("User Not Found:", err);
                  res.status(401).json(
                    encryption.encryptResponse(
                      JSON.stringify({
                        status: false,
                        message: ERROR[400].tokenNotAuthenticated,
                        details: {
                          isTokenInvalid: true,
                          tokenExpired: false,
                        },
                      }),
                      req.headers
                    )
                  );
                } else {
                  req.body = {
                    ...req.body,
                    tokenDetail: {
                      tokenExpired: false,
                      isTokenInvalid: false,
                      userId: userDetails.userId,
                      userType: userDetails.userType,
                      email: userDetails.email,
                      token: token,
                    },
                  };
                  next();
                }
              } else {
                res.status(500).json(
                  encryption.encryptResponse(
                    JSON.stringify({
                      status: false,
                      message: ERROR[500].afterQuery,
                    }),
                    req.headers
                  )
                );
              }
            })
            .catch((err) => {
              console.log("db try catch error", err);
              res.status(500).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: false,
                    message: ERROR.messages.unExpectedError,
                  }),
                  req.headers
                )
              );
            });
        }
      });
    } else {
      res.status(400).json(
        encryption.encryptResponse(
          JSON.stringify({
            status: false,
            message: ERROR[400].tokenEmpty,
            details: {
              tokenExpired: false,
              isTokenInvalid: true,
            },
          }),
          req.headers
        )
      );
    }
  }
};

const getJwtToken = async (req, res, next) => {
  try {
    const token = req.headers.authorization.split(" ")[1];
    if (!token) {
      throw new AppError(ERROR[400].tokenEmpty, 400);
    } else {
      jwt.verify(token, process.env.JWT_SECRET_KEY, async function (error) {
        if (!error) {
          res.status(400).json(
            encryption.encryptResponse(
              JSON.stringify({
                status: false,
                message: ERROR[400].tokenNotExpired,
                details: {
                  newToken: token,
                },
              }),
              req.headers
            )
          );
        } else {
          if (error.name === "TokenExpiredError") {
            const data = jwt.decode(token);
            console.log(data);
            const result = await queryExecutor(query.preLogin.findSessionById, [
              data.userId,
              token,
              "refreshToken",
            ]);
            if (result && result?.data[0] && result?.data[0][0]) {
              const users = result?.data[0][0];
              if (users.message === "User not found") {
                res.status(400).json(
                  encryption.encryptResponse(
                    JSON.stringify({
                      status: false,
                      message: ERROR[400].tokenNotAuthenticated,
                    }),
                    req.headers
                  )
                );
              } else if (users.token === token) {
                const newToken = jwt.sign(
                  {
                    userId: data.userId,
                    email: users.email,
                    userType: data.userType,
                  },
                  process.env.JWT_SECRET_KEY,
                  { expiresIn: JWT.expiration }
                );

                const expiresOn = jwt.verify(
                  newToken,
                  process.env.JWT_SECRET_KEY,
                  (err, decoded) => {
                    return decoded.exp * 1000;
                  }
                );
                const response = await queryExecutor(
                  query.preLogin.insertUserSession,
                  [users.userId, newToken, users.userType]
                );
                req.data = {
                  newRefreshToken: newToken,
                  tokenExp: expiresOn,
                };
                res.status(200).json(
                  encryption.encryptResponse(
                    JSON.stringify({
                      status: true,
                      details: {
                        newRefreshToken: newToken,
                        tokenExp: expiresOn,
                      },
                    }),
                    req.headers
                  )
                );
              }
            }
          } else {
            res.status(401).json(
              encryption.encryptResponse(
                JSON.stringify({
                  status: false,
                  message: ERROR[400].tokenMalformed,
                }),
                req.headers
              )
            );
          }
        }
      });
    }
  } catch (error) {
    console.log("catching");
    res.status(error.message || 401).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.message || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};

module.exports = {
  auth,
  getJwtToken,
};
