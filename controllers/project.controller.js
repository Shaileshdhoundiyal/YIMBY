const { encrypt, AppError, queryBuilder, queryExecutor } = require("../utils");
const { ERROR, SUCCESS } = require("../constants");
const query = require("../repositories/query.json");
const s3Helper = require("../utils/s3.controller.js");
const moment = require("moment/moment");
const { sendNotification } = require("./notification.controller.js");
const { adminNotificationType } = require("../constants/notificationType.js");

const projectDetailsObject = (projectInfo, userDetails) => {
  let { projectDetails, projectImages, cardDetails, defaultCardDetails } =
    projectInfo;
  //projectDetails.projectId = projectDetails.projectId;
  projectDetails.userId = userDetails.userId;
  projectDetails.projectName = projectDetails.projectName
    ? projectDetails.projectName.trim()
    : "";
  projectDetails.projectAddress = projectDetails.projectAddress
    ? projectDetails.projectAddress.trim()
    : "";
  projectDetails.zipCode = projectDetails.zipCode ? projectDetails.zipCode : "";
  projectDetails.latitude = projectDetails.latitude
    ? projectDetails.latitude
    : "";
  projectDetails.longitude = projectDetails.longitude
    ? projectDetails.longitude
    : "";
  projectDetails.buidlingHeight = projectDetails.buidlingHeight
    ? projectDetails.buidlingHeight
    : null;
  projectDetails.propertySize = projectDetails.propertySize
    ? projectDetails.propertySize
    : null;
  projectDetails.floorPlan = projectDetails.floorPlan
    ? projectDetails.floorPlan
    : null;
  projectDetails.residentialUnits = projectDetails.residentialUnits
    ? projectDetails.residentialUnits
    : null;
  projectDetails.maximumCapacity = projectDetails.maximumCapacity
    ? projectDetails.maximumCapacity
    : null;
  projectDetails.projectDescription = projectDetails.projectDescription
    ? projectDetails.projectDescription.trim()
    : null;
  projectDetails.presentationVideo = projectDetails.presentationVideo
    ? projectDetails.presentationVideo.trim()
    : null;
  projectDetails.benefit = projectDetails.benefit
    ? projectDetails.benefit.length > 0
      ? JSON.stringify(projectDetails.benefit)
      : "[]"
    : "[]";
  projectDetails.coverImage = projectDetails.coverImage
    ? projectDetails.coverImage.trim()
    : null;
  projectDetails.projectType = projectDetails.projectType
    ? projectDetails.projectType.trim()
    : null;
  projectDetails.projectPartner = projectDetails.projectPartner
    ? projectDetails.projectPartner.length > 0
      ? JSON.stringify(projectDetails.projectPartner)
      : null
    : null;
  projectDetails.phaseStatus = projectDetails.phaseStatus
    ? projectDetails.phaseStatus.trim()
    : null;
  projectDetails.projectStatus = "active";
  projectDetails.country = projectDetails.country
    ? projectDetails.country.trim()
    : null;
  projectDetails.state = projectDetails.state
    ? projectDetails.state.trim()
    : null;
  projectDetails.city = projectDetails.city ? projectDetails.city.trim() : null;
  projectImages = projectImages
    ? projectImages.length > 0
      ? projectImages
      : []
    : [];

  cardDetails = cardDetails
    ? cardDetails.length > 0
      ? cardDetails
      : null
    : null;

  defaultCardDetails = defaultCardDetails
    ? defaultCardDetails.length > 0
      ? defaultCardDetails
      : null
    : null;

  return { projectDetails, projectImages, cardDetails, defaultCardDetails };
};

const addProjectRequest = async (req, res) => {
  try {
    let { projectDetails, projectImages, cardDetails, defaultCardDetails } =
      projectDetailsObject(req.body, req.body.tokenDetail);

    let { newOrganisation = null, newPartnerOrganisations = null } = req.body;
    if (!projectDetails.projectName || projectDetails.projectName === "") {
      throw new AppError(ERROR.messages.projectNameEmpty, 400);
    } else if (
      !projectDetails.projectAddress ||
      projectDetails.projectAddress === ""
    ) {
      throw new AppError(ERROR.messages.projectAddressEmpty);
    } else if (
      (!cardDetails && !defaultCardDetails) ||
      (cardDetails?.length === 0 && defaultCardDetails?.length === 0)
    ) {
      throw new AppError(ERROR.messages.cardDetailEmpty);
    } else if (
      !projectDetails.latitude ||
      (projectDetails.latitude === "" && !projectDetails.longitude) ||
      projectDetails.longitude === ""
    ) {
      throw new AppError(ERROR.messages.locationEmpty);
    }
    projectDetails.projectStatus = "draft";
    const uploadedProjectImage = [];
    let i = 0;
    for (i; i < projectImages?.length; i++) {
      const imageLink = await s3Helper.uploadDocumentsToS3(
        projectImages[i],
        //data.tokenDetail.userId + date
        req.body.tokenDetail.userId + Date.now()
      );
      uploadedProjectImage.push(imageLink);
    }
    req.body.projectImages = uploadedProjectImage;
    await queryExecutor(query.postLogin.addNewProjectRequest, [
      req.body.tokenDetail.userId,
      null,
      JSON.stringify(req.body),
    ]);
    console.log(JSON.stringify(projectDetails));
    sendNotification({
      fromUserId: req.body.tokenDetail.userId,
      fromUserType: req.body.tokenDetail.userType,
      activityId: 1,
      activityType: "Project Request",
      projectId: projectDetails.projectId,
      title: "YIMBY || Project Request",
      text: `Dear Admin, 
New project request has been received. 
Please review and perform the appropriate action. 
                                      
Best regards, 
Customer Support - YIMBY`,
      admin: true,
      type: adminNotificationType.isNewProjectAdded,
    });
    res.status(200).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: true,
          message: SUCCESS.messages.requestAdded,
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

const create_new_project = async (data, tokenDetail) => {
  try {
    if (data.tokenDetail.userType === "re_developer") {
      if (data) {
        let userDetails = data.tokenDetail;
        delete data.tokenDetail;
        let { projectDetails, projectImages, cardDetails, defaultCardDetails } =
          projectDetailsObject(data, userDetails);

        let { newOrganisation = null, newPartnerOrganisations = null } = data;
        if (!projectDetails.projectName || projectDetails.projectName === "") {
          throw new AppError(ERROR.messages.projectNameEmpty, 400);
        } else if (
          !projectDetails.projectAddress ||
          projectDetails.projectAddress === ""
        ) {
          throw new AppError(ERROR.messages.projectAddressEmpty);
        } else if (
          (!cardDetails && !defaultCardDetails) ||
          (cardDetails?.length === 0 && defaultCardDetails?.length === 0)
        ) {
          throw new AppError(ERROR.messages.cardDetailEmpty);
        } else if (
          !projectDetails.latitude ||
          (projectDetails.latitude === "" && !projectDetails.longitude) ||
          projectDetails.longitude === ""
        ) {
          throw new AppError(ERROR.messages.locationEmpty);
        }

        // sql query string for project.                    <string>
        let projectQuery =
          queryBuilder.projectInsertQueryBuilder(projectDetails);

        // sql query string for cards and subtopics.        <Array>
        let cardDetailsQuery = [];
        if (cardDetails) {
          // cardDetailsQuery = queryBuilder.cardDetailsQueryBuilder(cardDetails);
        }
        cardDetailsQuery = JSON.stringify(cardDetails);

        //sql query string for phase status.                <Array>
        let phaseStatusQuery = [];
        if (projectDetails.phaseStatus) {
          // phaseStatusQuery = queryBuilder.phaseStatusQueryBuilder(
          //   projectDetails.phaseStatus
          // );
        }
        phaseStatusQuery = JSON.stringify(phaseStatusQuery);
        let result = await queryExecutor("call create_new_project(?,?,?,?)", [
          projectQuery,
          // projectDetails.projectPartner,
          projectDetails.benefit,
          JSON.stringify(projectImages) || "[]",
          cardDetailsQuery,
          // phaseStatusQuery,
          // newOrganisationQuery,
          // newPartnerOrganisationsQuery,
          // newOrganisationName,
          // newPartnerOrganisationsNames,
          // projectDetails.organisationId,
        ]);
        if (
          result &&
          result?.data[0][0] &&
          result?.data[0][0].message === "Success"
        ) {
          if (cardDetails?.length > 0) {
            for (const element of cardDetails) {
              await queryExecutor(query.postLogin.insertProjectCard, [
                element.id,
                result?.data[0][0].projectId,
              ]);
            }
          }
          if (defaultCardDetails?.length > 0) {
            for (const element of defaultCardDetails) {
              await queryExecutor(
                "INSERT INTO project_static_cards (projectId,staticCardId) VALUES(?,?)",
                [result?.data[0][0].projectId, element.staticCardId]
              );
            }
          }
          if (projectDetails.isInDraft) {
            let pushnotificationInfo =
              await addCommentsOnProjects.pushnotificationDetails(
                userDetails.userId,
                result[0][0].projectId,
                null,
                result[0][0].projectId,
                "CREATE_PROJECT",
                userDetails.userType,
                null,
                null
              );
            let { pushTokenInfo, isPushNotif } = pushnotificationInfo;
            return {
              message: SUCCESS.messages.projectPublished,
              projectId: result[0][0].projectId,
              details: result[0][0],
            };
          } else {
            return {
              status: true,
              message: SUCCESS.messages.DraftProjectCreated,
              projectId: result?.data[0][0].projectId,
              details: result?.data[0][0],
            };
          }
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      } else {
        throw new AppError(ERROR[400].contentNotAvailable, 400);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
    console.log(JSON.stringify(error));
    return error;
  }
};

const updateProjectRequest = async (req, res) => {
  try {
    let { projectDetails, projectImages, cardDetails, defaultCardDetails } =
      projectDetailsObject(req.body, req.body.tokenDetail);
    if (!projectDetails.projectName || projectDetails.projectName === "") {
      throw new AppError(ERROR.messages.projectNameEmpty, 400);
    } else if (
      !projectDetails.projectAddress ||
      projectDetails.projectAddress === ""
    ) {
      throw new AppError(ERROR.messages.projectAddressEmpty, 400);
    } else if (
      (!cardDetails && !defaultCardDetails) ||
      (cardDetails?.length === 0 && defaultCardDetails?.length === 0)
    ) {
      throw new AppError(ERROR.messages.cardDetailEmpty, 400);
    } else if (
      !projectDetails.latitude ||
      (projectDetails.latitude === "" && !projectDetails.longitude) ||
      projectDetails.longitude === ""
    ) {
      throw new AppError(ERROR.messages.locationEmpty, 400);
    }
    const response = await queryExecutor(
      "SELECT * FROM requests WHERE userId = ? and status = 'pending' and projectId = ?",
      [req.body.tokenDetail.userId, req.body.id]
    );
    if (response?.data.length > 0) {
      const addRequestData = await queryExecutor(
        "UPDATE requests SET requestTime = CURRENT_TIMESTAMP() , changedData = ? WHERE projectId = ? AND status = 'pending'",
        [JSON.stringify(req.body), req.body.id]
      );
    } else {
      await queryExecutor(query.postLogin.addUpdateProjectRequest, [
        req.body.tokenDetail.userId,
        req.body.id,
        JSON.stringify(req.body),
      ]);
    }
    const updateProjectStatus = await queryExecutor(
      "UPDATE project SET projectStatus = 'draft' WHERE projectId = ?",
      [req.body.id]
    );
    if (updateProjectStatus?.data?.affectedRows == 1) {
      sendNotification({
        fromUserId: req.body?.tokenDetail?.userId,
        fromUserType: req.body?.tokenDetail?.userType,
        activityId: 1,
        activityType: "Update Project",
        projectId: req?.body?.id,
        title: "YIMBY",
        text: "Update project request recieved.",
        admin: true,
        type: adminNotificationType.isNewProjectAdded,
      });
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.requestAdded,
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
const updateProject = async (data, tokenDetail) => {
  try {
    if (data.tokenDetail.userType === "re_developer") {
      const userDetails = data.tokenDetail;
      const id = data.id;
      let { projectDetails, projectImages, cardDetails, defaultCardDetails } =
        projectDetailsObject(data, userDetails);
      let { newPartnerOrganisations = null } = data;
      if (!projectDetails.projectName || projectDetails.projectName === "") {
        throw new AppError(ERROR.messages.projectNameEmpty, 400);
      } else if (
        !projectDetails.projectAddress ||
        projectDetails.projectAddress === ""
      ) {
        throw new AppError(ERROR.messages.projectAddressEmpty, 400);
      } else if (
        (!cardDetails && !defaultCardDetails) ||
        (cardDetails?.length === 0 && defaultCardDetails?.length === 0)
      ) {
        throw new AppError(ERROR.messages.cardDetailEmpty);
      } else if (
        !projectDetails.latitude ||
        (projectDetails.latitude === "" && !projectDetails.longitude) ||
        projectDetails.longitude === ""
      ) {
        throw new AppError(ERROR.messages.locationEmpty);
      }

      let newPartnerOrganisationsQuery = null;
      let newPartnerOrganisationsNames = null;
      if (newPartnerOrganisations) {
        newPartnerOrganisationsNames = newPartnerOrganisations.map(
          (partner) => partner.name
        );
        projectDetails.projectPartner = null;
        newPartnerOrganisationsQuery = JSON.stringify(
          newPartnerOrganisationsQuery
        );
        newPartnerOrganisationsNames = JSON.stringify(
          newPartnerOrganisationsNames
        );
      }

      let updateProjectQuery = "";

      for (let i = 0; i < projectImages.length; i++) {
        if (!projectImages[i].includes("https")) {
          projectImages[i] = await s3Helper.uploadDocumentsToS3(
            projectImages[i],
            data.tokenDetail.userId + Date.now()
          );
        }
      }
      let updateCardDetails = [];
      if (projectDetails)
        updateProjectQuery = queryBuilder.updateProjectQueryBuilder(
          projectDetails,
          projectImages
        );

      if (cardDetails)
        updateCardDetails = queryBuilder.updateCardDetails(cardDetails);
      updateCardDetails = JSON.stringify(updateCardDetails);
      projectDetails.isInDraft = 0;
      updateProjectQuery = updateProjectQuery.replace(
        "@projectImages",
        `"${JSON.stringify(projectImages ?? [])}"`
      );
      updateProjectQuery = updateProjectQuery.replace("@pId", `'${id}'`);

      let result = await queryExecutor(updateProjectQuery, [
        JSON.stringify(projectImages ?? []),
        id,
      ]);
      // let result = await queryExecutor(updateProjectQuery.toString());

      if (result?.data?.affectedRows > 0) {
        let storedCards = await queryExecutor(
          "SELECT * FROM project_cards WHERE projectId = ?",
          [id]
        );
        let storedDefaultCards = await queryExecutor(
          "SELECT * FROM project_static_cards WHERE projectId = ?",
          [id]
        );
        if (storedCards?.data?.length > 0) {
          storedCards = storedCards?.data.map((item) => item.cardId);
          storedCards = storedCards.sort();

          let newCards = [];
          if (cardDetails?.length > 0) {
            newCards = cardDetails.map((item) => item.id);
            newCards = newCards.sort();

            let i = 0;
            let j = 0;
            while (i < storedCards.length && j < newCards.length) {
              if (storedCards[i] === newCards[j]) {
                i++;
                j++;
              } else if (storedCards[i] > newCards[j]) {
                let k = i;
                let isExist = false;
                for (k; k < storedCards.length; k++) {
                  if (storedCards[k] === newCards[j]) {
                    isExist = true;
                    break;
                  }
                }
                if (isExist) {
                } else {
                  await queryExecutor(
                    "DELETE FROM be_heard_comments WHERE cardId = ? AND projectId = ?",
                    [storedCards[i], id]
                  );
                  await queryExecutor(
                    "DELETE FROM project_cards WHERE cardId = ? AND projectId = ?",
                    [storedCards[i], id]
                  );
                }
                await queryExecutor(query.postLogin.insertProjectCard, [
                  newCards[j],
                  id,
                ]);
                j++;
              } else {
                let k = j;
                let isExist = false;
                for (k; k < newCards.length; k++) {
                  if (newCards[k] === storedCards[i]) {
                    isExist = true;
                    break;
                  }
                }
                if (isExist) {
                } else {
                  await queryExecutor(
                    "DELETE FROM be_heard_comments WHERE cardId = ? AND projectId = ?",
                    [storedCards[i], id]
                  );
                  await queryExecutor(
                    "DELETE FROM project_cards WHERE cardId = ? AND projectId = ?",
                    [storedCards[i], id]
                  );
                }
                i++;
              }
            }
            if (i < storedCards.length) {
              while (i < storedCards.length) {
                await queryExecutor(
                  "DELETE FROM be_heard_comments WHERE cardId = ? AND projectId = ?",
                  [storedCards[i], id]
                );
                await queryExecutor(
                  "DELETE FROM project_cards WHERE cardId = ? AND projectId = ?",
                  [storedCards[i], id]
                );
                i++;
              }
            }
            if (j < newCards.length) {
              while (j < newCards.length) {
                await queryExecutor(query.postLogin.insertProjectCard, [
                  newCards[j],
                  id,
                ]);
                j++;
              }
            }
          }else{
            for (let i = 0 ; i < storedCards.length ; i++) {
              await queryExecutor(
                "DELETE FROM be_heard_comments WHERE cardId = ? AND projectId = ?",
                [storedCards[i], id]
              );
              await queryExecutor(
                "DELETE FROM project_cards WHERE cardId = ? AND projectId = ?",
                [storedCards[i], id]
              );
            }
          }
        } else {
          let newCards = [];
          newCards =
            cardDetails && cardDetails?.length > 0
              ? cardDetails.map((item) => item.id)
              : [];
          newCards = newCards.sort();

          let i = 0;
          for (i; i < newCards.length; i++) {
            await queryExecutor(query.postLogin.insertProjectCard, [
              newCards[i],
              id,
            ]);
          }
        }
        if (storedDefaultCards?.data?.length > 0) {
          storedDefaultCards = storedDefaultCards?.data.map(
            (item) => item.staticCardId
          );
          storedDefaultCards = storedDefaultCards.sort();
          let newCards = [];
          if (defaultCardDetails?.length > 0) {
            newCards = defaultCardDetails.map((item) => item.staticCardId);
            newCards = newCards.sort();
            console.log(newCards);
            let i = 0;
            let j = 0;
            while (i < storedDefaultCards.length && j < newCards.length) {
              if (storedDefaultCards[i] === newCards[j]) {
                i++;
                j++;
              } else if (storedDefaultCards[i] > newCards[j]) {
                let k = i;
                let isExist = false;
                for (k; k < storedDefaultCards.length; k++) {
                  if (storedDefaultCards[k] === newCards[j]) {
                    isExist = true;
                    break;
                  }
                }
                if (isExist) {
                } else {
                  await queryExecutor(
                    "DELETE FROM static_be_heard_comments WHERE staticCardId = ? AND projectId = ?",
                    [storedDefaultCards[i], id]
                  );
                  await queryExecutor(
                    "DELETE FROM project_static_cards WHERE staticCardId = ? AND projectId = ?",
                    [storedDefaultCards[i], id]
                  );
                }
                await queryExecutor(
                  "INSERT INTO project_static_cards (staticCardId,projectId) values(?,?)",
                  [newCards[j], id]
                );
                j++;
              } else {
                let k = j;
                let isExist = false;
                for (k; k < newCards.length; k++) {
                  if (newCards[k] === storedDefaultCards[i]) {
                    isExist = true;
                    break;
                  }
                }
                if (isExist) {
                } else {
                  await queryExecutor(
                    "DELETE FROM static_be_heard_comments WHERE staticCardId = ? AND projectId = ?",
                    [storedDefaultCards[i], id]
                  );
                  await queryExecutor(
                    "DELETE FROM project_static_cards WHERE staticCardId = ? AND projectId = ?",
                    [storedDefaultCards[i], id]
                  );
                }
                i++;
              }
            }
            if (i < storedCards.length) {
              while (i < storedCards.length) {
                await queryExecutor(
                  "DELETE FROM static_be_heard_comments WHERE staticCardId = ? AND projectId = ?",
                  [storedCards[i], id]
                );
                await queryExecutor(
                  "DELETE FROM project_static_cards WHERE staticCardId = ? AND projectId = ?",
                  [storedCards[i], id]
                );
                i++;
              }
            }
            if (j < newCards.length) {
              while (j < newCards.length) {
                await queryExecutor(
                  "INSERT INTO project_static_cards (staticCardId,projectId) values(?,?)",
                  [newCards[j], id]
                );
                j++;
              }
            }
          }else{
            for (let i = 0 ; i < storedDefaultCards.length ; i++) {
              await queryExecutor(
                "DELETE FROM static_be_heard_comments WHERE staticCardId = ? AND projectId = ?",
                [storedDefaultCards[i], id]
              );
              await queryExecutor(
                "DELETE FROM project_static_cards WHERE staticCardId = ? AND projectId = ?",
                [storedDefaultCards[i], id]
              );
            }
          }
        } else {
          let newDefaultCards = [];
          newDefaultCards = defaultCardDetails?.map((item) => item?.staticCardId);
          newDefaultCards = newDefaultCards?.sort();
          let i = 0;
          for (i; i < newDefaultCards?.length; i++) {
            await queryExecutor(
              "INSERT INTO project_static_cards (staticCardId,projectId) values(?,?)",
              [newDefaultCards[i], id]
            );
          }
        }
        return {
          "projectId" : id
        };
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
    throw error;
  }
};

const projectCardsVoting = async (req, res) => {
  try {
    let { projectId, cardId, agree, comment, isDefault } = req.body;
    projectId = projectId ? projectId : "";
    cardId = cardId ? cardId : "";
    if (
      !projectId ||
      projectId === "" ||
      !cardId ||
      cardId === "" ||
      agree === undefined ||
      agree === ""
    ) {
      throw new AppError(ERROR[400].contentNotAvailable, 400);
    } else {
      const { tokenDetail } = req.body;
      let projectCards, projectCardsStatusmeter;
      if (isDefault) {
        projectCards = await queryExecutor(
          `SELECT * FROM project_static_cards where projectId = ? and staticCardId = ?`,
          [projectId, cardId]
        );
        projectCardsStatusmeter = await queryExecutor(
          `SELECT * FROM static_project_cards_statusmeter where projectId = ? and userId = ?`,
          [projectId, tokenDetail?.userId]
        );
      } else {
        projectCards = await queryExecutor(
          `SELECT * FROM project_cards where projectId = ? and cardId = ?`,
          [projectId, cardId]
        );
        projectCardsStatusmeter = await queryExecutor(
          `SELECT * FROM project_cards_statusmeter where projectId = ? and userId = ?`,
          [projectId, tokenDetail?.userId]
        );
      }
      projectCards = projectCards?.data;
      projectCardsStatusmeter = projectCardsStatusmeter?.data;
      let agreeCount = projectCards[0]?.cardAgreeCount ?? 0;
      let disagreeCount = projectCards[0]?.cardDisAgreeCount ?? 0;
      let skipCount = projectCards[0]?.cardSkipCount ?? 0;

      if (projectCardsStatusmeter?.length > 0) {
        let agreeList = projectCardsStatusmeter[0]?.agreeCardIds ?? [];
        let disagreeList = projectCardsStatusmeter[0]?.disAgreeCardIds ?? [];
        let skipList = projectCardsStatusmeter[0]?.skipCardIds ?? [];
        let check;
        let cardIds = "";
        let cardsReviewedCount = 0;
        if (agree === "agree") {
          check = agreeList.find((item) => item == cardId);
          if (check) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardAgreed,
                }),
                req.headers
              )
            );
          } else {
            check = null;
            agreeList.push(cardId);
            agreeCount += 1;
            check = disagreeList.find((item) => item == cardId);
            if (check) {
              disagreeList = disagreeList.filter((item) => item != cardId);
              disagreeCount -= 1;
            }
            check = null;
            check = skipList.find((item) => item == cardId);
            if (check) {
              skipList = skipList.filter((item) => item != cardId);
              skipCount -= 1;
            }
            agreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            disagreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            skipList.forEach((element) => {
              cardIds += `${element},`;
            });
            cardIds = cardIds.slice(0, -1);
            cardsReviewedCount += agreeList?.length;
            cardsReviewedCount += disagreeList?.length;
            cardsReviewedCount += skipList?.length;
            let updateStatusmeter, updateProjectCard;
            if (isDefault) {
              updateStatusmeter = `UPDATE static_project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
            } else {
              updateStatusmeter = `UPDATE project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
            }
            await queryExecutor(updateStatusmeter, [
              cardsReviewedCount,
              JSON.stringify(agreeList),
              JSON.stringify(disagreeList),
              JSON.stringify(skipList),
              cardIds,
              moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
              projectId,
              tokenDetail?.userId,
            ]);
            await queryExecutor(updateProjectCard, [
              agreeCount,
              disagreeCount,
              skipCount,
              projectId,
              cardId,
            ]);
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardAgreed,
                }),
                req.headers
              )
            );
          }
        } else if (agree === "disagree") {
          check = disagreeList.find((item) => item == cardId);
          if (check) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardDisAgreed,
                }),
                req.headers
              )
            );
          } else {
            check = null;
            disagreeList.push(cardId);
            disagreeCount += 1;
            check = agreeList.find((item) => item == cardId);
            if (check) {
              agreeList = agreeList.filter((item) => item != cardId);
              agreeCount -= 1;
            }
            check = null;
            check = skipList.find((item) => item == cardId);
            if (check) {
              skipList = skipList.filter((item) => item != cardId);
              skipCount -= 1;
            }
            check = null;
            agreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            disagreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            skipList.forEach((element) => {
              cardIds += `${element},`;
            });
            cardIds = cardIds.slice(0, -1);
            cardsReviewedCount += agreeList?.length;
            cardsReviewedCount += disagreeList?.length;
            cardsReviewedCount += skipList?.length;
            let updateStatusmeter, updateProjectCard;
            if (isDefault) {
              updateStatusmeter = `UPDATE static_project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
            } else {
              updateStatusmeter = `UPDATE project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
            }
            console.log([
              cardsReviewedCount,
              JSON.stringify(agreeList),
              JSON.stringify(disagreeList),
              JSON.stringify(skipList),
              cardIds,
              moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
              projectId,
              tokenDetail?.userId,
            ]);
            await queryExecutor(updateStatusmeter, [
              cardsReviewedCount,
              JSON.stringify(agreeList),
              JSON.stringify(disagreeList),
              JSON.stringify(skipList),
              cardIds,
              moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
              projectId,
              tokenDetail?.userId,
            ]);
            await queryExecutor(updateProjectCard, [
              agreeCount,
              disagreeCount,
              skipCount,
              projectId,
              cardId,
            ]);
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardDisAgreed,
                }),
                req.headers
              )
            );
          }
        } else {
          check = skipList.find((item) => item == cardId);
          if (check) {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardAgreed,
                }),
                req.headers
              )
            );
          } else {
            check = null;
            skipList.push(cardId);
            skipCount += 1;
            check = agreeList.find((item) => item == cardId);
            if (check) {
              agreeList = agreeList.filter((item) => item != cardId);
              agreeCount -= 1;
            }
            check = null;
            check = disagreeList.find((item) => item == cardId);
            if (check) {
              disagreeList = disagreeList.filter((item) => item != cardId);
              disagreeCount -= 1;
            }
            check = null;
            agreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            disagreeList.forEach((element) => {
              cardIds += `${element},`;
            });
            skipList.forEach((element) => {
              cardIds += `${element},`;
            });
            cardIds = cardIds.slice(0, -1);
            cardsReviewedCount += agreeList?.length;
            cardsReviewedCount += disagreeList?.length;
            cardsReviewedCount += skipList?.length;
            let updateStatusmeter, updateProjectCard;
            if (isDefault) {
              updateStatusmeter = `UPDATE static_project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
            } else {
              updateStatusmeter = `UPDATE project_cards_statusmeter SET cardsReviewedCount = ?, agreeCardIds = ?, disAgreeCardIds = ?, skipCardIds = ?, cardIds =?, modifiedOn=? WHERE  projectId = ? and userId = ?`;
              updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
            }
            await queryExecutor(updateStatusmeter, [
              cardsReviewedCount,
              JSON.stringify(agreeList),
              JSON.stringify(disagreeList),
              JSON.stringify(skipList),
              cardIds,
              moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
              projectId,
              tokenDetail?.userId,
            ]);
            await queryExecutor(updateProjectCard, [
              agreeCount,
              disagreeCount,
              skipCount,
              projectId,
              cardId,
            ]);
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.cardSkipped,
                }),
                req.headers
              )
            );
          }
        }
      } else {
        if (agree === "agree") {
          let updateStatusmeter, updateProjectCard;
          if (isDefault) {
            updateStatusmeter = `INSERT INTO static_project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
          } else {
            updateStatusmeter = `INSERT INTO project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
          }
          await queryExecutor(updateStatusmeter, [
            tokenDetail?.userId,
            projectId,
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            JSON.stringify([cardId]),
            JSON.stringify([]),
            JSON.stringify([]),
            cardId,
          ]);
          await queryExecutor(updateProjectCard, [
            agreeCount + 1,
            disagreeCount,
            skipCount,
            projectId,
            cardId,
          ]);
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.cardAgreed,
              }),
              req.headers
            )
          );
        } else if (agree === "disagree") {
          let updateStatusmeter, updateProjectCard;
          if (isDefault) {
            updateStatusmeter = `INSERT INTO static_project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
          } else {
            updateStatusmeter = `INSERT INTO project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
          }
          await queryExecutor(updateStatusmeter, [
            tokenDetail?.userId,
            projectId,
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            JSON.stringify([]),
            JSON.stringify([cardId]), 
            JSON.stringify([]),
            cardId,
          ]);
          await queryExecutor(updateProjectCard, [
            agreeCount,
            disagreeCount + 1,
            skipCount,
            projectId,
            cardId,
          ]);
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.cardDisAgreed,
              }),
              req.headers
            )
          );
        } else {
          let updateStatusmeter, updateProjectCard;
          if (isDefault) {
            updateStatusmeter = `INSERT INTO static_project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_static_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and staticCardId = ?`;
          } else {
            updateStatusmeter = `INSERT INTO project_cards_statusmeter (userId,projectId,cardsReviewedCount,createdOn,modifiedOn,agreeCardIds,disAgreeCardIds,skipCardIds,cardIds) VALUES (?,?,1,?,?,?,?,?,?) `;
            updateProjectCard = `UPDATE project_cards SET cardAgreeCount  = ?,cardDisAgreeCount = ? ,cardSkipCount = ? where projectId = ? and cardId = ?`;
          }
          await queryExecutor(updateStatusmeter, [
            tokenDetail?.userId,
            projectId,
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            moment(Date.now()).format("YYYY-MM-DD hh:mm:ss"),
            JSON.stringify([]),
            JSON.stringify([]),
            JSON.stringify([cardId]),
            cardId,
          ]);
          await queryExecutor(updateProjectCard, [
            agreeCount,
            disagreeCount,
            skipCount + 1,
            projectId,
            cardId,
          ]);
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.cardSkipped,
              }),
              req.headers
            )
          );
        }
      }
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

const isViewed = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      let {
        projectId = null,
        pushNotificationId = null,
        isResponded = false,
      } = req.body;
      let result = await queryExecutor(`call isViewed(?, ?, ?, ?)`, [
        req.body.tokenDetail.userId,
        projectId,
        pushNotificationId,
        isResponded,
      ]);
      if (projectId && !result?.data[0][0].isProjectFound) {
        throw new AppError(ERROR[404].projectNotFound, 404);
      } else if (projectId && !result?.data[0][0].isUpdated) {
        throw new AppError(ERROR.messages.viewsNotUpdated, 400);
      } else {
        // resolve({statusCode: 200, message: config.settings.success.messages.viewerIdAdded});

        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: "Success",
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

const dropDownData = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor("call getDropDownData(?)", [
        req.body.tokenDetail.details.userId,
      ]);
      // if(err) {
      //     reject({ statusCode: 500, message: config.settings.errors[500].afterQuery });
      //     return;
      // }
      let projectType = result?.data[1].map((type, index, arr) => {
        return type.projectType;
      });
      let real_estate_developer = result[0];
      let businessType = result[2].map((type, index, arry) => {
        return type.type;
      });
      let projectDetails = result[3];
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            real_estate_developer: real_estate_developer,
            projectType: projectType,
            businessType: businessType,
            projectDetails: projectDetails,
          }),
          req.headers
        )
      );
    } else {
      // reject({ statusCode: 403, message: config.settings.errors[400].invalidUserType });
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

const updateProjectPhaseStatus = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      if (req.body) {
        let { id, isCompleted = false } = req.body;
        if (!id) {
          throw new AppError(ERROR[400].phaseStatusId, 400);
        }
        let result = await queryExecutor(
          `call updateProjectPhaseStatus(?, ?)`,
          [id, isCompleted]
        );
        if (result?.data[0][0].isUpdated) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.projectPhaseStatus,
              }),
              req.headers
            )
          );
        } else if (!result?.data[0][0].isUpdated) {
          throw new AppError(result?.data[0][0].message, 400);
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
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

const deleteProject = async (req, res) => {
  try {
    const { projectId, RequestId } = req.body;
    const result = await queryExecutor(query.postLogin.deleteProject, [
      req.body.tokenDetail.userId,
      projectId,
    ]);
    if(RequestId)
    {
      await queryExecutor(
        "DELETE FROM requests WHERE RequestId = ?",
        [RequestId]
      );
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.projectDeleted,
          }),
          req.headers
        )
      );
  }
    else if (result && result?.data && result?.data[0] && result?.data[0][0]) {
      if (result?.data[0][0].message === "Success") {
          await queryExecutor(
            "DELETE FROM requests WHERE projectId = ?",
            [projectId]
          );
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.projectDeleted,
            }),
            req.headers
          )
        );
      } else if (result?.data[0][0].message === "invalid User") {
        throw new AppError(ERROR[400].invalidUserType, 400);
      } else if (result?.data[0][0] === "Project Not Found") {
        throw new AppError(ERROR[404].projectNotFound, 404);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
    } else {
      throw new AppError(ERROR[500].afterQuery, 500);
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

const getProjectWithComments = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor(
        "select * from project where userId = ? and projectId in (select projectId from be_heard_comments)",
        [req.body.tokenDetail.userId]
      );
      let staticResult = await queryExecutor(
        "select * from project where userId = ? and projectId in (select projectId from static_be_heard_comments)",
        [req.body.tokenDetail.userId]
      );
      const data = [...result.data,...staticResult.data];
      const set = new Set(data?.map((element) => element.projectId));
      let projects = [];
      data?.map((element) => {
        if(set.has(element.projectId)){
          projects.push(element)
          set.delete(element.projectId)
        }
      })
      if (result?.data || staticResult?.data) {
        if (result?.data.length > 0 || staticResult?.data.length > 0) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.projectListFetched,
                result: projects
              }),
              req.headers
            )
          );
        } else {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.noComments,
                result: result?.data,
              }),
              req.headers
            )
          );
        }
      } else {
        throw new AppError(result?.data.message, 400);
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
          message: error.explanation || ERROR[500].afterQuery,
        }),
        req.headers
      )
    );
  }
};

const getCardWithComments = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor(
        "SELECT * FROM cards WHERE userId = ? and id IN (select cardId from be_heard_comments where projectId= ?)",
        [req.body.tokenDetail.userId, req.query.queryRequest.projectId]
      );
      let staticResult = await queryExecutor(
        "SELECT * FROM static_cards WHERE staticCardId IN (select staticCardId from static_be_heard_comments where projectId= ?)",
        [req.query.queryRequest.projectId]
      );
      console.log(staticResult);
      if (result?.data || staticResult?.data) {
        if (result?.data.length > 0 || staticResult?.data.length > 0) {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.cardListFetched,
                result: [...result?.data, ...staticResult?.data],
              }),
              req.headers
            )
          );
        } else {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.noComments,
                result: result?.data,
              }),
              req.headers
            )
          );
        }
      } else {
        throw new AppError(result?.data.message, 400);
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
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

const removeCard = (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {}
};

module.exports = {
  create_new_project,
  updateProject,
  projectCardsVoting,
  isViewed,
  dropDownData,
  updateProjectPhaseStatus,
  deleteProject,
  addProjectRequest,
  updateProjectRequest,
  getProjectWithComments,
  getCardWithComments,
};



