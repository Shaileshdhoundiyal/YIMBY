const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");

const { ERROR, SUCCESS } = require("../constants");
const query = require("../repositories/query.json");

const updateMyPassword = async (req, res) => {
  try {
    let { currentPassword, newPassword, confirmPassword } = req.body;
    currentPassword = currentPassword
      ? currentPassword.trim()
        ? currentPassword.trim()
        : ""
      : "";
    newPassword = newPassword
      ? newPassword.trim()
        ? newPassword.trim()
        : ""
      : "";
    confirmPassword = confirmPassword
      ? confirmPassword.trim()
        ? confirmPassword.trim()
        : ""
      : "";
    if (!currentPassword || currentPassword === "") {
      throw new AppError(ERROR.messages.currentPasswordEmpty, 400);
    } else if (!newPassword || !confirmPassword) {
      throw new AppError(ERROR.messages.passwordEmpty, 400);
    } else if (newPassword !== confirmPassword) {
      throw new AppError(ERROR[400].incorrectConfirmPassword, 400);
    } else if (newPassword.length < 8 || newPassword.length > 20) {
      throw new AppError(ERROR.messages.passwordLength, 400);
    } else if (newPassword === currentPassword) {
      throw new AppError(ERROR[400].PreviousPassword, 400);
    } else {
      let result = await queryExecutor(query.postLogin.getMyPassword, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
      ]);
      if (result && result?.data[0] && result?.data[0][0]) {
        const users = result?.data[0][0];
        if (users.message === "Success") {
          const originalPassword = encrypt.decryptPassword(users.password);
          if (currentPassword === originalPassword) {
            const response = await queryExecutor(
              query.postLogin.updatePassword,
              [
                req.body.tokenDetail.userId,
                req.body.tokenDetail.userType,
                encrypt.encryptPassword(newPassword),
              ]
            );
            console.log(response);
            if (
              response &&
              response?.data[0] &&
              response?.data[0][0] &&
              response?.data[0][0].message === "Success"
            ) {
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    details: {
                      message: SUCCESS.messages.passwordUpdated,
                    },
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR[500].afterQuery, 500);
            }
          } else {
            throw new AppError(ERROR[400].incorrectPassword, 400);
          }
        } else if (users.message === "User not found") {
          throw new AppError("user not found", 404);
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    }
  } catch (error) {
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

const getNotificationList = async (req, res) => {
  try {
    if (req) {
      let { userId, userType } = req.body.tokenDetail;
      let result = await queryExecutor(
        "SELECT * FROM pushnotifications WHERE toUserId = ? AND toUserType=? ORDER BY modifiedOn DESC",
        [userId, userType === "neighbours" ? "neighbor" : userType]
      );
      let notification = result?.data;
      let comments = [];
      let replies = [];
      if (userType === "neighbours") {
        let i, j, k;
        for (i = 0; i < notification.length; i++) {
          if (notification[i]?.activityType === "Comment Reply (Default)") {
            let response = await queryExecutor(
              "SELECT * FROM static_be_heard_comments where commentId = ?",
              [notification[i].activityId]
            );
            response.data?.length > 0 &&
              response?.data.forEach((element) => {
                comments.push({ ...element, isDefault: true });
              });

            let response2 = await queryExecutor(
              "SELECT * FROM commentreplies where beHeardCommentId = ? AND isDefault = 1",
              [notification[i].activityId]
            );
            response2.data?.length > 0 &&
              response2?.data.forEach((element) => {
                replies.push({ ...element });
              });
          } else if (notification[i]?.activityType === "Comment Reply") {
            let response = await queryExecutor(
              "SELECT * FROM be_heard_comments where commentId = ?",
              [notification[i].activityId]
            );
            response.data?.length > 0 &&
              response?.data.forEach((element) => {
                comments.push({ ...element, isDefault: false });
              });

            let response2 = await queryExecutor(
              "SELECT * FROM commentreplies where beHeardCommentId = ? AND isDefault = 0",
              [notification[i].activityId]
            );
            response2.data?.length > 0 &&
              response2?.data.forEach((element) => {
                replies.push({ ...element });
              });
          }
        }
      }
      if (result && result.data) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              details: {
                message: "Success",
                data:
                  userType === "neighbours"
                    ? { notification: result?.data, comments, replies }
                    : result?.data,
              },
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else {
      throw new AppError(ERROR[400].contentNotAvailable, 400);
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

const getUserNotificationSettings = async (req, res) => {
  try {
    const result = await queryExecutor(
      query.postLogin.getUserNotificationSettings,
      [req.body.tokenDetail.userId, req.body.tokenDetail.userType]
    );
    if (
      result &&
      result.data[0] &&
      result.data[0][0] &&
      result.data[0][0].message === "Success"
    ) {
      delete result.data[0][0].message;
      console.log(JSON.stringify(result.data[0][0]));
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.userNotificationsFetched,
            details: {
              userNotification: result.data[0][0],
            },
          }),
          req.headers
        )
      );
    } else {
      throw new AppError(ERROR[500].afterQuery, 500);
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

const getMyActivities = async (req, res) => {
  try {
    if (req.body) {
      // eslint-disable-next-line eqeqeq
      const isNotificationOpened =
        req.body.isNotificationOpened !== undefined &&
        Boolean(req.body.isNotificationOpened) === true
          ? 1
          : 0; //If notification screen is opened make isNew as false
      let result = await queryExecutor(query.postLogin.getMyActivities, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        isNotificationOpened,
      ]);
      if (req.body.tokenDetail.userType === "neighbours") {
        if (result && result.data[1]) {
          for (let data of result.data[1]) {
            data.userDetails = data.userDetails ? data.userDetails : [];
            data.projectDetails = data.projectDetails
              ? data.projectDetails
              : [];
          }
        }
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.activityFetched,
              details: {
                pendingInvitationList: result
                  ? result[1]
                    ? result[1]
                    : []
                  : [],
                totalNewCount: result
                  ? result[0]
                    ? result[0][0].newNotificationCount
                    : 0
                  : 0,
              },
            }),
            req.headers
          )
        );
      } else {
        if (result && result[1]) {
          for (let data of result[1]) {
            data.userDetails = data.userDetails ? data.userDetails : [];
            data.projectDetails = data.projectDetails
              ? data.projectDetails
              : [];
          }
        }
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.activityFetched,
              details: {
                pendingInvitationList: result
                  ? result[1]
                    ? result[1]
                    : []
                  : [],
                totalNewCount: result
                  ? result[0]
                    ? result[0][0].newNotificationCount
                    : 0
                  : 0,
              },
            }),
            req.headers
          )
        );
      }
    } else {
      throw new AppError(ERROR[400].contentNotAvailable, 400);
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

const getPreviousRequest = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      const result = await queryExecutor(
        "SELECT r.*, dev.firstName, dev.surName FROM requests as r INNER JOIN re_developer as dev ON r.userId=dev.userId WHERE r.status != 'pending'"
      );
      if (result?.data.length > 0) {
        result?.data.sort((a,b)=> b.requestTime - a.requestTime);
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              requests: result?.data,
            }),
            req.headers
          )
        );
      } else if (result?.data.length == 0) {
        throw new AppError(ERROR.messages.NoRequest, 500);
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
  updateMyPassword,
  getNotificationList,
  getUserNotificationSettings,
  getMyActivities,
  getPreviousRequest,
};
