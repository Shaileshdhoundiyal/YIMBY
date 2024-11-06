const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");
const { ERROR, JWT, SUCCESS } = require("../constants");
const firebase = require("firebase-admin");
const query = require("../repositories/query.json");
const moment = require("moment/moment");
const { sendNotification } = require("./notification.controller");
const pushnotificationDetails = async (
  fromUserId,
  projectId,
  cardId,
  activityId,
  activityType,
  fromUserType,
  beHeardCommentId,
  subTopicCommentId
) => {
  try {
    let result = await queryExecutor(
      "call insertPushNotification(?, ?, ?, ?, ?, ?, ?, ?)",
      [
        fromUserId,
        projectId,
        cardId,
        activityId,
        activityType,
        fromUserType,
        beHeardCommentId,
        subTopicCommentId,
      ]
    );

    if (result) {
      let isPushNotif = false;
      let pushTokenInfo = [];
      if (result.length) {
        for (let notif of result) {
          if (notif[0] && notif[0].deviceToken) {
            isPushNotif = true;
            notif[0].deviceToken = notif[0].deviceToken;
            pushTokenInfo.push(notif[0]);
          }
        }
      } else {
        isPushNotif = false;
      }
      return {
        pushTokenInfo: pushTokenInfo,
        isPushNotif: isPushNotif,
      };
    } else {
      throw new AppError(ERROR[500].afterQuery, 500);
    }
  } catch (error) {
    throw error;
  }
};

const addBeHeardComments = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { projectId, cardId, comment, commentType, isDefault } = req.body;
        projectId = projectId ? projectId : "";
        cardId = cardId ? cardId : "";
        comment = comment ? (comment.trim() ? comment : "") : "";
        let userId = req.body.tokenDetail.userId;
        if (!projectId || projectId === "" || !cardId || cardId === "") {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else if (!comment || comment === "") {
          throw new AppError(ERROR.messages.commentEmpty, 400);
        } else {
          let result = await queryExecutor(query.postLogin.addbeHeardComment, [
            userId,
            projectId,
            cardId,
            comment,
            commentType,
            isDefault,
          ]);
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              if (result.data[0][0].email && result.data[1]) {
                result.data[1][0].comment = comment;
              }
              let webPushNotificationInfo = await pushnotificationDetails(
                userId,
                projectId,
                cardId,
                result.data[0][0].commentId,
                commentType == "beHeardComment"
                  ? "BE_HEARD_COMMENT"
                  : "TOPIC_COMMENT",
                "neighbour",
                result.data[0][0].commentId,
                null
              );

              let {
                pushTokenInfo: webPushTokenInfo = [],
                isPushNotif: webIsPushNotif = false,
              } = webPushNotificationInfo;

              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.success.commentAdded,
                    details: {
                      result: result.data,
                      webPushTokenInfo: webPushTokenInfo,
                      webIsPushNotif: webIsPushNotif,
                    },
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR.messages.projectNotFound, 404);
            }
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        }
      } else {
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

const addCommentsOnProjectCardSubTopic = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { projectId, cardId, topicId, comment } = req.body;
        if (!projectId || !cardId || !topicId) {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else if (!comment || !comment.trim()) {
          throw new AppError(ERROR.messages.commentEmpty, 400);
        } else {
          let userId = req.body.tokenDetail.userId;
          let result = await queryExecutor(
            query.postLogin.addCommentsOnProjectCardSubTopic,
            [userId, projectId, cardId, topicId, comment]
          );
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              if (result.data[0][0].email && result.data[1]) {
                result.data[1][0].comment = comment;
              }
              let webPushNotificationInfo = await pushnotificationDetails(
                userId,
                projectId,
                cardId,
                result.data[0][0].commentId,
                "SUB_TOPIC_COMMENT",
                "neighbours",
                null,
                result.data[0][0].commentId
              );
              let {
                pushTokenInfo: webPushTokenInfo = [],
                isPushNotif: webIsPushNotif = false,
              } = webPushNotificationInfo;

              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.success.commentAdded,
                    details: {
                      result: result.data,
                      webPushTokenInfo: webPushTokenInfo,
                      webIsPushNotif: webIsPushNotif,
                    },
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR.messages.projectNotFound, 404);
            }
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        }
      } else {
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

const replyToProjectComment = async (req, res) => {
  try {
    if (req.body.tokenDetails.userType === "re_developer") {
      if (req.body) {
        let {
          projectId,
          beHeardCommentId = null,
          subTopicCommentId = null,
          comment,
        } = req.body;
        if (!projectId || projectId === "") {
          throw new AppError(ERROR.messages.projectIdEmpty, 400);
        } else if (!beHeardCommentId && !subTopicCommentId) {
          throw new AppError(ERROR.messages.commentIdEmpty);
        } else if (!comment || comment === "") {
          throw new AppError(ERROR.messages.commentEmpty, 400);
        } else {
          const userDetails = req.body.tokenDetails.details;

          let result = await queryExecutor(
            query.postLogin.replyToProjectComment,
            [
              userDetails.userId,
              userDetails.userType,
              projectId,
              beHeardCommentId,
              subTopicCommentId,
              comment,
            ]
          );
          if (
            result &&
            result.data[0][0] &&
            result.data[0][0].message == "Success"
          ) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.success.commentAdded,
                }),
                req.headers
              )
            );
            if (result.data[0][0].email && result.data[1]) {
              result.data[1][0].comment = comment;
            }

            let pushnotificationInfo = await this.pushnotificationDetails(
              userDetails.userId,
              projectId,
              null,
              result.data[0][0].commentId,
              "REPLY_TO_COMMENT",
              userDetails.userType,
              beHeardCommentId,
              subTopicCommentId
            );
            let { pushTokenInfo, isPushNotif } = pushnotificationInfo;

            const neighbourId = await queryExecutor(
              "select userId from be_heard_comments where commentId = ?",
              [beHeardCommentId]
            );
            sendNotification({
              fromUserId: userDetails.userId,
              fromUserType: userDetails.userType,
              activityId: 1,
              activityType: "Comment reply",
              title: "YIMBY || New reply on comment",
              text: `Dear [Name],
Your have received a new reply on your comment.

Best regards, 
Customer Support - YIMBY`,
              userId: neighbourId.data[0].userId,
              projectId: projectId,
              type: "new reply on comment",
            });

            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.success.commentAdded,
                  details: {
                    result: result.data,
                    pushTokenInfo: pushTokenInfo,
                    isPushNotif: isPushNotif,
                  },
                }),
                req.headers
              )
            );
          } else if (
            result &&
            result.data[0][0] &&
            result.data[0][0].message === "Invalid request"
          ) {
            throw new AppError(ERROR.messages.invalidRequest, 404);
          } else {
            throw new AppError(ERROR.unExpectedError, 500);
          }
        }
      } else {
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
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

const feedBack = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { feedback } = req.body;
        if (!feedback) {
          throw new AppError(ERROR.messages.emptyFeedback, 400);
        }
        let result = await queryExecutor("call feedback(?, ?, ?)", [
          req.body.tokenDetail.userId,
          feedback,
          req.body.tokenDetail.userType,
        ]);
        if (
          result.data[0].length &&
          result.data[0][0].message === "User not found"
        ) {
          throw new AppError(ERROR[404].neighbourUserNotFound, 404);
        } else {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.success.feedBackAddedSuccess,
              }),
              req.headers
            )
          );
        }
      } else {
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

const editDeleteMessage = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let { commentId, comment, isDelete = false } = req.body;
        if (!commentId) {
          throw new AppError(ERROR[400].commentIdMissing, 400);
        } else if (!comment) {
          throw new AppError(ERROR[400].commentMissing, 400);
        }
        let result = await queryExecutor("call editDeleteMessage(?, ?, ?, ?)", [
          req.body.tokenDetail.userId,
          commentId,
          comment,
          isDelete,
        ]);
        if (result.data[0][0].isUpdated) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: result.data[0][0].message,
              }),
              req.headers
            )
          );
        } else if (!result[0][0].isUpdated) {
          throw new AppError(result.data[0][0].message, 400);
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      } else {
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

const showBeHeardComments = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        console.log(req.body);
        let { projectId, Id, isDefault } = req.body;
        projectId = projectId ? projectId : "";
        Id = Id ? Id : "";
        if (!projectId || projectId === "" || !Id || Id === "") {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else {
          let result, resultreply;
          if (isDefault === false) {
            result = await queryExecutor(
              "select *  from be_heard_comments as bhc INNER JOIN neighbours as n ON bhc.userId = n.userId WHERE bhc.cardId = ? and bhc.projectId = ?",
              [Id, projectId]
            );
            resultreply = await queryExecutor(
              "SELECT * FROM commentreplies where beHeardCommentId = ? AND isDeleted = 0 AND isDefault = 0",
              [result?.data[0].commentId]
            );
          } else {
            result = await queryExecutor(
              "select * from static_be_heard_comments as shc INNER JOIN neighbours as n ON shc.userID = n.userId WHERE shc.staticCardId = ? and shc.projectId = ?",
              [Id, projectId]
            );
            resultreply = await queryExecutor(
              "SELECT * FROM commentreplies where beHeardCommentId = ? AND isDeleted = 0 AND isDefault = 1",
              [result?.data[0].commentId]
            );
          }
          console.log(resultreply.data);
          if (result && result.data.length > 0) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  cardComments: result.data,
                  commentReplies: resultreply.data,
                }),
                req.headers
              )
            );
          } else if (result.data.length == 0) {
            throw new AppError(SUCCESS.messages.NoComments, 200);
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        }
      } else {
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

const replyBeHeardComments = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours" || "re_developer") {
      if (req.body) {
        let { projectId, comment, beHeardCommentId, neighbourId, isDefault } =
          req.body;
        projectId = projectId ? projectId : "";
        comment = comment ? (comment.trim() ? comment : "") : "";
        let userId = req.body.tokenDetail.userId;
        let userType = req.body.tokenDetail.userType;
        if (
          !projectId ||
          projectId === "" ||
          !beHeardCommentId ||
          beHeardCommentId === ""
        ) {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else if (!comment || comment === "") {
          throw new AppError(ERROR.messages.commentEmpty, 400);
        } else {
          let result = await queryExecutor(
            "INSERT INTO commentreplies (userId,userType,projectId,comment,beHeardCommentId,neighbourId,isDefault) VALUES (?,?,?,?,?,?,?)",
            [
              userId,
              userType,
              projectId,
              comment,
              beHeardCommentId,
              neighbourId,
              isDefault,
            ]
          );
          const neighbour = await queryExecutor(
            `SELECT * FROM neighbours WHERE userId = ?`,
            [neighbourId]
          );

          const message = {
            notification: {
              title: "YIMBY || New reply on comment",
              body: `Dear ${neighbour?.data[0]?.firstName},
              Your have received a new reply on your comment.
               
              Best regards,
              Customer Support - YIMBY`,
            },
          };
          await queryExecutor(query.postLogin.addPushNotification, [
            userId,
            userType,
            neighbour?.data[0]?.userId,
            "neighbor",
            beHeardCommentId,
            isDefault ? "Comment Reply (Default)" : "Comment Reply",
            JSON.stringify(message),
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            projectId ?? 1,
          ]);

          firebase
            .messaging()
            .sendToDevice(neighbour?.data[0]?.deviceToken, message)
            .then((response) => {
              console.log("Notification sent successfully:", response);
            })
            .catch((error) => {
              console.error("Error sending notification:", error);
            });

          if (result) {
            if (result) {
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.success.commentAdded,
                    details: {
                      result: result.data,
                    },
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR.messages.projectNotFound, 404);
            }
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        }
      } else {
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

const showCommentRplies = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        const Id = req.params.Id;
        Id = Id ? Id : "";
        if (!Id || Id === "") {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else {
          let result = await queryExecutor(
            "SELECT * FROM commentreplies as c INNER JOIN neighbours as n ON c.userId = n.userId WHERE c.beHeardCommentId = ? AND isDeleted = 0",
            [Id]
          );
          if (result && result.data.length > 0) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  cardComments: result.data,
                }),
                req.headers
              )
            );
          } else if (result.data.length == 0) {
            throw new AppError(SUCCESS.messages.NoComments, 200);
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        }
      } else {
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
  pushnotificationDetails,
  addBeHeardComments,
  addCommentsOnProjectCardSubTopic,
  replyToProjectComment,
  feedBack,
  editDeleteMessage,
  showBeHeardComments,
  replyBeHeardComments,
  showCommentRplies,
};
