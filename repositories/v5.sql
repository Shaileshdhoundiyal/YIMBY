USE `yimbyqadb`;
ALTER TABLE `re_developer` MODIFY COLUMN
 `isApproved` enum('approved','pending','rejected', 'suspended');

 USE `yimbyqadb`;
ALTER TABLE `neighbours` ADD COLUMN
 `isApproved` enum('approved', 'suspended');


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
  `neighbourId` int DEFAULT NULL,
  `isDefault` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`replyId`)
) ;

DELIMITER ;;
CREATE DEFINER=`yimby`@`%` PROCEDURE `activateAccountAndProjects`(in uId int,in eId varchar(255))
BEGIN
    if  exists(select * from `re_developer` where userId=uId and email=eId) then
         
            update `re_developer` set isActive=1 where userId=uId;
            update `project` set isDeleted=0 where userId=uId;
            SELECT 'Success' AS message;
       
    else
        select 'Invalid user' as message;
    end if;
END;;


use `yimbyqadb`;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `deleteProjectNew` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `deleteProjectNew`(in uId int,in pId varchar(255))
BEGIN
    if exists(select * from `project` where projectId = pId and isDeleted = 0) then
            if exists(select * from `admins` where userId = uId and isActive = 1) or exists(select * from `project` where projectId = pId and userId = uId and isDeleted = 0) then
                DELETE FROM `be_heard_comments`  where projectId=pId;
                DELETE FROM `static_be_heard_comments` where projectid = pId;
                DELETE FROM `card_comment`  where projectId=pId;
                DELETE FROM `commentreplies`  where projectId=pId;
                DELETE FROM `comments`  where projectId=pId;
                DELETE FROM `topics_comments`  where projectId=pId;
                DELETE FROM `sub_topics_comments`  where projectId=pId;
                DELETE FROM `project_images`  where projectId=pId;
                DELETE FROM `project_cards_sub_topics`  where projectId=pId;
                DELETE FROM `project_cards`  where projectId=pId;
                DELETE FROM `project_static_cards` WHERE projectId = pId;
                DELETE FROM `project_cards_statusmeter`  where projectId=pId;
                DELETE FROM `static_project_cards_statusmeter` where projectid = pId;
                DELETE FROM `project`  where projectId=pId;
                select 'Success' as message;
            else
                select 'invalid User' as message;
            end if;
        else
            select 'Project Not Found' as message;
        end if;
END;;