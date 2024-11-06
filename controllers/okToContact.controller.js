const { encrypt, AppError, queryExecutor } = require("../utils");
const { ERROR, JWT, SUCCESS } = require("../constants");

const okToContact = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let { projectId, isOk } = req.body;
        let result = await queryExecutor("call okToContact(?, ?, ?)", [
          req.body.tokenDetail.userId,
          projectId,
          isOk,
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
  okToContact,
};
