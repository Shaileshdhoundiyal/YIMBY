const encryption = require("../utils/encrypt.util");
const ERROR = require("../constants/error.json");
const jwt = require("jsonwebtoken");
const JWT = require("../constants/jwt.json");
const SUCCESS = require("../constants/success.json");
const validator = require("validator");
const query = require("../repositories/query.json");
const queryExecutor = require("../utils/queryExecutor.util");
const { json } = require("express");
const AppError = require('../utils/AppError.util')


const updatePushToken = async (req, res) => {
    try {
        let { deviceId, deviceToken, fcmToken, deviceType } = req.body;
        if (deviceType && deviceToken && deviceId && fcmToken) {
            let result = await queryExecutor(query.postLogin.updatePushTokenDetails, [req.body.tokenDetail.userId, deviceId, deviceToken, fcmToken, deviceType]);
            res.status(200).json(
                encryption.encryptResponse(
                    JSON.stringify({
                        status: true,
                        details: {
                            message: SUCCESS.messages.pushDetailsUpdated,
                            result: result
                        }

                    }),
                    req.headers
                )
            );

        }
        else {
            throw new AppError(ERROR.messages.emptyFields, 400);
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

}

module.exports = {
    updatePushToken
}