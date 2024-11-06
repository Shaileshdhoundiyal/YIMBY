const { queryExecutor, encrypt } = require("../utils");
const query = require("../repositories/query.json");
const { SUCCESS, ERROR } = require("../constants");
const reportList = async (req, res) => {
  try {
    let txt = "";
    if (req?.query?.queryRequest?.filter)
      txt = req?.query?.queryRequest?.filter;
    if (req.body.tokenDetail.userType === "admin") {
      const result = await queryExecutor(query.postLogin.projectsForAdmin, [
        txt,
      ]);
      if (result?.data) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.ProjectRejected,
              data: result.data[0]
            }),
            req.headers
          )
        );
      } else if (result?.data?.length == 0) {
        throw new AppError(ERROR.messages.NoRequest, 400);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else if (req.body.tokenDetail.userType === "re_developer") {
      const result = await queryExecutor(query.postLogin.projectsForDeveloper, [
        req.body.tokenDetail.userId,
        txt,
      ]);
      if (result?.data) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.ProjectRejected,
              data: result.data[0]
            }),
            req.headers
          )
        );
      } else if (result?.data?.length == 0) {
        throw new AppError(ERROR.messages.NoRequest, 400);
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
module.exports = { reportList };
