const {
  encrypt,
  AppError,
  EmailHelper,
  queryBuilder,
  queryExecutor,
} = require("../utils");
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json } = require("express");

const referToFriend = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      const user = await queryExecutor(
        "SELECT firstName,surName from neighbours WHERE userId = ?",
        req.body.tokenDetail.userId
      );
      const userName = user?.data[0].firstName + " " + user?.data[0].surName;
      if (req.body) {
        let { emails } = req.body;

        let result = await queryExecutor(query.postLogin.referToFriend, [
          req.body.tokenDetail.userId,
          req.body.tokenDetail.userType,
          JSON.stringify(emails),
        ]);
        if (result) {
          for (let i = 0 ; i < emails.length ; i++ ) {
            await EmailHelper.sendEmail({
              to: emails[i],
              subject: "Recomendation for YIMBY",
              text: `Dear neighbour,
Our application is recomendated to you by ${userName}
Download the app and be heard in neighbourhood from the below link
Best regards, 
Customer Support - YIMBY`,
            });
          }
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.success,
                emails: emails,
              }),
              req.headers
            )
          );
        }
      } else {
        //reject({ statusCode: 400, message: config.settings.errors[400].contentNotAvailable });
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
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
const volunteerForProject = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { projectId, isVolunteer } = req.body;
        let result = await queryExecutor("call volunteerForProject(?, ?, ?)", [
          req.body.tokenDetail.userId,
          projectId,
          isVolunteer,
        ]);
        console.log(result?.data);

        if (result?.data[0][0].isUpdated) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: result?.data[0][0].message,
              }),
              req.headers
            )
          );
        }
      } else {
        //reject({ statusCode: 400, message: config.settings.errors[400].contentNotAvailable });
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
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
  referToFriend,
  volunteerForProject,
};
