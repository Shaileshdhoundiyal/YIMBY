const express = require("express");
const {
  signupController,
  loginController,
  addNighboursQuestionAnswerController,
  forgetPasswordController,
  updatePushTokenController,
  dashBoardController,
  adminController,
  userController,
  projectController,
  docuSignController,
  commonController,
  businessController,
  getProjectDetailController,
  addCommentOnProjectController,
  addLikesOnProjectController,
  getCommentController,
  volunteerAndRefer,
  pushNotificationController,
  cardsController,
  reportController,
  stateController,
  notificationController,
  emailController,
  reportListController,
  okToContactController,
} = require("../controllers");
const router = express.Router();
const { addDescription } = require("../utils/description.util");
const { AuthenticateUser } = require("../middlewares");
router.post("/neighbours-signup", signupController.neighbourSignup);
router.post("/login", loginController.login);
router.post(
  "/addNeighboursQuestionAnswers",

  addNighboursQuestionAnswerController.addNeighboursQuestionAnswers
);
router.post(
  "/real-estate-developer-signup",

  signupController.realEstateDevSignUp
);
router.post("/editNeighboursProfile", userController.editNeighboursProfile);
router.post("/editUserProfile", userController.editUserProfile);

router.post("/adminSignup", adminController.adminSignup);
router.post(
  "/forgotPasswordStep1",
  forgetPasswordController.forgotPasswordStep1
);
router.post(
  "/forgotPasswordStep2",
  forgetPasswordController.forgotPasswordStep2
);
router.post("/updatePushToken", updatePushTokenController.updatePushToken);
router.post(
  "/editNeighboursNotificationSettings",

  dashBoardController.editNeighboursNotificationSettings
);
router.post(
  "/editREDeveloperNotificationSettings",

  dashBoardController.editREDeveloperNotificationSettings
);
router.post("/saveEmail", loginController.saveEmail);
router.post("/addReUser", adminController.addReUser);

router.post("/docuSign", docuSignController.docuSign);
router.post(
  "/editREDeveloperProfile",
  dashBoardController.editREDeveloperProfile
);
router.post("/getReUser", adminController.getReUser);
router.post("/updateMyPassword", commonController.updateMyPassword);
router.post("/addBusinessProfile", businessController.addBusinessProfile);
router.post("/editBusinessProfile", businessController.editBusinessProfile);
router.post("/create_new_project", projectController.addProjectRequest);
router.post("/updateProject", projectController.updateProjectRequest);

router.get("/getNotificationList", commonController.getNotificationList);
router.get("/logout", loginController.logout);
router.get("/getJWTtoken", AuthenticateUser.getJwtToken);
router.get("/getUserProfile", userController.getUserProfile);
router.get(
  "/getNearByProjectOffline",
  getProjectDetailController.getNearByProjectOffline
);
router.get("/getMyProject", getProjectDetailController.getMyProject);
router.delete("/deleteAccount", userController.deleteAccount);
router.post("/projectCardsVoting", projectController.projectCardsVoting);

router.post(
  "/addBeHeardComments",
  addCommentOnProjectController.addBeHeardComments
);
router.post(
  "/showBeHeardComments",
  addCommentOnProjectController.showBeHeardComments
);
router.post(
  "/replyBeHeardComments",
  addCommentOnProjectController.replyBeHeardComments
);
router.post("/getReUser", adminController.getReUser);
router.post("/updateMyPassword", commonController.updateMyPassword);
router.post("/addBusinessProfile", businessController.addBusinessProfile);
router.post("/editBusinessProfile", businessController.editBusinessProfile);
router.get("/getNotificationList", commonController.getNotificationList);
router.get("/.well-known/assetlinks.json", (req, res) => {
  const asset = require("../auth_config.json");
  res.json(asset);
});
router.post("/updateProject", projectController.updateProject);
router.post("/confirm-otp", signupController.confirmOtp);
router.get("/neighbourSignStatus", docuSignController.neighbourSignStatus);
router.get(
  "/getUserNotificationSettings",
  commonController.getUserNotificationSettings
);

router.get(
  "/getProjectByProjectIdForREDeveloper",
  getProjectDetailController.getProjectByProjectIdForREDeveloper
);
router.get("/getNearByProjects", getProjectDetailController.getNearByProject);
router.get(
  "/getProjectByProjectIdForNeighbours",
  getProjectDetailController.getProjectByProjectIdForNeighbours
);

router.post(
  "/addCommentsOnProjectCardSubTopic",
  addCommentOnProjectController.addCommentsOnProjectCardSubTopic
);

router.post(
  "/addLikesOnProjectCardSubTopic",
  addLikesOnProjectController.addLikesOnProjectCardSubTopic
);

router.get(
  "/getCommentsBySubTopicId",
  getCommentController.getCommentsBySubTopicId
);

router.get("/commentsInNotif", getCommentController.commentsInNotif);

router.post("/referToFriend", volunteerAndRefer.referToFriend);

router.post("/volunteerForProject", volunteerAndRefer.volunteerForProject);

router.post("/isViewed", projectController.isViewed);

router.post(
  "/replyToProjectComment",
  addCommentOnProjectController.replyToProjectComment
);

router.get(
  "/getCommentsBySubTopicId",
  getCommentController.getCommentsBySubTopicId
);

router.get(
  "/getProjectVotingResultByProjectId",
  getProjectDetailController.getProjectVotingResultByProjectId
);
router.get(
  "/getCommentsBySubTopicId",
  getCommentController.getCommentsBySubTopicId
);

router.post("/addDeviceToken", pushNotificationController.addDeviceToken);

router.get("/getMyActivities", commonController.getMyActivities);

router.get(
  "/reviewYourCommentByProjectId",
  getCommentController.YourCommentByProjectIdreview
);

router.post("/feedback", addCommentOnProjectController.feedBack);

router.post(
  "/editDeleteMessage",
  addCommentOnProjectController.editDeleteMessage
);

router.post(
  "/updateProjectPhaseStatus",
  projectController.updateProjectPhaseStatus
);

router.get("/getBusinessProfile", businessController.getBusinessProfile);

router.get("/getMessageList", getCommentController.getMessagesList);

router.post("/deleteProject", projectController.deleteProject);

router.get("/getAllCards", cardsController.getAllCards);

router.post("/createNewCard", cardsController.createCard);

router.get("/getProjectCards/:id", cardsController.getProjectCards);

router.get("/getCard", cardsController.getCard);

router.delete("/deleteProjectCard/:id", cardsController.DeleteProjectCard);

router.delete(
  "/deleteAllProjectsCards/:id",
  cardsController.DeleteAllProjectsCards
);

router.patch("/updateCard", cardsController.updateCard);

router.post("/editUserProfile", userController.editUserProfile);

router.get("/getUsers", adminController.getUsers);

router.get("/getUserDetail", adminController.getUserDetail);
router.post("/updateTheme", userController.updateTheme);
router.post("/updateNotification", userController.updateNotification);
router.get("/requests", adminController.requestListing);
router.post("/approveRequest", adminController.approveRequest);
router.post("/rejectRequest", adminController.rejectRequest);
router.get("/getRequestDetail", adminController.getRequestDetail);
router.get("/neighboursForDev", reportController.getNeighboursForDev);
router.get("/neighboursForAdmin", reportController.getNeighboursForAdmin);
router.get("/getStates", stateController.getStates);
router.post("/getCities", stateController.getCities);
router.get("/reportList", reportListController.reportList);
router.post("/sendNotification", notificationController.sendNotification);
router.post("/setDeviceToken", userController.setDeviceToken);
// router.get("/adminDashboard", dashBoardController.adminDashboard);
// router.get("/developerDashboard", dashBoardController.developerDashboard);
router.get("/dashboard", dashBoardController.dashBoard);
router.get("/projectsForDashboard", dashBoardController.projectsForDashboard);
router.get("/usersForDashboard", dashBoardController.usersForDashboard);
router.get("/requestForDashboard", dashBoardController.requestForDashboard);
router.post("/resendOtp", signupController.resendOTP);
router.get("/getProjectWithComments", projectController.getProjectWithComments);
router.get("/getCardWithComments", projectController.getCardWithComments);
router.post("/okToContact", okToContactController.okToContact);
router.post("/suspendUser", adminController.suspendUser);
router.post("/unSuspendUser", adminController.unSuspendUser);
router.get("/defaultCards", cardsController.getAllDefaultCardList);
router.get(
  "/showCommentReplies",
  addCommentOnProjectController.showCommentRplies
);
router.post("/setIsViewed", notificationController.setIsViewed);
router.get("/getAllRequests", commonController.getPreviousRequest);
router.post("/addDescription", addDescription);

module.exports = router;
