const { ERROR, SUCCESS } = require("../constants");
const { queryBuilder, queryExecutor, AppError } = require("../utils");
const { encryptResponse } = require("../utils/encrypt.util");

const addNeighboursQuestionAnswers = async (req, res) => {
  try {
    let { userId } = req.body?.tokenDetail;
    let questionAnswer = req.body?.answer;
    if (questionAnswer?.length < 3) {
      console.log({
        status: false,
        message: ERROR[500].serverError,
      });
      res.status(500).json(
        encryptResponse(
          JSON.stringify({
            status: false,
            message: ERROR[500].serverError,
          }),
          req.headers
        )
      );
    }
    let surveyStrings = [];
    if (questionAnswer.length) {
      surveyStrings = queryBuilder.addSurveyAnswersQueryBuilder(
        questionAnswer,
        userId
      );
    }
    surveyStrings = JSON.stringify(surveyStrings);
    const result = await queryExecutor(`call addSurveyQuestionsAnswers(?, ?)`, [
      surveyStrings,
      userId,
    ]);
    if (result?.data[0][0].message === "previously_answered") {
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            message: ERROR.messages.userAlreadyAnswered,
          }),
          req.headers
        )
      );
    } else if (result?.data[0][0].message === "failed") {
      res.status(400).json(
        encryptResponse(
          JSON.stringify({
            status: false,
            message: ERROR.messages.failedToAddAnswers,
          }),
          req.headers
        )
      );
    } else if (result?.data[0][0].message === "added") {
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.answersAdded,
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

module.exports = {
  addNeighboursQuestionAnswers,
};
