const validator = require("validator");
const encryption = require("../utils/encrypt.util");
const jwt = require("jsonwebtoken");
const { JWT, SUCCESS, ERROR } = require("../constants");
const query = require("../repositories/query.json");
const { AppError, queryExecutor } = require("../utils");

const login = (req, res) => {
  try {
    let { email, password, userType } = req.body;
    if (!email || !email.trim()) {
      throw new AppError(ERROR[400].emailRequired, 400);
    } else if (!validator.isEmail(email.trim())) {
      throw new AppError(ERROR[400].invalidEmailFormat, 400);
    } else if (!password || !password.trim()) {
      throw new AppError(ERROR.messages.passwordEmpty);
    } else {
      email = email.toLowerCase().trim();
      queryExecutor(query.preLogin.userLogin, [email, userType])
        .then(async (result) => {
          if (
            result &&
            result?.data[0] &&
            result?.data[0][0] &&
            result?.data[0][0].message === "Success"
          ) {
            const userDetails = result?.data[0][0];
            let lastLogged = userDetails.lastLoggedAt;
            let now = new Date();
            let diff =
              (now?.getTime() - lastLogged?.getTime()) / (1000 * 60 * 60 * 24);
            delete userDetails.lastLoggedAt;
            if (userDetails.isActive === 0 && diff >= 15) {
              res.status(500).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: false,
                    message: SUCCESS.messages.userIdNotFound,
                  }),
                  req.headers
                )
              );
              return;
            } else if (userDetails.isActive === 0) {
              queryExecutor(query.preLogin.ActivateREDeveloperAccount, [
                userDetails.userId,
              ]);
              userDetails.isActive = 1;
              queryExecutor(query.preLogin.activeAccount, [
                userDetails.userId,
                email
              ]);
            }
            let orginalPassword = encryption.decryptPassword(
              userDetails.password
            );
            if (password === orginalPassword) {
              if (userDetails.isActive === 1) {
                const token = jwt.sign(
                  {
                    userId: userDetails.userId,
                    email: userDetails.email,
                    userType: userDetails.userType,
                  },
                  process.env.JWT_SECRET_KEY,
                  {
                    expiresIn: JWT.expiration,
                  }
                );
                delete userDetails.password;
                delete userDetails.userExistsToken;
                delete userDetails.message;

                const expiresOn = jwt.verify(
                  token,
                  process.env.JWT_SECRET_KEY,
                  (err, decoded) => {
                    return decoded.exp * 1000;
                  }
                );

                queryExecutor(query.preLogin.insertUserSession, [
                  userDetails.userId,
                  token,
                  userDetails.userType,
                ])
                  .then((result) => {
                    if (result) {
                      userDetails["token"] = token;
                      userDetails.tokenExp = expiresOn;
                      userDetails.tempToken
                        ? res.json(
                            encryption.encryptResponse(
                              JSON.stringify({
                                status: true,
                                tempToken: userDetails.tempToken,
                                message: userDetails.message,
                              }),
                              req.headers
                            )
                          )
                        : res.json(
                            encryption.encryptResponse(
                              JSON.stringify({
                                status: true,
                                result: userDetails,
                                message: SUCCESS.messages.loginSuccess,
                              }),
                              req.headers
                            )
                          );
                    } else {
                      console.log("insertUserSession SPS Error", err);
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
                    console.log("db try catch error ", err);
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
                res.status(400).json(
                  encryption.encryptResponse(
                    JSON.stringify({
                      status: false,
                      message: SUCCESS.messages.accountDeactivated,
                    }),
                    req.headers
                  )
                );
              }
            } else {
              res.status(400).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: false,
                    message: SUCCESS.messages.passwordIncorrect,
                  }),
                  req.headers
                )
              );
            }
          } else if (
            result &&
            result?.data[0] &&
            result?.data[0][0] &&
            result?.data[0][0].message === "status is pending"
          ) {
            res.status(400).json(
              encryption.encryptResponse(
                JSON.stringify({
                  status: false,
                  message: SUCCESS.messages.statusPending,
                }),
                req.headers
              )
            );
          } else if (
            result &&
            result?.data[0] &&
            result?.data[0][0] &&
            result?.data[0][0].message === "status is rejected"
          ) {
            res.status(400).json(
              encryption.encryptResponse(
                JSON.stringify({
                  status: false,
                  message: SUCCESS.messages.statusRejected,
                }),
                req.headers
              )
            );
          } else {
            res.status(400).json(
              encryption.encryptResponse(
                JSON.stringify({
                  status: false,
                  message: SUCCESS.messages.userIdNotFound,
                }),
                req.headers
              )
            );
          }
        })
        .catch((err) => {
          console.log("Database Error: userLogin SPS: ", err);
          res.status(500).json(
            encryption.encryptResponse(
              JSON.stringify({
                status: false,
                message: ERROR[500].afterQuery,
              }),
              req.headers
            )
          );
        });
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

const logout = (req, res) => {
  try {
    console.log("Inside try");
    const queryRequest = req?.query?.queryRequest;
    const deviceId = queryRequest?.deviceId;
    const userType = queryRequest?.userType;
    if (!deviceId || deviceId === "") {
      throw new AppError(ERROR[400].contentNotAvailable);
    } else {
      let { userId, token } = req.body?.tokenDetail;
      queryExecutor(query.postLogin.logoutUser, [
        token,
        userId,
        deviceId ? deviceId : null,
        userType,
      ])
        .then((result) => {
          console.log(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.successfullyLoggedOut,
            })
          );
          res.status(200).json(
            encryption.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.successfullyLoggedOut,
              }),
              req.headers
            )
          );
        })
        .catch((err) => {
          console.log(
            JSON.stringify({
              status: false,
              message: err,
            })
          );
          res.status(500).json(
            encryption.encryptResponse(
              JSON.stringify({
                status: false,
                message: ERROR[500].afterQuery,
              }),
              req.headers
            )
          );
        });
    }
  } catch (error) {
    console.log("Inside CATCH");
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

const saveEmail = async (req, res) => {
  try {
    let email = req.body.email;
    if (email) {
      let { result } = await queryExecutor(
        "insert into saveemails (emails) values (?)",
        [email]
      );
      if (result.data && result.data.affectedRows === 1) {
        res.status(200).json(
          encryption.encryptResponse(
            JSON.stringify({
              status: true,
              message: "success",
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else {
      throw new AppError(ERROR.messages.emailRequired, 400);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};

module.exports = {
  login,
  logout,
  saveEmail,
};
