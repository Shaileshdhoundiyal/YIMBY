const addSurveyAnswersQueryBuilder = (questionsAnswers, userId) => {
  let surveyStringsArray = [];
  questionsAnswers.forEach((questionAnswer, index, arr) => {
    let keys = "";
    let values = "";
    for (let [key, value] of Object.entries(questionAnswer)) {
      keys += `${key},`;
      values += `'${value}',`;
    }
    keys = keys.substring(0, keys.length - 1);
    values = values.substring(0, values.length - 1);

    let surveyString = `insert into neighbour_survey_answers (${keys}, userId) values (${values}, ${userId})`;
    surveyStringsArray.push(surveyString);
  });

  return surveyStringsArray;
};

const adminEditReDevQueryBuilder = (userDetails, userId) => {
  let keyValueStr = "";
  for (let [key, value] of Object.entries(userDetails)) {
    if (key === "userType" || key === "organisationId" || key === "userId")
      continue;
    if (key === "password") {
      value = encryptDecryptUtility.getEncryptedString(value.trim());
    }
    keyValueStr += `${key}="${value}",`;
  }
  keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);
  return `update re_developer set ${keyValueStr}  where userId = ${userId} and isActive is true`;
};

const insertBusinessProfileQueryBuilder = (businessProfile) => {
  let keys = "";
  let values = "";
  for (let [key, value] of Object.entries(businessProfile)) {
    keys += `${key},`;
    values += `'${value}',`;
  }
  keys = keys.substring(0, keys.length - 1);
  values = values.substring(0, values.length - 1);

  let businessProfileQuery = `insert into organisations (${keys}) values (${values})`;
  return businessProfileQuery;
};

const insertLinksQueryBuilder = (links) => {
  let keys = "";
  let values = "";
  for (let [key, value] of Object.entries(links)) {
    keys += `${key},`;
    values += `'${value}',`;
  }
  keys = keys.substring(0, keys.length - 1);
  values = values.substring(0, values.length - 1);

  let linksQuery = `insert into organisation_links (organisationId,${keys}) values (@orgId,${values})`;
  return linksQuery;
};

const updateBusinessProfileQueryBuilder = (businessProfile) => {
  let keyValueStr = "";
  for (let [key, value] of Object.entries(businessProfile)) {
    if (key == "id") continue;
    keyValueStr += `${key}='${value}',`;
  }
  keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);
  let businessProfileQuery = `update organisations set ${keyValueStr} where id = ${businessProfile.id}`;
  return businessProfileQuery;
};

const updateLinksQueryBuilder = (links, organisationId) => {
  let keyValueStr = "";
  for (let [key, value] of Object.entries(links)) {
    if (key == "id") continue;
    keyValueStr += `${key}='${value}',`;
  }
  keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);
  let businessProfileQuery = `update organisation_links set ${keyValueStr} where organisationId = ${organisationId}`;
  return businessProfileQuery;
};

const newOrganisationQueryBuilder = (newOrganisation) => {
  let values = "";
  let keys = "";
  for (let [key, value] of Object.entries(newOrganisation)) {
    keys = keys + `${key},`;
    values = values + `"${value}",`;
  }
  values = values.substring(0, values.length - 1);
  keys = keys.substring(0, keys.length - 1);
  let newOrganisationQuery = `insert into organisations (${keys}) values (${values})`;
  return newOrganisationQuery;
};

const newPartnerOrganisationsQueryBuilder = (newPartnerOrganisations) => {
  let newPartnerOrganisationsQueries = [];
  for (let newPartnerOrganisation of newPartnerOrganisations) {
    let values = "";
    let keys = "";
    for (let [key, value] of Object.entries(newPartnerOrganisation)) {
      keys = keys + `${key},`;
      values = values + `'${value}',`;
    }
    values = values.substring(0, values.length - 1);
    keys = keys.substring(0, keys.length - 1);
    let newPartnerOrganisationsQuery = `insert into organisations (${keys}) values (${values})`;
    newPartnerOrganisationsQueries.push(newPartnerOrganisationsQuery);
  }
  return newPartnerOrganisationsQueries;
};

const cardDetailsQueryBuilder = (cardDetails) => {
  let cardsInsertQueries = [];
  cardDetails.forEach((card, index, array) => {
    let cardValues = "";
    let cardKeys = "";
    let subTopicsInsertQueries = [];
    for (let [key, value] of Object.entries(card)) {
      if (key === "subTopics" && value) {
        card.subTopics.forEach((subTopic, index1, array1) => {
          let subTopicValues = "";
          let subTopicKeys = "";
          for (let [key1, value1] of Object.entries(subTopic)) {
            subTopicValues += `'${value1}',`;
            subTopicKeys += `${key1},`;
          }
          subTopicValues = subTopicValues.substring(
            0,
            subTopicValues.length - 1
          );
          subTopicKeys = subTopicKeys.substring(0, subTopicKeys.length - 1);
          let subTopicInsertQuery = `insert into project_cards_sub_topics(${subTopicKeys},cardId, projectId) values(${subTopicValues}, @cardId, @pId)`;
          subTopicsInsertQueries.push(subTopicInsertQuery);
        });
        continue;
      }
      cardValues += `'${value}',`;
      cardKeys += `${key},`;
    }
    cardValues = cardValues.substring(0, cardValues.length - 1);
    cardKeys = cardKeys.substring(0, cardKeys.length - 1);
    let cardInsertQuery = [
      `insert into project_cards(${cardKeys}, projectId) values(${cardValues}, @pId)`,
    ];
    cardInsertQuery.push("SELECT LAST_INSERT_ID() INTO @cardId");
    if (subTopicsInsertQueries) {
      cardInsertQuery.push(...subTopicsInsertQueries);
    }
    cardsInsertQueries.push(JSON.stringify(cardInsertQuery));
  });
  return cardsInsertQueries;
};

const phaseStatusQueryBuilder = (phaseStatus) => {
  let phaseStatusQuery = [];
  phaseStatus.forEach((phase, index, array) => {
    let phaseKeys = "";
    let phaseValues = "";
    for (let [key, value] of Object.entries(phase)) {
      phaseKeys += `${key},`;
      phaseValues += `'${value}',`;
    }
    phaseValues = phaseValues.substring(0, phaseValues.length - 1);
    phaseKeys = phaseKeys.substring(0, phaseKeys.length - 1);
    phaseStatusQuery.push(
      `insert into project_phase_status(${phaseKeys}, projectId) values(${phaseValues}, @pId)`
    );
  });
  return phaseStatusQuery;
};

const projectInsertQueryBuilder = (projectDetails) => {
  let values = "";
  let keys = "";
  for (let [key, value] of Object.entries(projectDetails)) {
    if (
      key === "projectPartner" ||
      key === "phaseStatus" ||
      key === "benefit" ||
      key === "organisationId"
    ) {
      continue;
    }
    keys = keys + `${key},`;
    values = values + `"${value}",`;
  }
  values = values.substring(0, values.length - 1);
  keys = keys.substring(0, keys.length - 1); //, projectPartner, organisationId
  let projectInsertQuery = `insert into project (${keys}, images, benefit) values (${values}, @projectImages, @projectBenefits)`; //, @projectPartner, @organisationId
  return projectInsertQuery;
};

const updateProjectQueryBuilder = (projectDetails, images) => {
  let keyValueStr = "";
  for (let [key, value] of Object.entries(projectDetails)) {
    if (
      key === "phaseStatus" ||
      key === "benefit" ||
      key === "projectId" ||
      key === "projectPartner"
    )
      continue;
    keyValueStr += `${key}="${value}",`; // key = "value"
  }
  keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);

  let updateProjectQuery = `update project set ${keyValueStr}, images = ? where projectId = ? and isDeleted = false`;
  return updateProjectQuery;
};

const updatePhaseStatusQuery = (phaseStatus) => {
  let updatePhaseQueries = [];
  phaseStatus.forEach((phaseStateObject, i, array) => {
    let updatePhaseQuery = "";
    if (phaseStateObject.id) {
      if (phaseStateObject.isDeleted) {
        //delete
        updatePhaseQuery = `update project_phase_status set isDeleted = true where id = ${phaseStateObject.id} and projectId = @pId and isDeleted is false`;
      } else {
        //update
        let keyValueStr = "";
        for (let [key, value] of Object.entries(phaseStateObject)) {
          if (key === "id" || key === "isDeleted") continue;
          keyValueStr += `${key}="${value}",`;
        }
        keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);
        updatePhaseQuery = `update project_phase_status set ${keyValueStr} where projectId = @pId and id = ${phaseStateObject.id} and isDeleted is false`;
      }
    } else {
      // add
      updatePhaseQuery = this.phaseStatusQueryBuilder([phaseStateObject])[0];
    }
    updatePhaseQueries.push(updatePhaseQuery);
  });
  return updatePhaseQueries;
};

const updateCardDetails = (cardDetails) => {
  let updateCardQueriesResult = [];
  cardDetails.forEach((card, index, arr) => {
    let updateCardQueries = [];
    let updateSubTopicQueries = [];
    if (card.cardId) {
      if (card.isDeleted) {
        // delete
        let updateCardQuery = `update project_cards set isDeleted = true where cardId = ${card.cardId} and isDeleted is false`;
        let updateSubTopicQuery = `update project_cards_sub_topics set isDeleted = true where cardId = ${card.cardId} and isDeleted is false`;
        updateCardQueries.push(updateCardQuery, updateSubTopicQuery);
      } else {
        // update
        let keyValueStr = "";
        for (let [key, value] of Object.entries(card)) {
          if (key === "cardId" || key === "isDeleted") continue;
          else if (key === "subTopics" && value) {
            card.subTopics.forEach((subTopic, i, array) => {
              if (subTopic.topicId) {
                if (subTopic.isDeleted) {
                  // delete
                  updateSubTopicQueries.push(
                    `update project_cards_sub_topics set isDeleted = true where topicId = ${subTopic.topicId} and isDeleted is false and cardId = ${card.cardId} and projectId = @pId`
                  );
                } else {
                  // update
                  let subTopickeyValueStr = "";
                  for (let [key1, value1] of Object.entries(subTopic)) {
                    if (key1 === "topicId" || key1 === "isDeleted") continue;
                    subTopickeyValueStr += `${key1}='${value1}',`;
                  }
                  subTopickeyValueStr = subTopickeyValueStr.substring(
                    0,
                    subTopickeyValueStr.length - 1
                  );
                  updateSubTopicQueries.push(
                    `update project_cards_sub_topics set ${subTopickeyValueStr} where topicId = ${subTopic.topicId} and cardId = ${card.cardId} and isDeleted is false and projectId = @pId`
                  );
                }
              } else {
                // add
                let subTopicValues = "";
                let subTopicKeys = "";
                for (let [key1, value1] of Object.entries(subTopic)) {
                  subTopicValues += `'${value1}',`;
                  subTopicKeys += `${key1},`;
                }
                subTopicValues = subTopicValues.substring(
                  0,
                  subTopicValues.length - 1
                );
                subTopicKeys = subTopicKeys.substring(
                  0,
                  subTopicKeys.length - 1
                );
                updateSubTopicQueries.push(
                  `insert into project_cards_sub_topics(${subTopicKeys}, cardId, projectId) values(${subTopicValues}, ${card.cardId}, @pId)`
                );
              }
            });
            continue;
          } else if (key === "subTopics" && !value) {
            continue;
          }
          keyValueStr += `${key}='${value}',`;
        }
        keyValueStr = keyValueStr.substring(0, keyValueStr.length - 1);
        let updateCardQuery = `update project_cards set ${keyValueStr} where cardId = ${card.cardId} and projectId = @pId and isDeleted is false`;
        updateCardQueries.push(updateCardQuery, ...updateSubTopicQueries);
      }
    } else {
      updateCardQueries = JSON.parse(cardDetailsQueryBuilder([card])[0]);
    }
    updateCardQueriesResult.push(JSON.stringify(updateCardQueries));
  });
  return updateCardQueriesResult;
};

module.exports = {
  addSurveyAnswersQueryBuilder,
  adminEditReDevQueryBuilder,
  insertBusinessProfileQueryBuilder,
  insertLinksQueryBuilder,
  updateBusinessProfileQueryBuilder,
  updateLinksQueryBuilder,
  newOrganisationQueryBuilder,
  newPartnerOrganisationsQueryBuilder,
  cardDetailsQueryBuilder,
  phaseStatusQueryBuilder,
  projectInsertQueryBuilder,
  updateProjectQueryBuilder,
  updatePhaseStatusQuery,
  updateCardDetails,
};
