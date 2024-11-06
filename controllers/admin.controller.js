const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");
const EmailHelper = require("./email.controller");
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json, response } = require("express");
const { create_new_project, updateProject } = require("./project.controller");
const { sendNotification } = require("./notification.controller");
const {
  neighbourNotificationType,
  developerNotificationType,
} = require("../constants/notificationType");

const adminSignup = async (req, res) => {
  try {
    let { firstName, surName, email, password } = req.body;
    firstName = firstName ? (firstName.trim() ? firstName.trim() : "") : "";
    surName = surName ? (surName.trim() ? surName.trim() : "") : "";
    email = email ? (email.trim() ? email.toLowerCase().trim() : "") : "";
    password = password ? (password.trim() ? password.trim() : "") : "";
    if (!firstName || firstName === "") {
      throw new AppError(ERROR.messages.firstNameRequired, 400);
    } else if (!surName || surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    } else if (!email || email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!password || password === "") {
      throw new AppError(ERROR.messages.passwordEmpty, 400);
    } else if (!validator.isEmail(email)) {
      throw new AppError(ERROR.messages.invalidEmailFormat);
    } else if (password.length < 8 || password.length > 20) {
      throw new AppError(ERROR.messages.passwordLength, 400);
    } else {
      const result = await queryExecutor(query.preLogin.insertNewAdmin, [
        email,
        encrypt.encryptPassword(password),
        firstName,
        surName,
      ]);
      if (result && result?.data[0] && result?.data[0][0]) {
        const users = result?.data[0][0];
        if (users && users.message === "Success") {
          const token = jwt.sign(
            {
              userId: users.userId,
              email: users.email,
              userType: users.userType,
            },
            process.env.JWT_SECRET_KEY,
            { expiresIn: JWT.expiration }
          );
          const expiresOn = jwt.verify(
            token,
            process.env.JWT_SECRET_KEY,
            (err, decoded) => {
              return decoded.exp * 1000;
            }
          );
          delete users.password;
          await queryExecutor(query.preLogin.insertUserSession, [
            users.userId,
            token,
            users.userType,
          ]);
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                details: {
                  message: SUCCESS.messages.registrationSuccess,
                  userDetails: users,
                  token: token,
                  tokenExp: expiresOn,
                },
              }),
              req.headers
            )
          );
        } else if (users && users.message === "Email already registered") {
          throw new AppError(users.message, 400);
        }
      } else {
        throw new AppError(result.data[0][0]?.message, 500);
      }
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

const addReUser = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let { firstName, surName, email, password } = req.body;
      firstName = firstName ? (firstName.trim() ? firstName.trim() : "") : "";
      surName = surName ? (surName.trim() ? surName.trim() : "") : "";
      email = email ? (email.trim() ? email.toLowerCase().trim() : "") : "";
      password = password ? (password.trim() ? password.trim() : "") : "";
      if (!firstName || firstName === "") {
        throw new AppError(ERROR.messages.firstNameRequired, 400);
      } else if (!surName || surName === "") {
        throw new AppError(ERROR.messages.surNameRequired, 400);
      } else if (!email || email === "") {
        throw new AppError(ERROR.messages.emailRequired, 400);
      } else if (!password || password === "") {
        throw new AppError(ERROR.messages.passwordEmpty, 400);
      } else if (!validator.isEmail(email)) {
        throw new AppError(ERROR.messages.invalidEmailFormat);
      } else if (password.length < 8 || password.length > 20) {
        throw new AppError(ERROR.messages.passwordLength, 400);
      } else {
        const result = await queryExecutor(
          query.preLogin.insertNewREDeveloper,
          [firstName, surName, email, encrypt.encryptPassword(password)]
        );
        if (result && result?.data[0] && result?.data[0][0]) {
          const users = result?.data[0][0];

          delete users.password;
          await EmailHelper.sendEmail({
            to: users.email,
            subject: "Invite mail",
            text: "you can add your project for review here",
          });
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.success,
                details: {
                  users,
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
      throw new AppError(ERROR[400].invalidUserType);
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

const editReUser = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let {
        firstName,
        userId,
        surName,
        email,
        phoneNumber,
        profilePhoto,
        password,
        deleteUser,
      } = req.body;
      firstName = firstName || delete req.body.firstName;
      surName = surName || delete req.body.surName;
      phoneNumber = phoneNumber || delete req.body.phoneNumber;
      (profilePhoto = profilePhoto || delete req.body.phoneNumber),
        (password =
          encrypt.encryptPassword(password) || delete req.body.password);
      deleteUser = deleteUser || false;
      if (!userId) throw new AppError("userId missing", 400);

      if (deleteUser) {
        if (!email || !userId) throw new AppError(ERROR[400].invalidData);
        const result = await queryExecutor(`call deleteAccount(?, ?, ?)`, [
          userId,
          "admin",
          email,
        ]);

        if (result && result?.data && result.data.afectedRows === 1) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                details: {
                  message: SUCCESS.messages.success,
                },
              }),
              req.headers
            )
          );
        } else {
          throw new AppError(ERROR.messages.dataNotFound, 500);
        }
      } else if (email != null) {
        if (!validator.isEmail(email)) {
          throw new AppError(ERROR[400].invalidEmailFormat, 400);
        }
        delete req.body.tokenDetail;
        let editReDevQuery = queryBuilder.adminEditReDevQueryBuilder(
          req.body,
          userId
        );

        const result = await queryExecutor(query.postLogin.editReUser, [
          editReDevQuery,
          userId,
          "re_developer",
          email,
        ]);
        if (result && result?.data && result.data.afectedRows === 1) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                details: {
                  message: SUCCESS.messages.success,
                },
              }),
              req.headers
            )
          );
        } else {
          throw new AppError(ERROR.messages.dataNotFound, 500);
        }
      } else {
        throw new AppError(ERROR.messages.emailRequired, 400);
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

const getReUser = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let { limit = 10, offset = 0, userSearch = null, userId } = req.body;
      if (!userId) {
        throw new AppError(ERROR[400].contentNotAvailable);
      }
      const result = await queryExecutor(query.postLogin.getReUsers, [
        limit,
        offset,
        userSearch,
        JSON.parse(userId),
      ]);

      if (result.data && result.data[1][0].totalCount == 0) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details: {
                totalCount: result.data[1][0].totalCount,
                data: result.data[0],
              },
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

const requestListing = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let txt = "";

      if (req.query?.queryRequest?.filter) {
        txt = req.query.queryRequest.filter;
      }
      // const result = await queryExecutor(
      //   "SELECT r.*,re.firstName,re.surName FROM requests as r INNER JOIN re_developer as re ON r.userId = re.userId",
      //   []
      // );
      const result = await queryExecutor(query.postLogin.getRequests, [
        txt.toString(),
      ]);
      let data = [];
      data = result?.data[0];

      // let response = [];
      // result.data[0].map((Element) => {
      //   if (Element.creationTime < Element.createdAt) {
      //     Element.requestType = "Updated Project";
      //   }
      //   response.push(Element);
      // });
      // result.data[1].map((Element) => response.push(Element));
      data = data.sort((a, b) => b.requestTime - a.requestTime);
      if (data?.length > 0) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details: {
                totalCount: data.length,
                data: data,
              },
            }),
            req.headers
          )
        );
      } else if (data.length == 0) {
        throw new AppError(SUCCESS.messages.NoRequests,200);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
    console.error(error);
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
const getRequestDetail = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let requestType = req.query.type;
      let id = req.query.id;

      const result = await queryExecutor(query.postLogin.getRequestDetail, [
        id,
        requestType,
      ]);

      if (result && result?.data[0] && result?.data[0][0]) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details: {
                totalCount: result.data.length,
                data: result.data[0],
              },
            }),
            req.headers
          )
        );
      } else if (
        result?.data[0]?.length === 0 &&
        result?.data[1]?.length === 0
      ) {
        throw new AppError(SUCCESS.messages.NoRequests, 400);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
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

const approveRequest = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      const { requestId, requestType } = req.body;
      const response = await queryExecutor(
        "SELECT * FROM requests WHERE requestId = ?",
        [requestId]
      );
      if (requestType === "New Project") {
        if (response?.data.length > 0) {
          const result = await create_new_project(
            response?.data[0]?.changedData,
            req.body.tokenDetail
          );

          console.log(JSON.stringify(response));
          if (result.status) {
            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              activityType: "Project Request",
              title: "YIMBY || Project Request Approved",
              text: `Dear [Name],
Your New Project ${response?.data[0]?.changedData?.projectDetails?.projectName} Request is successfully Approved.  
              
Best regards, 
Customer Support - YIMBY`,
              userId: response?.data[0]?.userId,
              projectId: result?.projectId,
              type: developerNotificationType.isProjectUpdated,
            });

            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              latitude: response?.data[0]?.changedData.projectDetails.latitude,
              longitude: response?.data[0]?.changedData.projectDetails.latitude,
              activityType: "Project Status",
              title: "YIMBY",
              text: "New Project Added",
              neighbor: true,
              type: neighbourNotificationType.isNewDevelopments,
              projectId: result?.projectId,
            });

            const approvedRequest = await queryExecutor(
              "UPDATE requests SET status = 'approved' WHERE requestId = ?",
              [requestId]
            );
            if (approvedRequest?.data?.affectedRows == 1) {
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.RequestApproved,
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR[500].NoRequest, 500);
            }
          } else {
            throw new AppError(ERROR.messages.UnableToCreateProject, 400);
          }
        } else {
          throw new AppError(ERROR.messages.NoRequest, 400);
        }
      } else if (requestType == "Updated Project") {
        if (response?.data.length > 0) {
          const result = await updateProject(
            response?.data[0]?.changedData,
            req.body.tokenDetail
          );
          if (result) {
            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              activityType: "Project Status",
              projectId: result?.projectId,
              title: "YIMBY || Project Request Approved",
              text: `Dear [Name],
              Your Project update request is successfully Approved.  
              
              Best regards, 
              Customer Support - YIMBY`,
              userId: response?.data[0]?.userId,
              type: developerNotificationType.isProjectUpdated,
            });
            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              latitude: response?.data[0]?.changedData.projectDetails.latitude,
              longitude: response?.data[0]?.changedData.projectDetails.latitude,
              activityType: "Project Status",
              title: "YIMBY",
              text: "Project Updated",
              neighbor: true,
              type: neighbourNotificationType.isNewDevelopments,
              projectId: result?.projectId,
            });
            // sendNotification({
            //   fromUserId: req.body.tokenDetail.userId,
            //   fromUserType: req.body.tokenDetail.userType,
            //   activityId: 1,
            //   latitude : response?.data[0]?.changedData.projectDetails.latitude,
            //   longitude : response?.data[0]?.changedData.projectDetails.latitude,
            //   activityType: "Project Status",
            //   title: "YIMBY || Project Request Approved",
            //   text: `Dear [Name],
            //   Your Project update request is successfully Approved.

            //   Best regards,
            //   Customer Support - YIMBY`,
            //   neighbor: true,
            //   type: neighbourNotificationType.isNewDevelopments,
            //   projectId: result?.projectId,
            // });
            const approvedRequest = await queryExecutor(
              "UPDATE requests SET status = 'approved' WHERE requestId = ?",
              [requestId]
            );
            if (approvedRequest?.data?.affectedRows == 1) {
              res.status(200).json(
                encrypt.encryptResponse(
                  JSON.stringify({
                    status: true,
                    message: SUCCESS.messages.RequestApproved,
                  }),
                  req.headers
                )
              );
            } else {
              throw new AppError(ERROR[500].NoRequest, 500);
            }
          } else {
            throw new AppError(ERROR.messages.NoRequest, 400);
          }
        } else {
          throw new AppError(ERROR.messages.NoRequest, 400);
        }
      } else if (requestType == "New Developer") {
        const result = await queryExecutor(
          "UPDATE `re_developer` SET isApproved = 'approved' where userId = ? and isApproved = 'pending'",
          [response?.data[0]?.userId]
        );
        await EmailHelper.sendEmail({
          to: response?.data[0]?.changedData.email,
          subject: "YIMBY || Welcome to YIMBY",
          text: `Dear ${response?.data[0]?.changedData.firstName}, 
Congratulations and welcome to YIMBY! Your Registration is Approved. 
We're thrilled to have you join our community. 
As a new member, you now have access to Projects, Cards, User Profile, Messages, Notifications and many more. 
Here are a few things you can do now: 
- Complete your profile  
- Explore our Features
Once again, welcome aboard! We're excited to have you with us.
          
Best regards, 
          
Customer Support - YIMBY`,
        });

        if (result?.data?.affectedRows == 1) {
          await queryExecutor(
            "UPDATE requests SET status = 'approved' WHERE requestId = ?",
            [requestId]
          );
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.RequestApproved,
              }),
              req.headers
            )
          );
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      } else {
        throw new AppError(ERROR.messages.invalidRequestType, 400);
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

const rejectRequest = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      const { requestId, requestType } = req.body;
      const request = await queryExecutor(
        "select * from requests WHERE requestId = ?",
        [requestId]
      );
      const result = await queryExecutor(
        "UPDATE requests SET status = 'rejected' WHERE requestId = ?",
        [requestId]
      );
      if (result?.data.affectedRows == 1) {
        if (requestType == "Updated Project") {
          const projectStatus = await queryExecutor(
            "UPDATE project SET projectStatus = 'active' , isInDraft = 0 WHERE projectId = ?",
            request?.data[0].changedData?.id
          );
          if (projectStatus?.data?.affectedRows == 1) {
            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              activityType: "Project Status",
              projectId: request?.data[0].changedData?.id,
              title: "YIMBY || Project Request Declined",
              text: `Dear [Name],
Your New Project ${request.data[0]?.changedData?.projectDetails?.projectName} Request is Declined.  
              
Best regards, 
Customer Support - YIMBY`,
              userId: request?.data[0]?.userId,
              type: developerNotificationType.isProjectUpdated,
            });

            // await EmailHelper.sendEmail({
            //   to: request?.data[0]?.changedData?.email,
            //   subject: " YIMBY || Project Request Declined",
            //   text: `Dear [Name],
            //          Your New Project (Project Name) Request is Declined.

            //          Best regards,
            //          Customer Support - YIMBY`,
            // });

            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.RequestRejected,
                }),
                req.headers
              )
            );
          } else {
            throw new AppError(ERROR[500].afterQuery, 500);
          }
        } else {
          if (requestType == "New Project") {
            sendNotification({
              fromUserId: req.body.tokenDetail.userId,
              fromUserType: req.body.tokenDetail.userType,
              activityId: 1,
              activityType: "Project Status",
              projectId: request?.data[0].changedData?.id,
              title: "YIMBY || Project Rejected",
              text: `Dear [Name], 
              Your project request has been rejected due to following some unethical practices. 
              Please use all valid details and try again.
              
              Best regards, 
              
              Customer Support - YIMBY`,
              userId: request?.data[0]?.userId,
              type: developerNotificationType.isProjectUpdated,
            });
          } else {
            await queryExecutor(
              "UPDATE re_developer set isApproved = 'rejected' WHERE email = ?",
              [request?.data[0]?.changedData?.email]
            );
            console.log(request?.data[0]?.changedData);
            await EmailHelper.sendEmail({
              to: request?.data[0]?.changedData?.email,
              subject: "YIMBY || Registration Rejected",
              text: `Dear ${request?.data[0]?.changedData?.firstName}, 
Your registration request has been rejected due to following some unethical practices for signing up for a new account. 
Please use all valid details and try again.
              
Best regards, 
              
Customer Support - YIMBY`,
            });
          }
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.RequestRejected,
              }),
              req.headers
            )
          );
        }
      } else if (result?.data.affectedRows == 0) {
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

const getUsers = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let result = [];
      let txt = "";
      let type = req.query?.queryRequest.type;
      if (req.query?.queryRequest?.filter) {
        txt = req.query?.queryRequest?.filter;
      }

      if (type === "Developer") {
        // result = await queryExecutor(
        //   "SELECT * FROM re_developer where isActive=1"
        // );
        result = await queryExecutor(query.postLogin.getDevelopers, [
          txt.toString(),
        ]);
        result.data[0] = result.data[0].map((item) => {
          return { ...item, userType: "Developer" };
        });
      } else if (type === "Neighbour") {
        // result = await queryExecutor(
        //   "SELECT * FROM neighbours where isActive=1"
        // );
        result = await queryExecutor(query.postLogin.getNeighbours, [
          txt.toString(),
        ]);
        result.data[0] = result.data[0].map((item) => {
          return { ...item, userType: "Neighbour" };
        });
      } else {
        // result = await queryExecutor(
        //   "SELECT * FROM re_developer where isActive=1"
        // );
        result = await queryExecutor(query.postLogin.getDevelopers, [
          txt.toString(),
        ]);

        result.data[0] = result.data[0].map((item) => {
          return { ...item, userType: "Developer" };
        });
        // const neig = await queryExecutor(
        //   "SELECT * FROM neighbours where isActive=1"
        // );
        const neig = await queryExecutor(query.postLogin.getNeighbours, [
          txt.toString(),
        ]);
        neig.data[0] = neig.data[0].map((item) => {
          return { ...item, userType: "Neighbour" };
        });
        result.data[0].push(...neig.data[0]);
      }
      result.data[0].sort((a, b) => b.createdOn - a.createdOn);
      if (!result.data) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details: {
                totalCount: result.data[0]?.length,
                data: result.data[0],
              },
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

const getUserDetail = async (req, res) => {
  try {
    let type = req.query.queryRequest.type;
    let userId = req.query.queryRequest.id;

    const result = await queryExecutor(query.postLogin.getUserDetail, [
      userId,
      type,
    ]);
    if (
      result &&
      result?.data[0] &&
      result?.data[0][0] &&
      result?.data[0][0].message === "Success"
    ) {
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.userDataFetched,
            userDetail: result?.data[0][0],
            otherDetails: result?.data[1],
          }),
          req.headers
        )
      );
    } else {
      throw new AppError(ERROR.messages.userIdNotFound, 404);
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

const suspendUser = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let { email, userType } = req.body;
      const result = await queryExecutor(
        `UPDATE ${userType} SET isApproved = 'suspended' WHERE email = ?`,
        [email]
      );
      if (result?.data?.affectedRows == 1) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.userSuspend,
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR[500].NoRequest, 500);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

const unSuspendUser = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "admin") {
      let { email, userType } = req.body;
      const result = await queryExecutor(
        `UPDATE ${userType} SET isApproved = 'approved' WHERE email = ?`,
        [email]
      );
      if (result?.data?.affectedRows == 1) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.userUnSuspend,
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR[500].NoRequest, 500);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encryption.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

module.exports = {
  adminSignup,
  addReUser,
  editReUser,
  getReUser,
  getUsers,
  getUserDetail,
  requestListing,
  approveRequest,
  rejectRequest,
  getRequestDetail,
  suspendUser,
  unSuspendUser,
};
