const firebase = require("firebase-admin");
const { queryExecutor, AppError, encrypt } = require("../utils");
const { ERROR, SUCCESS } = require("../constants");
const moment = require("moment/moment");
const query = require("../repositories/query.json");
const { sendEmail } = require("./email.controller");

const sendNotification = async ({
  fromUserId,
  fromUserType,
  activityId,
  latitude,
  longitude,
  activityType,
  projectId,
  title,
  text,
  userId,
  admin,
  neighbor,
  type,
}) => {
  try {
    const message = {
      notification: {
        title,
        body: text,
      },
    };

    if (admin) {
      const result = await queryExecutor(
        `SELECT * FROM admins` // WHERE ${type} = 1
      );
      const admins = result?.data;
      admins?.forEach(async (item) => {
        if (item?.isEmailNotification) {
          await sendEmail({
            to: item?.email,
            subject: title,
            text: text.replace("[Name]", item?.firstName),
          });
        }
        message.notification.body = text.replace("[Name]", item?.firstName);
        await sendPushNotificationAndSave(
          item?.deviceToken,
          message,
          item?.userId,
          "admin",
          fromUserId,
          fromUserType,
          activityId,
          activityType,
          projectId
        );
      });
    } else if (neighbor) {
      const result = await queryExecutor(
        `SELECT * FROM neighbours  `, //WHERE userId = ? AND ${type} = 1 AND (3959 * ACOS(COS(RADIANS(?)) * COS(RADIANS(latitude)) *  COS(RADIANS(longitude) - RADIANS(?)) + SIN(RADIANS()) * SIN(RADIANS(latitude)))) < 10
        [userId, latitude, longitude, latitude]
      );
      const neighbors = result?.data;
      neighbors?.forEach(async (item) => {
        message.notification.body = text.replace("[Name]", item?.firstName);
        await sendPushNotificationAndSave(
          item?.deviceToken,
          message,
          item?.userId,
          "neighbor",
          fromUserId,
          fromUserType,
          activityId,
          activityType,
          projectId
        );
      });
    } else {
      const result = await queryExecutor(
        `SELECT * FROM re_developer WHERE userId = ? `, //AND ${type} = 1
        [userId]
      );
      if (result.data[0]?.isEmailNotification) {
        await sendEmail({
          to: result.data[0]?.email,
          subject: title,
          text: text.replace("[Name]", result.data[0]?.firstName),
        });
      }
      message.notification.body = text.replace(
        "[Name]",
        result?.data[0]?.firstName
      );
      await sendPushNotificationAndSave(
        result?.data[0]?.deviceToken,
        message,
        result?.data[0]?.userId,
        "re_developer",
        fromUserId,
        fromUserType,
        activityId,
        activityType,
        projectId
      );
    }
  } catch (er) {
    console.log("Send notification error::", er);
    return null;
  }
};

const sendPushNotificationAndSave = async (
  token,
  message,
  userId,
  userType,
  fromUserId,
  fromUserType,
  activityId,
  activityType,
  projectId
) => {
  try {
    let result = await queryExecutor(query.postLogin.addPushNotification, [
      fromUserId,
      fromUserType,
      userId,
      userType,
      activityId,
      activityType,
      JSON.stringify(message),
      moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
      moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
      projectId ?? 1,
    ]);
    firebase
      .messaging()
      .sendToDevice(token, message)
      .then((response) => {
        console.log("Notification sent successfully:", response);
      })
      .catch((error) => {
        console.error("Error sending notification:", error);
      });
  } catch (er) {
    console.log(er);
  }
};

const setIsViewed = async (req, res) => {
  try {
    let { Id, viewAll } = req.body;
    if (
      req.body.tokenDetail.userType === "re_developer" ||
      req.body.tokenDetail.userType === "admin"
    ) {
      let result;
      if (viewAll === true) {
        result = await queryExecutor(
          "UPDATE pushnotifications SET isViewed = true WHERE toUserId = ?",
          [req.body.tokenDetail.userId]
        );
      } else {
        result = await queryExecutor(
          "UPDATE pushnotifications SET isViewed = true WHERE id = ?",
          [Id],
          [req.body.tokenDetail.userId]
        );
      }
      console.log(result.data);
      if (result?.data?.affectedRows > 0) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
            }),
            req.headers
          )
        );
      } else if (result?.data?.affectedRows == 0) {
        throw new AppError(ERROR.messages.notificationNotFound, 404);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
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
  sendNotification,
  setIsViewed,
};
