const crypto = require("crypto");
const encryption = require("../utils/encrypt.util");
const ERROR = require("../constants/error.json");
const jwt = require("jsonwebtoken");
const JWT = require("../constants/jwt.json");
const SUCCESS = require("../constants/success.json");
const validator = require("validator");
const query = require("../repositories/query.json");
const queryExecutor = require("../utils/queryExecutor.util");
const moment = require("moment/moment");
const AppError = require("../utils/AppError.util");
const EmailHelper = require("./email.controller");
const { sendNotification } = require("./notification.controller");
const { adminNotificationType } = require("../constants/notificationType");

let developersToVerify = [];
const regx = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})/;

const neighbourSignup = async (req, res) => {
  try {
    let {
      address,
      firstName,
      surName,
      email,
      password,
      latitude,
      longitude,
      country,
      city,
      state,
      zipcode,
    } = req.body;
    latitude = latitude ? latitude : 0;
    longitude = longitude ? longitude : 0;
    if (!address || address === "") {
      throw new AppError(ERROR.messages.addressRequired, 400);
    } else if (!firstName || firstName === "") {
      throw new AppError(ERROR.messages.firstNameRequired, 400);
    } else if (!surName || surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    } else if (!email || email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!password || password === "") {
      throw new AppError(ERROR.messages.passwordEmpty, 400);
    } else if (!validator.isEmail(email)) {
      throw new AppError(ERROR[400].invalidEmailFormat);
      // } else if (!country || country === "") {
      //   throw new AppError(ERROR[400].countryEmpty, 400);
      // } else if (!city || city === "") {
      //   throw new AppError(ERROR[400].cityEmpty, 400);
      // } else if (!state || state === "") {
      //   throw new AppError(ERROR[400].stateEmpty, 400);
    } else if (!regx.test(password)) {
      throw new AppError(ERROR[400].weakPassword, 400);
      // } else if (  !latitude ||
      //   (latitude === "" && !longitude) ||
      //   longitude === ""
      // ) {
      //   throw new AppError(ERROR.messages.locationEmpty, 400);
    } else {
      queryExecutor(query.preLogin.insertNewNeighbours, [
        email,
        encryption.encryptPassword(password),
        firstName,
        surName,
        address,
        latitude,
        longitude,
        country,
        state,
        city,
        zipcode,
      ])
        .then((result) => {
          if (result && result?.data[0] && result?.data[0][0]) {
            const users = result?.data[0][0];
            if (users && users.message === "Success") {
              const token = jwt.sign(
                {
                  userId: users.userId,
                  email: users.email,
                  userType: users.userType,
                },
                process.env.JWT_SECRET_KEY,
                { expiresIn: JWT.expiration }
              );
              const expiresOn = jwt.verify(
                token,
                process.env.JWT_SECRET_KEY,
                (err, decoded) => {
                  return decoded.exp * 1000;
                }
              );
              delete users.password;
              queryExecutor(query.preLogin.insertUserSession, [
                users.userId,
                token,
                users.userType,
              ])
                .then((sessionResult) => {
                  res.status(200).json(
                    encryption.encryptResponse(
                      JSON.stringify({
                        status: true,
                        details: {
                          message: SUCCESS.messages.registrationSuccess,
                          userDetails: users,
                          token: token,
                          tokenExp: expiresOn,
                        },
                      }),
                      req.headers
                    )
                  );
                })
                .catch((err) => {
                  console.log(err);
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
            } else if (users && users.message === "Email already registered") {
              res.status(400).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: false,
                    message: users.message,
                  }),
                  req.headers
                )
              );
            } else if (
              users &&
              users.message === SUCCESS.messages.developerNotBeNeighbour
            ) {
              res.status(400).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: false,
                    message: ERROR.messages.EmailAlreadyExist,
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
                  message: result.data[0][0]?.message,
                }),
                req.headers
              )
            );
          }
        })
        .catch((err) => {
          console.log(err);
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

const resendOTP = async (req, res) => {
  try {
    const { email } = req.body;
    const user = developersToVerify.find((item) => item.user.email === email);
    if (user) {
      if (new Date(user.expireIn).getTime() < new Date().getTime()) {
        throw new AppError(ERROR[401].sessionExpired, 401);
      } else {
        await EmailHelper.sendEmail({
          to: email,
          subject: "Your One-Time Password (OTP) to confirm your account",
          text: `Dear ${user.user.firstName},
  Please use the following OTP within the next 5 minutes to confirm your account: 
  One-Time Password (OTP): ${user.otp}. 
        
  Best regards, 
  Customer Support - YIMBY`,
        });
        res.status(200).json(
          encryption.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.emailSent,
            }),
            req.headers
          )
        );
      }
    } else {
      throw new AppError(ERROR[404].re_developerUserNotFound, 404);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};

const realEstateDevSignUp = async (req, res) => {
  try {
    let {
      firstName,
      surName,
      email,
      password,
      mobile,
      organizationName,
      zipcode,
      country,
      city,
      state,
      address,
      longitude,
      latitude,
    } = req.body;
    if (!firstName || firstName === "") {
      throw new AppError(ERROR.messages.firstNameRequired, 400);
    } else if (!surName || surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    } else if (!email || email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!password || password === "") {
      throw new AppError(ERROR.messages.passwordEmpty, 400);
    } else if (!mobile || mobile === "") {
      throw new AppError(ERROR.messages.phoneRequired, 400);
    } else if (!organizationName || organizationName === "") {
      throw new AppError(ERROR.messages.organisationNameRequired, 400);
    } else if (!validator.isEmail(email)) {
      throw new AppError(ERROR[400].invalidEmailFormat);
    } else if (!regx.test(password)) {
      throw new AppError(ERROR[400].weakPassword, 400);
    } else {
      const existingDev = await queryExecutor(query.postLogin.getReDeveloper, [
        email,
        mobile,
      ]);
      const savedDev = developersToVerify.find(
        (item) => item.email == email || item.user.mobile == mobile
      );
      if (savedDev) {
        if (new Date(savedDev.expireIn).getTime() > new Date().getTime()) {
          throw new AppError(ERROR.messages.alreadyRegistered, 400);
        }
      }
      if (existingDev?.data.length > 0) {
        throw new AppError(ERROR.messages.alreadyRegistered, 400);
      } else {
        const result = await queryExecutor(query.preLogin.getNeighbourByEmail, [
          email,
        ]);
        if (result?.data.length > 0) {
          throw new AppError(ERROR.messages.EmailAlreadyExist, 400);
        }
        developersToVerify = developersToVerify.filter(
          (item) => item.user.email != email
        );
        const otp = crypto.randomInt(100000, 999999);
        let expireIn = moment(Date.now()).add(300, "s").toDate();
        developersToVerify.push({
          otp,
          expireIn,
          user: {
            firstName,
            surName,
            email,
            password,
            mobile,
            organizationName,
            zipcode,
            country,
            state,
            city,
            address,
            longitude,
            latitude,
          },
        });
        await EmailHelper.sendEmail({
          to: email,
          subject: "YIMBY || Your One-Time Password (OTP) to confirm your account",
          text: `Dear ${firstName},
Please use the following OTP within the next 5 minutes to confirm your account: 
One-Time Password (OTP): ${otp}. 
        
Best regards, 
Customer Support - YIMBY`,
        });
        res.status(200).json(
          encryption.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.emailSent,
            }),
            req.headers
          )
        );
      }
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};

const confirmOtp = async (req, res) => {
  try {
    let { email, otp } = req.body;
    if (!email || email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!otp || otp === "") {
      throw new AppError(ERROR.messages.otpEmpty, 400);
    } else {
      const user = developersToVerify.find((item) => item.user.email === email);
      if (user === undefined) {
        throw new AppError(ERROR[404].re_developerUserNotFound, 404);
      } else {
        const {
          firstName,
          surName,
          email,
          password,
          mobile,
          organizationName,
          zipcode,
          country,
          state,
          city,
          address,
          longitude,
          latitude,
        } = user.user;
        console.log(otp, user.otp);
        if (new Date(user.expireIn).getTime() < new Date().getTime()) {
          throw new AppError(ERROR[401].otpExpired, 401);
        } else if (otp == user.otp) {
          developersToVerify = developersToVerify.filter(
            (item) => item.user.email != email
          );
          const result = await queryExecutor(
            query.preLogin.insertNewREDeveloper,
            [
              firstName,
              surName,
              email,
              encryption.encryptPassword(password),
              mobile,
              organizationName,
              zipcode,
              country,
              state,
              city,
              address,
              longitude,
              latitude,
            ]
          );
          if (result && result?.data[0] && result?.data[0][0]) {
            const users = result?.data[0][0];
            if (users && users.message === "Success") {
              const data = {
                firstName: firstName,
                surName: surName,
                email: email,
                mobile: mobile,
                organizationName: organizationName,
                zipcode: zipcode,
                country: country,
                state: state,
                city: city,
                address: address,
                longitude: longitude,
                latitude: latitude,
              };
              await queryExecutor(query.postLogin.addDeveloperRequest, [
                users.userId,
                JSON.stringify(data),
              ]);
              sendNotification({
                fromUserId: users.userId,
                fromUserType: "re_developer",
                activityId: 1,
                activityType: "Developer addition",
                projectId: users.userId,
                title: "YIMBY || New real estate developer Request",
                text: `Dear Admin, 
New real estate developer request has been received. 
Please review and perform the appropriate action. 
                
Best regards, 
Customer Support - YIMBY`,
                admin: true,
                type: adminNotificationType.isNewDeveloperAdded,
              });

              await EmailHelper.sendEmail({
                to: users.email,
                subject: "YIMBY || Registration Request Sent",
                text: `Dear ${firstName}, 
Thank you for registering with us! 
You will receive a welcome email as soon as request is accepted by Admin. 
                
Best regards, 
Customer Support - YIMBY`,
              });

              res.status(200).json(
                encryption.encryptResponse(
                  JSON.stringify({
                    status: true,
                    details: {
                      message: SUCCESS.messages.registrationSuccess,
                      userDetails: users,
                    },
                  }),
                  req.headers
                )
              );
            } else if (users && users.message === "Email already registered") {
              throw new AppError(users.message, 400);
            } else {
              throw new AppError(ERROR[500].afterQuery, 500);
            }
          } else {
            throw new AppError(result.data[0][0]?.message, 500);
          }
        } else {
          throw new AppError(ERROR.messages.invalidCode, 400);
        }
      }
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
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
  neighbourSignup,
  realEstateDevSignUp,
  confirmOtp,
  resendOTP,
};
