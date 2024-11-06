DROP TABLE IF EXISTS `neighbours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `neighbours` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `surName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
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
  `isThemesMode` enum('Light Mode','Dark Mode','Follow the system') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Follow the system',
  `otp` varchar(6) DEFAULT NULL,
  `otpExpireAt` timestamp(3) NULL DEFAULT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=346 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;



DROP TABLE IF EXISTS `re_developer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `re_developer` (
  `userId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) DEFAULT NULL,
  `surName` varchar(255) DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` text,
  `profilePhoto` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
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
  `isProjectSummaries` enum('Monthly','Daily','Fortnightly','Weekly') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'Weekly',
  `isProjectStatusChangeByTeam` tinyint(1) DEFAULT '1',
  `isFeatureUpdates` tinyint(1) DEFAULT '1',
  `isNewsAboutYimby` tinyint(1) DEFAULT '1',
  `isProjectCompletion` tinyint(1) DEFAULT '1',
  `isAccountOrSecurityIssues` tinyint(1) DEFAULT '1',
  `phoneNumber` varchar(45) DEFAULT NULL,
  `organisationName` varchar(255) DEFAULT NULL,
  `isDeleted` tinyint DEFAULT '0',
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;



DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'subham admin','kumar','subham@admin.com','U2FsdGVkX1+PQEfGR1kV5nGqbe/Yir0+G/0T1n+WjBc=',NULL,'2023-01-18 11:19:33.679','2023-07-25 12:51:02.470',1,'2023-07-25 12:51:02.000','admin'),(2,'subham admin','kumar','subham@4screenmedia.com','U2FsdGVkX1/VkkXHscA+5+OriSK+HlFtiGstnc0QA/c=',NULL,'2023-06-23 09:27:30.430','2023-06-23 09:27:30.477',1,'2023-06-23 09:27:30.000','admin');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `be_heard_comments`
--

DROP TABLE IF EXISTS `be_heard_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
  CONSTRAINT `be_heard_comments_ibfk_2` FOREIGN KEY (`cardId`) REFERENCES `project_cards` (`cardId`),
  CONSTRAINT `be_heard_commentUserId` FOREIGN KEY (`userId`) REFERENCES `neighbours` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=290 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `be_heard_comments`
--
