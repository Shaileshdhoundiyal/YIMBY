const { encrypt, queryExecutor, AppError } = require("../utils");
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json } = require("express");

const editNeighboursNotificationSettings = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      if (req.body) {
        let {
          isNewProjectsYourArea,
          isUpdatesProjectYourArea,
          isCommentApprovals,
          isResponsesYourComments,
          isReceiveEmails,
          // isCommentApprovalByEmail,
          isResponsesYourCommentsByEmail,
          // isNewDevelopments,
          isFeatureUpdates,
          isAboutYimby,
          isAccountSecurity,
          isThemesMode,
        } = req.body;
        const mode = ["follow the system", "light mode", "dark mode"];
        isNewProjectsYourArea = isNewProjectsYourArea ? true : false;
        isUpdatesProjectYourArea = isUpdatesProjectYourArea ? true : false;
        isCommentApprovals = isCommentApprovals ? true : false;
        isResponsesYourComments = isResponsesYourComments ? true : false;
        isReceiveEmails = isReceiveEmails ? true : false;
        // isCommentApprovalByEmail = isCommentApprovalByEmail ? true : false;
        isResponsesYourCommentsByEmail = isResponsesYourCommentsByEmail
          ? true
          : false;
        // isNewDevelopments = isNewDevelopments ? true : false;
        isFeatureUpdates = isFeatureUpdates ? true : false;
        isAboutYimby = isAboutYimby ? true : false;
        isAccountSecurity = isAccountSecurity ? true : false;
        isThemesMode = isThemesMode
          ? isThemesMode.trim()
            ? isThemesMode.toLowerCase().trim()
            : ""
          : "";
        if (isThemesMode && isThemesMode !== "") {
          if (mode.includes(isThemesMode)) {
            let querry, params;
            if (isReceiveEmails) {
              querry = query.postLogin.editNeighboursNotificationSettings1;
              params = [
                isNewProjectsYourArea,
                isUpdatesProjectYourArea,
                isCommentApprovals,
                isResponsesYourComments,
                isReceiveEmails,
                /* isCommentApprovalByEmail,*/
                isResponsesYourCommentsByEmail,
                /* isNewDevelopments,*/
                isFeatureUpdates,
                isAboutYimby,
                isAccountSecurity,
                isThemesMode,
                req.body.tokenDetail.userId,
              ];
              const result = await queryExecutor(querry, params);
              if (result.data && result.data.affectedRows === 1) {
                res.status(200).json(
                  encrypt.encryptResponse(
                    JSON.stringify({
                      status: true,
                      details: {
                        message: SUCCESS.messages.notificationUpdated,
                      },
                    }),
                    req.headers
                  )
                );
              } else {
                throw new AppError(ERROR[500].afterQuery, 500);
              }
            } else {
              query = query.postLogin.editNeighboursNotificationSettings2;
              params = [
                isNewProjectsYourArea,
                isUpdatesProjectYourArea,
                isCommentApprovals,
                isResponsesYourComments,
                isReceiveEmails,
                isThemesMode,
                tokenDetail.details.userId,
              ];
              let result = await queryExecutor(querry, params);
              if (result && result.affectedRows === 1) {
                res.status(200).json(
                  encrypt.encryptResponse(
                    JSON.stringify({
                      status: true,
                      details: {
                        message: SUCCESS.messages.notificationUpdated,
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
            throw new AppError(ERROR.messages.InvalidMode);
          }
        } else {
          throw new AppError(ERROR.messages.darkModeEmpty, 400);
        }
      } else {
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      }
    } else {
      throw new AppError(ERROR[400].tokenNotAuthenticated, 400);
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

const editREDeveloperNotificationSettings = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let {
          isNewResponsesByProject,
          isProjectStatusChangeByTeam,
          isYimbyUpdates,
          isReceiveEmails,
          isNewFeedbackByProject,
          isProjectCompletion,
          isFeatureUpdates,
          isNewsAboutYimby,
          isAccountOrSecurityIssues,
        } = req.body;
        const summariesOption = ["daily", "fortnightly", "monthly", "weekly"];
        isNewResponsesByProject = isNewResponsesByProject ? true : false;
        isProjectStatusChangeByTeam = isProjectStatusChangeByTeam
          ? true
          : false;
        isYimbyUpdates = isYimbyUpdates ? true : false;
        isReceiveEmails = isReceiveEmails ? true : false;
        isNewFeedbackByProject = isNewFeedbackByProject ? true : false;
        isAccountOrSecurityIssues = isAccountOrSecurityIssues ? true : false;
        isProjectCompletion = isProjectCompletion ? true : false;
        isFeatureUpdates = isFeatureUpdates ? true : false;
        isNewsAboutYimby = isNewsAboutYimby ? true : false;

        let querry, params;
        querry = query.postLogin.editREDeveloperNotificationSettings1;

        params = [
          isNewResponsesByProject,
          isYimbyUpdates,
          isReceiveEmails,
          isNewFeedbackByProject,
          isProjectStatusChangeByTeam,
          isFeatureUpdates,
          isNewsAboutYimby,
          isAccountOrSecurityIssues,
          isProjectCompletion,
          req.body.tokenDetail.userId,
        ];
        const result = await queryExecutor(querry, params);
        if (result.data && result.data.affectedRows === 1) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                details: {
                  message: SUCCESS.messages.notificationUpdated,
                },
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
      throw new AppError(ERROR[400].tokenNotAuthenticated, 400);
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

const editREDeveloperProfile = async function (req, res) {
  try {
    let { firstName, surName, email, phoneNumber, profilePhoto, organisation } =
      req.body;
    firstName = firstName ? (firstName.trim() ? firstName.trim() : "") : "";
    surName = surName ? (surName.trim() ? surName.trim() : "") : "";
    email = email ? (email.trim() ? email.toLowerCase().trim() : "") : "";
    profilePhoto = profilePhoto ? profilePhoto.trim() : null;
    phoneNumber = phoneNumber ? phoneNumber.trim() : null;
    if (!firstName && firstName === "") {
      throw new AppError(ERROR.messages.invalidFirstName, 400);
    } else if (!surName && surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    } else if (!email && email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!validator.isEmail(email.trim())) {
      throw new AppError(ERROR.messages.invalidEmail, 400);
    } else {
      let result = await queryExecutor(query.postLogin.editREDeveloperProfile, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        firstName,
        surName,
        email,
        phoneNumber,
        profilePhoto ? profilePhoto : null,
        organisation ? organisation : null,
      ]);
      if (result && result.data[0] && result.data[0][0]) {
        let userDetails = result.data[0][0];
        if (userDetails.message === "Email exist") {
          throw new AppError(SUCCESS.messages.mailAlreadyExist, 400);
        } else if (userDetails.message === "User not found") {
          throw new AppError(SUCCESS.messages.userIdNotFound, 400);
        } else if (userDetails.message === "Success") {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                details: {
                  message: SUCCESS.messages.userDetailsUpdated,
                },
              }),
              req.headers
            )
          );
        }
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
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

const adminDashboard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let result = await queryExecutor(query.postLogin.adminDashboard);
      if (!result.data) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              totalCount: result.data[0]?.length,
              projectGraph: result.data[0],
              devGraph: result.data[1],
              requestGraph: result.data[5],
              totolUser: result.data[2],
              activeUser: result.data[3],
              pendingUser: result.data[4],
            }),
            req.headers
          )
        );
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
const developerDashboard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor(query.postLogin.developerDashboard, [
        req.body.tokenDetail.userId,
      ]);
      if (!result.data) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              projectGraph: result.data[0],
              requestGraph: result.data[4],
              totolProject: result.data[1],
              activeProject: result.data[2],
              pendingProject: result.data[3],
            }),
            req.headers
          )
        );
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
const dashBoard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType == "admin") {
      // const developer = await queryExecutor(
      //   "SELECT COUNT(*) AS developer FROM re_developer WHERE isActive = 1 AND isDeleted = 0 AND isApproved = 'approved'"
      // );
      const neighbour = await queryExecutor(
        "SELECT COUNT(*) AS neighbour FROM neighbours WHERE isActive = 1"
      );
      const activeUsers = await queryExecutor(
        "SELECT COUNT(*) AS active_users FROM re_developer WHERE isActive=1 AND isDeleted = 0 AND isApproved = 'approved'"
      );
      const pendingUsers = await queryExecutor(
        "SELECT COUNT(*) AS pending_users  FROM re_developer WHERE isApproved = 'pending'"
      );
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            total:
              activeUsers?.data[0].active_users +
              neighbour?.data[0].neighbour +
              pendingUsers?.data[0].pending_users,
            active:
              activeUsers?.data[0].active_users + neighbour?.data[0].neighbour,
            pending: pendingUsers?.data[0].pending_users,
          }),
          req.headers
        )
      );
    } else if (req.body.tokenDetail.userType == "re_developer") {
      const active_project = await queryExecutor(
        "SELECT COUNT(*) AS active_project FROM project WHERE userId = ? AND isDeleted = 0 AND projectStatus = 'active'",
        [req.body.tokenDetail.userId]
      );
      const pending_project = await queryExecutor(
        "SELECT COUNT(*) AS pending_project  FROM requests WHERE userId = ? AND requestType = 'New Project' AND status = 'pending'",
        [req.body.tokenDetail.userId]
      );
      const inReviewProject = await queryExecutor(
        "SELECT COUNT(*) AS review_project FROM project WHERE userId = ? AND isDeleted = 0 AND projectStatus = 'draft'",
        [req.body.tokenDetail.userId]
      );
      const total_projects =
        active_project?.data[0].active_project +
        pending_project?.data[0].pending_project +
        inReviewProject?.data[0].review_project;
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            total: total_projects,
            active: active_project?.data[0].active_project,
            pending:
              pending_project?.data[0].pending_project +
              inReviewProject?.data[0].review_project,
            InReview: inReviewProject?.data[0].review_project,
          }),
          req.headers
        )
      );
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

const projectsForDashboard = async (req, res) => {
  try {
    let duration = req?.query?.queryRequest?.duration;
    duration = duration ? duration : "All Time";
    const result = await queryExecutor(query.postLogin.projectsForDashboard, [
      req.body.tokenDetail.userId,
      req.body.tokenDetail.userType,
      duration,
    ]);
    res.status(200).json(
      encrypt.encryptResponse(
        JSON.stringify({
          projects: result.data[0],
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

const usersForDashboard = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let duration = req?.query?.queryRequest?.duration;
      duration = duration ? duration : "All Time";
      const result = await queryExecutor(query.postLogin.usersForDashboard, [
        duration,
      ]);
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            users: result.data[0],
          }),
          req.headers
        )
      );
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

const requestForDashboard = async (req, res) => {
  try {
    let duration = req?.query?.queryRequest?.duration;
    duration = duration ? duration : "All Time";
    const result = await queryExecutor(query.postLogin.requestForDsahboard, [
      req.body.tokenDetail.userId,
      req.body.tokenDetail.userType,
      duration,
    ]);
    res.status(200).json(
      encrypt.encryptResponse(
        JSON.stringify({
          request: result.data[0],
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
  editNeighboursNotificationSettings,
  editREDeveloperNotificationSettings,
  editREDeveloperProfile,
  adminDashboard,
  developerDashboard,
  usersForDashboard,
  projectsForDashboard,
  dashBoard,
  requestForDashboard,
};
