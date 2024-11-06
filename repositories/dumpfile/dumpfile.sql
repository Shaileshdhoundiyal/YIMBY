CREATE DATABASE  IF NOT EXISTS `yimbyqadb`;
USE `yimbyqadb`;
DROP TABLE IF EXISTS `admins`;
CREATE TABLE `admins` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) DEFAULT NULL,
  `surName` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` text NOT NULL,
  `profilePhoto` varchar(45) DEFAULT NULL,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isActive` tinyint(1) DEFAULT '1',
  `lastLoggedAt` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `userType` varchar(10) DEFAULT 'admin',
  PRIMARY KEY (`userId`)
);




DROP TABLE IF EXISTS `card_comment`;
CREATE TABLE `card_comment` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `cardId` int NOT NULL,
  `comment` text,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`commentId`)
);


DROP TABLE IF EXISTS `device_token`;
CREATE TABLE `device_token` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `userType` varchar(45) DEFAULT NULL,
  `deviceToken` text NOT NULL,
  `deviceType` varchar(45) NOT NULL,
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `platformEndpoint` text,
  `deviceId` varchar(255) DEFAULT NULL,
  `versionInfo` varchar(45) DEFAULT NULL,
  `senderId` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `deviceId_UNIQUE` (`deviceId`),
  UNIQUE KEY `senderId_UNIQUE` (`senderId`)
) ;


DROP TABLE IF EXISTS `envelope_details`;
CREATE TABLE `envelope_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `envelopeId` varchar(45) NOT NULL,
  `createdAt` timestamp(3) NOT NULL,
  `modifiedAt` timestamp(3) NOT NULL,
  `expireDateTime` timestamp(3) NOT NULL,
  `completedDateTime` timestamp(3) NULL DEFAULT NULL,
  `initialSentDateTime` timestamp(3) NOT NULL,
  `statusChangedDateTime` timestamp(3) NOT NULL,
  `certificateUri` text,
  `envelopeUri` text,
  `notificationUri` text,
  `recipientsUri` text,
  `re_docusignAccountId` varchar(45) NOT NULL,
  `re_email` varchar(255) DEFAULT NULL,
  `re_docusignUserId` varchar(45) DEFAULT NULL,
  `signingLocation` varchar(45) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `projectId` int NOT NULL,
  `re_dev_Id` int NOT NULL,
  `neighbour_Id` int NOT NULL,
  `viewUrlCreatedAt` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `envelopePdfKey` varchar(100) DEFAULT NULL,
  `envelopePdfUrl` text,
  `certificatePdfkey` varchar(100) DEFAULT NULL,
  `certificatePdfUrl` text,
  `documentId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

DROP TABLE IF EXISTS `neighbour_survey_answers`;
CREATE TABLE `neighbour_survey_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `questionId` int DEFAULT NULL,
  `answer` text,
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

DROP TABLE IF EXISTS `neighbours`;
CREATE TABLE `neighbours` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255)  NOT NULL,
  `surName` varchar(255)  DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` text ,
  `address` text ,
  `latitude` decimal(9,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  `zipCode` varchar(255) DEFAULT NULL,
  `profile` varchar(255) DEFAULT NULL,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `loginAttempts` int NOT NULL DEFAULT (0),
  `lastLoggedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `isNewProjectsYourArea` tinyint(1) DEFAULT '1',
  `isUpdatesProjectYourArea` tinyint(1) DEFAULT '1',
  `isCommentApprovals` tinyint(1) DEFAULT '1',
  `isResponsesYourComments` tinyint(1) DEFAULT '1',
  `isReceiveEmails` tinyint(1) DEFAULT '1',
  `isCommentApprovalByEmail` tinyint(1) DEFAULT '1',
  `isResponsesYourCommentsByEmail` tinyint(1) DEFAULT '1',
  `isNewDevelopments` tinyint(1) DEFAULT '1',
  `isFeatureUpdates` tinyint(1) DEFAULT '1',
  `isAboutYimby` tinyint(1) DEFAULT '1',
  `isAccountSecurity` tinyint(1) DEFAULT '1',
  `questions` text,
  `isThemesMode` enum('Light Mode','Dark Mode','Follow the system')  NOT NULL DEFAULT 'Follow the system',
  `otp` varchar(6) DEFAULT NULL,
  `otpExpireAt` timestamp(3) NULL DEFAULT NULL,
  PRIMARY KEY (`userId`)
);

DROP TABLE IF EXISTS `neighbours_activities`;
CREATE TABLE `neighbours_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `myId` int DEFAULT NULL,
  `event` text,
  `activityType` varchar(255) NOT NULL,
  `re_developerId` int DEFAULT NULL,
  `projectId` int DEFAULT NULL,
  `commentId` int DEFAULT NULL,
  `replyId` int DEFAULT NULL,
  `isNew` tinyint(1) DEFAULT '1',
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isDeleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `myIdForNeighboursActivites` (`myId`),
  KEY `replyIdForNeighbours_activites` (`replyId`),
  KEY `projectId` (`projectId`),
  KEY `re_developerIdForActivities` (`re_developerId`)
) ;

DROP TABLE IF EXISTS `organisations`;
CREATE TABLE `organisations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `coverImage` varchar(255) DEFAULT NULL,
  `description` text,
  `icon` varchar(255) DEFAULT NULL,
  `isDeleted` tinyint NOT NULL DEFAULT '0',
  `isFullInfo` tinyint DEFAULT '0',
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `organisation_links`;
CREATE TABLE `organisation_links` (
  `id` int NOT NULL AUTO_INCREMENT,
  `twitter` varchar(255) DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `linkedIn` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `instagram` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `organisationId` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `organisationIdFK_idx` (`organisationId`),
  CONSTRAINT `organisationIdFK` FOREIGN KEY (`organisationId`) REFERENCES `organisations` (`id`)
);DROP TABLE IF EXISTS `re_developer`;
CREATE TABLE `re_developer` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) DEFAULT NULL,
  `surName` varchar(255) DEFAULT NULL,
  `email` varchar(255)  NOT NULL,
  `password` text,
  `profilePhoto` text ,
  `organisationId` int DEFAULT NULL,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `loginAttempts` int NOT NULL DEFAULT '0',
  `lastLoggedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `isNewResponsesByProject` tinyint(1) DEFAULT '1',
  `isYimbyUpdates` tinyint(1) DEFAULT '1',
  `isReceiveEmails` tinyint(1) DEFAULT '1',
  `isNewFeedbackByProject` tinyint(1) DEFAULT '1',
  `isProjectSummaries` enum('Monthly','Daily','Fortnightly','Weekly')  NOT NULL DEFAULT 'Weekly',
  `isProjectStatusChangeByTeam` tinyint(1) DEFAULT '1',
  `isFeatureUpdates` tinyint(1) DEFAULT '1',
  `isNewsAboutYimby` tinyint(1) DEFAULT '1',
  `isProjectCompletion` tinyint(1) DEFAULT '1',
  `isAccountOrSecurityIssues` tinyint(1) DEFAULT '1',
  `phoneNumber` varchar(45) DEFAULT NULL,
  `organisationName` varchar(255) DEFAULT NULL,
  `isDeleted` tinyint DEFAULT '0',
  PRIMARY KEY (`userId`)
) ;

DROP TABLE IF EXISTS `project`;
CREATE TABLE `project` (
  `projectId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectType` varchar(255) DEFAULT NULL,
  `projectName` varchar(255)  DEFAULT NULL,
  `projectAddress` text ,
  `zipCode` varchar(255)  DEFAULT NULL,
  `projectStatus` enum('draft','active','completed')  NOT NULL DEFAULT 'active',
  `phaseStatus` json DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `buidlingHeight` varchar(255) DEFAULT NULL,
  `propertySize` varchar(255) DEFAULT NULL,
  `floorPlan` varchar(255) DEFAULT NULL,
  `residentialUnits` varchar(255) DEFAULT NULL,
  `maximumCapacity` varchar(255) DEFAULT NULL,
  `thisProjectNumberLikes` varchar(255)  DEFAULT '0',
  `thisProjectNumberLikedUserIds` json DEFAULT NULL,
  `projectDescription` text ,
  `projectDescriptionLikes` varchar(255)  DEFAULT '0',
  `projectDescriptionLikedUserIds` json DEFAULT NULL,
  `presentationVideo` text,
  `benefit` json DEFAULT NULL,
  `benefitLikes` varchar(255)  DEFAULT '0',
  `benefitLikedUserIds` json DEFAULT NULL,
  `coverImage` text,
  `userType` enum('neighbours','re_developer') NOT NULL,
  `views` varchar(255)  DEFAULT '0',
  `viewedUserId` json DEFAULT NULL,
  `isInDraft` tinyint(1) DEFAULT '1',
  `projectPartner` json DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `organisationId` int DEFAULT NULL,
  `images` json DEFAULT NULL,
  `buildingHeight` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`projectId`),
  KEY `projectUserId` (`userId`),
  KEY `deleteIndex` (`isDeleted`),
  CONSTRAINT `projectUserId` FOREIGN KEY (`userId`) REFERENCES `re_developer` (`userId`)
) ;
DROP TABLE IF EXISTS `project_static_cards`;
CREATE TABLE `project_static_cards` (
  `staticCardId` int NOT NULL AUTO_INCREMENT,
  `cardTitle` varchar(255)  DEFAULT NULL,
  `cardIcon` text ,
  `cardDescription` text ,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`staticCardId`)
) ;

DROP TABLE IF EXISTS `cards`;
CREATE TABLE `cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `cardTitle` varchar(255)  DEFAULT NULL,
  `cardIcon` text ,
  `cardDescription` text ,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    KEY `cardUserId` (`userId`),
    CONSTRAINT `cardUserId` FOREIGN KEY (`userId`) REFERENCES `re_developer` (`userId`),
  PRIMARY KEY (`id`)
) ;


DROP TABLE IF EXISTS `project_cards`;
CREATE TABLE `project_cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cardId` int DEFAULT NULL,
  `projectId` int NOT NULL,
  `isDeleted` tinyint(1) DEFAULT (0),
  `cardAgreeCount` int DEFAULT (0),
  `cardDisAgreeCount` int DEFAULT (0),
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `projectIdForProject_Cards` (`projectId`),
  KEY `cardId` (`cardId`),
  CONSTRAINT `project_cards_ibfk_1` FOREIGN KEY (`cardId`) REFERENCES `cards` (`id`),
  CONSTRAINT `projectIdForProject_Cards` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
) ;

DROP TABLE IF EXISTS `be_heard_comments`;
CREATE TABLE `be_heard_comments` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int DEFAULT NULL,
  `cardId` int NOT NULL,
  `comment` text,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isViewed` tinyint DEFAULT '0',
  PRIMARY KEY (`commentId`),
  KEY `be_heard_commentUserId` (`userId`),
  KEY `be_heard_commentProjectId` (`projectId`),
  KEY `cardId` (`cardId`),
  CONSTRAINT `be_heard_commentProjectId` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`),
  CONSTRAINT `be_heard_comments_ibfk_2` FOREIGN KEY (`cardId`) REFERENCES `cards` (`id`),
  CONSTRAINT `be_heard_commentUserId` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`)
);

DROP TABLE IF EXISTS `project_cards_sub_topics`;
CREATE TABLE `project_cards_sub_topics` (
  `topicId` int NOT NULL AUTO_INCREMENT,
  `cardId` int NOT NULL,
  `projectId` int NOT NULL,
  `topicTitle` text ,
  `topicImage` text ,
  `topicDescription` text ,
  `topicLikesCount` int DEFAULT '0',
  `topicLikedUserIds` json DEFAULT NULL,
  `isDeleted` tinyint(1) DEFAULT (0),
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`topicId`),
  KEY `projectIdForProject_cards_sub_topics` (`projectId`),
  KEY `cardIdForProject_cards` (`cardId`),
  CONSTRAINT `cardIdForProject_cards` FOREIGN KEY (`cardId`) REFERENCES `project_cards` (`cardId`),
  CONSTRAINT `projectIdForProject_cards_sub_topics` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
);
DROP TABLE IF EXISTS `sub_topics_comments`;
CREATE TABLE `sub_topics_comments` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `topicId` int NOT NULL,
  `cardId` int NOT NULL,
  `projectId` int NOT NULL,
  `comment` text NOT NULL,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isDeleted` tinyint DEFAULT '0',
  `isViewed` tinyint DEFAULT '0',
  PRIMARY KEY (`commentId`),
  KEY `sectionIdForSection_comment` (`topicId`),
  KEY `projectIdForProject` (`projectId`),
  KEY `cardIdForcards` (`cardId`),
  KEY `userIdForNeighboursComment` (`userId`),
  CONSTRAINT `cardIdForcards` FOREIGN KEY (`cardId`) REFERENCES `project_cards` (`cardId`),
  CONSTRAINT `projectIdForProject` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`),
  CONSTRAINT `topicIdForSub_topics` FOREIGN KEY (`topicId`) REFERENCES `project_cards_sub_topics` (`topicId`),
  CONSTRAINT `userIdForNeighboursComment` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`)
) ;

DROP TABLE IF EXISTS `re_developer_activities`;
CREATE TABLE `re_developer_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `myId` int DEFAULT NULL,
  `event` text,
  `activityType` varchar(255) NOT NULL,
  `neighboursId` int DEFAULT NULL,
  `beHeardCommentId` int DEFAULT NULL,
  `topicCommentId` int DEFAULT NULL,
  `replyId` int DEFAULT NULL,
  `projectId` int DEFAULT NULL,
  `isNew` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isDeleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`,`activityType`),
  KEY `myIdForRe_developer_activities` (`myId`),
  KEY `neighboursIdForRe_developer_activites` (`neighboursId`),
  KEY `projectIdForRe_developer_activites` (`projectId`),
  KEY `commentIdForBeHeardCommentsCommentId` (`beHeardCommentId`),
  KEY `commentIdForProjectCardSubTopicCommentId` (`topicCommentId`),
  CONSTRAINT `commentIdForBeHeardCommentsCommentId` FOREIGN KEY (`beHeardCommentId`) REFERENCES `be_heard_comments` (`commentId`),
  CONSTRAINT `commentIdForProjectCardSubTopicCommentId` FOREIGN KEY (`topicCommentId`) REFERENCES `sub_topics_comments` (`commentId`),
  CONSTRAINT `myIdForRe_developer_activities` FOREIGN KEY (`myId`) REFERENCES `re_developer` (`userId`),
  CONSTRAINT `neighboursIdForRe_developer_activites` FOREIGN KEY (`neighboursId`) REFERENCES `neighbours` (`userId`),
  CONSTRAINT `projectIdForRe_developer_activites` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
) ;


DROP TABLE IF EXISTS `commentreplies`;
CREATE TABLE `commentreplies` (
  `replyId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `userType` varchar(255) DEFAULT NULL,
  `projectId` int NOT NULL,
  `comment` text NOT NULL,
  `isDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `beHeardCommentId` int DEFAULT NULL,
  `subTopicCommentId` int DEFAULT NULL,
  `topicCommentId` int DEFAULT NULL,
  `neighbourId` int DEFAULT NULL,
  PRIMARY KEY (`replyId`),
  KEY `replyCommentProjectId` (`projectId`),
  KEY `replyCommentUserId` (`userId`),
  KEY `replyBeHeardCommentId_idx` (`beHeardCommentId`),
  KEY `replySubTopicCommentId_idx` (`subTopicCommentId`),
  CONSTRAINT `replyBeHeardCommentId` FOREIGN KEY (`beHeardCommentId`) REFERENCES `be_heard_comments` (`commentId`),
  CONSTRAINT `replyCommentProjectId` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`),
  CONSTRAINT `replyCommentUserId` FOREIGN KEY (`userId`) REFERENCES `re_developer` (`userId`),
  CONSTRAINT `replySubTopicCommentId` FOREIGN KEY (`subTopicCommentId`) REFERENCES `sub_topics_comments` (`commentId`)
);




DROP TABLE IF EXISTS `project_cards_statusmeter`;
CREATE TABLE `project_cards_statusmeter` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `cardsReviewedCount` int DEFAULT '0',
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `agreeCardIds` json DEFAULT NULL,
  `disAgreeCardIds` json DEFAULT NULL,
  `cardIds` longtext,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `projectId` (`projectId`),
  CONSTRAINT `project_cards_statusmeter_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`),
  CONSTRAINT `project_cards_statusmeter_ibfk_2` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
) ;


DROP TABLE IF EXISTS `project_images`;
CREATE TABLE `project_images` (
  `imageId` int NOT NULL AUTO_INCREMENT,
  `projectId` int NOT NULL,
  `image` text,
  `imageDescription` text,
  `imageLikesCount` int DEFAULT '0',
  `imageLikedUserIds` json NOT NULL,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `ModifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`imageId`),
  KEY `projectIdForProjectImages` (`projectId`),
  CONSTRAINT `projectIdForProjectImages` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
);

DROP TABLE IF EXISTS `project_phase_status`;
CREATE TABLE `project_phase_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `phaseName` varchar(100) DEFAULT NULL,
  `phaseBegins` timestamp(3) NULL DEFAULT NULL,
  `phaseEnds` timestamp(3) NULL DEFAULT NULL,
  `projectId` int NOT NULL,
  `isDeleted` tinyint DEFAULT '0',
  `isCompleted` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ;



DROP TABLE IF EXISTS `project_viewers`;
CREATE TABLE `project_viewers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `lastViewedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `viewedCount` int NOT NULL DEFAULT '1',
  `isResponded` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ;

DROP TABLE IF EXISTS `pushnotifications`;
CREATE TABLE `pushnotifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fromUserId` int DEFAULT NULL,
  `fromUserType` varchar(20) NOT NULL,
  `toUserId` int NOT NULL,
  `toUserType` varchar(20) NOT NULL,
  `activityId` int NOT NULL,
  `activityType` varchar(45) NOT NULL,
  `createdOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `projectId` int NOT NULL,
  `isViewed` tinyint DEFAULT '0',
  `message` text,
  `updateCount` int DEFAULT NULL,
  `commentType` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

DROP TABLE IF EXISTS `pushtokendetails`;
CREATE TABLE `pushtokendetails` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deviceId` text,
  `userId` int NOT NULL,
  `deviceType` varchar(255) DEFAULT NULL,
  `deviceToken` text,
  `fcmToken` text,
  `appVersion` int DEFAULT NULL,
  `createdAt` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `platformEndPoint` varchar(255) DEFAULT NULL,
  `userType` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userIdForPushTokendetails` (`userId`)
);


DROP TABLE IF EXISTS `referToFriend`;
CREATE TABLE `referToFriend` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `userType` varchar(20) NOT NULL,
  `emails` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;





DROP TABLE IF EXISTS `saveemails`;
CREATE TABLE `saveemails` (
  `id` int NOT NULL AUTO_INCREMENT,
  `emails` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `emails_UNIQUE` (`emails`)
) ;




DROP TABLE IF EXISTS `session`;
CREATE TABLE `session` (
  `userId` int NOT NULL,
  `token` text NOT NULL,
  `currentDeviceId` varchar(255) DEFAULT NULL,
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `userType` enum('neighbours','re_developer','admin')  NOT NULL,
  `isAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  KEY `userIdForRe_developerSession` (`userId`)
);


DROP TABLE IF EXISTS `templates`;
CREATE TABLE `templates` (
  `id` int NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `body` text NOT NULL,
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `temporary_session`;
CREATE TABLE `temporary_session` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `token` text NOT NULL,
  `userType` enum('neighbours','re_developer')  NOT NULL,
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `userIdForRe_developerTempSession` (`userId`)
) ;


DROP TABLE IF EXISTS `topics_comments`;
CREATE TABLE `topics_comments` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `cardId` int NOT NULL,
  `comment` text,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isViewed` tinyint DEFAULT '0',
  PRIMARY KEY (`commentId`)
) ;


DROP TABLE IF EXISTS `updates`;
CREATE TABLE `updates` (
  `updatesId` int NOT NULL AUTO_INCREMENT,
  `projectId` int NOT NULL,
  `updateTitle` text,
  `updateDescription` text,
  `updateMedia` json DEFAULT NULL,
  `updateCommentLikes` varchar(255) DEFAULT '0',
  `updateCommentLikedUserIds` text ,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`updatesId`),
  KEY `projectIdForUpdates` (`projectId`),
  CONSTRAINT `projectIdForUpdates` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
) ;

DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `userType` enum('neighbours','re_developer')  DEFAULT NULL,
  `projectId` int NOT NULL,
  `updatesId` int NOT NULL,
  `comment` text NOT NULL,
  `commentStatus` enum('approved','rejected')  DEFAULT 'rejected',
  `isDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedAt` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`commentId`),
  KEY `userIdForUpdatesComment` (`userId`),
  KEY `projectIdForUpdatesComment` (`projectId`),
  KEY `updatesIdForUpdatesComment` (`updatesId`),
  CONSTRAINT `projectIdForUpdatesComment` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`),
  CONSTRAINT `updatesIdForUpdatesComment` FOREIGN KEY (`updatesId`) REFERENCES `updates` (`updatesId`),
  CONSTRAINT `userIdForUpdatesComment` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`)
) ;
DROP TABLE IF EXISTS `userLocation`;
CREATE TABLE `userLocation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;


DROP TABLE IF EXISTS `volunteerForProject`;
CREATE TABLE `volunteerForProject` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `isVolunteer` tinyint DEFAULT '1',
  PRIMARY KEY (`id`)
) ;


DROP TABLE IF EXISTS `yimby_feedback`;
CREATE TABLE `yimby_feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `feedback` text,
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `userType` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

/*!50003 DROP PROCEDURE IF EXISTS `addBasicOrganisation` */;
DELIMITER ;;
CREATE PROCEDURE `addBasicOrganisation`(in _businessName VARCHAR(255), in _icon TEXT)
BEGIN
	if(exists(select * from organisations where name = _businessName)) then
		select false status, 'Business Profile already exists. Please keep a unique business profile name' message;
	else
		insert into organisations (name, icon) values (_businessName, _icon);
        select true status, last_insert_id() organisationId;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addbeHeardComment` */;
DELIMITER ;;
CREATE PROCEDURE `addbeHeardComment`(in uId int,in pId int,in cId int,in comments text, in commentType varchar(45))
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
		if(commentType = 'cardComment') then
			insert into `topics_comments` (userId,projectId,cardId,`comment`) values(uId,pId,cId,comments);
        else
			insert into `be_heard_comments` (userId,projectId,cardId,`comment`) values(uId,pId,cId,comments);
		end if;
		if exists(SELECT * FROM `re_developer` WHERE userId=(SELECT userId FROM `project` WHERE projectId=pId) and isReceiveEmails=1 and isNewFeedbackByProject=1) then
			SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, p.userId, 'subham@4screenmedia.com' as email /*re.email*/,p.projectName,concat(n.firstName,' ',n.surName) as userName, concat(re.firstName,' ',re.surName) as re_userName FROM `project` p JOIN `re_developer` re join `neighbours` n WHERE p.projectId=pId AND re.userId=(SELECT userId FROM `project` WHERE projectId=pId) and n.userId=uId;
            #SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, p.userId, 'subham@4screenmedia.com' as email,p.projectName,concat(n.firstName,' ',n.surName) as userName, concat(re.firstName,' ',re.surName) as re_userName FROM `project` p JOIN `re_developer` re join `neighbours` n WHERE p.projectId=pId AND re.userId=(SELECT userId FROM `project` WHERE projectId=pId) and n.userId=uId;
            select body from templates where id = 3;
		else
			SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
		end if;
	else
		select 'Project not found' as message;
	end if;
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addBusinessProfile` */;
DELIMITER ;;
CREATE PROCEDURE `addBusinessProfile`(in _insertOrgQuery text, in _insertLinkQuery text)
BEGIN
	set @insertOrgQuery = _insertOrgQuery;
    select replace(@insertOrgQuery, '\\', '') into @insertOrgQuery;
	PREPARE insertOrganisationQuery from @insertOrgQuery;
    EXECUTE insertOrganisationQuery;
    DEALLOCATE PREPARE insertOrganisationQuery;
    
	select last_insert_id() into @orgId;
    
    if(exists(select * from organisations where id = @orgId)) then
		if(_insertLinkQuery is not null) then
			set @insertLinkQuery = _insertLinkQuery;
			PREPARE insertLinksQuery from @insertLinkQuery;
			EXECUTE insertLinksQuery;
			DEALLOCATE PREPARE insertLinksQuery;
		end if;
        select 'success' as message;
	else
		select 'failed' as message;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addCommentsOnProject` */;

DELIMITER ;;
CREATE PROCEDURE `addCommentsOnProject`(in uId int,in uType varchar(30),in pId int, in commentText text,in updateId int)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = r.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) or EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
		INSERT INTO comments(userId,userType, projectId, `comment`,updatesId) VALUES(uId,uType, pId, commentText,updatesId);
		select 'Success' as message,LAST_INSERT_ID() as commentId,p.userId as projectUserId from project p where p.projectId=pId ;
	else
		SELECT 'Invalid Request' AS message;
	end if;
		
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addCommentsOnProjectCardSubTopic` */;

DELIMITER ;;
CREATE PROCEDURE `addCommentsOnProjectCardSubTopic`(in uId int,in pId int,in cId int,in topId int,in comments text)
BEGIN
	if exists(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId join `project_cards`pc on pc.projectId=p.projectId join `project_cards_sub_topics`st on pc.cardId=st.cardId WHERE p.projectId = pId AND p.isInDraft=0 AND p.isDeleted = 0 AND r.isActive = 1 and pc.projectId=pId and pc.cardId=cId and pc.isDeleted=0 and st.projectId=pId and st.cardId=cId and st.topicId=topId and st.isDeleted=0) THEN
		insert into `sub_topics_comments` (userId,topicId, cardId, projectId,`comment`)values(uId,topId, cId, pId, comments);
		#select 'Success' as message, last_insert_id() as commentId,userId from `project` where projectId=pId;
        if exists(SELECT * FROM `re_developer` WHERE userId=(SELECT userId FROM `project` WHERE projectId=pId) and isReceiveEmails=1 and isNewFeedbackByProject=1) then
			SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, p.userId, 'subham@4screenmedia.com' as email, /*re.email,*/p.projectName,concat(n.firstName,' ',n.surName) as userName, concat(re.firstName,' ',re.surName) as re_userName FROM `project` p JOIN `re_developer` re join `neighbours` n WHERE p.projectId=pId AND re.userId=(SELECT userId FROM `project` WHERE projectId=pId) and n.userId=uId;
			#SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, p.userId, 'subham@4screenmedia.com' as email,p.projectName,concat(n.firstName,' ',n.surName) as userName, concat(re.firstName,' ',re.surName) as re_userName FROM `project` p JOIN `re_developer` re join `neighbours` n WHERE p.projectId=pId AND re.userId=(SELECT userId FROM `project` WHERE projectId=pId) and n.userId=uId;
			select body from templates where id = 3;
		else
			SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
		end if;
	else 
		select'Invalid request' as message;
	end if;	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addDeviceToken` */;

DELIMITER ;;
CREATE PROCEDURE `addDeviceToken`(in _userId int, in _userType varchar(20), in _deviceToken text, in _deviceType varchar(20), in _endpointArn text, in _deviceId text, in _senderId varchar(50))
BEGIN
	if(_userType = 'neighbours') then 
    	if(exists(select * from device_token where deviceId = _deviceId and deviceType = _deviceType)) then
			update device_token set userId = _userId, deviceToken = _deviceToken, platformEndPoint = _endpointArn, userType = _userType where deviceId = _deviceId and deviceType = _deviceType;
		else 
			insert into device_token (userId, deviceToken, deviceType, platformEndPoint, userType, deviceId) values(_userId, _deviceToken, _deviceType, _endpointArn, _userType, _deviceId);
		end if;
    elseif(_userType = 're_developer') then
		if(exists(select * from device_token where senderId = _senderId and deviceType = _deviceType)) then
			update device_token set userId = _userId, deviceToken = _deviceToken, userType = _userType where senderId = _senderId and deviceType = _deviceType;
        else
			insert into device_token (userId, deviceToken, deviceType, userType, senderId) values(_userId, _deviceToken, _deviceType, _userType, _senderId);
        end if;
    end if;
    
    if(exists(select * from device_token where deviceToken = _deviceToken and userId = _userId and userType = _userType and deviceType = _deviceType)) then
		select true isAdded, deviceToken, deviceType, platformEndPoint, userId, userType, senderId from device_token where deviceToken = _deviceToken and userId = _userId and userType = _userType and deviceType = _deviceType;
	else
		select false isAdded, 'failed to add device token' message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addInPublishProject` */;

DELIMITER ;;
CREATE PROCEDURE `addInPublishProject`(in pId int,in uId int,in cImage text,in pType text,in pHeight varchar(255),in pSize varchar(255),in pFloorPlan varchar(255),in pUnits varchar(255),in maxCapacity varchar(255),in pDescription text, in pImage text,in pBenefit text,in pSection text,in pPartner text,in updatesTitle text,in updatesDecription text,in updatesMedia text )
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.userId=uId AND p.isDeleted = 0 AND r.isActive = 1) THEN
		#SELECT JSON_ARRAY_APPEND(updates,'$',CAST( yourUpdate AS JSON) )INTO @data FROM `project` WHERE projectId=pId ;
		#UPDATE `project` SET updates=@data, isInDraft=0 WHERE projectId=pId AND isDeleted=0;
		insert into `updates` (projectId,updateTitle,updateDescription,updateMedia,updateCommentLikes,updateCommentLikedUserIds)values(pId,updatesTitle,updatesDecription,updatesMedia,0,'[]');
		update `project` set coverImage=cImage, projectType=pType, buidlingHeight=pHeight, propertySize=pSize, floorPlan=pFloorPlan, residentialUnits=pUnits, maximumCapacity=maxCapacity, projectDescription=pDescription, projectImage=pImage, benefit=pBenefit, section=pSection, projectPartner=pPartner,isInDraft=0 where projectId=pId;
		SELECT 'Success'AS message,JSON_ARRAYAGG(n.userId) AS userIds FROM `neighbours` n JOIN `project` p ON p.zipCode=n.zipCode  WHERE n.isNewProjectsYourArea=1 AND n.isActive=1 AND p.projectId=pId;
	ELSE
		SELECT 'Invalid request' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addLikesOnProject` */;

DELIMITER ;;
CREATE PROCEDURE `addLikesOnProject`(in likedUserId text,in pId int,in likeType varchar(255))
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
		if likeType='thisProjectNumberLikes'then
			SELECT JSON_CONTAINS((SELECT thisProjectNumberLikedUserIds FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(json_quote(likedUserId) AS json),'$')INTO @result;
			IF @result=0 THEN	
				UPDATE `project`p SET p.thisProjectNumberLikes=p.thisProjectNumberLikes+1, p.thisProjectNumberLikedUserIds=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(thisProjectNumberLikedUserIds,'$',CAST(likedUserId AS char))FROM `project` WHERE projectId=pId) AS userIds) WHERE p.projectId=pId; 
				select 'Liked' as message;
			else
				UPDATE  `project`p SET p.thisProjectNumberLikes=p.thisProjectNumberLikes-1, p.thisProjectNumberLikedUserIds= JSON_REMOVE(thisProjectNumberLikedUserIds,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT thisProjectNumberLikedUserIds FROM project WHERE projectId=pId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE projectId=pId;
				select 'unLiked' as message;
			END IF;
		elseif likeType='projectDescriptionLikes'then
			SELECT JSON_CONTAINS((SELECT projectDescriptionLikedUserIds FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(JSON_QUOTE(likedUserId) AS JSON),'$')INTO @result;
			IF @result=0 THEN	
				UPDATE `project`p SET p.projectDescriptionLikes=p.projectDescriptionLikes+1, p.projectDescriptionLikedUserIds=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(projectDescriptionLikedUserIds,'$',CAST(likedUserId AS char))FROM `project` WHERE projectId=pId) AS userIds) WHERE p.projectId=pId; 
				select 'Liked'as message;
			ELSE
				UPDATE  `project`p SET p.projectDescriptionLikes=p.projectDescriptionLikes-1, p.thisProjectNumberLikedUserIds= JSON_REMOVE(thisProjectNumberLikedUserIds,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT projectDescriptionLikedUserIds FROM project WHERE projectId=pId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE projectId=pId;
				select'unLiked'as message;
			END IF;
		elseif likeType='benefitLikes'then
			SELECT JSON_CONTAINS((SELECT benefitLikedUserIds FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(JSON_QUOTE(likedUserId) AS JSON),'$')INTO @result;
				IF @result=0 THEN	
					UPDATE `project`p SET p.benefitLikes=p.benefitLikes+1, p.benefitLikedUserIds=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(benefitLikedUserIds,'$',CAST(likedUserId AS char))FROM `project` WHERE projectId=pId) AS userIds) WHERE p.projectId=pId; 
					select 'Liked'as message;
				ELSE
					UPDATE  `project`p SET p.benefitLikes=p.benefitLikes-1, p.benefitLikedUserIds= JSON_REMOVE(benefitLikedUserIds,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT benefitLikedUserIds FROM project WHERE projectId=pId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE projectId=pId;
					select'unLiked'as message;
				END IF;
		/*elseif likeType='sectionLikes'then
			SELECT JSON_CONTAINS((SELECT sectionLikedUserIds FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(JSON_QUOTE(likedUserId) AS JSON),'$')INTO @result;
				IF @result=0 THEN	
					UPDATE `project`p SET p.sectionLikes=p.sectionLikes+1, p.sectionLikedUserIds=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(sectionLikedUserIds,'$',CAST(likedUserId AS char))FROM `project` WHERE projectId=pId) AS userIds) WHERE p.projectId=pId; 
					SELECT 'Liked'AS message;
				ELSE
					UPDATE  `project`p SET p.sectionLikes=p.sectionLikes-1, p.sectionLikedUserIds= JSON_REMOVE(sectionLikedUserIds,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT sectionLikedUserIds FROM project WHERE projectId=pId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE projectId=pId;
					SELECT 'unLiked'AS message;
				END IF;*/
		end if;
	ELSE
		SELECT 'ProjectId not found' AS message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addLikesOnProjectCardSubTopic` */;

DELIMITER ;;
CREATE PROCEDURE `addLikesOnProjectCardSubTopic`(in likedUserId int,in pId int,in cId int,in tId int)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId JOIN `project_cards`pc ON pc.projectId=p.projectId JOIN `project_cards_sub_topics`st ON pc.cardId=st.cardId WHERE p.projectId = pId AND p.isInDraft=0 AND p.isDeleted = 0 AND r.isActive = 1 AND pc.projectId=pId AND pc.cardId=cId AND pc.isDeleted=0 AND st.projectId=pId AND st.cardId=cId AND st.topicId=tId AND st.isDeleted=0) THEN
		SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=pId AND cardId=cId AND topicId=tId INTO @topicLikedUserIdList;
		# SELECT JSON_CONTAINS((@topicLikedUserIdList ),CAST(Json_quote(likedUserId) AS json),'$')INTO @result;
        SELECT json_search(@topicLikedUserIdList, 'one', likedUserId) into @result;
			IF (@result is null) THEN	
				UPDATE `project_cards_sub_topics` SET topicLikesCount=topicLikesCount+1, topicLikedUserIds=(SELECT JSON_ARRAY_APPEND(@topicLikedUserIdList,'$',concat(likedUserId))) WHERE projectId=pId and cardId=cId and topicId=tId; 
				SELECT 'Liked' AS message;
			ELSE
				SELECT json_search(@topicLikedUserIdList, 'one', likedUserId) into @idx;
				UPDATE  `project_cards_sub_topics` SET topicLikesCount=topicLikesCount-1, topicLikedUserIds= (select json_remove(@topicLikedUserIdList, json_unquote(@idx))) WHERE projectId=pId AND cardId=cId AND topicId=tId;
				SELECT 'unLiked' AS message;
			END IF;
	else
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addLikesOnProjectImage` */;

DELIMITER ;;
CREATE PROCEDURE `addLikesOnProjectImage`(in likedUserId text,in url text,in pId int)
BEGIN
	
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
		select projectImage into @data from`project`where projectId=pId;
		SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT JSON_EXTRACT(@data, "$[*].imageUrl") AS `find_index`),'all',CAST(url AS CHAR)))into@indexValue;
		if @indexValue!= 'Null' then
			SELECT JSON_CONTAINS((@data),CAST(JSON_QUOTE(likedUserId) AS JSON),CONCAT(@indexValue,'.imageLikedUserId'))into @result;
			if @result=0 then
				SET @data= JSON_SET(@data, CONCAT(@indexValue,'.imageLikes'),(SELECT CAST((SELECT JSON_EXTRACT(@data,CONCAT(@indexValue,'.imageLikes'))+1) AS CHAR)));
				UPDATE project SET projectImage=(SELECT JSON_ARRAY_APPEND(@data,CONCAT(@indexValue,'.imageLikedUserId'),CAST(likedUserId AS CHAR)))WHERE projectId=pId;
				SELECT 'Liked' AS message;
			else
				SET @data=JSON_SET(@data, CONCAT(@indexValue,'.imageLikes'),(SELECT CAST((SELECT JSON_EXTRACT(@data,CONCAT(@indexValue,'.imageLikes'))-1) AS CHAR)));
				UPDATE project SET projectImage=JSON_REMOVE(@data,(SELECT INSERT((SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT JSON_EXTRACT(@data, CONCAT(@indexValue,'.imageLikedUserId'))),'all',CAST(likedUserId AS CHAR)))),1,1,CONCAT(@indexValue,'.imageLikedUserId'))))WHERE projectId=pId;
				SELECT 'unLiked' AS message;
			end if;
		else
			select 'Image not found' as message;
		end if;
	else
		select 'Project not found' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addLikesOnSectionTopic` */;

DELIMITER ;;
CREATE PROCEDURE `addLikesOnSectionTopic`(in likedUserId int,in pId int,in secId int)
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId Join `project_section` ps on ps.projectId=p.projectId  WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1 and ps.sectionId and ps.projectId=pId) THEN
		SELECT JSON_CONTAINS((SELECT sectionLikedUserId FROM`project_section`WHERE projectId=pId ),CAST(JSON_QUOTE(likedUserId) AS JSON),'$')INTO @result;
			IF @result=0 THEN	
				UPDATE `project_section` SET sectionLikes=sectionLikes+1, sectionLikedUserId=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(sectionLikedUserId,'$',CAST(likedUserId AS CHAR))FROM `project_section` WHERE projectId=pId) AS userIds) WHERE projectId=pId; 
				SELECT 'Liked' AS message;
			ELSE
				UPDATE  `project_section` SET sectionLikes=sectionLikes-1, sectionLikedUserId= JSON_REMOVE(sectionLikedUserId,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT sectionLikedUserId FROM `project_section` WHERE projectId=pId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE projectId=pId;
				SELECT 'unLiked' AS message;
			END IF;
	else
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addLikesOnUpdatesComment` */;

DELIMITER ;;
CREATE PROCEDURE `addLikesOnUpdatesComment`(in likedUserId text,in pId int,in updateId int)
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId join `updates` u on p.projectId=u.projectId WHERE p.projectId = pId and u.updatesId=updateId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
		SELECT JSON_CONTAINS((SELECT updateCommentLikedUserIds FROM`updates`WHERE projectId=pId and updatesId=updateId ),CAST(JSON_QUOTE(likedUserId) AS JSON),'$')INTO @result;
		IF @result=0 THEN	
			UPDATE `updates`u SET u.updateCommentLikes=u.updateCommentLikes+1, u.updateCommentLikedUserIds=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(updateCommentLikedUserIds,'$',CAST(likedUserId AS CHAR))FROM `updates` WHERE updatesId=updateId) AS userIds) WHERE u.projectId=pId and u.updatesId=updateId; 
			select 'Liked' as message;
		ELSE
			UPDATE  `updates`u SET u.updateCommentLikes=u.updateCommentLikes-1, u.updateCommentLikedUserIds= JSON_REMOVE(updateCommentLikedUserIds,(SELECT* FROM(SELECT JSON_UNQUOTE(JSON_SEARCH((SELECT updateCommentLikedUserIds FROM `updates` WHERE updatesId=updateId),'all',CAST(likedUserId AS CHAR))))AS removePath))WHERE u.projectId=pId AND u.updatesId=updateId; 
			select 'unLiked' as message;
		END IF;
	else
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `addSurveyQuestionsAnswers` */;

DELIMITER ;;
CREATE PROCEDURE `addSurveyQuestionsAnswers`(in survey_queries json, in _userId int)
BEGIN
	set @i = 0;
    if((select count(id) from neighbour_survey_answers where userId = _userId) >= 4) then
		select 'previously_answered' as message; 
    else
		while @i < json_length(survey_queries) do
			select JSON_EXTRACT(survey_queries, CONCAT('$[',@i,']')) INTO @singleQuery;
			select replace(@singleQuery, '\\', '') into @singleQuery;
			select trim('"' from @singleQuery) into @singleQuery;
			PREPARE insert_question_answer from @singleQuery;
			EXECUTE insert_question_answer;
			DEALLOCATE PREPARE insert_question_answer;
			SELECT @i + 1 INTO @i;
		end while;
        if((select count(id) from neighbour_survey_answers where userId = _userId) = 4) then
			select 'added' as message; 
        else 
			select 'failed' as message; 
        end if;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `adminAddReDeveloper` */;

DELIMITER ;;
CREATE PROCEDURE `adminAddReDeveloper`(in _firstName varChar(255), in _surname varchar(255), in _email text, in _userType varchar(20), in _organisationId int)
BEGIN
	if(_userType = 're_developer') then
		if(not exists(select * from organisations where id = _organisationId)) then
			select false isAdded, 'organisation not found' message;
		elseif(exists(select * from re_developer where email = _email and password is not null and isActive is true)) then
			select organisationId from re_developer where email = _email and password is not null and isActive is true into @organisationIds;
            if(@organisationId is null || @organisationId = '[]') then
				select concat('["',_organisationId,'"]') into @organisationIds;
                update re_developer set organisationId = @organisationIds where email = _email and password is not null and isActive is true;
            else
				SELECT JSON_ARRAY_APPEND(@organisationId,'$',concat(_organisationId)) into @organisationId;
                update re_developer set organisationId = @organisationIds where email = _email and password is not null and isActive is true;
            end if;
			select false isAdded, true isUserExists, 're_developer already exists and added to organisation' message;
		else 
			select concat('["',_organisationId,'"]') into @organisationIds;
			insert into re_developer (firstName, surName, email, organisationId) values (_firstName, _surName, _email, @organisationIds);
            select true isAdded, 're_developer added successfully' message;
			if(exists(select userId from re_developer where userId = last_insert_id() and password is null)) then
				select firstName, surName, 'subham@4screenmedia.com' email from re_developer where userId = last_insert_id() and password is null;
                select * from organisations where id = _organisationId;
                select * from templates where id = 4;
			else 
				select false isAdded, 'failed to add re_developer' message;
            end if;
		end if;
	else 
		select false isAdded, 'invalid user type' message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `adminDeleteAccounts` */;

DELIMITER ;;
CREATE PROCEDURE `adminDeleteAccounts`(in _neighboursIdStr text, in _re_developersIdStr text)
BEGIN
	update `neighbours` set isActive=0 where userId in (_neighboursIdStr);
	update `sub_topics_comments` set isDeleted=1 where userId in (_neighboursIdStr);
	delete from `session` where userId in (_neighboursIdStr) and userType='neighbour';
	delete from `temporary_session` where userId in (_neighboursIdStr) and userType='neighbour';
	delete from `pushtokendetails` where userId in (_neighboursIdStr);
	update `be_heard_comments` set isDeleted=1 where userId in (_neighboursIdStr);
	select 'Success' as message;
	
	update `re_developer` set isActive=0 where userId in (_re_developersIdStr);
	update `project` set isDeleted=1 where userId in (_re_developersIdStr);
	DELETE FROM `session` WHERE userId in (_re_developersIdStr) AND userType='re_developer';
	DELETE FROM `temporary_session` WHERE userId in (_re_developersIdStr) AND userType='re_developer';
	SELECT 'Success' AS message;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `adminEditUsers` */;

DELIMITER ;;
CREATE PROCEDURE `adminEditUsers`(in _editUserQuery Text, in _userId int, in _userType varchar(20), _email varchar(50))
BEGIN
	set @updateUser = _editUserQuery;
	if(_userType = 're_developer') then
		if(exists(select  * from re_developer where userId = _userId and isActive is true)) then
            if _email is not null then 
               if exists(select * from `re_developer` where email=_email and userId !=_userId and isActive=1) /*or exists(select * from `neighbours` where email=eId and isActive=1 )*/ then
				select 'Email already exist' as message;
                end if;
            else 
				PREPARE updateReDeveloper from @updateUser;
				EXECUTE	updateReDeveloper;
				DEALLOCATE PREPARE updateReDeveloper;
				select true isUpdated, 'User updated successfully' message;
			end if;
        else
			select false isUpdated, 'user not found' message;
        end if;
    elseif(_userType = 'neighbour') then
		if(exists(select * from neighbour where userId = _userId and isActive is true)) then
			PREPARE updateNeighbour from @updateUser;
            EXECUTE updateNeighbour;
            DEALLOCATE PREPARE updateneighbour;
            select true isUpdated, 'User updated successfully' message;
		else
			select false isUpdated, 'User not found' message;
		end if;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `cardAgreeOrDisAgree` */;

DELIMITER ;;
CREATE PROCEDURE `cardAgreeOrDisAgree`(in uId int,in pId int,in cId int ,in agreeOrDisAgree int, in comment text)
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId JOIN `project_cards` pc ON pc.projectId=p.projectId  WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1 AND pc.cardId=cId AND pc.projectId=pId) THEN
		if exists(select * from `project_cards_statusmeter` where userId=uId and projectId=pId)then
			#SELECT FIND_IN_SET(cId,CONCAT(IFNULL(disAgreeCardIds,''),',',IFNULL(agreeCardIds,''))) into @result FROM `project_cards_statusmeter` WHERE userId=uId AND projectId=pId;
			#select find_in_set(cId,cardIds) into @result from `project_cards_statusmeter` where userId=uId AND projectId=pId;
			SELECT agreeCardIds FROM`project_cards_statusmeter`WHERE projectId=pId AND userId=uId into @agreeCardIds;
            SELECT disAgreeCardIds FROM`project_cards_statusmeter`WHERE projectId=pId AND userId=uId into @disAgreeCardIds;
			#SELECT JSON_CONTAINS(ifnull(@agreeCardIds, '[]'),cast(concat(cId) as json),'$')INTO @agreeResult;
            #SELECT JSON_CONTAINS(ifnull(@disAgreeCardIds, '[]') ,cast(concat(cId) as json),'$')INTO @disAgreeResult;
            SELECT json_search(@agreeCardIds, 'one', cId) into @agreeResult;
            SELECT json_search(@disAgreeCardIds, 'one', cId) into @disAgreeResult;
            #select find_in_set(cId,concat(ifNull(@agreeCardIds,''), ',', ifnull(@disAgreeCardIds,''))) into @result;

			if (@agreeResult is null and @disAgreeResult is null) then
				if agreeOrDisAgree=1 then	
					update`project_cards` set cardAgreeCount=cardAgreeCount+1 where projectId=pId and cardId=cId;
					#update`project_cards_statusmeter` set agreeCardIds= ifnull(concat(agreeCardIds,',',cId),cId) ,cardsReviewedCount=cardsReviewedCount+1 where userId=uId and projectId=pId;
                    if(@agreeCardIds is null) then 
						update `project_cards_statusmeter` set cardsReviewedCount=cardsReviewedCount+1, agreeCardIds=concat('["',cId,'"]'), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId)  where userId=uId and projectId=pId; 
					else 
						update `project_cards_statusmeter` set cardsReviewedCount=cardsReviewedCount+1, agreeCardIds=(SELECT JSON_ARRAY_APPEND(@agreeCardIds,'$',concat(cId))), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) where userId=uId and projectId=pId; 
					end if;
					SELECT 'Agree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
				else
					UPDATE `project_cards` SET cardDisAgreeCount=cardDisAgreeCount+1 WHERE projectId=pId AND cardId=cId;
                    if(@disAgreeCardIds is null) then
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, disAgreeCardIds=concat('["',cId,'"]'), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId;
					else 
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, disAgreeCardIds=(SELECT JSON_ARRAY_APPEND(@disAgreeCardIds,'$',concat(cId))), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId; 
                    end if;
					SELECT 'DisAgree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
				end if;
			else 
				if(comment != '') then
					insert into `topics_comments` (userId, projectId, cardId, comment) values (uId, pId, cId, comment);
				end if;
				if(agreeOrDisAgree=1 and @agreeResult is null and @disAgreeResult is not null) then
					SELECT json_search(@disAgreeCardIds, 'one', cId) into @idx;
                    update `project_cards_statusmeter` set disAgreeCardIds=(select json_remove(@disAgreeCardIds, json_unquote(@idx))) where userId=uId and projectId=pId;
                    UPDATE `project_cards` SET cardDisAgreeCount=cardDisAgreeCount-1, cardAgreeCount=cardAgreeCount+1 WHERE projectId=pId AND cardId=cId;
                    if(@agreeCardIds is null) then 
                        update `project_cards_statusmeter` set agreeCardIds=concat('["',cId,'"]') where userId=uId and projectId=pId;
					else 
                        update `project_cards_statusmeter` set agreeCardIds=(SELECT JSON_ARRAY_APPEND(@agreeCardIds,'$',concat(cId))) where userId=uId and projectId=pId;
                    end if;
                    SELECT 'Agree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
				elseif(agreeOrDisAgree=0 and @agreeResult is not null and @disAgreeResult is null) then
					SELECT json_search(@agreeCardIds, 'one', cId) into @idx; #index
                    update `project_cards_statusmeter` set agreeCardIds=(select json_remove(@agreeCardIds, json_unquote(@idx))) where userId=uId and projectId=pId;
                    update`project_cards` set cardAgreeCount=cardAgreeCount-1, cardDisAgreeCount=cardDisAgreeCount+1 where projectId=pId and cardId=cId;
                    if(@disAgreeCardIds is null) then
						UPDATE `project_cards_statusmeter` SET disAgreeCardIds=concat('["',cId,'"]') WHERE userId=uId AND projectId=pId;
					else 
						UPDATE `project_cards_statusmeter` SET disAgreeCardIds=(SELECT JSON_ARRAY_APPEND(@disAgreeCardIds,'$',concat(cId))) WHERE userId=uId AND projectId=pId; 
                    end if;
					SELECT 'DisAgree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
                else
					if(agreeOrDisAgree=1) then
						SELECT 'Agree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
					else 
						SELECT 'DisAgree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
					end if;
                end if;
			end if;
		else
			IF agreeOrDisAgree=1 THEN				
				UPDATE `project_cards` SET cardAgreeCount=cardAgreeCount+1 WHERE projectId=pId AND cardId=cId;
				insert into `project_cards_statusmeter` (userId,projectId,agreeCardIds,cardsReviewedCount,cardIds) values(uId,pId,concat('["',cId,'"]'),1,concat(cId));
				#INSERT INTO `project_cards_statusmeter` (userId,projectId,agreeCardIds,cardsReviewedCount) VALUES(uId,pId,cId,1);				
				select 'Agree' as message,cardsReviewedCount from`project_cards_statusmeter`where userId=uId and projectId=pId;
			ELSE
				UPDATE `project_cards` SET cardDisAgreeCount=cardDisAgreeCount+1 WHERE projectId=pId AND cardId=cId;
				INSERT INTO `project_cards_statusmeter` (userId,projectId,disAgreeCardIds,cardsReviewedCount,cardIds) VALUES(uId,pId,CONCAT('["',cId,'"]'),1,concat(cId));
				#INSERT INTO `project_cards_statusmeter` (userId,projectId,disAgreeCardIds,cardsReviewedCount) VALUES(uId,pId,cId,1);
				SELECT 'DisAgree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
			END IF;
		end if;
	else
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `commentsInNotif` */;

DELIMITER ;;
CREATE PROCEDURE `commentsInNotif`(in _userId int, in _projectId int, in _replyId int)
BEGIN
	set @beHeardCommentId = (select beHeardCommentId from commentreplies where replyId = _replyId);
    set @subtopicCommentId = (select subTopicCommentId from commentreplies where replyId = _replyId);
    set @topicCommentId = (select topicCommentId from commentreplies where replyId = _replyId);
	select *, 'BE_HEARD_COMMENT' commentType, (select json_object('firstName',firstName, 'surName',surName, 'profilePhoto',profilePhoto, 'organisationId',organisationId) from re_developer where userId = commentreplies.userId) as re_developer from commentreplies where userId in (select userId from commentreplies where replyId = _replyId) and projectId = _projectId and beHeardCommentId is not null and neighbourId = _userId;
	select *, 'BE_HEARD_COMMENT' commentType from be_heard_comments where userId = _userId and projectId = _projectId;
	select *, 'SUB_TOPIC_COMMENT' commentType, (select json_object('firstName',firstName, 'surName',surName, 'profilePhoto',profilePhoto, 'organisationId',organisationId) from re_developer where userId = commentreplies.userId) as re_developer from commentreplies where userId in (select userId from commentreplies where replyId = _replyId) and projectId = _projectId and subTopicCommentId is not null and neighbourId = _userId;
	select *, 'SUB_TOPIC_COMMENT' commentType from sub_topics_comments where userId = _userId and projectId = _projectId;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `createNewProjectStep3` */;

DELIMITER ;;
CREATE PROCEDURE `createNewProjectStep3`(IN uId INT ,IN uType VARCHAR(30),IN pName VARCHAR(255),IN pAddress TEXT,IN zCode VARCHAR(255),IN lat DECIMAL(8,6),IN `long` DECIMAL(8,6),pBulidingHeight VARCHAR(255),IN pSize VARCHAR(255),IN pFloorPlan VARCHAR(255),pResidentialUnits VARCHAR(255),IN maxCapacity VARCHAR(255),pDescription TEXT,IN pVidoes TEXT,IN projectImageInsertQuery TEXT)
BEGIN
	INSERT INTO `project`(userId, userType, projectName, projectAddress, zipCode, latitude, longitude, buidlingHeight, propertySize, floorPlan, residentialUnits, maximumCapacity, projectDescription, presentationVideo,viewedUserId, thisProjectNumberLikedUserIds, projectDescriptionLikedUserIds,benefitLikedUserIds,phaseStatus) VALUES (uId,uType,pName,pAddress,zCode,lat,`long`,pBulidingHeight,pSize,pFloorPlan,pResidentialUnits,maxCapacity,pDescription,pVidoes,'[]', '[]', '[]','[]','[]' );
	if projectImageInsertQuery != 'null' then
		SELECT LAST_INSERT_ID() INTO @pId;
		SET @query=REPLACE(projectImageInsertQuery,'pId',@pId);
		PREPARE insertProjectImages FROM @query;
		EXECUTE insertProjectImages;
		DEALLOCATE PREPARE insertProjectImages;	
		SELECT 'Success' AS message,@pId AS projectId;
	end if;	
	SELECT 'Success' AS message,LAST_INSERT_ID() AS projectId;
		
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `createNewProjectStep5` */;

DELIMITER ;;
CREATE PROCEDURE `createNewProjectStep5`(in uId int ,in uType varchar(30),in pName varchar(255),in pAddress text,in zCode varchar(255),in lat decimal(8,6),in `long` decimal(8,6),pBulidingHeight varchar(255),in pSize varchar(255),in pFloorPlan varchar(255),pResidentialUnits VARCHAR(255),in maxCapacity varchar(255),pDescription text,in pVidoes text,in projectImageInsertQuery text,in pBenefit text,in cardInsertQuery text)
BEGIN
		set @query='';	
		INSERT INTO `project`(userId, userType, projectName, projectAddress, zipCode, latitude, longitude, buidlingHeight, propertySize, floorPlan, residentialUnits, maximumCapacity, projectDescription, presentationVideo,benefit, viewedUserId, thisProjectNumberLikedUserIds, projectDescriptionLikedUserIds, benefitLikedUserIds,phaseStatus) VALUES (uId,uType,pName,pAddress,zCode,lat,`long`,pBulidingHeight,pSize,pFloorPlan,pResidentialUnits,maxCapacity,pDescription,pVidoes,pBenefit,'[]', '[]', '[]', '[]','[]' );
		SELECT LAST_INSERT_ID() INTO @pId;
		set @query=Replace(projectImageInsertQuery,'pId',@pId);
		PREPARE insertProjectImages FROM @query;
		EXECUTE insertProjectImages;
		DEALLOCATE PREPARE insertProjectImages;
		set @query=replace(cardInsertQuery,'pId',@pId);
		PREPARE insertProjectCards FROM @query;
		EXECUTE insertProjectCards;
		DEALLOCATE PREPARE insertProjectCards;	
		select 'Success' as message,@pId as projectId;
	END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `create_new_project` */;

DELIMITER ;;
CREATE PROCEDURE `create_new_project`(in project_query text, in project_Partner json, in project_benefit json, in project_images json, in card_details_query json, in phase_status_query json, in _newOrganisationQuery text, in _newPartnerOrganisationsQuery json, in _newOrganisationName VARCHAR(255), in _newPartnerOrganisationsNames JSON, in _organisationId int)
BEGIN
	set @projectQuery = project_query;
    set @projectImages = project_images;
	set @projectBenefits = project_benefit;
    set @projectPartner = project_Partner;
    set @newPartnerOrganisationsNames = _newPartnerOrganisationsNames;
    set @newPartnerOrganisationsQuery = _newPartnerOrganisationsQuery;
	set @newOrganisationQuery = _newOrganisationQuery;
    set @organisationId = _organisationId;
    
    
	if((@newOrganisationQuery is not null) and !exists(select * from organisations where name = _newOrganisationName)) then
		PREPARE add_new_organisation from @newOrganisationQuery;
        EXECUTE add_new_organisation;
        DEALLOCATE PREPARE add_new_organisation;
        select last_insert_id() into @organisationId;
	elseif((@newOrganisationQuery is not null) and exists(select * from organisations where name = _newOrganisationName)) then
		select id from organisations where name = _newOrganisationName into @organisationId;
    end if;
    
	-- select @organisationId; -- .....................................................
    
	if(JSON_LENGTH(_newPartnerOrganisationsNames) > 0 and JSON_LENGTH(_newPartnerOrganisationsQuery) > 0) then
		set @i = 0;
		while @i < JSON_LENGTH(@newPartnerOrganisationsQuery) do
			select JSON_UNQUOTE(JSON_EXTRACT(@newPartnerOrganisationsNames, CONCAT('$[',@i,']'))) into @partnerOrganisationName;
			if(!exists(select * from organisations where name = @partnerOrganisationName)) then
				select JSON_EXTRACT(_newPartnerOrganisationsQuery, CONCAT('$[',@i,']')) into @newPartnerOrganisation_query;
                select replace(@newPartnerOrganisation_query, '\\', '') into @newPartnerOrganisation_query;
                select trim('"' from @newPartnerOrganisation_query) into @newPartnerOrganisation_query;
                PREPARE add_new_partnerOrganisation from @newPartnerOrganisation_query;
                EXECUTE add_new_partnerOrganisation;
                DEALLOCATE PREPARE add_new_partnerOrganisation;
                if(@projectPartner is null) then
					select concat('[', last_insert_id(), ']') into @projectPartner;
				else 
					select replace(@projectPartner, ']', concat(',', last_insert_id(), ']')) into @projectPartner;
				end if;
			else 
				if(@projectPartner is null) then
					select concat('[', id, ']') from organisations where name = @partnerOrganisationName into @projectPartner;
                else
					select replace(@projectPartner, ']', concat(',', id, ']')) from organisations where name = @partnerOrganisationName into @projectPartner;
                end if;
			end if;
            -- select 'project partner 1', @i, @projectPartner; -- ............................................................
            select @i + 1 into @i;
        end while;
    end if;
    
	PREPARE insert_project from @projectQuery;
	EXECUTE insert_project;
	DEALLOCATE PREPARE insert_project;
		
	SELECT LAST_INSERT_ID() INTO @pId;

	if(exists(select * from project where projectId = @pId)) then
		-- update project set phaseStatus = phase_Status, benefit = project_benefit, projectPartner = project_Partner  where projectId = @pId;
        if(JSON_LENGTH(phase_status_query) > 0) then
			set @i = 0;
            while @i < JSON_LENGTH(phase_status_query) DO
				select JSON_EXTRACT(phase_status_query, CONCAT('$[',@i,']')) INTO @phaseQuery;
                select trim('"' from @phaseQuery) into @phaseQuery;
                PREPARE insert_phase_status from @phaseQuery;
                EXECUTE insert_phase_status;
                DEALLOCATE PREPARE insert_phase_status;
                SELECT @i + 1 INTO @i;
			end while;
        end if;
		#if(JSON_LENGTH(project_images) > 0) then
		#	set @i = 0;
		#	while @i < JSON_LENGTH(project_images) DO 
		#		SELECT JSON_EXTRACT(project_images,CONCAT('$[',@i,']')) INTO @image;
		#		insert into project_images (projectId, image, imageLikedUserIds) values (@pId, @image, '[]');
		#		SELECT @i + 1 INTO @i;
		#	end while;
		#end if;
		if(JSON_LENGTH(card_details_query) > 0) then
			set @i = 0;
			while @i < JSON_LENGTH(card_details_query) DO
				select JSON_EXTRACT(card_details_query, CONCAT('$[',@i,']')) INTO @cardQuery;
				select replace(@cardQuery, '\\', '') into @cardQuery;
				select trim('"' from @cardQuery) into @cardQuery;
				set @j = 0;
				while @j < JSON_LENGTH(@cardQuery) DO
					select JSON_EXTRACT(@cardQuery, CONCAT('$[',@j,']')) INTO @subQuery;
					select trim('"' from @subQuery) into @subQuery;
					PREPARE insert_card_and_sub_topic from @subQuery;
					EXECUTE insert_card_and_sub_topic;
					DEALLOCATE PREPARE insert_card_and_sub_topic;
					SELECT @j + 1 INTO @j;
				end while;
				SELECT @i + 1 INTO @i;
			end while;
		end if;
		SELECT 'Success' AS message,@pId AS projectId, @phase_Status, project_images;
	else
		select 'failed to insert project';
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `deleteAccount` */;

DELIMITER ;;
CREATE PROCEDURE `deleteAccount`(in uId int,in uType varchar(30),in eId varchar(255))
BEGIN
	if exists(select * from `neighbours` where userId=uId and email=eId) or exists(select * from `re_developer` where userId=uId and email=eId) then
		if uType='neighbours' then
			update `neighbours` set isActive=0 where userId=uId;
			update `sub_topics_comments` set isDeleted=1 where userId=uId;
			delete from `session` where userId=uId and userType=uType;
			delete from `temporary_session` where userId=uId and userType=uType;
			delete from `device_token` where userId=uId and userType = 'neighbours';
			update `be_heard_comments` set isDeleted=1 where userId=uId;
			select 'Success' as message;
		else 
			update `re_developer` set isActive=0 where userId=uId;
			update `project` set isDeleted=1 where userId=uId;
			DELETE FROM `session` WHERE userId=uId AND userType=uType;
			DELETE FROM `temporary_session` WHERE userId=uId AND userType=uType;
            delete from `device_token` where userId=uId and userType = 're_developer';
			SELECT 'Success' AS message;
		end if;
	else 
		select 'Invalid user' as message;
	end if;
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `deleteAccounts` */;

DELIMITER ;;
CREATE PROCEDURE `deleteAccounts`(in _uIds text, in _utype varchar(20))
BEGIN
	if uType='neighbour' then
		update `neighbours` set isActive=0 where userId in (_uIds);
		update `sub_topics_comments` set isDeleted=1 where userId in (_uIds);
		delete from `session` where userId in (_uIds) and userType=_utype;
		delete from `temporary_session` where userId in (_uIds) and userType=_utype;
		delete from `pushtokendetails` where userId in (_uIds);
		update `be_heard_comments` set isDeleted=1 where userId in (_uIds);
		select 'Success' as message;
	else 
		update `re_developer` set isActive=0 where userId in (_uIds);
		update `project` set isDeleted=1 where userId in (_uIds);
		DELETE FROM `session` WHERE userId in (_uIds) AND userType=_utype;
		DELETE FROM `temporary_session` WHERE userId in (_uIds) AND userType=_utype;
		SELECT 'Success' AS message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `doLogin` */;

DELIMITER ;;
CREATE PROCEDURE `doLogin`(IN eId VARCHAR(255), in user_type varchar(255))
BEGIN
	SET @loggedInUserId = 0;
	IF (EXISTS(SELECT * FROM `neighbours` WHERE email = eId and isActive=1)  and user_type = 'neighbour') THEN
		SELECT userId INTO @loggedInUserId FROM `neighbours` WHERE email = eId and isActive is true;
		SELECT 'Success' AS message,'neighbours' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and  userType='neighbours') AS userExistsToken,*/ userId,firstName,surName,email,`password`,address/*,streetAddress,city,state,zipCode*/ ,`profile`, isThemesMode,createdOn,modifiedOn,isActive,loginAttempts,lastLoggedAt FROM `neighbours` WHERE email = eId and isActive is true LIMIT 1;
	ELSEIF (EXISTS(SELECT * FROM `re_developer` WHERE email = eId and isActive=1) and user_type = 're_developer')THEN
		SELECT userId INTO @loggedInUserId FROM `re_developer` WHERE email = eId and isActive is true;
		SELECT 'Success' AS message,'re_developer' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and userType='re_developer') AS userExistsToken,*/ userId,`password`,profilePhoto,createdOn,isActive,loginAttempts FROM `re_developer` WHERE email = eId and isActive is true LIMIT 1;
	elseif exists(select * from admins where email = eId and isActive is true) and user_type = 'admin' then
		select userId INTO @loggedInUserId FROM admins WHERE email = eId and isActive is true;
        SELECT 'Success' AS message,'admin' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and userType='re_developer') AS userExistsToken,*/ userId,`password`,createdOn,isActive FROM admins WHERE email = eId and isActive is true LIMIT 1;
	ELSE
		SELECT 'User not found' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `editBusinessProfile` */;

DELIMITER ;;
CREATE PROCEDURE `editBusinessProfile`(in _orgId int, in _updateOrgQuery text, in _updateLinkQuery text)
BEGIN
    if(exists(select * from organisations where id = _orgId)) then
		set @updateOrgQuery = _updateOrgQuery;
		select replace(@updateOrgQuery, '\\', '') into @updateOrgQuery;
		PREPARE updateOrganisationQuery from @updateOrgQuery;
		EXECUTE updateOrganisationQuery;
		DEALLOCATE PREPARE updateOrganisationQuery;
    
		if(_updateLinkQuery is not null) then
			set @updateLinkQuery = _updateLinkQuery;
			PREPARE updateLinksQuery from @updateLinkQuery;
			EXECUTE updateLinksQuery;
			DEALLOCATE PREPARE updateLinksQuery;
		end if;
        select 'success' as message;
	else
		select false `status`, "organisation doesn't exists" as message;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `editDeleteMessage` */;

DELIMITER ;;
CREATE PROCEDURE `editDeleteMessage`(in _userId int, in _commentId int, in _comment text, in _isDelete tinyint)
BEGIN
	if(exists (select * from commentreplies where userId = _userId AND replyId = _commentId and isDeleted is false)) then
		update commentreplies set `comment` = _comment, isDeleted = _isDelete where replyId = _commentId and isDeleted is false and userId = _userId;
        select true isUpdated, 'comment updated successfully' message;
	else 
		select false isUpdated, 'comment not found' message;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `editNeighboursProfile` */;

DELIMITER ;;
CREATE PROCEDURE `editNeighboursProfile`(in uId int,in uType varchar(30),in fName varchar(255),sName varchar(255),in adrs text,in eId varchar(255), in  pImg text,IN lat DECIMAL(9,6),IN `long` DECIMAL(9,6))
BEGIN
	IF EXISTS(SELECT * FROM `neighbours` WHERE userId=uId AND isActive=1)THEN
		IF EXISTS(SELECT * FROM `neighbours` WHERE email=eId AND userId !=uId AND isActive=1) /*OR EXISTS(SELECT * FROM `re_developer` WHERE email=eId AND isActive=1)*/THEN
			SELECT 'Email exist' AS message;
		ELSE
			UPDATE `neighbours` SET firstName=fName, surName=sName,address=adrs/*, streetAddress=streetAdd, city=cit, state=stat, zipCode=zCode*/,latitude=lat, longitude=`long`, email=eId, `profile`=pImg  WHERE userId=uId;
			SELECT 'Success' AS message;
		END IF;
	ELSE
		SELECT 'User not found' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `editREDeveloperProfile` */;

DELIMITER ;;
CREATE PROCEDURE `editREDeveloperProfile`(in uId int ,in uType varchar(30),in fname varchar(255),in sName varchar(255),in eId varchar(255),in _phoneNumber varchar(45), in `pImg` text,in org text)
BEGIN
		if exists(select * from `re_developer` where userId=uId and isActive=1)then
			if exists(select * from `re_developer` where email=eId and userId !=uId and isActive=1) /*or exists(select * from `neighbours` where email=eId and isActive=1 )*/ then
				select 'Email exist' as message;
			else
				update `re_developer` set firstName=fName, surName=sName, email=eId, profilePhoto=pImg ,`organisationName`=org, phoneNumber=_phoneNumber where userId=uId;
				select 'Success' as message;
			end if;
		else
			select 'User not found' as message;
		end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `envelopeDetails` */;

DELIMITER ;;
CREATE PROCEDURE `envelopeDetails`(in _envelopeId varchar(45), in _createdAt varchar(45), in _modifiedAt varchar(45), in _expireDateTime varchar(45), in _initialSentDateTime varchar(45), in _statusChangedDateTime varchar(45), in _certificateUri varchar(255), in _envelopeUri varchar(255), in _notificationUri varchar(255), in _recipientsUri varchar(255), in _re_docusignAccountId varchar(45), in _re_email varchar(100), in _re_docusignUserId varchar(45), in _signingLocation varchar(45), in _status varchar(45), in _projectId int, in _re_dev_Id int, in _neighbour_Id int, in _completedDateTime varchar(45), in _documentId int)
BEGIN
	if(exists(select * from envelope_details where projectId = _projectId and re_dev_Id = _re_dev_Id and neighbour_Id = _neighbour_Id)) then
		update envelope_details set envelopeId = _envelopeId, createdAt = _createdAt, modifiedAt = _modifiedAt, expireDateTime = _expireDateTime, initialSentDateTime = _initialSentDateTime, statusChangedDateTime = _statusChangedDateTime, certificateUri = _certificateUri, envelopeUri = _envelopeUri, notificationUri = _notificationUri, recipientsUri = _recipientsUri, re_docusignAccountId = _re_docusignAccountId, re_email = _re_email, re_docusignUserId = _re_docusignUserId, signingLocation = _signingLocation, status = _status, completedDateTime = _completedDateTime, documentId = _documentId where projectId = _projectId and re_dev_Id = _re_dev_Id and neighbour_Id = _neighbour_Id;
		select 'updated' message, id from envelope_details where projectId = _projectId and re_dev_Id = _re_dev_Id and neighbour_Id = _neighbour_Id;
    else
		insert into envelope_details (envelopeId, createdAt, modifiedAt, expireDateTime, initialSentDateTime, statusChangedDateTime, certificateUri, envelopeUri, notificationUri, recipientsUri, re_docusignAccountId, re_email, re_docusignUserId, signingLocation, status, projectId, re_dev_Id, neighbour_Id, documentId) values (_envelopeId, _createdAt, _modifiedAt, _expireDateTime, _initialSentDateTime, _statusChangedDateTime, _certificateUri, _envelopeUri, _notificationUri, _recipientsUri, _re_docusignAccountId, _re_email, _re_docusignUserId, _signingLocation, _status, _projectId, _re_dev_Id, _neighbour_Id, _documentId);
        select 'added' message, id from envelope_details where projectId = _projectId and re_dev_Id = _re_dev_Id and neighbour_Id = _neighbour_Id;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `feedback` */;

DELIMITER ;;
CREATE PROCEDURE `feedback`(in _userId int, in _feedback text, in user_type varchar(20))
BEGIN
	if(exists(select * from neighbours where userId = _userId)) then
		insert into yimby_feedback (userId, feedback, userType) values (_userId, _feedback, user_type);
        select 'added successfully' message, last_insert_id() feedbackId;
	else
		select 'User not found' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `findSessionById` */;

DELIMITER ;;
CREATE PROCEDURE `findSessionById`(in uId int,in tok text,in Api text)
BEGIN
	if exists(SELECT * FROM `session` s JOIN `neighbours` n ON n.userId = s.userId WHERE s.userId = uId AND s.token = tok AND n.isActive = 1 AND s.isAdmin = 0 and s.`userType`='neighbours')then
		select 'neighbours' as userType, n.*, s.token from `neighbours` n left join session s on s.userId = n.userId where n.userId=uId and s.token = tok;
	elseif exists(select * from `session` s join `re_developer` r on r.userId = s.userId where s.userId = uId and s.token = tok and r.isActive = 1 and  s.isAdmin =0 and s.`userType`='re_developer') then
		select 're_developer' as userType,re_developer. * from `re_developer`  WHERE userId=uId ;
	elseif exists(SELECT * FROM `session` s JOIN `admins` a ON a.userId = s.userId WHERE s.userId = uId AND s.token = tok AND a.isActive = 1 AND s.isAdmin = 0 and s.`userType`='admin') then
		select 'admins' as userType, a.* from `admins` a  WHERE userId=uId ;
	else
		select 'User not found' as message;
	end if;
	if Api ='refreshToken' then
		DELETE FROM `session` WHERE token=tok AND userId=uId AND isAdmin=0;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `findSessionByToken` */;

DELIMITER ;;
CREATE PROCEDURE `findSessionByToken`(in tok text)
BEGIN
		 
		if exists(SELECT * FROM `session` s JOIN `neighbours` n ON n.userId = s.userId WHERE s.token = tok AND n.isActive = 1 AND s.isAdmin = 0) or EXISTS(SELECT * FROM `session` s JOIN `re_developer` r ON r.userId = s.userId WHERE s.token = tok AND r.isActive =1 AND s.isAdmin =0)THEN
			select 1 as userFound ;  
		else 
			select 0 as userFound ;
		end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `forgotPasswordStep1` */;

DELIMITER ;;
CREATE PROCEDURE `forgotPasswordStep1`(in eId text, in userType varchar(20), in _otp varchar(6))
BEGIN
	if (userType = 're_developer' and exists(select * from `re_developer` where email=eId and isActive=1))then
		select 'Success' as message, 're_developer' as userType,r.userId,t.body,t.subject,concat(r.firstName,' ',r.surName) as userName from  `re_developer` r  join templates t where r.email=eId and t.id = 1;
	elseif (userType = 'neighbour' and exists(select * from `neighbours` where email=eId and isActive=1)) then
		update neighbours set otp = _otp, otpExpireAt = date_add(current_timestamp(3), interval 30 minute) where email=eId;
		select 'Success' as message,'neighbours' as userType ,n.userId,t.body,t.subject,CONCAT(n.firstName,' ',n.surName) as userName from `neighbours`n join  templates t where n.email=eId and t.id = 5;
	else
		select "Email Id doesn't exist" as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `forgotPasswordStep2` */;

DELIMITER ;;
CREATE PROCEDURE `forgotPasswordStep2`(in uId int, in tok text,in uType varchar(30),in passcode text, in _otp varchar(6))
BEGIN
	if exists(select * from `temporary_session` where token=tok) then
		if uType='neighbours' then
			if passcode is NULL  then 
				select otpExpireAt  from neighbours where userId = uId AND otp =  _otp into  @otpExpiresAt;
				if(date_sub(current_timestamp(3), INTERVAL 30 MINUTE) < @otpExpiresAt ) then
					select 'Success' as message;
				else
					select 'Otp has been expired' as message;
				end if;
            else 
				select otpExpireAt  from neighbours where userId = uId AND otp =  _otp into  @otpExpiresAt;
				if(date_sub(current_timestamp(3), INTERVAL 30 MINUTE) < @otpExpiresAt ) then
					update `neighbours` set `password`=passcode where userId=uId;
					DELETE FROM `temporary_session` WHERE token=tok;
                    select 'Success' as message;
				else
					select 'otp expired' as message;
				end if;
			end if;
		else
			update `re_developer` set `password`=passcode where userId=uId;
			delete from `temporary_session` where token=tok;
			select 'Success' as message;
		end if;
	else
		select 'Token not found' as message;
	end if;
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getCommentsBySubTopicId` */;

DELIMITER ;;
CREATE PROCEDURE `getCommentsBySubTopicId`(In uId int,in pId int,in tId int,in limt int,in ofset int)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN`re_developer` re ON p.userId=re.userId  JOIN `project_cards_sub_topics` st ON p.projectId=st.projectId WHERE p.projectId=pId AND p.userId=uId AND p.isDeleted=0 AND re.isActive=1 AND st.topicId=tId AND st.projectId=pId AND st.isDeleted=0) THEN
		#SELECT 'Success' as message,JSON_OBJECT('commentId',tc.commentId,'projectId',tc.projectId,'comment',tc.comment,'userId',tc.userId,'firstName',n.firstName,'surName',n.surName,'profile',n.profile,'createAt',tc.createdOn) as commentDetails FROM `sub_topics_comments` tc JOIN `neighbours` n ON n.userId=tc.userId WHERE tc.projectId=pId AND tc.topicId=tId and  tc.isdeleted=0 and n.isActive=1 limit limt offset ofset;
		SELECT 'Success' as message,tc.commentId,tc.projectId,tc.comment,tc.userId,n.firstName,n.surName,n.profile,tc.createdOn FROM `sub_topics_comments` tc JOIN `neighbours` n ON n.userId=tc.userId WHERE tc.projectId=pId AND tc.topicId=tId and  tc.isdeleted=0 and n.isActive=1 limit limt offset ofset;
	else 
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getDetailsDocusign` */;

DELIMITER ;;
CREATE PROCEDURE `getDetailsDocusign`(in _neighbourId int, in _projectId int)
BEGIN
	select userId, firstName, surName, email, address, latitude, longitude, zipCode from neighbours where userId = _neighbourId and isActive is true;
	select re.userId, re.firstName, re.surName, re.email, re.organisationId from re_developer re left join project p on p.userId = re.userId where projectId = _projectId;
    select projectId, projectType, projectName, projectAddress, zipCode, projectStatus, latitude, longitude, projectDescription from project where projectId = _projectId and isDeleted is false;
    select *, datediff(expireDateTime, CURRENT_TIMESTAMP(3)) expiresIn from envelope_details where neighbour_Id = _neighbourId and projectId = _projectId;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getDropDownData` */;

DELIMITER ;;
CREATE PROCEDURE `getDropDownData`(in _userId int)
BEGIN
	select id, name, icon from organisations;
    select projectType from project where projectType is not null and projectType != 'null' group by projectType;
    select type from organisations where type is not null and type != 'null' group by type;
    -- select org.id from organisations org left join re_developer re on re.organisationId = org.id where re.userId = _userId into @orgId;
    select projectId, projectName, isInDraft, isDeleted, projectStatus from project where userId = _userId;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getLikedUserIds` */;

DELIMITER ;;
CREATE PROCEDURE `getLikedUserIds`(in uType varchar(30),in pId int,in likeType varchar(100))
BEGIN
	if uType='neighbours' then
		IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1) THEN
			if likeType='thisProjectNumberLikes'then
				select 'Success' as message,`project`.thisProjectNumberLikedUserIds as likedUserIds from project where projectId=pId;
			elseif likeType='projectDescriptionLikes'then
				SELECT 'Success' AS message,`project`.projectDescriptionLikedUserIds AS likedUserIds FROM project WHERE projectId=pId;
			elseif likeType='benefitLikes'then
				SELECT 'Success' AS message,`project`.benefitLikedUserIds AS likedUserIds FROM project WHERE projectId=pId;
			elseif likeType='sectionLikes'then
				SELECT 'Success' AS message,`project`.sectionLikedUserIds AS likedUserIds FROM project WHERE projectId=pId;
			end if;
		else
			select 'projectId not found' as message;	
		end if;
	else
		select 'Invalid userId' as message;	
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getMessagesList` */;

DELIMITER ;;
CREATE PROCEDURE `getMessagesList`(in _reUserId int, in _projectId int, in _neighbourId int)
BEGIN
	if(_projectId is null and _neighbourId is null) then
		select p.projectId, p.projectName, 
        ((select count(bhc.commentId) from be_heard_comments bhc where bhc.projectId = p.projectId and bhc.isDeleted is false and bhc.isViewed is false) + 
        (select count(stc.commentId) from sub_topics_comments stc where stc.projectId = p.projectId and stc.isDeleted is false and stc.isViewed is false)) unViewedMessageCount,
        ((select count(bhc.commentId) from be_heard_comments bhc where bhc.projectId = p.projectId and bhc.isDeleted is false ) + 
		(select count(stc.commentId) from sub_topics_comments stc where stc.projectId = p.projectId and stc.isDeleted is false)) allMessageCount
        from project p 
        where p.userId = _reUserId 
        and p.isInDraft is false 
        and p.isDeleted is false 
        having allMessageCount != 0; 
    elseif(_projectId is not null and _neighbourId is null) then
		select 
			((select count(bhc.commentId) from be_heard_comments bhc where bhc.projectId = _projectId and bhc.isDeleted is false and bhc.isViewed is false) + 
			(select count(stc.commentId) from sub_topics_comments stc where stc.projectId = _projectId and stc.isDeleted is false and stc.isViewed is false)) unViewedMessageCount,
            userId, firstName, surName, createdOn, modifiedOn, `profile` profilePic, projectId from 
			((select stc.userId, stc.commentId, stc.comment, stc.cardId, stc.createdOn, stc.modifiedOn, n.firstName, n.surName, n.`profile`, pcst.topicTitle, stc.projectId from sub_topics_comments stc left join neighbours n on n.userId = stc.userId left join project_cards_sub_topics pcst on pcst.cardId = stc.cardId and pcst.topicId = stc.topicId where stc.projectId = _projectId)
				union
			(select bhc.userId, bhc.commentId, bhc.comment, bhc.cardId, bhc.createdOn, bhc.modifiedOn, n.firstName, n.surName, n.`profile`, pc.cardTitle, bhc.projectId from be_heard_comments bhc left join neighbours n on n.userId = bhc.userId left join project_cards pc on pc.cardId = bhc.cardId where bhc.projectId = _projectId)) 
		as a group by userId;
    elseif(_projectId is not null and _neighbourId is not null) then
		select stc.*, 'SUB_TOPIC_COMMENT' commentType, 'neighbour' userType, pcst.topicTitle title, n.firstName, n.surName, n.`profile` profilePic from sub_topics_comments stc left join project_cards_sub_topics pcst on pcst.topicId = stc.topicId and pcst.cardId = stc.cardId left join neighbours n on n.userId = stc.userId where stc.userId = _neighbourId and stc.projectId = _projectId;
		select bhc.*, 'BE_HEARD_COMMENT' commentType, 'neighbour' userType, pc.cardTitle title, n.firstName, n.surName, n.`profile` profilePic from be_heard_comments bhc left join project_cards pc on pc.cardId = bhc.cardId left join neighbours n on n.userId = bhc.userId where bhc.userId = _neighbourId and bhc.projectId = _projectId;
        select cr.*, 're_developer' userType, re.firstName, re.surName, re.profilePhoto from commentreplies cr left join re_developer re on re.userId = cr.userId where cr.userId = _reUserId and cr.projectId = _projectId and cr.neighbourId = _neighbourId and cr.isDeleted is false;
        update be_heard_comments set isViewed = true where projectId = _projectId and userId = _neighbourId;
        update sub_topics_comments set isViewed = true where projectId = _projectId and userId = _neighbourId;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getMyActivites` */;

DELIMITER ;;
CREATE PROCEDURE `getMyActivites`(in uId int,in userType varchar(30),in isNotificationOpened bool)
BEGIN
	if userType='neighbours'then		
		DELETE FROM `neighbours_activities` WHERE createdAt < NOW() - INTERVAL 1 MONTH;
		SELECT COUNT(*) AS newNotificationCount FROM `neighbours_activities` WHERE myId = uId AND isNew = 1 and isDeleted=0;
		SELECT a.id AS activityId, a.myId, NULL AS userDetails, (SELECT JSON_ARRAYAGG(JSON_OBJECT('userId', userId, 'projectId', project.projectId)) FROM `project` WHERE projectId = a.projectId) AS projectDetails, a.isNew, re.email AS projectUserEmail, concat(re.firstName,' ',re.surName) AS projectUserName,re.profilePhoto AS projectUserProfileImage,a.activityType, a.commentId, a.replyId, (SELECT REPLACE(a.`event`, '{{projectName}}', p.projectName)) AS `event`, a.createdAt FROM `neighbours_activities` a JOIN re_developer re ON re.userId = a.re_developerId JOIN project p ON p.projectId = a.projectId WHERE(a.activityType = 'updatesToProjectsInYourArea' OR a.activityType = 'updatesToProjectsInYourArea') AND a.myId = uId and a.isDeleted=0 ORDER BY activityId DESC;	
		IF isNotificationOpened = TRUE THEN
			UPDATE `neighbours_activities`SET isNew = 0 WHERE myId = uId;
		end if;
	else
		Delete from `re_developer_activities` where createdAt < now() -interval 1 month;
		select count(*) as newNotificationCount from `re_developer_activities` where myId = uId and isNew = 1 AND isDeleted=0;
		SELECT a.id AS activityId, a.myId, NULL AS userDetails, (SELECT JSON_ARRAYAGG(JSON_OBJECT('userId', userId, 'projectId', project.projectId)) FROM `project` WHERE projectId = a.projectId) AS projectDetails, a.isNew, n.email AS commentUserEmail, CONCAT(n.firstName,' ',n.surName) AS commentUserName,n.profile AS commentUserProfileImage,a.activityType, a.beHeardcommentId, a.topicCommentId, a.replyId, (SELECT REPLACE((SELECT REPLACE(a.`event`, '{{userName}}',commentUserName )), '{{projectName}}', p.projectName)) AS `event`, a.createdAt FROM `re_developer_activities` a JOIN `neighbours` n ON n.userId = a.neighboursId JOIN project p ON p.projectId = a.projectId WHERE(a.activityType = 'projectComment' OR a.activityType = 'topicComment') AND a.myId = uId and a.isDeleted=0 ORDER BY activityId DESC;		
		IF isNotificationOpened = TRUE THEN
			UPDATE `re_developer_activities` SET isNew = 0 WHERE myId = uId;
		end if;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getMyPassword` */;

DELIMITER ;;
CREATE PROCEDURE `getMyPassword`(in uId int,uType varchar(30))
BEGIN
	if uType='neighbours' then
		if exists(select * from `neighbours` where userId=uId and isActive=1)then
			select 'Success' as message,`neighbours`.`password` from `neighbours` where userId=uId and isActive=1;
		else
			select 'User not found' as message;
		END IF;
	else
		IF EXISTS(SELECT * FROM `re_developer` WHERE userId=uId AND isActive=1)THEN
			SELECT 'Success' AS message,`re_developer`.`password` FROM `re_developer` WHERE userId=uId AND isActive=1;
		ELSE
			SELECT 'User not found' AS message;
		END IF;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getMyProjectByUserId` */;

DELIMITER ;;
CREATE PROCEDURE `getMyProjectByUserId`(in requestId int)
BEGIN
	if exists (select * from `re_developer` where userId=requestId and isActive=1) then	
		set @organisationId = (select organisationId from re_developer where userId = requestId);
		SELECT p.projectId,p.projectName,p.coverImage,p.isInDraft,views,
        (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses, 
        (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
        (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
        (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as 'currentPhase'
        FROM `project` p WHERE p.userId=requestId AND p.isDeleted=0;
	else 
		SELECT 'User not found' AS message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getNearByProject` */;

DELIMITER ;;
CREATE PROCEDURE `getNearByProject`(in _latitude varchar(255), in _longitude varchar(255), in _limit int, in _offset int)
BEGIN
	if(_limit is not null && _offset is not null) then
		SELECT p.projectId, p.projectName,p.coverImage , p.projectAddress, p.zipCode, p.latitude,p.longitude,
        (3959 * ACOS(COS(RADIANS(_latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(_longitude)) + SIN(RADIANS(_latitude)) * SIN(RADIANS(p.latitude)))) AS distance 
        FROM project p JOIN re_developer r ON r.userId = p.userId 
        WHERE r.isActive = 1 AND  p.isDeleted = 0 AND  isInDraft = 0  
        HAVING distance <= 5 ORDER BY distance LIMIT _limit OFFSET _offset;
	else 
		SELECT p.projectId, p.projectName,p.coverImage , p.projectAddress, p.zipCode, p.latitude,p.longitude,
        (3959 * ACOS(COS(RADIANS(_latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(_longitude)) + SIN(RADIANS(_latitude)) * SIN(RADIANS(p.latitude)))) AS distance 
        FROM project p JOIN re_developer r ON r.userId = p.userId 
        WHERE r.isActive = 1 AND  p.isDeleted = 0 AND  isInDraft = 0  
        HAVING distance <= 5 ORDER BY distance;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getNearByProjectOffline` */;

DELIMITER ;;
CREATE PROCEDURE `getNearByProjectOffline`(in _latitude varchar(255), in _longitude varchar(255), in _limit int, in _offset int, in _userId int)
BEGIN
	if(exists(select * from userLocation where userId = _userId)) then
		update userLocation set latitude = _latitude, longitude = _longitude where userId = _userId;
    else
		insert into userLocation (userId, latitude, longitude) values (_userId, _latitude, _longitude);
    end if;
	if(_limit is not null and _offset is not null) then
		SELECT 'Success' AS message,_userId as userId, p.benefit ,p.modifiedAt,
        (select JSON_OBJECT("projectId",p.projectId, "projectName",p.projectName, "projectAddress",p.projectAddress,"city",p.city,"state",p.state, "zipCode",p.zipCode, "latitude",p.latitude, "longitude",p.longitude,"property", (select json_object("buidlingHeight",p.buidlingHeight, "propertySize",p.propertySize, "floorPlan",p.floorPlan,"residentialUnits",p.residentialUnits, "maximumCapacity",p.maximumCapacity)),"projectDescription",p.projectDescription, "presentationVideo",p.presentationVideo, "projectType",p.projectType, "coverImage",p.coverImage, "projectImages", p.images)) as projectDetails,
		(select json_object("orgName", org.name, "orgImage", org.coverImage, "orgType", org.type, "orgLinks", (select json_object("facebook", orgl.facebook, "twitter", orgl.twitter, "linkedIn", orgl.linkedIn, "website", orgl.website, "instagram", orgl.instagram, "email", orgl.email) from organisation_links orgl where organisationId = p.organisationId), "orgDescription", org.description) from organisations org where id = p.organisationId) AS organizationDetails,
        
		 (3959 * ACOS(COS(RADIANS(_latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(_longitude)) + SIN(RADIANS(_latitude)) * SIN(RADIANS(p.latitude)))) AS distance,

		-- (SELECT JSON_MERGE(
		(SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'isRequired',c.isRequired,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
'cardStatus',
        (CASE
            WHEN EXISTS(
                SELECT *
                FROM `project_cards_statusmeter`
                WHERE projectId = p.projectId AND userId = _userId
            ) THEN
                CASE
                    WHEN JSON_CONTAINS(
                        (SELECT agreeCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'agree'
                    WHEN JSON_CONTAINS(
                        (SELECT disAgreeCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'disAgree'
                    WHEN JSON_CONTAINS(
                        (SELECT skipCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'skip'
                    ELSE 'not answered'
                END
            ELSE 'not answered'
        END),
    

        'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `cards` c ON pc.cardId=c.id WHERE pc.projectId=p.projectId  AND pc.isDeleted=0)
		-- (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'isRequired',c.isRequired,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
        -- 'cardStatus', if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1, 'agree',if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1,'disAgree', null)), null),
        -- 'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
        -- 'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        -- 'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        -- 'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		-- FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `cards` c ON pc.cardId=c.id WHERE pc.projectId=p.projectId  AND pc.isDeleted=0))) 
		AS cardDetails,
        (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
'cardStatus',
        (CASE
            WHEN EXISTS(
                SELECT *
                FROM `static_project_cards_statusmeter`
                WHERE projectId = p.projectId AND userId = _userId
            ) THEN
                CASE
                    WHEN JSON_CONTAINS(
                        (SELECT agreeCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'agree'
                    WHEN JSON_CONTAINS(
                        (SELECT disAgreeCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'disAgree'
                    WHEN JSON_CONTAINS(
                        (SELECT skipCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'skip'
                    ELSE 'not answered'
                END
            ELSE 'not answered'
        END),
    
        'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.staticCardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.staticCardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.staticCardId AND pcst.isDeleted=0 ))),'[]')FROM  project_static_cards pc JOIN `static_cards` c ON pc.staticCardId=c.staticCardId WHERE pc.projectId=p.projectId  AND pc.isDeleted=0)
        AS staticCardDetails,
 
        if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId),(select cardsReviewedCount from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId) , FALSE) cardsReviewedCount ,
        -- (select cardReviewCount from `static_project_cards_statusmeter` where projectId = p.projectId and userId = _userId ) staticCardReviewCount
         if(exists(select * from `static_project_cards_statusmeter` where projectId=p.projectId and userId=_userId),(select cardsReviewedCount from `static_project_cards_statusmeter` where projectId=p.projectId and userId=_userId) ,FALSE)  static_cardsReviewedCount 

		FROM project p JOIN re_developer r ON r.userId = p.userId 
		WHERE r.isActive = 1 AND  p.isDeleted = 0   
		/*HAVING distance <= 4000*/ 
        -- HAVING  distance <=4000
        ORDER BY p.modifiedAt DESC;
        -- ORDER BY distance /*limit _limit offset _offset*/ ;
	else 
		SELECT 'Success' AS message,_userId as userId, p.benefit,p.modifiedAt,
        (select JSON_OBJECT("projectId",p.projectId, "projectName",p.projectName, "projectAddress",p.projectAddress,"city",p.city,"state",p.state, "zipCode",p.zipCode, "latitude",p.latitude, "longitude",p.longitude,"property", (select json_object("buidlingHeight",p.buidlingHeight, "propertySize",p.propertySize, "floorPlan",p.floorPlan,"residentialUnits",p.residentialUnits, "maximumCapacity",p.maximumCapacity)),"projectDescription",p.projectDescription, "presentationVideo",p.presentationVideo, "projectType",p.projectType, "coverImage",p.coverImage, "projectImages", p.images)) as projectDetails,
		(select json_object("orgName", org.name, "orgImage", org.coverImage, "orgType", org.type, "orgLinks", (select json_object("facebook", orgl.facebook, "twitter", orgl.twitter, "linkedIn", orgl.linkedIn, "website", orgl.website, "instagram", orgl.instagram, "email", orgl.email) from organisation_links orgl where organisationId = p.organisationId), "orgDescription", org.description) from organisations org where id = p.organisationId) AS organizationDetails,
		(3959 * ACOS(COS(RADIANS(_latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(_longitude)) + SIN(RADIANS(_latitude)) * SIN(RADIANS(p.latitude)))) AS distance,
		 -- (SELECT JSON_MERGE(
		(SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'isRequired',c.isRequired,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
'cardStatus',
        (CASE
            WHEN EXISTS(
                SELECT *
                FROM `project_cards_statusmeter`
                WHERE projectId = p.projectId AND userId = _userId
            ) THEN
                CASE
                    WHEN JSON_CONTAINS(
                        (SELECT agreeCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'agree'
                    WHEN JSON_CONTAINS(
                        (SELECT disAgreeCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'disAgree'
                    WHEN JSON_CONTAINS(
                        (SELECT skipCardIds FROM project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.cardId,JSON)
                    ) THEN 'skip'
                    ELSE 'not answered'
                END
            ELSE 'not answered'
        END),
    

        'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `cards` c ON pc.cardId=c.id WHERE pc.projectId=p.projectId  AND pc.isDeleted=0)
		 -- (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'isRequired',c.isRequired,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
         -- 'cardStatus', if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1, 'agree',if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1,'disAgree', null)), null),
         -- 'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
         -- 'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
         -- 'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        -- 'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		 -- FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `cards` c ON pc.cardId=c.id WHERE pc.projectId=p.projectId  AND pc.isDeleted=0))) 
		AS cardDetails,
        (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',c.cardTitle,'cardIcon',c.cardIcon,'cardDescription',c.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
'cardStatus',
        (CASE
            WHEN EXISTS(
                SELECT *
                FROM `static_project_cards_statusmeter`
                WHERE projectId = p.projectId AND userId = _userId
            ) THEN
                CASE
                    WHEN JSON_CONTAINS(
                        (SELECT agreeCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'agree'
                    WHEN JSON_CONTAINS(
                        (SELECT disAgreeCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'disAgree'
                    WHEN JSON_CONTAINS(
                        (SELECT skipCardIds FROM static_project_cards_statusmeter WHERE userId = _userId AND projectId = p.projectId),
                        convert(pc.staticCardId,JSON)
                    ) THEN 'skip'
                    ELSE 'not answered'
                END
            ELSE 'not answered'
        END),
    

        'cardComment',(select JSON_ARRAYAGG(comment) from card_comment where userId = _userId and projectId = p.projectId and cardId = pc.staticCardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.staticCardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.staticCardId AND pcst.isDeleted=0 ))),'[]')FROM  project_static_cards pc JOIN `static_cards` c ON pc.staticCardId=c.staticCardId WHERE pc.projectId=p.projectId  AND pc.isDeleted=0)
        AS staticCardDetails,
 
        if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId),(select cardsReviewedCount from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), FALSE) cardsReviewedCount,
                 if(exists(select * from `static_project_cards_statusmeter` where projectId=p.projectId and userId=_userId),(select cardsReviewedCount from `static_project_cards_statusmeter` where projectId=p.projectId and userId=_userId) ,FALSE)  static_cardsReviewedCount 
		FROM project p JOIN re_developer r ON r.userId = p.userId 
		WHERE r.isActive = 1 AND  p.isDeleted = 0  
		-- HAVING (distance <= 10 or distance = null)
        ORDER BY p.modifiedAt DESC;
       -- ORDER BY distance;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getProjectByProjectId` */;

DELIMITER ;;
CREATE PROCEDURE `getProjectByProjectId`(in pId int ,in uId int , in uType varchar(30))
BEGIN
	if uType='re_developer' then
		IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 and p.isInDraft=1)THEN
			SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan, p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes, p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds, p.coverImage, p.projectPartner/*(select count(commentId)from`comments`where projectId=pId and isDeleted=0)as commentsDetails,(SELECT JSON_OBJECT('commentId',c.commentId,'comment',c.comment,'commentUserId',c.userId,'commentLikes',c.likes,'commentLikedUserIds',c.commentLikedUserIds) FROM `comments` c WHERE c.projectId=pId AND c.isDeleted=0) AS commentsDetails */FROM `project` p JOIN comments c  WHERE p.projectId=pId AND p.isDeleted=0;
		ELSEIF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 and p.isInDraft=0)THEN
			SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds,p.coverImage, p.projectPartner,(SELECT JSON_OBJECT('updatesId',updatesId,'updateTitle',updateTitle,'updateDescription',updateDescription,'updateMedia',updateMedia,'updateCommentLikes',updateCommentLikes,'updateCommentLikedUserIds',updateCommentLikedUserIds,'createdOn',createdOn,'commentsCount',(SELECT COUNT(commentId) FROM `comments` WHERE updatesId=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId ) AND projectId=pId) ,'previousUpdatesCount',(SELECT COUNT(u1.updatesId) FROM `updates` u1  WHERE u1.projectId=pId AND u1.updatesId!=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId )))FROM updates u WHERE  u.projectId=pId AND u.updatesId=(SELECT MAX(updatesId)FROM updates  WHERE projectId=pId))AS updatesDetails  FROM `project` p  WHERE p.projectId=pId AND p.isDeleted=0; 
		else
			SELECT 'ProjectId not found' AS message;
		END IF;
	else
		if exists(select p. * from `project` p join `re_developer` r on p.userId=r.userId where p.projectId=pId and p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1)then
			SELECT JSON_CONTAINS((SELECT viewedUserId FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(uId AS JSON),'$')into @result;
			if @result=0 then	
				UPDATE `project`p SET p.views=p.views+1, p.viewedUserId=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(viewedUserId,'$',CAST(uId AS JSON))FROM `project` WHERE projectId=pId) AS viewList) WHERE p.projectId=pId; 
			end if;
				SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds,p.coverImage, p.projectPartner,(SELECT JSON_OBJECT('updatesId',updatesId,'updateTitle',updateTitle,'updateDescription',updateDescription,'updateMedia',updateMedia,'updateCommentLikes',updateCommentLikes,'updateCommentLikedUserIds',updateCommentLikedUserIds,'createdOn',createdOn,'commentsCount',(SELECT COUNT(commentId) FROM `comments` WHERE updatesId=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId ) AND projectId=pId) ,'previousUpdatesCount',(SELECT COUNT(u1.updatesId) FROM `updates` u1  WHERE u1.projectId=pId AND u1.updatesId!=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId )))FROM updates u WHERE  u.projectId=pId AND u.updatesId=(SELECT MAX(updatesId)FROM updates  WHERE projectId=pId))AS updatesDetails  FROM `project` p  WHERE p.projectId=pId AND p.isDeleted=0; 
		else
			select 'ProjectId not found' as message;
		end if;	
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getProjectByProjectIdForNeighbours` */;

DELIMITER ;;
CREATE PROCEDURE `getProjectByProjectIdForNeighbours`(in _userId int, in pId int)
BEGIN
	if exists(select p.* from `project` p join `re_developer` re on p.userId=re.userId where p.projectId=pId and p.isInDraft=0 and isDeleted=0 and re.isActive=1) then
		SELECT 'Success' AS message,_userId as userId, p.benefit,
        (select JSON_OBJECT("projectId",p.projectId, "projectName",p.projectName, "projectAddress",p.projectAddress, "zipCode",p.zipCode, "latitude",p.latitude, "longitude",p.longitude,"property", (select json_object("buidlingHeight",p.buidlingHeight, "propertySize",p.propertySize, "floorPlan",p.floorPlan,"residentialUnits",p.residentialUnits, "maximumCapacity",p.maximumCapacity)),"projectDescription",p.projectDescription, "presentationVideo",p.presentationVideo, "projectType",p.projectType, "coverImage",p.coverImage, "projectImages", p.images)) as projectDetails,
		(select json_object("orgName", 'Urban Conversions', "orgImage", 'url', "orgType", 'type', "orgLinks", (select json_object("facebook", 'url', "twitter", 'url', "linkedIn", 'url')), "orgDescription", 'description')) AS organizationDetails,
		(SELECT JSON_MERGE(
		(SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
        'cardStatus', if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1, 'agree',if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1,'disAgree', null)), null),
        'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))),'[]')FROM `project_cards` pc WHERE pc.projectId=p.projectId AND pc.staticCardId IS NULL AND pc.isDeleted=0),
		(SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',psc.cardTitle,'cardIcon',psc.cardIcon,'cardDescription',psc.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
        'cardStatus', if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1, 'agree',if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = _userId and projectId = p.projectId) = 1,'disAgree', null)), null),
        'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = _userId and projectId = p.projectId and cardId = pc.cardId),
        'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
        'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=p.projectId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', _userId) is not null), true, false)),
        'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = _userId and stc.topicId =  pcst.topicId and stc.projectId = p.projectId)))
		FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=p.projectId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `project_static_cards` psc ON pc.staticCardId=psc.staticCardId WHERE pc.projectId=p.projectId AND pc.staticCardId IS NOT NULL AND pc.isDeleted=0))) 
		AS cardDetails,
        if(exists(select * from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId),(select cardsReviewedCount from `project_cards_statusmeter` where projectId=p.projectId and userId=_userId), FALSE) cardsReviewedCount
		FROM project p JOIN re_developer r ON r.userId = p.userId 
		WHERE r.isActive = 1 AND  p.isDeleted = 0 AND  isInDraft = 0 and p.projectId = pId;
        
		#SELECT JSON_CONTAINS((SELECT viewedUserId FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(requestId  AS JSON),'$')INTO @result;
		#IF @result=0 THEN	
		#	UPDATE `project`p SET p.views=p.views+1, p.viewedUserId=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(viewedUserId,'$',CAST(requestId  AS JSON))FROM `project` WHERE projectId=pId) AS viewList) WHERE p.projectId=pId; 
		#END IF;
		/* if exists(select * from `project_cards_statusmeter` where projectId=pId and userId=requestId) then			
			SELECT 'Success' AS message,p.projectId,requestId as userId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity,p.projectDescription, p.presentationVideo, p.benefit, p.coverImage,
            p.images AS projectImages,
            'Urban Conversions' AS organizationName,
            (SELECT JSON_MERGE(
            (SELECT ifnull(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,
            'cardStatus',if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = requestId and projectId = pId) = 1, 'agree',
            if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = requestId and projectId = pId) = 1, 'disAgree', null)),
            'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = requestId and projectId = pId and cardId = pc.cardId),
            'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
            'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=pId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', requestId) is not null), true, false)),
            'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = requestId and stc.topicId =  pcst.topicId and stc.projectId = pId)))
            FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))),'[]')FROM `project_cards` pc WHERE pc.projectId=pId AND pc.staticCardId IS NULL AND pc.isDeleted=0),
            (SELECT ifNull(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',psc.cardTitle,'cardIcon',psc.cardIcon,'cardDescription',psc.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
            'cardStatus', if((select json_search(agreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = requestId and projectId = pId) = 1, 'agree',
            if((select json_search(disAgreeCardIds, 'one', pc.cardId) is not null from project_cards_statusmeter where userId = requestId and projectId = pId) = 1, 'disAgree', null)),
            'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = requestId and projectId = pId and cardId = pc.cardId),
            'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
            'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=pId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', requestId) is not null), true, false)),
            'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = requestId and stc.topicId =  pcst.topicId and stc.projectId = pId)))
            FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')
            FROM  project_cards pc JOIN `project_static_cards` psc ON pc.staticCardId=psc.staticCardId WHERE pc.projectId=pId AND pc.staticCardId IS NOT NULL AND pc.isDeleted=0))) 
            AS cardDetails ,pcs.cardsReviewedCount FROM `project`p join `project_cards_statusmeter` pcs on p.projectId=pcs.projectId WHERE p.projectId=pId AND p.isDeleted=0 and pcs.projectId=pId and pcs.userId=requestId;
			#SELECT 'Success' AS message,p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.benefit, p.benefitLikes,p.benefitLikedUserIds,p.coverImage,(SELECT JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription))FROM `project_cards` pc WHERE pc.cardId NOT IN ((SELECT pc.cardId WHERE FIND_IN_SET(pc.cardId,pcs.cardIds))) AND pc.projectId=pId AND pc.isDeleted=0) AS cardDetails,pcs.cardsReviewedCount FROM `project`p join `project_cards_statusmeter` pcs on p.projectId=pcs.projectId WHERE p.projectId=pId AND p.isDeleted=0 and pcs.projectId=pId and pcs.userId=requestId;
			#SELECT 'Success' AS message,p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.benefit, p.benefitLikes,p.benefitLikedUserIds,p.coverImage,(SELECT JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription))FROM `project_cards` pc WHERE pc.cardId NOT IN (SELECT xval FROM JSON_TABLE(pcs.cardIds,"$[*]" COLUMNS(xval VARCHAR(100) PATH "$")) AS  jt1) AND pc.projectId=pId AND pc.isDeleted=0 ) AS cardDetails,pcs.cardsReviewedCount FROM `project`p join `project_cards_statusmeter` pcs on p.projectId=pcs.projectId WHERE p.projectId=pId AND p.isDeleted=0 and pcs.projectId=pId and pcs.userId=requestId;
		else
			SELECT 'Success' AS message,p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.projectDescription, p.presentationVideo, p.benefit,p.coverImage,
			p.images AS projectImages,
            'Urban Conversions' AS organizationName,
            (SELECT JSON_MERGE(
            (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,
            'cardStatus',null,
            'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = requestId and projectId = pId and cardId = pc.cardId),
            'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
            'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=pId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', requestId) is not null), true, false)),
            'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = requestId and stc.topicId =  pcst.topicId and stc.projectId = pId)))
            FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))),'[]')FROM `project_cards` pc WHERE pc.projectId=pId AND pc.staticCardId IS NULL AND pc.isDeleted=0),
            (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',psc.cardTitle,'cardIcon',psc.cardIcon,'cardDescription',psc.cardDescription,'createdOn',pc.createdOn,'modifiedOn',pc.modifiedOn,'cardAgreeCount',pc.cardAgreeCount,'cardDisAgreeCount',pc.cardDisAgreeCount,
            'cardStatus',null,
            'topicComment',(select JSON_ARRAYAGG(comment) from topics_comments where userId = requestId and projectId = pId and cardId = pc.cardId),
            'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription,
            'topicLiked',(select if((select json_search((SELECT topicLikedUserIds FROM`project_cards_sub_topics`WHERE projectId=pId AND cardId=pc.cardId AND topicId=pcst.topicId), 'one', requestId) is not null), true, false)),
            'subTopicComments',(select json_arrayagg(comment) from sub_topics_comments stc where stc.userId = requestId and stc.topicId =  pcst.topicId and stc.projectId = pId)))
            FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')
            FROM  project_cards pc JOIN `project_static_cards` psc ON pc.staticCardId=psc.staticCardId WHERE pc.projectId=pId AND pc.staticCardId IS NOT NULL AND pc.isDeleted=0))) 
            AS cardDetails, FALSE AS cardsReviewedCount FROM `project`p  WHERE p.projectId=pId AND p.isDeleted=0 ;
			#SELECT 'Success' AS message,p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.benefit, p.benefitLikes,p.benefitLikedUserIds,p.coverImage,(SELECT JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription))FROM `project_cards` pc WHERE pc.projectId=pId AND pc.isDeleted=0 ) AS cardDetails, false as cardsReviewedCount FROM `project`p  WHERE p.projectId=pId AND p.isDeleted=0 ;
		end if; */
	else  
		select 'Project not found' as message;
	end if;	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getProjectByProjectIdForREDeveloper` */;

DELIMITER ;;
CREATE PROCEDURE `getProjectByProjectIdForREDeveloper`(in pId int,in uId int)
BEGIN
	IF EXISTS (SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId = r.userId WHERE p.projectId = pId AND p.isDeleted = 0 AND r.isActive = 1 AND p.isInDraft is true and p.userId = uId) THEN
		SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, 
			p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan, p.residentialUnits, 
			p.maximumCapacity, p.thisProjectNumberLikes,p.projectDescription, p.presentationVideo,p.benefit,
			p.isInDraft, p.coverImage,p.images,p.organisationId,
        (select json_object('id', id, 'name', name, 'type', type,'coverImage', coverImage,'description', description,'icon', icon) from organisations where id = p.organisationId) as organisation,
        (SELECT JSON_ARRAYAGG(json_object('id', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'isCompleted', isCompleted)) FROM project_phase_status WHERE projectId = p.projectId) as phaseStatus,
        (SELECT JSON_ARRAYAGG(json_object('id', id, 'name', o.name, 'type', o.type,'coverImage', o.coverImage,'description', o.description,'icon', o.icon)) FROM project p
				CROSS JOIN JSON_TABLE(p.projectPartner, '$[*]' COLUMNS (partnerId INT PATH '$')) pt
				JOIN organisations o ON o.id = pt.partnerId
				WHERE p.projectId = pId) as newPartnerOrganisations,

        /*(SELECT JSON_ARRAYAGG(JSON_OBJECT('imageId',imageId,'projectId',projectId,'image',image,'imageDescription',imageDescription)) FROM `project_images` WHERE projectId=pID AND isDeleted=0) AS projectImagesDetails*/ /*(SELECT JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))) FROM `project_cards` pc WHERE pc.projectId=pId AND pc.isDeleted=0)AS projectCardsDetails,*/
        (SELECT JSON_MERGE((SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))),'[]')FROM `project_cards` pc 
			WHERE pc.projectId=pId AND pc.staticCardId IS NULL AND pc.isDeleted=0),(SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',psc.cardTitle,'cardIcon',psc.cardIcon,'cardDescription',psc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `project_static_cards` psc ON pc.staticCardId=psc.staticCardId WHERE pc.projectId=pId AND pc.staticCardId IS NOT NULL AND pc.isDeleted=0))) AS projectCardsDetails FROM `project` p WHERE p.projectId=pId AND p.isDeleted is false and p.userId = uId;
	ELSEIF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 AND p.isInDraft is false and p.userId = uId)THEN
		SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress, p.zipCode, 
        p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan, p.residentialUnits, 
        p.maximumCapacity, p.thisProjectNumberLikes,p.projectDescription, p.presentationVideo,p.benefit,
        p.isInDraft, p.coverImage,p.images,
        (select json_object('id', id, 'name', name, 'type', type,'coverImage', coverImage,'description', description,'icon', icon) from organisations where id = p.organisationId) as organisation,
		(SELECT JSON_ARRAYAGG(json_object('id', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'isCompleted', isCompleted)) FROM project_phase_status WHERE projectId = p.projectId) as phaseStatus,
        (SELECT JSON_ARRAYAGG(json_object('id', id, 'name', o.name, 'type', o.type,'coverImage', o.coverImage,'description', o.description,'icon', o.icon)) FROM project p
				CROSS JOIN JSON_TABLE(p.projectPartner, '$[*]' COLUMNS (partnerId INT PATH '$')) pt
				JOIN organisations o ON o.id = pt.partnerId
				WHERE p.projectId = pId) as newPartnerOrganisations,
        /*(SELECT JSON_ARRAYAGG(JSON_OBJECT('imageId',imageId,'projectId',projectId,'image',image,'imageDescription',imageDescription)) FROM `project_images` WHERE projectId=pID AND isDeleted=0) AS projectImagesDetails,*/
        /*(SELECT JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))) FROM `project_cards` pc WHERE pc.projectId=pId AND pc.isDeleted=0)AS projectCardsDetails*/ 
        (SELECT JSON_MERGE((SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',pc.cardTitle,'cardIcon',pc.cardIcon,'cardDescription',pc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0))),'[]')FROM `project_cards` pc WHERE pc.projectId=pId AND pc.staticCardId IS NULL AND pc.isDeleted=0),
        (SELECT IFNULL(JSON_ARRAYAGG(JSON_OBJECT('cardId',pc.cardId,'staticCardId',pc.staticCardId,'projectId',pc.projectId,'cardTitle',psc.cardTitle,'cardIcon',psc.cardIcon,'cardDescription',psc.cardDescription,'subTopics',(SELECT JSON_ARRAYAGG(JSON_OBJECT('topicId',pcst.topicId,'cardId',pcst.cardId,'projectId',pcst.projectId,'topicTitle',pcst.topicTitle,'topicImage',pcst.topicImage,'topicDescription',pcst.topicDescription))FROM `project_cards_sub_topics` pcst WHERE pcst.projectId=pId AND pcst.cardId=pc.cardId AND pcst.isDeleted=0 ))),'[]')FROM  project_cards pc JOIN `project_static_cards` psc ON pc.staticCardId=psc.staticCardId WHERE pc.projectId=pId AND pc.staticCardId IS NOT NULL AND pc.isDeleted=0))) AS projectCardsDetails 
        FROM `project` p WHERE p.projectId=pId AND p.isDeleted is false and p.userId = uId;
	ELSE
		SELECT 'Project not found' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getProjectCardSubtopicBycardId` */;

DELIMITER ;;
CREATE PROCEDURE `getProjectCardSubtopicBycardId`(in pId int,in cId int)
BEGIN
		IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId join `project_cards` pc on pc.projectId=p.projectId join `project_cards_sub_topics`st on pc.cardId=st.cardId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 AND p.isInDraft=0 and pc.cardId=cId and st.cardId=cId and st.isDeleted=0)THEN
			select 'Success' as message,cardId, topicId, topicTitle, topicDescription,topicImage,topicLikedUserIds from`project_cards_sub_topics` where projectId=pId and cardId=cId and isDeleted=0;
		else
			select 'Invalid request' as message;
		end if;
	END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getProjectDetails` */;

DELIMITER ;;
CREATE PROCEDURE `getProjectDetails`(in pId int,in uId int)
BEGIN
	/*if exists(select p.*,p.userId from `project` p join `re_developer` r on p.userId=r.userId where p.projectId=pId and p.userId=uId and  p.isDeleted=0 and r.isActive=1) then	
			SELECT 'Success' as message, projectType,projectName,projectAddress,zipCode,latitude,longitude,buidlingHeight,propertySize,floorPlan,residentialUnits,maximumCapacity,projectDescription,presentationVideo,projectImage,benefit,section,coverImage FROM project WHERE projectId=pId AND isDeleted=0;
		else
			select 'Invalid request' as message;
		end if;*/
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getReUsers` */;

DELIMITER ;;
CREATE PROCEDURE `getReUsers`(IN _limit INT, IN _offset INT, IN _userSearch VARCHAR(50), IN _uId INT)
BEGIN
    SET @db_name = DATABASE();
    SET @whereCondition = '';

    IF _userSearch IS NOT NULL AND _uId IS NULL THEN
        SET @whereCondition = CONCAT('AND (firstName LIKE "%', _userSearch, '%" OR surName LIKE "%', _userSearch, '%")');
    END IF;

    IF _userSearch IS NULL AND _uId IS NOT NULL THEN
        SET @whereCondition = CONCAT(' AND userId = ', _uId);
    END IF;

    SET @_condition = CONCAT( ' LIMIT ', _limit, ' OFFSET ', _offset);

    SET @sql = CONCAT(
        'SELECT ',
        (SELECT REPLACE(GROUP_CONCAT(COLUMN_NAME), 'password,', '')
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 're_developer' AND TABLE_SCHEMA = @db_name),
        ' FROM re_developer WHERE isActive = true ',@whereCondition, @_condition
    );
	
	SET @totalCount = CONCAT('SELECT COUNT(*)  as totalCount FROM re_developer WHERE isActive = true ', @whereCondition);
     
    PREPARE stmt1 FROM @sql;
    EXECUTE stmt1;  
    PREPARE stmt2 FROM @totalCount;
    EXECUTE stmt2;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getSectionCardByProjectId` */;

DELIMITER ;;
CREATE PROCEDURE `getSectionCardByProjectId`(in pId int)
BEGIN
		IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 AND p.isInDraft=0)THEN
			select 'Success' as message, sectionId, sectionTitle, sectionDescription,sectionImage, sectionLikes,sectionLikedUserId from`project_section` where projectId=pId;
		else
			select 'Project not found' as message;
		end if;
	END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getUserNotifications` */;

DELIMITER ;;
CREATE PROCEDURE `getUserNotifications`(IN requestId INT ,IN uType VARCHAR(30))
BEGIN
	IF uType='neighbours'THEN		
		SELECT 'Success' AS message,isNewProjectsYourArea,isUpdatesProjectYourArea,isCommentApprovals,isResponsesYourComments,isReceiveEmails,isCommentApprovalByEmail,isResponsesYourCommentsByEmail,isNewDevelopments,isFeatureUpdates,isAboutYimby,isAccountSecurity,isDarkMode from `neighbours`  WHERE userId=requestId;
			
	ELSE
		SELECT 'Success' AS message,isNewResponsesByProject,isProjectStatusByTeam,isYimbyUpdates,isReceiveEmails,isNewFeedbackByProject,isProjectSummaries,isProjectStatusChangeByTeam,isTipsYimbyAcademy,isFeatureUpdates,isNewsAboutYimby from `re_developer` WHERE userId=requestId;
	END IF;	
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getUserNotificationSettings` */;

DELIMITER ;;
CREATE PROCEDURE `getUserNotificationSettings`(IN requestId INT ,IN uType VARCHAR(30))
BEGIN

	IF uType='neighbours'THEN		

		SELECT 'Success' AS message,isNewProjectsYourArea,isUpdatesProjectYourArea,isCommentApprovals,isResponsesYourComments,isReceiveEmails,/*isCommentApprovalByEmail,*/isResponsesYourCommentsByEmail,/*isNewDevelopments,*/isFeatureUpdates,isAboutYimby,isAccountSecurity,isThemesMode FROM `neighbours`  WHERE userId=requestId;

			

	ELSE

		SELECT 'Success' AS message,isNewResponsesByProject,
                            isProjectStatusChangeByTeam,
                            isYimbyUpdates,
                            isReceiveEmails,
                            isNewFeedbackByProject,
                            isProjectCompletion,
                            isFeatureUpdates,
                            isNewsAboutYimby,
                            isAccountOrSecurityIssues from `re_developer` WHERE userId=requestId;

	END IF;	

	

END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `getUserProfile` */;

DELIMITER ;;
CREATE PROCEDURE `getUserProfile`(In requestId int ,in uType varchar(30))
BEGIN

	if uType='neighbours'then

		select 'Success' as message, userId,firstName,surName,email,/*streetAddress,city,state,zipCode*/address,latitude,longitude,`profile`,isThemesMode,if((SELECT count(*) FROM neighbour_survey_answers where userId = requestId) = 4, true, false) isSurveyDone from `neighbours` where userId=requestId and isActive=1;	

	else

		SELECT 'Success' AS message, userId,firstName,surName,email, profilePhoto,organisationId,organisationName as organisation,phoneNumber from `re_developer` WHERE userId=requestId AND isActive=1;	

	end if;

END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertNewAdmin` */;

DELIMITER ;;
CREATE PROCEDURE `insertNewAdmin`(IN userEmail VARCHAR(255), IN password1 text, IN fName VARCHAR(255), IN sName VARCHAR(255))
BEGIN
	IF EXISTS(SELECT * FROM admins WHERE email = userEmail and isActive is true) THEN
		SELECT 'Email already registered' AS message;
	ELSE
		INSERT INTO admins(email, `password`, firstName, surName) VALUES(userEmail, password1, fName, sName);
		SELECT LAST_INSERT_ID() INTO @uId;
		SELECT 'Success' AS message,'admin' AS userType,userId,firstName,surName,email,password,isActive,createdOn,modifiedOn,lastLoggedAt FROM admins WHERE userId=@uId;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertNewNeighbours` */;

DELIMITER ;;
CREATE PROCEDURE `insertNewNeighbours`(IN userEmail VARCHAR(255), IN password1 text, IN fName VARCHAR(255), IN sName VARCHAR(255), IN adrs text, IN lat DECIMAL(9,6),IN `long` DECIMAL(9,6))
BEGIN

	IF EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail and isActive is true) THEN

		SELECT 'Email already registered' AS message;

	ELSE

		INSERT INTO `neighbours`(email, `password`, firstName, surName,address,latitude,longitude) VALUES(userEmail, password1, fName, sName,adrs,lat,`long`);

		SELECT LAST_INSERT_ID() INTO @uId;

		SELECT 'Success' AS message,'neighbours' AS userType,userId,firstName,surName,email,`password`,address,/*zipCode*/`profile`,isActive,createdOn,modifiedOn,lastLoggedAt,isThemesMode FROM `neighbours` WHERE userId=@uId;

	END IF;

END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertNewREDeveloper` */;

DELIMITER ;;
CREATE PROCEDURE `insertNewREDeveloper`(IN _firstName VARCHAR(255), IN _surName varchar(50), In _email varchar(50))
BEGIN
	IF EXISTS(SELECT * FROM `re_developer` WHERE email = _email) /*or EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail)*/ THEN
		SELECT 'Email already registered' AS message;
	ELSE
		INSERT INTO `re_developer`(firstName, surName, email)VALUES(_firstName, _surName, _email);
		SELECT LAST_INSERT_ID() INTO @uId; 
		SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName,'subham@4screenmedia.com' email,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE userId=@uId;
		select * from templates where id = 4;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertPushNotification` */;

DELIMITER ;;
CREATE PROCEDURE `insertPushNotification`(in _fromUserId int, in _projectId int, in _cardId int, in _activityId int, in _activityType varchar(40), in _fromUserType varchar(20), in beHeardCId int, in subTopicCId int)
BEGIN
	if(_fromUserType = 'neighbours') then
		set @toUserId = (select re.userId from project p left join re_developer re on re.userId = p.userId where p.projectId = _projectId and p.isDeleted is false);
        set @fromUserName = (select concat(firstName, ' ', surName) from neighbours where userId = _fromUserId);
        set @projectName = (select projectName from project where projectId = _projectId);
        set @toUserType = 're_developer';
        set @message = "{{neighbourName}} commented on your project {{projectName}}";
        set @message = replace(replace(@message, '{{neighbourName}}', @fromUserName), '{{projectName}}', @projectName);
		if(beHeardCId is not null) then
			set @commentType = 'BE_HEARD_COMMENT';
		elseif(subTopicCId is not null) then
			set @commentType = 'SUB_TOPIC_COMMENT';
		end if;
        select _fromUserId, _fromUserType, @toUserId, @toUserType, _activityId, _activityType, _projectId, @message, @commentType;
		insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, message, commentType) values (_fromUserId, _fromUserType, @toUserId, @toUserType, _activityId, _activityType, _projectId, @message, @commentType);
        select last_insert_id() into @pushNotifId;
		select pn.*, 'commented on your project' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',createdOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId and userType = 're_developer' and deviceType = 'web') deviceToken from pushnotifications pn left join re_developer re on re.userId = pn.toUserId where pn.id = @pushNotifId and pn.toUserId = @toUserId and re.isYimbyUpdates is true and pn.toUserType = 're_developer' and pn.activityType = _activityType;
    elseif(_fromUserType = 're_developer') then
		set @toUserType = 'neighbours';
		if(_activityType = 'UPDATE_PROJECT') then 
			set @toUserIds = (select JSON_ARRAYAGG(userId) from project_viewers where projectId = _projectId);
            set @i = 0;
            while(@i < json_length(@toUserIds)) do
				select JSON_EXTRACT(@toUserIds, CONCAT('$[',@i,']')) INTO @toUserId;
                set @pushNotifId = (select pn.id from pushnotifications pn left join project_viewers iv on iv.userId = pn.toUserId and iv.projectId = pn.projectId where pn.projectId = _projectId and pn.toUserId = @toUserId and pn.activityType = 'UPDATE_PROJECT' and pn.createdOn > iv.lastViewedOn and pn.isViewed is false);

				if(@pushNotifId is not null) then
					set @message = '{{updateCount}} updates have been posted on {{project_title}} project since you last viewed the project.';
                    set @updateCount = (select updateCount + 1 from pushnotifications where id = @pushNotifId);
                    set @projectTitle = (select projectName from project where projectId = _projectId);
					SELECT replace(replace(@message, '{{updateCount}}', @updateCount), '{{project_title}}', @projectTitle) into @message;
                    
					update pushnotifications set message = @message, updateCount = @updateCount where id = @pushNotifId;
                else
					set @message = 'An update has been posted on the {{project_title}} projects';
                    set @projectTitle = (select projectName from project where projectId = _projectId);
                    select replace(@message, '{{project_title}}', @projectTitle) into @message;
                    
                    insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, updateCount, message) values (_fromUserId, _fromUserType, @toUserId, @toUserType, _activityId, _activityType, _projectId, 1, @message);
                    select last_insert_id() into @pushNotifId;
                end if;
				-- select 'touserId' touserid, @toUserId;
				select pn.*, 'Project Updated' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',modifiedOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId) deviceToken from pushnotifications pn left join neighbours n on n.userId = pn.toUserId where pn.id = @pushNotifId and pn.fromuserId = _fromUserId and n.isUpdatesProjectYourArea is true;
                select @i + 1 into @i;
            end while;
		elseif(_activityType = 'UPDATE_PROJECT_STATUS') then
			set @toUserType = 're_developer';
			set @toUserIds = (select JSON_ARRAYAGG(re.userId) from project p 
			left join organisations org on org.id = p.organisationId 
			left join re_developer re on re.organisationId = org.id 
			where p.projectId = _projectId);
            select replace(@toUserIds, concat(_fromUserId, ', '), '') into @toUserIds; -- removed fromUserId from toUserId
			set @i = 0;
			while(@i < json_length(@toUserIds)) do
				set @projectName = (select projectName from project where projectId = _projectId);
				-- set @phaseStatusName = (select phaseName from project_phase_status where id = _activityId);
				set @message = "Status of {{projectName}} project has been modified";
				select replace(@message, '{{projectName}}', @projectName) into @message;
				select JSON_EXTRACT(@toUserIds, CONCAT('$[',@i,']')) INTO @toUserId;
				insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, message, commentType) values (_fromUserId, 'YIMBY', @toUserId, @toUserType, _activityId, _activityType, _projectId, @message, null);
				select last_insert_id() into @pushNotifId;
				select pn.*, 'project status updated' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',createdOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId and userType = 're_developer' and deviceType = 'web') deviceToken from pushnotifications pn left join re_developer re on re.userId = pn.toUserId where pn.id = @pushNotifId and pn.toUserId = @toUserId and re.isProjectStatusChangeByTeam is true and pn.toUserType = 're_developer' and pn.activityType = _activityType;
				select @i + 1 into @i;
			end while;
		elseif(_activityType = 'CREATE_PROJECT') then
			set @toUserIds = (select JSON_ARRAYAGG(n.userId) from project p join neighbours n where projectId = _projectId and (3959 * ACOS(COS(RADIANS(n.latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(n.longitude)) + SIN(RADIANS(n.latitude)) * SIN(RADIANS(p.latitude)))) < 20);
            set @i = 0;
            while(@i < json_length(@toUserIds)) do
				select JSON_EXTRACT(@toUserIds, CONCAT('$[',@i,']')) INTO @toUserId;
                set @pushNotifId = (select pn.id from pushnotifications pn left join project_viewers iv on iv.userId = pn.toUserId and iv.projectId = pn.projectId where pn.projectId = _projectId and pn.toUserId = @toUserId and pn.activityType = 'CREATE_PROJECT' and pn.createdOn > iv.lastViewedOn and pn.isViewed is false);
                set @message = 'new project {{project_title}} created nearby';
                set @projectTitle = (select projectName from project where projectId = _projectId);
                SELECT replace(@message, '{{project_title}}', @projectTitle) into @message;
                insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, updateCount, message) values (_fromUserId, _fromUserType, @toUserId, @toUserType, _activityId, _activityType, _projectId, 1, @message);
                select last_insert_id() into @pushNotifId;
                select pn.*, 'New Project Added' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',createdOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId) deviceToken from pushnotifications pn left join neighbours n on n.userId = pn.toUserId where pn.id = @pushNotifId and pn.fromuserId = _fromUserId and n.isNewProjectsYourArea is true;
                select @i + 1 into @i;
            end while;
        else
			set @message = '{{re_developer_name}} responded to your comment on {{project_title}}';
            set @re_developerName = (select concat(firstName, ' ', surName) from re_developer where userId = _fromUserId and isActive is true);
            set @projectTitle = (select projectName from project where projectId = _projectId);
            select replace(replace(@message, '{{re_developer_name}}', @re_developerName), '{{project_title}}', @projectTitle) into @message;
            
			set @toUserId = 0;
            set @commentType = '';
			if(beHeardCId is not null) then
				set @toUserId = (select userId from be_heard_comments where commentId = beHeardCId);
                set @commentType = 'BE_HEARD_COMMENT';
			elseif(subTopicCId is not null) then
				set @toUserId = (select userId from sub_topics_comments where commentId = subTopicCId);
                set @commentType = 'SUB_TOPIC_COMMENT';
			end if;
			insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, message, commentType) values (_fromUserId, _fromUserType, @toUserId, @toUserType, _activityId, _activityType, _projectId, @message, @commentType);
            select last_insert_id() into @pushNotifId;
			select pn.*, 'Reply to your comment' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',createdOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId) deviceToken from pushnotifications pn left join neighbours n on n.userId = pn.toUserId where pn.id = @pushNotifId and pn.fromuserId = _fromUserId and n.isResponsesYourComments is true;
			#select * from pushtokendetails where userId = @toUserId;
        end if;
	elseif(_fromUserType = 'yimby') then
		set @toUserIds = (select JSON_ARRAYAGG(re.userId) from project p 
			left join organisations org on org.id = p.organisationId 
			left join re_developer re on re.organisationId = org.id 
			where p.projectId = _projectId);
		set @i = 0;
        while(@i < json_length(@toUserIds)) do
			set @toUserType = 're_developer';
            set @projectName = (select projectName from project where projectId = _projectId);
            set @phaseStatusName = (select phaseName from project_phase_status where id = _activityId);
            set @message = "{{phase_name}} of the {{projectName}} projects is ending in 24 hrs";
            select replace(replace(@message, '{{phase_name}}', @phaseStatusName), '{{projectName}}', @projectName) into @message;
			select JSON_EXTRACT(@toUserIds, CONCAT('$[',@i,']')) INTO @toUserId;
            insert into pushnotifications (fromUserId, fromUserType, toUserId, toUserType, activityId, activityType, projectId, message, commentType) values (_fromUserId, 'YIMBY', @toUserId, @toUserType, _activityId, _activityType, _projectId, @message, null);
            select last_insert_id() into @pushNotifId;
            select pn.*, 'project phase status' title, (select JSON_ARRAYAGG(JSON_OBJECT('id',id, 'deviceId',deviceId, 'userId',userId, 'deviceType',deviceType, 'deviceToken',deviceToken, 'createdAt',createdOn, 'modifiedAt',createdOn, 'platformEndPoint',platformEndPoint, 'userType',userType)) from device_token where userId = @toUserId and userType = 're_developer' and deviceType = 'web') deviceToken from pushnotifications pn left join re_developer re on re.userId = pn.toUserId where pn.id = @pushNotifId and pn.toUserId = @toUserId and re.isYimbyUpdates is true and pn.toUserType = 're_developer' and pn.activityType = _activityType;
            select @i + 1 into @i;
        end while;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertSessionToken` */;

DELIMITER ;;
CREATE PROCEDURE `insertSessionToken`(IN uId INT,IN sessionToken TEXT,IN uType varchar(30))
BEGIN
	
	INSERT INTO `session`(userId,token,userType) VALUES(uId,sessionToken,uType);		
	IF uType='neighbours' THEN			
		UPDATE neighbours SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
	elseif uType='admin' then
		update admins set lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
	ELSE
		UPDATE `re_developer` SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
	END IF;	
	
	/*IF EXISTS(SELECT * FROM `session` WHERE userId = uId AND userType = uType and isAdmin=0) THEN
		UPDATE `session` SET token = sessionToken, userType=uType WHERE userId = uId AND userType=uType and isAdmin=0;
			if uType='neighbours' then
				UPDATE neighbours SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
			else
				UPDATE `re_developer` SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
			end if;		
	ELSE
		INSERT INTO `session`(userId,token,userType) VALUES(uId,sessionToken,uType);		
			IF uType='neighbours' THEN			
				UPDATE neighbours SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
			ELSE
				UPDATE `re_developer` SET lastLoggedAt = CURRENT_TIMESTAMP() WHERE userId = uId;
			END IF;
	END IF;*/
		
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `insertTemporaryToken` */;

DELIMITER ;;
CREATE PROCEDURE `insertTemporaryToken`(IN tempTok VARCHAR(30), IN uId INT,in uType varchar(255))
BEGIN
	IF EXISTS(SELECT * FROM `temporary_session` WHERE userId = uId  AND userType=uType) THEN
		UPDATE `temporary_session` SET token = tempTok, userType=uType WHERE userId = uId and userType=uType;
	ELSE
		INSERT INTO `temporary_session`(userId, token,userType) VALUES(uId, tempTok,uType);
	END IF;
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `isViewed` */;

DELIMITER ;;
CREATE PROCEDURE `isViewed`(in _uId int, in _pId int, in _pnId int, in _isResponded TINYINT)
BEGIN
	if(_pnId is not null and exists(select * from pushnotifications where id = _pnId)) then
		update pushnotifications set isViewed = true where id = _pnId;
    end if;
	if (_pId is not null and exists(select p.* from `project` p join `re_developer` re on p.userId=re.userId where p.projectId=_pId and p.isInDraft=0 and isDeleted=0 and re.isActive=1)) then
		if(exists(select * from project_viewers where userId = _uId and projectId = _pId)) then
			update project_viewers set viewedCount = viewedCount + 1 where userId = _uId and projectId = _pId;
            update project_viewers set isResponded = _isResponded where isResponded is false and _isResponded is true and userId = _uId and projectId = _pId;
        else
			insert into project_viewers (userId, projectId, viewedCount, isResponded) values (_uId, _pId, 1, _isResponded);
        end if;
        
		if((select viewedUserId from project where projectId = _pId) is null) then
			update project set viewedUserId = concat('[',_uId,']'), views = views + 1 where projectId = _pId;
		else
			SELECT JSON_CONTAINS((SELECT viewedUserId FROM`project`WHERE projectId=_pId AND isDeleted=0),CAST(_uId  AS JSON),'$')INTO @result;
			IF @result=0 THEN	
				UPDATE `project`p SET p.views=p.views+1, p.viewedUserId=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(viewedUserId,'$',CAST(_uId  AS JSON))FROM `project` WHERE projectId=_pId) AS viewList) WHERE p.projectId=_pId; 
			END IF;
		end if;
        
        SELECT JSON_CONTAINS((SELECT viewedUserId FROM`project`WHERE projectId=_pId AND isDeleted=0),CAST(_uId  AS JSON),'$')INTO @result;
        if @result != 0 then
			select true as isUpdated, true as isProjectFound;
		else
			select false as isUpdated, true as isProjectFound;
		end if;
	else
		select false as isUpdated, false as isProjectFound;
	end if;	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `loginWithTempToken` */;

DELIMITER ;;
CREATE PROCEDURE `loginWithTempToken`(in uId int,in tempTok text)
BEGIN
	if exists (select * from `temporary_session` where token=tempTok and userId=uId)then
		select userType into @uType from `temporary_session` where token= tempTok;	
		DELETE FROM `temporary_session` WHERE token=tempTok;
		if @uType='neighbours' then
			SELECT 'Success' AS message,@uType as userType , `neighbours`.* FROM `neighbours` WHERE userId = uId;
		else
			select 'Success' as  message,@uType as userType, `re_developer`.* from `re_developer` where userId=uId;
		end if;
	else
		SELECT 'User session not found' AS message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `logoutUser` */;

DELIMITER ;;
CREATE PROCEDURE `logoutUser`(in tok text ,in uId int,in dId text,IN userType VARCHAR(30))
BEGIN
	IF EXISTS(SELECT * FROM `session` WHERE token=tok AND userId=uId)THEN
		DELETE FROM `session` WHERE token=tok AND userId=uId AND isAdmin=0;
		IF userType='neighbours' THEN
			DELETE FROM `device_token` WHERE deviceId=dId AND userId=uId;
		END IF;
		SELECT 'Success' AS message;
	ELSE
		SELECT 'Invalid user session' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `pushNotificationList` */;

DELIMITER ;;
CREATE PROCEDURE `pushNotificationList`(in _userId int, in _userType varchar(20), in _limit int, in _offset int)
BEGIN
	if(_userType = 'neighbours') then
		select pn.*,
		if(pn.commentType is not null,
			if(pn.commentType = 'BE_HEARD_COMMENT',
				(select json_object('commentId',commentId,'userId',userId,'projectId',projectId,'cardId',cardId,'comment',`comment`,'isDeleted',isDeleted,'createdOn',createdOn,'modifiedOn',modifiedOn,'isViewed',isViewed) from be_heard_comments where commentId = (select beHeardCommentId from commentreplies where replyId = pn.activityId)),
				(select json_object('commentId',commentId,'userId',userId,'topicId',topicId,'projectId',projectId,'cardId',cardId,'comment',`comment`,'isDeleted',isDeleted,'createdOn',createdOn,'modifiedOn',modifiedOn) from sub_topics_comments where commentId = (select subTopicCommentId from commentreplies where replyId = pn.activityId))
			),
			null) as commentInfo,
		pn.toUserId,
		p.coverImage,
		(select json_object('firstName',firstName, 'surName',surName, 'profilePhoto',profilePhoto, 'organisationId',organisationId) from re_developer where userId = pn.fromUserId) as re_developer from pushnotifications pn
		left join project_viewers pv on pv.userId = pn.toUserId and pv.projectId = pn.projectId left join project p on p.projectId = pn.projectId
		where (activityType = 'REPLY_TO_COMMENT' and pn.id in (select max(id) from pushnotifications where toUserId = _userId and activityType = 'REPLY_TO_COMMENT' and toUserType = _userType group by toUserId, projectId, commentType order by id)) or 
			  (activityType = 'UPDATE_PROJECT' and pn.toUserId = _userId and toUserType = _userType) or (activityType = 'CREATE_PROJECT' and pn.toUserId = _userId and toUserType = _userType)
		order by pn.id desc limit _limit offset _offset;
		#where pn.toUserId = _userId and pn.toUserType = _userType or (pn.activityType = 'UPDATE_PROJECT' and pn.createdOn > pv.lastViewedOn) order by pn.createdOn desc;
	elseif(_userType = 're_developer') then
		select pn.* from pushnotifications pn where toUserType = _userType and toUserId = _userId order by id desc limit _limit offset _offset;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `referToFriend` */;

DELIMITER ;;
CREATE PROCEDURE `referToFriend`(in _uId int, in _userType varchar(45), in  _emails  varchar(100) )
BEGIN
	insert into referToFriend (userId, userType, emails) values (_uId, _userType, _emails);
    Select body from templates where id = 4;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `removeProjectCardSubTopic` */;

DELIMITER ;;
CREATE PROCEDURE `removeProjectCardSubTopic`(in uId int, in pId int, in cId int, in TopId int)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN`re_developer` re ON p.userId=re.userId JOIN `project_cards` pc ON p.projectId=pc.projectId Join `project_cards_sub_topics` st on pc.cardId=st.cardId WHERE p.projectId=pId AND p.userId=uId AND p.isDeleted=0 AND re.isActive=1 AND pc.projectId=pId AND pc.cardId=cId and pc.isDeleted=0 AND st.topicId=topId and st.projectId=pId  and st.cardId=cId and st.isDeleted=0) THEN
		update `project_cards_sub_topics` set isDeleted=1 where topicId=topId and isDeleted=0;
		select 'Success' as message;
	else 
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `removeProjectCardSubTopicImage` */;

DELIMITER ;;
CREATE PROCEDURE `removeProjectCardSubTopicImage`(IN uId INT, IN pId INT, IN cId INT, IN TopId INT)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN`re_developer` re ON p.userId=re.userId JOIN `project_cards` pc ON p.projectId=pc.projectId JOIN `project_cards_sub_topics` st ON pc.cardId=st.cardId WHERE p.projectId=pId AND p.userId=uId AND p.isDeleted=0 AND re.isActive=1 AND pc.projectId=pId AND pc.cardId=cId AND pc.isDeleted=0 AND st.topicId=topId AND st.projectId=pId  AND st.cardId=cId AND st.isDeleted=0) THEN
		UPDATE `project_cards_sub_topics` SET topicImage=null WHERE topicId=topId AND isDeleted=0;
		SELECT 'Success' AS message;
	ELSE 
		SELECT 'Invalid request' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `removeProjectImage	` */;

DELIMITER ;;
CREATE PROCEDURE `removeProjectImage	`(in uId int, in pId int, in imgId int)
BEGIN
	if exists(select p.* from `project` p join`re_developer` re on p.userId=re.userId join `project_images` pimg on p.projectId=pimg.projectId where p.projectId=pId and p.userId=uId and p.isDeleted=0 and re.isActive=1 and pimg.projectId=pId and pimg.imageId=imgId and pimg.isDeleted=0) then
		update `project_images` set isDeleted=1 where projectId=pId and imageId=imgId;
		select 'Success' as message;
	else
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `removeProjectImage` */;

DELIMITER ;;
CREATE PROCEDURE `removeProjectImage`(IN uId INT, IN pId INT, IN imgId INT)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN`re_developer` re ON p.userId=re.userId JOIN `project_images` pimg ON p.projectId=pimg.projectId WHERE p.projectId=pId AND p.userId=uId AND p.isDeleted=0 AND re.isActive=1 AND pimg.projectId=pId AND pimg.imageId=imgId AND pimg.isDeleted=0) THEN
		UPDATE `project_images` SET isDeleted=1 WHERE projectId=pId AND imageId=imgId;
		SELECT 'Success' AS message;
	ELSE
		SELECT 'Invalid request' AS message;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `removeProjectVideo` */;

DELIMITER ;;
CREATE PROCEDURE `removeProjectVideo`(IN uId INT,IN pId INT)
BEGIN
	IF EXISTS(SELECT p.* FROM `project` p JOIN`re_developer` re ON p.userId=re.userId WHERE p.projectId=pId AND p.userId=uId AND p.isDeleted=0 AND re.isActive=1 ) THEN
		update `project` set presentationVideo=null where projectId=pId;
		select 'Success' as message;
	else 
		select 'Invalid request' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `replyToProjectComment` */;

DELIMITER ;;
CREATE PROCEDURE `replyToProjectComment`(in uId int,in uType varchar(30),in pId int ,in beHeardCId int,in subTopicCId int,in rComment text)
BEGIN
	if(beHeardCId is not null) then
		if exists(SELECT p.* FROM `project` p JOIN `re_developer` re ON re.userId = p.userId join be_heard_comments bhc on p.projectId=bhc.projectId WHERE p.projectId = pId and bhc.commentId=beHeardCId and p.isInDraft = 0 AND p.isDeleted = 0 and bhc.isDeleted=0 AND re.isActive = 1) then
			set @neighbourId = (select userId from be_heard_comments where commentId = beHeardCId);
			insert into `commentreplies` (userId,userType,projectId,beHeardCommentId,subTopicCommentId,`comment`, neighbourId)values(uId,uType,pId,beHeardCId,subTopicCId,rComment, @neighbourId);
            if exists(SELECT * FROM `neighbours` WHERE userId=(SELECT userId FROM `be_heard_comments` WHERE commentId=beHeardCId) and isReceiveEmails=1) then
				select 'Success' as message, last_insert_id() as commentId, n.userId, 'subham@4screenmedia.com' as email /*n.email*/, p.projectName, concat(n.firstName, ' ', n.surName) as userName, concat(re.firstName, ' ', re.surName) as re_userName
				from be_heard_comments bhc
                left join project p on p.projectId = bhc.projectId
                left join neighbours n on n.userId = bhc.userId
                left join re_developer re on re.userId = p.userId
                where re.userId = uId and p.projectId = pId and bhc.commentId = beHeardCId;
                select body from templates where id = 3;
            else
				SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
            end if;
		else
			select 'Invalid request' as message;
		end if;
	else 
		if exists(SELECT p.* FROM `project` p JOIN `re_developer` re ON re.userId = p.userId join sub_topics_comments stc on p.projectId=stc.projectId WHERE p.projectId = pId and stc.commentId=subTopicCId and p.isInDraft = 0 AND p.isDeleted = 0 and stc.isDeleted=0 AND re.isActive = 1) then
			set @neighbourId = (select userId from sub_topics_comments where commentId = subTopicCId);
            insert into `commentreplies` (userId,userType,projectId,beHeardCommentId,subTopicCommentId,`comment`, neighbourId)values(uId,uType,pId,beHeardCId,subTopicCId,rComment, @neighbourId);
            if exists(SELECT * FROM `neighbours` WHERE userId=(SELECT userId FROM `sub_topics_comments` WHERE commentId=subTopicCId) and isReceiveEmails=1) then
				select 'Success' as message,max(cr.replyId) as commentId, n.userId,'subham@4screenmedia.com' as email /*n.email*/, p.projectName, concat(n.firstName, ' ', n.surName) as userName, concat(re.firstName, ' ', re.surName) as re_userName
				from commentreplies cr
				left join sub_topics_comments stc on stc.commentId = cr.subTopicCommentId
				left join neighbours n on n.userId = stc.userId
				left join re_developer re on re.userId = cr.userId
				left join project p on p.userId = cr.userId
				where p.projectId = pId and stc.commentId = subTopicCId and cr.userId = uId
				group by cr.userId;
				select body from templates where id = 3;
            else 
				SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
            end if;
        else
			select 'Invalid request' as message;
        end if;
	end if;
	#IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId join `comments`c on p.projectId=c.projectId WHERE p.projectId = pId and c.commentId=ifnull(beHeardCId, subTopicCId) and c.commentStatus='approved' and p.isInDraft = 0 AND p.isDeleted = 0 and c.isDeleted=0 AND r.isActive = 1) THEN
	#	insert into `commentreplies` (userId,userType,projectId,beHeardCommentId,subTopicCommentId,`comment`)values(uId,uType,pId,beHeardCId,subTopicCId,rComment);
	#	select 'Success' as message;
	#else
	#	select 'Invalid request' as message;
	#end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateMyActivitesForREDeveloper` */;

DELIMITER ;;
CREATE PROCEDURE `updateMyActivitesForREDeveloper`(IN uId VARCHAR(255), IN pId INT, IN neighbourId VARCHAR(255), IN activity VARCHAR(75), `eventName` VARCHAR(255), IN beHeardCId INT,IN topicCId INT, IN rId INT)
BEGIN
	#if activity='projectComment' then
		insert into `re_developer_activities` (myId,`event`,activityType,neighboursId,beHeardCommentId,topicCommentId,projectId) values(uId,eventName,activity,neighbourId,beHeardCId,topicCId,pId);
		select 'Success' as message;
	#elseIF activity='topicComment' THEN
		#INSERT INTO `re_developer_activities` (myId,`event`,activityType,neighboursId,topicCommentId,projectId) VALUES(uId,eventName,activity,neighbourId,topicCId,pId);
		#SELECT 'Success' AS message;
	#end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateMyActivitiesForNeighbours` */;

DELIMITER ;;
CREATE PROCEDURE `updateMyActivitiesForNeighbours`(in uIds text ,in eventName text ,in activity VARCHAR(255),in developerId int,in pId int,in cId int,in rId int)
BEGIN
	INSERT INTO `neighbours_activities`(myId,`event`,activityType,re_developerId,projectId,commentId,replyId) SELECT userId, eventName, activity,developerId,pId,cId,rId FROM `neighbours` WHERE FIND_IN_SET(userId, uIds) AND isActive = 1;
	select 'Success' as message;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateMyPassword` */;

DELIMITER ;;
CREATE PROCEDURE `updateMyPassword`(in uId int,in uType varchar(30),in newPassword text)
BEGIN
	if uType='neighbours' then
		update `neighbours` set `password`=newPassword where userId=uId;
		select 'Success' as message;
	else
		update `re_developer` set `password`=newPassword WHERE userId=uId;
		SELECT 'Success' AS message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateNewREDeveloper` */;

DELIMITER ;;
CREATE PROCEDURE `updateNewREDeveloper`(IN userEmail VARCHAR(255), IN _password text)
BEGIN
	IF NOT EXISTS(SELECT * FROM `re_developer` WHERE email = userEmail) /*or EXISTS(SELECT  FROM `neighbours` WHERE email = userEmail)*/ THEN
		SELECT 'User not found' AS message;
	ELSE
		# INSERT INTO `re_developer`(email,`PASSWORD`) VALUES(userEmail, password1);
        UPDATE `re_developer` SET PASSWORD = _password WHERE email = userEmail;
		SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName,email,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE email = userEmail;
	END IF;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateProject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `updateProject`(
	IN uId INT, 
	IN uType VARCHAR(30), 
	IN pId INT,IN pCoverImage TEXT,
	IN pType VARCHAR(255), 
	IN pStatus VARCHAR(30),
	IN `phase` JSON,
	IN pBuidlingHeight VARCHAR(255),
	IN pPropertySize VARCHAR(255),
	IN pFloorPlan VARCHAR(255),
	IN pResidentialUnits VARCHAR(255),
	IN pMaximumCapacity VARCHAR(255),
	IN pPresentationVideo TEXT, 
	IN pProjectDescription VARCHAR(255), 
	IN newProjectimagesInsertQuery TEXT,
	IN projectImagesDeleteQuery TEXT,
	IN pBenefits JSON,
	IN updateCardsQuery TEXT, 
	IN updateSubTopicsQuery TEXT, 
	IN existsCardsInsertNewSubTopicsQuerys TEXT, 
	IN insertNewCardsQuery TEXT, 
	IN insertNewSubTopicQuery TEXT, 
	IN insertNewCardQueryList TEXT,
	IN isInDraftVal BOOL,/*in actionType varchar(30),*/
	IN deletedSubTopicIds TEXT)
BEGIN

	DECLARE i INT DEFAULT 0;	

	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.userId=uId AND( p.isInDraft = 0 OR p.isInDraft=1) AND p.isDeleted = 0 AND r.isActive = 1) THEN

		SELECT IsInDraft FROM `project` WHERE projectId=pId INTO @projectState;

		IF @projectSatat=0 AND isInDraftVal=1 THEN

			SELECT 'Cannot change to draft' AS message;

		ELSE

			UPDATE `project` SET coverImage=pCoverImage, projectType=pType,phaseStatus=(CASE WHEN `phase`!='null' THEN (SELECT JSON_ARRAY_APPEND(phaseStatus,'$',`phase`)) ELSE (phaseStatus) END), projectStatus=pStatus, buidlingHeight=pBuidlingHeight, propertySize=pPropertySize, floorPlan=pFloorPlan, residentialUnits=pResidentialUnits, maximumCapacity=pMaximumCapacity, presentationVideo=pPresentationVideo, projectDescription=pProjectDescription, benefit=pBenefits, isInDraft=(CASE WHEN (isInDraft=0) THEN 0 ELSE (isInDraftVal) END) WHERE projectId=pId;

			SET @query='';		

			SET @query=updateCardsQuery;

			PREPARE updateProjectCards FROM @query;

			EXECUTE updateProjectCards;

			DEALLOCATE PREPARE updateProjectCards;

			#delete project images

			IF projectImagesDeleteQuery!='null' THEN

				SET @query= projectImagesDeleteQuery;

				PREPARE deleteProjectImages FROM @query;

				EXECUTE deleteProjectImages;

				DEALLOCATE PREPARE deleteProjectImages;		

			END IF;

			#insert new project images

			IF newProjectimagesInsertQuery!='null' THEN

				SET @query= newProjectimagesInsertQuery;

				PREPARE insertProjectImages FROM @query;

				EXECUTE insertProjectImages;

				DEALLOCATE PREPARE insertProjectImages;

			END IF;

			#deleted project cards sub topic and sub topic related comments and Myactivites also deleted 

			IF deletedSubTopicIds!='null' THEN			

				UPDATE `project_cards_sub_topics` SET isDeleted=1 WHERE topicId IN(SELECT * FROM(SELECT pcst.topicId FROM `project_cards_sub_topics` pcst WHERE FIND_IN_SET(pcst.topicId,deletedSubTopicIds) AND pcst.projectId=pId) AS topicIds) AND projectId=pId;

				UPDATE `sub_topics_comments` SET isDeleted=1 WHERE topicId IN (SELECT * FROM(SELECT pcst.topicId FROM `project_cards_sub_topics` pcst WHERE FIND_IN_SET(pcst.topicId,deletedSubTopicIds) AND pcst.projectId=pId ) AS topicIds) AND projectId=pId;

				UPDATE `re_developer_activities`  SET isDeleted=1 WHERE topicCommentId IN (SELECT * FROM(SELECT stcm.commentId FROM `sub_topics_comments` stcm WHERE stcm.topicId IN(SELECT * FROM(SELECT pcst.topicId FROM `project_cards_sub_topics` pcst WHERE FIND_IN_SET(pcst.topicId,deletedSubTopicIds) AND pcst.projectId=pId )AS topicIds) AND stcm.projectId=pId)AS commentIds) AND projectId=pId; 

			END IF;

			# update project cards sub topic

			IF updateSubTopicsQuery!='null'	THEN

				SET @query= updateSubTopicsQuery;

				PREPARE updateProjectCardsSubTopics FROM @query;

				EXECUTE updateProjectCardsSubTopics;

				DEALLOCATE PREPARE updateProjectCardsSubTopics;

			END IF;

			# exists cards insert new sub topic

			IF existsCardsInsertNewSubTopicsQuerys!='null' THEN

				SET @query=existsCardsInsertNewSubTopicsQuerys;

				PREPARE existsCardsInsertNewSubTopics FROM @query;

				EXECUTE existsCardsInsertNewSubTopics;

				DEALLOCATE PREPARE existsCardsInsertNewSubTopics;

			END IF;

			#insert new cards

			IF insertNewCardsQuery!='null' THEN

				SET @query=insertNewCardsQuery;

				PREPARE insertNewProjectCards FROM @query;

				EXECUTE insertNewProjectCards;

				DEALLOCATE PREPARE insertNewProjectCards;

			END IF;

			# insert new project cards and subtopics

			IF insertNewSubTopicQuery!='null' THEN	

				SET @insertNewProjectCardsSubTopic='';			

				SET @insertNewProjectCardsSubTopic = insertNewSubTopicQuery;			

				WHILE i < JSON_LENGTH(insertNewCardQueryList) DO

					SET @cardId='';

					SELECT JSON_UNQUOTE(JSON_EXTRACT(insertNewCardQueryList,CONCAT('$[',i,']'))) INTO @query;

					PREPARE insertNewProjectCards FROM @query;

					EXECUTE insertNewProjectCards;

					SET @cardId=(SELECT LAST_INSERT_ID());

					SET @insertNewProjectCardsSubTopic=REPLACE(@insertNewProjectCardsSubTopic,CONCAT('cId',i),@cardId);

					DEALLOCATE PREPARE insertNewProjectCards;

					SELECT i + 1 INTO i;

				END WHILE;			

				SET @query=@insertNewProjectCardsSubTopic;

				PREPARE insertNewSubTopic FROM @query;

				EXECUTE insertNewSubTopic;

				DEALLOCATE PREPARE insertNewSubTopic;			

			END IF;

			IF @projectState=1 AND isInDraftVal=1 THEN 

			#if actionType='save' then

				SELECT 'Success' AS message,pId AS ProjectId;

			ELSEIF @projectState=1 AND isInDraftVal=0 THEN

			#elseif actionType='publishProject' then

				SELECT 'Success'AS message,'publishProject' AS actionType,JSON_ARRAYAGG(n.userId) AS userIds,p.projectName,(3959 * ACOS(COS(RADIANS(n.latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(n.longitude)) + SIN(RADIANS(n.latitude)) * SIN(RADIANS(p.latitude)))) AS distance FROM project p JOIN `neighbours` n ON n.latitude = p.latitude AND n.longitude=p.longitude WHERE n.isActive = 1 AND n.isNewProjectsYourArea=1 AND p.projectId=pId  HAVING distance <= 5 ORDER BY distance;

				#SELECT 'Success'AS message,JSON_ARRAYAGG(n.userId) AS userIds,p.projectName FROM `neighbours` n JOIN `project` p ON p.zipCode=n.zipCode  WHERE n.isNewProjectsYourArea=1 AND n.isActive=1 AND p.projectId=pId;	

			ELSEIF (@projectState=0 AND isInDraftVal=0)THEN

			#elseif actionType='publishUpdate' then

				SELECT 'Success'AS message,'publishUpdate' AS actionType,JSON_ARRAYAGG(n.userId) AS userIds,p.projectName,(3959 * ACOS(COS(RADIANS(n.latitude)) * COS(RADIANS(p.latitude)) *  COS(RADIANS(p.longitude) - RADIANS(n.longitude)) + SIN(RADIANS(n.latitude)) * SIN(RADIANS(p.latitude)))) AS distance FROM project p JOIN `neighbours` n ON n.latitude = p.latitude AND n.longitude=p.longitude WHERE n.isActive = 1 AND n.isNewProjectsYourArea=1 AND p.projectId=pId  HAVING distance <= 5 ORDER BY distance;			

				#SELECT 'Success'AS message,JSON_ARRAYAGG(n.userId) AS userIds,p.projectName FROM `neighbours` n JOIN `project` p ON p.zipCode=n.zipCode  WHERE n.isUpdatesProjectYourArea=1 AND n.isActive=1 AND p.projectId=pId;	

			END IF;				

		END IF;

	ELSE

		SELECT 'Invalid request' AS message;

	END IF;



END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateProjectInformationSection` */;

DELIMITER ;;
CREATE PROCEDURE `updateProjectInformationSection`(in pId int,in uId int,in uType varchar(30),in updateSection text)
BEGIN
	if uType='re_developer' then
		if exists(SELECT p.* FROM `project` p JOIN `re_developer` r ON r.userId = p.userId WHERE p.projectId = pId AND p.userId=uId AND p.isDeleted = 0 AND r.isActive = 1) THEN
			select 'Success' as message;
			SELECT JSON_ARRAY_APPEND(section,'$',CAST(updateSection AS JSON) )INTO @data FROM `project` WHERE projectId=pId ;
			UPDATE `project` SET section=@data   WHERE projectId=1;
			
		else
			select 'Invalid request' as message;
		end if;
	else 
		select 'Invalid user' as message;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updateProjectPhaseStatus` */;

DELIMITER ;;
CREATE PROCEDURE `updateProjectPhaseStatus`(in _phaseStatusId int, in _isCompleted TINYINT)
BEGIN
	if(exists(select * from project_phase_status where id = _phaseStatusId)) then
		update project_phase_status set isCompleted = _isCompleted where id = _phaseStatusId;
        select true isUpdated, 'success' message;
    else
		select false isUpdated, 'Phase Status not found' message;
    end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `updatePushTokenDetails` */;

DELIMITER ;;
CREATE PROCEDURE `updatePushTokenDetails`(in uId int,in dId text,in dTok text, in fcmTok text,in dType varchar(255))
BEGIN
	if exists(select * from `pushtokendetails` where deviceId=dId)then
		update `pushtokendetails` set userId=uId,deviceId=dId,token=dTok,fcmToken=fcmTok,deviceType=dType where deviceId=dId;
	else
		insert into `pushtokendetails`(deviceId,userId,deviceType,token,fcmToken) values(dId,uId,dType,dTok,fcmTok);
	end if;
	
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `update_project` */;

DELIMITER ;;
CREATE PROCEDURE `update_project`(in _projectId int, in _userId int, in project_query text, in phase_status_query json, in card_details_query json, in project_images json, in _draftId boolean, in _newPartnerOrganisationsNames JSON, in _newPartnerOrganisationsQuery json, in project_Partner json  )
BEGIN
	DECLARE _isInDraft boolean; 
    set @projectQuery = project_query;
	set @projectImages = project_images;
	set @pId = _projectId;
    set @uId = _userId;
    set @projectPartner = project_Partner;
	set @newPartnerOrganisationsNames = _newPartnerOrganisationsNames;
    set @newPartnerOrganisationsQuery = _newPartnerOrganisationsQuery;
    #select replace(@projectQuery, '\\', '') into @projectQuery;
    #select trim('"' from @projectQuery) into @projectQuery;
    select isInDraft into _isInDraft  from project where projectId = _projectId;
    
    -- select @projectPartner incoming_project_partner;
    
    if(JSON_LENGTH(_newPartnerOrganisationsNames) > 0 and JSON_LENGTH(_newPartnerOrganisationsQuery) > 0) then
		-- select 'inside new partner', JSON_LENGTH(@newPartnerOrganisationsQuery) queryLength;
       --  select @projectPartner `before`; -- /////////////////////////////
		set @i = 0;
		while @i < JSON_LENGTH(@newPartnerOrganisationsQuery) do
			select JSON_UNQUOTE(JSON_EXTRACT(@newPartnerOrganisationsNames, CONCAT('$[',@i,']'))) into @partnerOrganisationName;
			if(!exists(select * from organisations where name = @partnerOrganisationName)) then
				select JSON_EXTRACT(_newPartnerOrganisationsQuery, CONCAT('$[',@i,']')) into @newPartnerOrganisation_query;
                select replace(@newPartnerOrganisation_query, '\\', '') into @newPartnerOrganisation_query;
                select trim('"' from @newPartnerOrganisation_query) into @newPartnerOrganisation_query;
                PREPARE add_new_partnerOrganisation from @newPartnerOrganisation_query;
                EXECUTE add_new_partnerOrganisation;
                DEALLOCATE PREPARE add_new_partnerOrganisation;
                if(@projectPartner is null) then
					-- select @projectPartner `inside !exists @projectPartner is null`; -- /////////////////////////////
					-- select @i, 'inside partner null' secondIf, 'inside new partner' firstIf;
					select concat('[', last_insert_id(), ']') into @projectPartner;
				else 
					-- select @projectPartner `inside !exists @projectPartner is not null`; -- /////////////////////////////
					-- select @i, 'inside partner not null' secondIf, 'inside new partner' firstIf, @projectPartner;
					select replace(@projectPartner, ']', concat(',', last_insert_id(), ']')) into @projectPartner;
				end if;
			else 
				if(@projectPartner is null) then
					-- select @projectPartner `inside exists @projectPartner is null`; -- /////////////////////////////
					-- select @i, 'inside partner null' secondIf, 'inside exist partner' firstIf;
					select concat('[', id, ']') from organisations where name = @partnerOrganisationName into @projectPartner;
                else
					-- select @projectPartner `inside exists @projectPartner is not null`; -- /////////////////////////////
					-- select @i, 'inside partner not null' secondIf, 'inside exist partner' firstIf, @projectPartner;
					select replace(@projectPartner, ']', concat(',', id, ']')) from organisations where name = @partnerOrganisationName into @projectPartner;
                end if;
			end if;
            -- select 'project partner 1', @i, @projectPartner; -- ............................................................
            select @i + 1 into @i;
        end while;
    end if;
    -- select @projectPartner `after`; -- /////////////////////////////
    -- if(@projectPartner is not null) then
		-- set @projectPartner = replace(@projectPartner, ' ', '');
	-- end if;
    
	-- select @pId, @projectQuery; -- //////////////////////////////////////////////
	PREPARE update_project from @projectQuery;
	EXECUTE update_project;
	DEALLOCATE PREPARE update_project;
    
	if(JSON_LENGTH(phase_status_query) > 0) then
		set @i = 0;
		while @i < JSON_LENGTH(phase_status_query) DO
			select JSON_EXTRACT(phase_status_query, CONCAT('$[',@i,']')) INTO @phaseQuery;
			select trim('"' from @phaseQuery) into @phaseQuery;
            select replace(@phaseQuery, '\\', '') into @phaseQuery;
			PREPARE update_phase_status from @phaseQuery;
			EXECUTE update_phase_status;
			DEALLOCATE PREPARE update_phase_status;
			SELECT @i + 1 INTO @i;
		end while;
	end if;
	if(JSON_LENGTH(card_details_query) > 0) then
		set @i = 0;
		while @i < JSON_LENGTH(card_details_query) DO
			select JSON_EXTRACT(card_details_query, CONCAT('$[',@i,']')) INTO @cardQuery;
			select replace(@cardQuery, '\\', '') into @cardQuery;
			select trim('"' from @cardQuery) into @cardQuery;
			set @j = 0;
			while @j < JSON_LENGTH(@cardQuery) DO
					select JSON_EXTRACT(@cardQuery, CONCAT('$[',@j,']')) INTO @subQuery;
					select trim('"' from @subQuery) into @subQuery;
					PREPARE insert_card_and_sub_topic from @subQuery;
					EXECUTE insert_card_and_sub_topic;
					DEALLOCATE PREPARE insert_card_and_sub_topic;
					SELECT @j + 1 INTO @j;
			end while;
			SELECT @i + 1 INTO @i;
		end while;
	end if;
    SELECT 'Success' AS message,@pId AS projectId;
	if (_draftId != _isInDraft and  _isInDraft is false)  Then 
		select "CREATE_PROJECT" as message, true isProjectStatusChange;
	end if;
	if(_draftId != _isInDraft) then
		select true isProjectStatusChange;
	end if;
END ;;
DELIMITER ;

/*!50003 DROP PROCEDURE IF EXISTS `volunteerForProject` */;

DELIMITER ;;
CREATE PROCEDURE `volunteerForProject`(in _userId int, in _projectId int, in _isVolunteer tinyint)
BEGIN
	if(exists(select * from volunteerForProject where userId = _userId and projectId = _projectId)) then
		update volunteerForProject set isVolunteer = _isVolunteer where userId = _userId and projectId = _projectId;
    else
		insert into volunteerForProject (userId, projectId, isVolunteer) values (_userId, _projectId, _isVolunteer);
    end if;
	if(exists(select * from volunteerForProject where userId = _userId and projectId = _projectId)) then
		select 'updated successfully' message, true isUpdated;
    else
		select 'failed to update' message, false isUpdated;
    end if;
END ;;
DELIMITER ;
