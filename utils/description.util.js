const { queryExecutor, encrypt, AppError } = require("../utils");
const query = require("../repositories/query.json");
const { SUCCESS, ERROR } = require("../constants");
const addDescription = async (req, res) => {
  try {
    const { addDescription } = req.body;
    console.log(addDescription);
    for (const key in addDescription) {
      await queryExecutor(
        "UPDATE static_cards SET cardDescription = ? WHERE cardTitle = ?",
        [addDescription[key], key]
      );
    }
    res.status(200).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: true,
          message: SUCCESS.messages.success
        }),
        req.headers
      )
    );
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
    addDescription
}
