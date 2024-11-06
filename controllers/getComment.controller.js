const {
  encrypt,
  AppError,
  queryBuilder,
  queryExecutor,
} = require("../utils");
const EmailHelper = require('./email.controller')
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json } = require("express");

const getCommentsBySubTopicId = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let { projectId, topicId, limit, startCount } = req.body;
        if (!projectId || !topicId) {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else {
          if (+limit && startCount) {
            limit = +limit;
            startCount = +startCount;
          } else {
            limit = 10;
            startCount = 0;
          }
          let result = await queryExecutor(
            query.postLogin.getCommentsBySubTopicId,
            [req.body.tokenDetail.userId, projectId, topicId, limit, startCount]
          );
          console.log(result);
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              const commentDetails = result.data[0].map((e, i) => {
                delete result.data[0][i].message;
                return result.data[0][i];
              });
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.commentsFetched,
                    commentDetails: commentDetails,
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR.messages.invalidRequest, 404);
            }
          } else {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.commentsFetched,
                  commentDetails: [],
                }),
                req.headers
              )
            );
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

const YourCommentByProjectIdreview = async (req, res) => {
  try {
    if (req.body) {
      let { projectId, limit, startCount } = req.body;
      projectId = projectId ? projectId : "";
      if (!projectId || projectId === "") {
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      } else {
        let result = await queryExecutor(
          query.postLogin.reviewYourCommentByProjectId,
          [
            req.body.tokenDetail.userId,
            projectId,
            startCount ? +startCount : 0,
            limit ? +limit : 15,
          ]
        );
        if (result) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.commentsFetched,
                commentDetails: result[0],
              }),
              req.headers
            )
          );
        } else {
          throw new AppError(ERROR.messages.invalidProject, 404);
        }
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

const getMessagesList = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let { projectId = null, neighbourId = null } = req.body;
        console.log("-----------------------", projectId, neighbourId);
        let result = await queryExecutor("call getMessagesList(?, ?, ?)", [
          req.body.tokenDetail.userId,
          projectId,
          neighbourId,
        ]);
        if (result) {
          if (neighbourId == null) {
            console.log(result);
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.MessagesListFetched,
                  data: result.data[0],
                }),
                req.headers
              )
            );
          } else {
            result = result.flat(2);
            result.pop();
            result = result.sort((a, b) => a.createdOn - b.createdOn);
            // result.forEach(elem => elem.re_developer ? elem.re_developer = (elem.re_developer): null);
            console.log(result);
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.MessagesListFetched,
                  data: result.data[0],
                }),
                req.headers
              )
            );
          }
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

const commentsInNotif = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { projectId, replyId } = req.body;
        console.log(projectId, replyId);
        if (!projectId || !replyId) {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        }
        let result = await queryExecutor(query.postLogin.commentsInNotif, [
          req.body.tokenDetail.userId,
          projectId,
          replyId,
        ]);
        console.log(result);
        // await executeQueryWithAsyncAwaitDestructure('call commentsInNotif(?, ?, ?)', [tokenDetail.details.userId, projectId, replyId]);
        if (result) {
          result = result.flat(2);
          result.pop();
          result = result.sort((a, b) => a.createdOn - b.createdOn);
          result.forEach((elem) =>
            elem.re_developer ? (elem.re_developer = elem.re_developer) : null
          );
          console.log(result);
          // resolve({statusCode: 200, data: result});
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: result.message,
                commentDetails: result,
              }),
              req.headers
            )
          );
        } else {
          console.log("data not found in db");
        }
      } else {
        console.log("not found in db");
        // reject({ statusCode: 400, message: config.settings.errors[400].contentNotAvailable });
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
  getCommentsBySubTopicId,
  commentsInNotif,
  YourCommentByProjectIdreview,
  getMessagesList,
};
