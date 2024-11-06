const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json } = require("express");
const EmailHelper = require('./email.controller')

const addLikesOnProjectCardSubTopic = async function (req, res) {
    try {
        if (req.body.tokenDetail.userType === 'neighbours') {
            if (req.body) {
                let {
                    projectId,
                    cardId,
                    topicId
                } = req.body;
                if (!projectId || !cardId || !topicId) {
                    throw new AppError(ERROR[400].contentNotAvailable, 400);
                } else {
                    let result = await queryExecutor(
                        query.postLogin.addLikesOnProjectCardSubTopic,
                        [
                            req.body.tokenDetail.userId,
                            projectId,
                            cardId,
                            topicId
                        ]
                    );
                    if (result && result.data[0] && result.data[0][0] && result.data[0][0].message) {
                        if (result.data[0][0].message === 'Liked') {
                            res.status(200).json(
                                encrypt.encryptResponse(
                                    JSON.stringify({
                                        status: true,
                                        message: SUCCESS.messages.likedSuccessfully,
                                    }),
                                    req.headers
                                )
                            )
                        } else if (result.data[0][0].message === 'unLiked') {
                            res.status(200).json(
                                encrypt.encryptResponse(
                                    JSON.stringify({
                                        status: true,
                                        message: SUCCESS.messages.unLikedSuccessfully,
                                    }),
                                    req.headers
                                )
                            )
                        }
                        else {
                            throw new AppError(ERROR.messages.projectNotFound, 404);
                        }
                    } else {
                        throw new AppError(ERROR[500].afterQuery, 500);
                    }
                }
            }
            else {
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
        )
    }
}

module.exports = {
    addLikesOnProjectCardSubTopic
}