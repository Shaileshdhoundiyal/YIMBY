const { queryExecutor, AppError, encrypt } = require("../utils");
const query = require("../repositories/query.json");
const { SUCCESS, ERROR } = require("../constants");
const { encryptResponse } = require("../utils/encrypt.util");

const getNearByProjectOffline = async (req, res) => {
  try {
    //let { latitude, longitude, limit, startCount } = req.query?.queryRequest;
    let limit, startCount;
    limit = limit ? +limit : null;
    let offset = startCount >= 0 ? startCount : null;
    const response = await queryExecutor('SELECT longitude , latitude FROM neighbours WHERE userId = ?',[req.body?.tokenDetail?.userId]);
    let params = [response?.data[0]?.latitude,response?.data[0]?.longitude, 10000, offset, req.body?.tokenDetail?.userId];
    const result = await queryExecutor(
      query.postLogin.getNearByProjectOffline,
      params
    );
    if (result) {
      for (let project of result?.data[0]) {
        if (project.message === "Success") {
          delete project.message;
          project.cardDetails = project.cardDetails
            ? typeof project.cardDetails == "string"
              ? JSON.parse(project.cardDetails)
              : project.cardDetails
            : [];
          project.staticCardDetails = project.staticCardDetails
            ? typeof project.staticCardDetails == "string"
              ? JSON.parse(project.staticCardDetails)
              : project.staticCardDetails
            : [];
          project.benefit = project.benefit ? project.benefit : [];
          project.projectDetails = project.projectDetails
            ? project.projectDetails
            : {};
          project.organizationDetails = project.organizationDetails
            ? project.organizationDetails
            : {};
          project.totalCards = project.cardDetails
            ? project.cardDetails.length + project.staticCardDetails.length
            : 0;
          project.static_cardsReviewedCount = project.static_cardsReviewedCount
            ? project.static_cardsReviewedCount
            : 0;
          project.cardsRemaining =
            project.totalCards -
            (project.cardsReviewedCount + project.static_cardsReviewedCount);
        }
      }
      const data = result?.data[0].filter((element)=>  element.distance == null || element.distance <= 20)
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.nearByProjectFetched,
            nearByProject: data,
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

const getMyProject = async function (req, res) {
  try {
    let txt = "";
    if (req?.query?.queryRequest?.filter)
      txt = req?.query?.queryRequest?.filter;

    // let result = await queryExecutor(query.postLogin.getMyProject, [
    //   req.body.tokenDetail.userId,
    // ]);
    let result;
    if (req.body.tokenDetail.userType === "admin") {
      result = await queryExecutor(query.postLogin.getAllProjectForAdmin, [
        req.body.tokenDetail.userId,
        txt.toString(),
      ]);
    } else {
      result = await queryExecutor(query.postLogin.getMyProjectNew, [
        req.body.tokenDetail.userId,
        txt.toString(),
      ]);
    }
    if (
      result &&
      result.data[0] &&
      result.data[0][0] &&
      result.data[0][0].message === "User not found"
    ) {
      throw new AppError(ERROR[404].invalidUser, 404);
    } else if (
      result &&
      result?.data[0] &&
      result?.data[0].length == 0 &&
      result?.data[1].length == 0
    ) {
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.noProjects,
          }),
          req.headers
        )
      );
    } else if (result && (result.data[0] || result.data[1])) {
      let array = [];
      result.data?.length > 0 &&
        result.data[0]?.forEach((element) => {
          array.push(element);
        });
      array.sort((a,b)=> b.modifiedAt - a.modifiedAt);
      // result.data[1]?.length > 0 &&
      //   result.data[1]?.forEach((element) => {
      //     array.push(element.changedData);
      //   });
      // result.data[0].map((e, i) => {
      //   result.data[0][i].phase = result.data[0][i]?.phase
      //     ? result.data[0][i]?.phase
      //     : null;
      //   result.data[0][i].currentPhase = result.data[0][i]?.currentPhase
      //     ? result.data[0][i]?.currentPhase
      //     : null;
      // });
      result?.data[1].sort((a, b) => b.requestTime - a.requestTime);
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            length: array.length,
            message: SUCCESS.messages.projectListFetched,
            projectList: array ? array : [],
            projectReview: result.data[1]?.length > 0 && result.data[1],
          }),
          req.headers
        )
      );
    } else {
      throw new AppError(ERROR.messages.unExpectedError, 400);
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

const getProjectByProjectIdForREDeveloper = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let { projectId } = req.body;
        if (!projectId || projectId === "") {
          throw new AppError(ERROR.messages.projectIdEmpty, 400);
        } else {
          let result = await queryExecutor(
            query.postLogin.getProjectByProjectIdForREDeveloper,
            [projectId, req.body.tokenDetail.userId]
          );
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              const projectDetails = result.data[0][0];
              projectDetails.benefit = projectDetails.benefit
                ? projectDetails.benefit
                : [];

              for (const [key, value] of Object.entries(projectDetails)) {
                if (value === "null" || value === "0" || value === "") {
                  if (
                    key === "buidlingHeight" ||
                    key === "floorPlan" ||
                    key === "propertySize" ||
                    key === "residentialUnits" ||
                    key === "maximumCapacity" ||
                    key === "thisProjectNumberLikes"
                  ) {
                    projectDetails[key] = 0;
                  } else {
                    projectDetails[key] = null;
                  }
                }
              }

              let projectImages = projectDetails.images
                ? projectDetails.images
                : [];
              let cardDetails = projectDetails.projectCardsDetails
                ? projectDetails.projectCardsDetails
                : [];
              let newOrganisation = projectDetails.organisation
                ? projectDetails.organisation
                : [];
              let newPartnerOrganisations =
                projectDetails.newPartnerOrganisations
                  ? projectDetails.newPartnerOrganisations
                  : [];
              delete projectDetails.images;
              delete projectDetails.projectCardsDetails;
              delete projectDetails.organisation;
              delete projectDetails.newPartnerOrganisations;
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.projectListFetched,
                    details: {
                      projectDetails,
                      projectImages,
                      cardDetails,
                      newOrganisation,
                      newPartnerOrganisations,
                    },
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR.messages.projectNotFound, 404);
            }
          } else {
            console.log("result", result);
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

const getNearByProject = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body && req.body.status) {
        let { latitude, longitude, limit, startCount } = req.body;
        if (latitude && longitude) {
          let params, querry;
          limit = limit ? +limit : null;
          offset = startCount ? +startCount : null;
          params = [latitude, longitude, limit, offset];
          if (limit && startCount) {
            limit = +limit;
            startCount = +startCount;
            querry = query.postLogin.getNearByProjectWithLimit;
            params = [latitude, longitude, latitude, 5, limit, startCount];
          } else {
            querry = query.postLogin.getNearByProjectWithoutLimit;
            params = [latitude, longitude, latitude, 5];
          }
          let result = await queryExecutor(querry, params);
          if (result && result.data.length > 0) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.projectListFetched,
                  nearByProject: result.data,
                }),
                req.headers
              )
            );
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        } else {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        }
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

const getProjectByProjectIdForNeighbours = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        // let projectId = event.queryStringParameters ? event.queryStringParameters.projectId ? event.queryStringParameters.projectId : '' : '';
        let { projectId } = req.body;
        if (!projectId || projectId === "") {
          throw new AppError(ERROR.messages.projectIdEmpty, 400);
        } else {
          let result = await queryExecutor(
            query.postLogin.getProjectByProjectIdForNeighbours,
            [req.body.tokenDetail.userId, projectId]
          );
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              const project = result[0][0];
              // delete details.message;
              // details.benefit = details.benefit ? (details.benefit) : [];
              // if(details.projectDetails) {
              //     details.projectDetails = details.projectDetails ? (details.projectDetails) : {};
              //     details.projectDetails.projectImages = details.projectDetails.projectImages ? (details.projectDetails.projectImages) : [];
              // }

              delete project.message;
              project.cardDetails = project.cardDetails
                ? project.cardDetails
                : [];
              project.benefit = project.benefit ? project.benefit : [];
              project.projectDetails = project.projectDetails
                ? project.projectDetails
                : {};
              project.organizationDetails = project.organizationDetails
                ? project.organizationDetails
                : {};
              project.totalCards = project.cardDetails
                ? project.cardDetails.length
                : 0;
              project.cardsRemaining =
                project.totalCards - project.cardsReviewedCount;

              // details.benefitLikedUserIds = details.benefitLikedUserIds ? (details.benefitLikedUserIds) : [];
              // details.organizationDetails = details.organizationDetails ? (details.organizationDetails) : {};
              // details.cardDetails = details.cardDetails ? (details.cardDetails) : [];
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.projectListFetched,
                    details: project,
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
      }
    } else {
      throw new AppError(ERROR[400].contentNotAvailable, 400);
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

const getPreDefinedProjectCards = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor(query.postLogin.getPreDefinedCards);
      if (result) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.PreDefinedCardsFetched,
              details: result,
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR.messages.invalidRequest, 404);
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

const getProjectVotingResultByProjectId = async (req, res) => {
  try {
    if (tokenDetail.details.userType === "neighbours") {
      if (req.body) {
        let { projectId } = req.body;
        if (!projectId || projectId === "") {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        } else {
          let result = await queryExecutor(
            query.postLogin.getProjectVotingResult,
            [tokenDetail.details.userId, projectId]
          );
          if (
            result &&
            result.data[0] &&
            result.data[0][0] &&
            result.data[0][0].message
          ) {
            if (result.data[0][0].message === "Success") {
              delete result.data[0][0].message;
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.projectListFetched,
                    projecstVotingResult: result[0][0].votingResult
                      ? result[0][0].votingResult
                      : {},
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
  getNearByProjectOffline,
  getMyProject,
  getProjectByProjectIdForREDeveloper,
  getNearByProject,
  getProjectByProjectIdForNeighbours,
  getPreDefinedProjectCards,
  getProjectVotingResultByProjectId,
};

