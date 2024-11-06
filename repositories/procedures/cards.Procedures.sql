DELIMITER ;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewNeighbours` */;
DELIMITER ;;


/*delete all card of a project */

CREATE PROCEDURE `deleteAllCardsForProject`(IN projectId1 int)
BEGIN
	if exists(select * from `project` where projectId = projectId1 and isDeleted = 0) then
		update `project_cards` set isDeleted = 1 where projectId = projectId1;
        select 'Success' as message;
	else
		select 'Project dont exist' as message;
	end if;
END

/* delete single card */

CREATE PROCEDURE `deleteCard`(IN cardId1 int)
BEGIN
	if exists(select * from `project_cards` where cardId = cardId1 and isDeleted = 0) then
		update `project_cards` set isDeleted = 1 where cardId = cardId1;
        select 'Success' as message;
	else
		select 'card not exist' as message;
	end if;
END


/* delete project  */

CREATE PROCEDURE `deleteProject`(in uId int,in pId varchar(255))
BEGIN
	if exists(select * from `project` where projectId = pid and isDeleted = 0) then
			if exists(select * from `admins` where userId = uId and isActive = 1) or exists(select * from `project` where projectId = pId and userId = uId and isDeleted = 0) then
				update `be_heard_comments` set isDeleted=1 where projectId=pId;
                update `card_comment` set isDeleted=1 where projectId=pId;
                update `commentreplies` set isDeleted=1 where projectId=pId;
                update `comments` set isDeleted=1 where projectId=pId;
                update `topics_comments` set isDeleted=1 where projectId=pId;
                update `sub_topics_comments` set isDeleted=1 where projectId=pId;
                update `project_images` set isDeleted=1 where projectId=pId;
                update `project_cards_sub_topics` set isDeleted=1 where projectId=pId;
                update `project_cards` set isDeleted=1 where projectId=pId;
                update `project` set isDeleted=1 where projectId=pId;
                update `project_cards` set isDeleted = 1 where projectId = pId;
                select 'Success' as message; 
			else 
				select 'invalid User' as message;
			end if;
		else
			select 'Project Not Found' as message;
		end if;
END

/* get project cards */

CREATE PROCEDURE `getProjectCards`(in requestId int)
BEGIN
	if exists (select * from `project` where projectId=requestId and isDeleted=0) then
		if exists(select * from `project_cards` where projectId = requestId and isDeleted=0) then
			select 'Success' as message ,p.cardId,p.staticCardId,p.projectId,p.cardTitle,p.cardIcon,p.cardDescription from `project_cards` as p where projectId = requestId and isDeleted = 0;
		else	
			select 'no cards' as message;
		end if;
	else 
		select 'User not found' AS message;
	end if;
END

/* insert card */
DELIMITER ;;
CREATE PROCEDURE `insertCard`(IN cardTitle1 VARCHAR(255), IN cardIcon1 text, IN cardDescription1 VARCHAR(255),IN projectId1 int)
BEGIN

	IF EXISTS(SELECT * FROM `project_static_cards` WHERE cardTitle = cardTitle1 and isDeleted = 0) THEN

		SELECT 'Card already registered' AS message;

	ELSE

		INSERT INTO `project_static_cards`(cardTitle,cardIcon,cardDescription) VALUES(cardTitle1,cardIcon1,cardDescription1);
        SELECT LAST_INSERT_ID() INTO @uId;
        insert INTO `project_cards` (staticCardId,projectId,cardTitle,cardIcon,cardDescription,cardAgreeCount,cardDisAgreeCount) VALUES(@uId,projectId1,cardTitle1,cardIcon1,cardDescription1,0,0);
		SELECT 'Success' AS message,'project_static_cards' AS cardTitle,cardIcon,cardDescription,isDeleted,createdOn,modifiedOn FROM `project_static_cards` WHERE staticCardId=@uId;

	END IF;
END;;