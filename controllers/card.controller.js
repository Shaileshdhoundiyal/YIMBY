const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");
const EmailHelper = require("./email.controller");
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const s3Helper = require("../utils/s3.controller.js");

const createCard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      const { cardTitle, cardIcon, cardDescription, isRequired } = req.body;
      const { userId } = req.body.tokenDetail;
      if (!cardTitle || cardTitle?.trim() == "") {
        throw new AppError(ERROR.messages.cardTitleMissing, 400);
      } else if (!cardDescription || cardDescription?.trim() === "") {
        throw new AppError(ERROR.messages.CardDescriptionMissing, 400);
      } else if (!cardIcon || cardIcon == "") {
        throw new AppError(ERROR.messages.CardIconMissing, 400);
      } else {
        const imageLink = await s3Helper.uploadDocumentsToS3(
          cardIcon,
          req.body.tokenDetail.userId + Date.now()
        );
        const result = await queryExecutor(query.postLogin.insertCard, [
          cardTitle,
          imageLink,
          cardDescription,
          isRequired,
          userId,
        ]);
        console.log(result?.data);
        if (
          result &&
          result.data[0] &&
          result.data[0][0] &&
          result.data[0][0].message === "Success"
        ) {
          delete result.data[0][0].message;
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.cardDetailsFetched,
                details: {
                  cardDetails: result.data[0][0],
                },
              }),
              req.headers
            )
          );
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
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

const getAllCards = async (req, res) => {
  try {
    if (
      req.body.tokenDetail.userType === "re_developer" ||
      req.body.tokenDetail.userType === "admin"
    ) {
      let txt = "";
      if (req?.query?.queryRequest?.filter)
        txt = req?.query?.queryRequest?.filter;
      // const result = await queryExecutor(query.postLogin.getAllCards, [
      //   req.body.tokenDetail.userId,
      // ]);
      const result = await queryExecutor(query.postLogin.getAllCardsNew, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        txt.toString(),
      ]);
      if (result && result.data.length > 0) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.cardDetailsFetched,
              details: {
                cardDetails: result.data[0],
              },
            }),
            req.headers
          )
        );
      } else if (result.data.length == 0) {
        throw new AppError(SUCCESS.messages.NoCards, 200);
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

const getProjectCards = async (req, res) => {
  try {
    const projectId = req.params.id;
    const result = await queryExecutor(query.postLogin.getProjectCards, [
      projectId,
    ]);
    const default_cards = await queryExecutor(
      "SELECT * FROM static_cards WHERE staticCardId IN (select staticCardId from project_static_cards where projectId= ?)",
      [projectId]
    );
    const data = [];
    result.data.map((card) => data.push(card));
    default_cards.data.map((card) => data.push(card));
    data.sort((a, b) => b.modifiedOn - a.modifiedOn);
    if (data && data.length > 0) {
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.cardDetailsFetched,
            details: {
              cardDetails: data,
            },
          }),
          req.headers
        )
      );
    } else if (data.length == 0) {
      throw new AppError(SUCCESS.messages.NoCards, 200);
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

const getCard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      console.log(req.query.queryRequest);
      // const cardId = req.params;
      const { cardId } = req.query.queryRequest;
      const result = await queryExecutor(query.postLogin.getCard, [cardId]);
      console.log(result);
      if (result && result.data.length > 0) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.cardDetailsFetched,
              details: {
                cardDetails: result.data,
              },
            }),
            req.headers
          )
        );
      } else if (result.data.length == 0) {
        throw new AppError(SUCCESS.messages.NoCards, 200);
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

const DeleteProjectCard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      const cardId = req.params.id;
      const projectCard = await queryExecutor(
        "SELECT * FROM project_cards WHERE cardId = ?",
        [cardId]
      );
      if (projectCard?.data?.length === 0) {
        const result = await queryExecutor(query.postLogin.deleteCard, [
          cardId,
          req.body.tokenDetail.userId,
        ]);
        if (
          result &&
          result.data[0] &&
          result.data[0][0] &&
          result.data[0][0].message === "Success"
        ) {
          delete result.data[0].message;
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.CardDeleted,
              }),
              req.headers
            )
          );
        } else if ((result.data[0][0].message = "card not exists")) {
          throw new AppError(SUCCESS.messages.NoCards, 404);
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      }else{
        throw new AppError(ERROR.messages.CardIsInProject,500);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType,500);
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

const DeleteAllProjectsCards = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      const projectId = req.params.id;
      const result = await queryExecutor(
        query.postLogin.deleteAllCardsForProject,
        [projectId]
      );
      if (
        result &&
        result.data[0] &&
        result.data[0][0] &&
        result.data[0][0].message === "Success"
      ) {
        delete result.data[0].message;
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.CardDeleted,
            }),
            req.headers
          )
        );
      } else if ((result.data[0][0].message = "Project not exist")) {
        throw new AppError(SUCCESS.messages.projectNotFound, 200);
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

const updateCard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let { cardId, cardIcon, cardDescription, isRequired, cardTitle } =
        req.body;
      if (!cardId || cardId == " ") {
        throw new AppError(ERROR.messages.CardIdMissing, 400);
      } else if (!cardIcon || cardIcon === "") {
        throw new AppError(ERROR.messages.CardIconMissing, 400);
      } else if (!cardDescription || cardDescription?.trim() === "") {
        throw new AppError(ERROR.messages.CardDescriptionMissing, 400);
      } else if (isRequired === "") {
        throw new AppError(ERROR.messages.isRequiredMissing, 400);
      } else if (!cardTitle || cardTitle?.trim() === "") {
        throw new AppError(ERROR.messages.cardTitleMissing, 400);
      }
      if (!cardIcon.includes("https:")) {
        cardIcon = await s3Helper.uploadDocumentsToS3(
          cardIcon,
          req.body.tokenDetail.userId + Date.now()
        );
      }
      const result = await queryExecutor(query.postLogin.updateCard, [
        cardId,
        cardTitle,
        cardIcon,
        cardDescription,
        isRequired,
        req.body.tokenDetail.userId,
      ]);
      if (
        result &&
        result.data[0] &&
        result.data[0][0] &&
        result.data[0][0].message === "Success"
      ) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.CardUpdated,
            }),
            req.headers
          )
        );
      } else if (result.data[0][0].message === "card does not exist") {
        throw new AppError(ERROR.messages.CardNotExist, 400);
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

const getAllDefaultCardList = async (req, res) => {
  try {
    if (
      req.body.tokenDetail.userType === "re_developer" ||
      req.body.tokenDetail.userType === "admin"
    ) {
      const result = await queryExecutor("select * from static_cards");
      if (result && result.data.length > 0) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              cardDetails: result.data,
            }),
            req.headers
          )
        );
      } else if (result.data.length == 0) {
        throw new AppError(SUCCESS.messages.NoCards, 200);
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
  createCard,
  getAllCards,
  getProjectCards,
  getCard,
  DeleteProjectCard,
  DeleteAllProjectsCards,
  updateCard,
  getAllDefaultCardList,
};
