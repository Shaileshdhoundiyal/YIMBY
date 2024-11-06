USE `yimbyqadb`;
ALTER TABLE `admins` ADD COLUMN `address` text;
ALTER TABLE `admins` ADD COLUMN `lattitude` decimal(9,6);
ALTER TABLE `admins` ADD COLUMN `longitude` decimal(9,6);
ALTER TABLE `admins` ADD COLUMN `zipCode` varchar(255);
ALTER TABLE `admins` ADD COLUMN `country` varchar(255);
ALTER TABLE `admins` ADD COLUMN `state` varchar(255);
ALTER TABLE `admins` ADD COLUMN `city` varchar(255);
ALTER TABLE `admins` ADD COLUMN `isThemesMode` enum('Light Mode','Dark Mode','Follow the system')  NOT NULL DEFAULT 'Follow the system';

USE `yimbyqadb`;
ALTER TABLE `re_developer` ADD COLUMN `address` text;
ALTER TABLE `re_developer` ADD COLUMN `lattitude` decimal(9,6);
ALTER TABLE `re_developer` ADD COLUMN `longitude` decimal(9,6);
ALTER TABLE `re_developer` ADD COLUMN `zipCode` varchar(255);
ALTER TABLE `re_developer` ADD COLUMN `country` varchar(255);
ALTER TABLE `re_developer` ADD COLUMN `state` varchar(255);
ALTER TABLE `re_developer` ADD COLUMN `city` varchar(255);
ALTER TABLE `re_developer` ADD COLUMN `isThemesMode` enum('Light Mode','Dark Mode','Follow the system')  NOT NULL DEFAULT 'Follow the system';

USE `yimbyqadb`;
ALTER TABLE `neighbours` ADD COLUMN `country` varchar(255);
ALTER TABLE `neighbours` ADD COLUMN `state` varchar(255);
ALTER TABLE `neighbours` ADD COLUMN `city` varchar(255);

USE `yimbyqadb`;
ALTER TABLE `re_developer` DROP COLUMN `isNewResponsesByProject`;
ALTER TABLE `re_developer` DROP COLUMN `isYimbyUpdates`;
ALTER TABLE `re_developer` DROP COLUMN `isReceiveEmails`;
ALTER TABLE `re_developer` DROP COLUMN `isNewFeedbackByProject`;
ALTER TABLE `re_developer` DROP COLUMN `isProjectSummaries`;
ALTER TABLE `re_developer` DROP COLUMN `isProjectStatusChangeByTeam`;
ALTER TABLE `re_developer` DROP COLUMN `isFeatureUpdates`;
ALTER TABLE `re_developer` DROP COLUMN `isNewsAboutYimby`;
ALTER TABLE `re_developer` DROP COLUMN `isProjectCompletion`;

USE `yimbyqadb`;
ALTER TABLE `re_developer` ADD COLUMN `isDesktopNotification` BOOLEAN DEFAULT false;
ALTER TABLE `re_developer` ADD COLUMN `isEmailNotification` BOOLEAN DEFAULT false;
ALTER TABLE `re_developer` ADD COLUMN `isProjectUpdated` BOOLEAN DEFAULT false;
ALTER TABLE `re_developer` ADD COLUMN `isApproved` BOOLEAN DEFAULT false;

USE `yimbyqadb`;
ALTER TABLE `admins` ADD COLUMN `isDesktopNotification` BOOLEAN DEFAULT false;
ALTER TABLE `admins` ADD COLUMN `isEmailNotification` BOOLEAN DEFAULT false;
ALTER TABLE `admins` ADD COLUMN `isNewProjectAdded` BOOLEAN DEFAULT false;
ALTER TABLE `admins` ADD COLUMN `isNewDeveloperAdded` BOOLEAN DEFAULT false;

USE `yimbyqadb`;
CREATE TABLE `ReviewDetail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `supporter` enum('yes','no')  NOT NULL,
  `volunteer` enum('yes','no')  NOT NULL,
  `projectStatus` enum('YIMBY','MIMBY','NIMBY')  NOT NULL,
  `projectType` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

USE `yimbyqadb`;
CREATE TABLE `review_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `supporter` enum('yes','no')  NOT NULL,
  `volunteer` enum('yes','no')  NOT NULL,
  `projectStatus` enum('YIMBY','MIMBY','NIMBY')  NOT NULL,
  `projectType` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

USE `yimbyqadb`;
ALTER TABLE `project` ADD COLUMN `country` varchar(255);
ALTER TABLE `project` ADD COLUMN `state` varchar(255);
ALTER TABLE `project` ADD COLUMN `city` varchar(255);

use `yimbyqadb`;
ALTER TABLE `project` MODIFY COLUMN `projectStatus` enum('draft','active','rejected','completed') DEFAULT 'draft';

use `yimbyqadb`;
ALTER TABLE `re_developer` MODIFY COLUMN `isApproved` enum('approved','pending','rejected') DEFAULT 'pending';

use `yimbyqadb`;
CREATE TABLE `requests` (requestId int NOT NULL AUTO_INCREMENT , requestType enum('New Developer','New Project','Updated Project'),requestTime DATETIME,changedData json,PRIMARY KEY (`requestId`),userId int not null,projectId int, status enum('pending','rejected','approved') default 'pending')


use `yimbyqadb`;
ALTER TABLE `re_developer` ADD COLUMN `deviceToken` varchar(255);
use `yimbyqadb`;
ALTER TABLE `admins` ADD COLUMN `deviceToken` varchar(255);
use `yimbyqadb`;
ALTER TABLE `neighbours` ADD COLUMN `deviceToken` varchar(255);


use `yimbyqadb`;
ALTER TABLE `be_heard_comments` DROP CONSTRAINT `be_heard_comments_ibfk_2`;

ALTER TABLE `be_heard_comments` ADD  CONSTRAINT `be_heard_comments_ibfk_2` FOREIGN KEY (`cardId`) REFERENCES `cards` (`id`);


ALTER TABLE yimbyqadb.project_cards_statusmeter 
ADD COLUMN skipCardIds json;

ALTER TABLE yimbyqadb.project_cards 
ADD COLUMN cardSkipCount int;


USE `yimbyqadb`;
ALTER TABLE `re_developer` ALTER COLUMN isDesktopNotification SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `re_developer` ALTER COLUMN isEmailNotification SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `re_developer` ALTER COLUMN isProjectUpdated SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `admins` ALTER COLUMN isEmailNotification SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `admins` ALTER COLUMN isDesktopNotification SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `admins` ALTER COLUMN isNewProjectAdded SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `admins` ALTER COLUMN isNewDeveloperAdded SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isNewProjectsYourArea SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isUpdatesProjectYourArea SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isCommentApprovals SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isResponsesYourComments SET DEFAULT 1;


USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isReceiveEmails SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isCommentApprovalByEmail SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isResponsesYourCommentsByEmail SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isNewDevelopments SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isFeatureUpdates SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isAboutYimby SET DEFAULT 1;

USE `yimbyqadb`;
ALTER TABLE `neighbours` ALTER COLUMN isAccountSecurity SET DEFAULT 1;

use `yimbyqadb`;
ALTER TABLE project_static_cards  RENAME static_cards;

use `yimbyqadb`;
DROP TABLE IF EXISTS `project_static_cards`;
CREATE TABLE `project_static_cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `staticCardId` int NOT NULL,
  `projectId` int NOT NULL,
  `isDeleted` tinyint(1) DEFAULT (0),
  `cardAgreeCount` int DEFAULT (0),
  `cardDisAgreeCount` int DEFAULT (0),
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `projectIdForProject_Cards` (`projectId`),
  KEY `staticCardId` (`staticCardId`),
  CONSTRAINT `fk_staticCardId` FOREIGN KEY (`staticCardId`) REFERENCES `static_cards` (`staticCardId`),
  CONSTRAINT `fk_projectId` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
);

use yimbyqadb;
DROP TABLE IF EXISTS `static_be_heard_comments`;
CREATE TABLE `static_be_heard_comments` (
  `commentId` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int DEFAULT NULL,
  `staticCardId` int NOT NULL,
  `comment` text,
  `isDeleted` tinyint(1) DEFAULT '0',
  `createdOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `modifiedOn` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `isViewed` tinyint DEFAULT '0',
  PRIMARY KEY (`commentId`),
  KEY `static_be_heard_commentUserId` (`userId`),
  KEY `static_be_heard_commentProjectId` (`projectId`),
  KEY `staticCardId` (`staticCardId`),
  CONSTRAINT `static_be_heard_commentProjectId` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`),
  CONSTRAINT `static_be_heard_comments_ibfk_2` FOREIGN KEY (`staticCardId`) REFERENCES `static_cards` (`staticCardId`),
  CONSTRAINT `static_be_heard_commentUserId` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`)
);

use yimbyqadb;
DROP TABLE IF EXISTS `static_project_cards_statusmeter`;
CREATE TABLE `static_project_cards_statusmeter` (
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
  CONSTRAINT `static_project_cards_statusmeter_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`),
  CONSTRAINT `static_project_cards_statusmeter_ibfk_2` FOREIGN KEY (`projectId`) REFERENCES `project` (`projectId`)
) ;

ALTER TABLE yimbyqadb.static_project_cards_statusmeter 
ADD COLUMN skipCardIds json;

ALTER TABLE yimbyqadb.project_static_cards 
ADD COLUMN cardSkipCount int;
