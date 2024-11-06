const validator = require("validator");
const { encrypt, queryExecutor, AppError } = require("../utils");
const jwt = require("jsonwebtoken");
const { JWT, SUCCESS, ERROR } = require("../constants");
const query = require("../repositories/query.json");
const crypto = require("crypto");
const EmailHelper = require("./email.controller");

const forgotPasswordStep1 = async (req, res) => {
  try {
    let { email, userType } = req.body;
    let name = await queryExecutor(
      `select firstName from ${
        userType === "neighbour" ? "neighbours" : userType
      } WHERE email = ?`,
      [email]
    );
    console.log(name.data);
    name = name?.data[0]?.firstName;
    if (!email || email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
      //reject({ statusCode: 400, message: config.settings.errors.messages.emailRequired });
    } else if (!validator.isEmail(email)) {
      throw new AppError(ERROR[400].invalidEmailFormat);
      //reject({ statusCode: 400, message: config.settings.errors[400].invalidEmailFormat });
    } else if (!userType || userType === "") {
      throw new AppError(ERROR.messages.emptyFields, 400);
      //reject({ statusCode: 400, message: config.settings.errors.messages.emailRequired });
    }
    const otp = crypto.randomInt(100000, 999999);
    const result = await queryExecutor(query.preLogin.forgotPasswordStep1, [
      email,
      userType,
      otp,
    ]);
    if (
      result &&
      result?.data[0] &&
      result?.data[0][0] &&
      result?.data[0][0].message === "Success"
    ) {
      const userDetails = result?.data[0][0];
      const tempToken = jwt.sign(
        {
          userId: userDetails.userId,
          userType: userDetails.userType,
          email,
        },
        process.env.JWT_TEMP_SECRET_KEY,
        {
          expiresIn: JWT.tempTokenExpiration,
        }
      );
      //userDetails.tempToken = tempToken;
      //userDetails.otp = otp;
      const response = await queryExecutor(
        query.preLogin.insertUserTemporarySession,
        [userDetails.userId, tempToken, userDetails.userType]
      );
      if (response && response.affectedRows === 1) {
        userDetails.body = userDetails.body.replace("{{userEmail}}", email);
        userDetails.body = userDetails.body.replace(
          "{{userName}}",
          userDetails.userName
        );
        userDetails.body = userDetails.body.replace(
          "{{currentYear}}",
          new Date().getFullYear()
        );
        userDetails.body = userDetails.body.replace(
          "{{otp}}",
          userDetails.userType === "neighbours"
            ? otp
            : process.env.DOMAIN_NAME + "REdev/forgotpassword"
        );
        userDetails.body = userDetails.body.replace("{{tokens}}", tempToken);
      }
      await EmailHelper.sendEmail({
        to: email,
        subject: "Your One-Time Password (OTP) for Password Reset ",
        text: `Dear ${name},
You've requested to reset your password for your YIMBY account. Please use the following OTP within the next 5 minutes to reset your password: 
One-Time Password (OTP): ${otp}
        
Best regards, 
Customer Support - YIMBY`,
      });
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.forgotPasswordLink,
            otp: otp,
            email: email,
            tempToken: tempToken,
            result: userDetails,
          }),
          req.headers
        )
      );
    } else {
      console.log(result?.data[0][0]);
      throw new AppError(ERROR.messages.invalidEmail, 400);
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

const forgotPasswordStep2 = async (req, res) => {
  try {
    let { otp, token, password, confirmPassword } = req.body;
    if (token) {
      if (!otp) {
        throw new AppError(ERROR[400].invalidData, 400);
      }
      if (password === null) {
        throw new AppError(ERROR.messages.passwordEmpty, 400);
        throw new AppError(ERROR.messages.passwordEmpty, 400);
      }
      if (password != confirmPassword) {
        throw new AppError(ERROR[400].incorrectConfirmPassword, 400);
      }
      const decode = jwt.verify(token, process.env.JWT_TEMP_SECRET_KEY);
      let { userId, userType } = decode;
      let response;
      if (userType == "re_developer") {
        response = await queryExecutor(query.preLogin.getDeveloperByUserId, [
          userId,
        ]);
      } else {
        response = await queryExecutor(query.preLogin.getNeighbourByUserId, [
          userId,
        ]);
      }
      const users = response.data[0];
      if (users.otp != otp) {
        throw new AppError(ERROR[401].incorrectOTP, 401);
      }
      if (password === encrypt.decryptPassword(users.password)) {
        throw new AppError(ERROR[400].PreviousPassword, 400);
      }
      const result = await queryExecutor(query.preLogin.forgotPasswordStep2, [
        userId,
        token,
        userType,
        encrypt.encryptPassword(password),
        otp,
      ]);
      const user = result?.data[0][0];
      if (user && user.message === "Success") {
        console.log({
          status: true,
          message: SUCCESS.messages.OTPverified,
        });
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.passwordUpdated,
            }),
            req.headers
          )
        );
      } else if (user.message === "otp expired") {
        throw new AppError(ERROR[401].otpExpired, 400);
      } else if (user.message === "Incorrect OTP") {
        throw new AppError(ERROR[401].incorrectOTP, 401);
      }
    } else {
      throw new AppError(ERROR.messages.tokenMalformed, 400);
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
  forgotPasswordStep1,
  forgotPasswordStep2,
};
