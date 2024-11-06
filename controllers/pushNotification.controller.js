const { queryExecutor, AppError, encrypt } = require("../utils");
const query = require("../repositories/query.json");
const { SUCCESS, ERROR } = require("../constants");
const { encryptResponse } = require("../utils/encrypt.util");

const addDeviceToken = async (req, res) => {
  try {
    let { deviceToken, deviceType, deviceId, endpointArn, senderId } = req.body;
    let result = await queryExecutor(
      "call addDeviceToken(?, ?, ?, ?, ?, ?, ?)",
      [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        deviceToken,
        deviceType,
        endpointArn,
        deviceId,
        senderId,
      ]
    );

    if (result.data[0][0].isAdded == 1) {
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.deviceTokenAdded,
          }),
          req.headers
        )
      );
    } else {
      throw new AppError(result.data[0][0].message, 400);
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
  addDeviceToken,
};
