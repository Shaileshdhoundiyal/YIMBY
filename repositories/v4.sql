
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getNearByProjectOffline` */;


CREATE DEFINER=`yimby`@`%` PROCEDURE `getNearByProjectOffline`(in _latitude varchar(255), in _longitude varchar(255), in _limit int, in _offset int, in _userId int)
BEGIN
	if(exists(select * from userLocation where userId = _userId)) then
		update userLocation set latitude = _latitude, longitude = _longitude where userId = _userId;
    else
		insert into userLocation (userId, latitude, longitude) values (_userId, _latitude, _longitude);
    end if;
	if(_limit is not null and _offset is not null) then
		SELECT 'Success' AS message,_userId as userId, p.benefit,
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
        HAVING distance <= 10
        ORDER BY modifiedAt DESC;
        -- ORDER BY distance /*limit _limit offset _offset*/ ;
	else 
		SELECT 'Success' AS message,_userId as userId, p.benefit,
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
		HAVING distance <= 10
        ORDER BY modifiedAt DESC;
       -- ORDER BY distance;
	end if;
END;;



DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `isViewed` */;


CREATE DEFINER=`yimby`@`%` PROCEDURE `isViewed`(in _uId int, in _pId int, in _pnId int, in _isResponded TINYINT)
BEGIN
	if(_pnId is not null and exists(select * from pushnotifications where id = _pnId)) then
		update pushnotifications set isViewed = true where id = _pnId;
    end if;
	if (_pId is not null and exists(select p.* from `project` p join `re_developer` re on p.userId=re.userId where p.projectId=_pId and p.isInDraft=0 and p.isDeleted=0 and re.isActive=1)) then
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
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getUserDetail` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getUserDetail`(In requestId int ,in uType varchar(30))
BEGIN
 
    if uType='Neighbour'then
 
        select 'Success' as message, userId,firstName,surName,email,/*streetAddress,city,state,zipCode*/address,latitude,longitude,`profile`,isThemesMode,if((SELECT count(*) FROM neighbour_survey_answers where userId = requestId) = 3, true, false) isSurveyDone from `neighbours` where userId=requestId and isActive=1;
SELECT 
    pcs.*,
    IF((SELECT 
                COUNT(*)
            FROM
                envelope_details
            WHERE
                neighbour_Id = requestId
                    AND projectId = pcs.projectId) > 0,
        TRUE,
        FALSE) isSupporter,
    (SELECT 
            isVolunteer
        FROM
            volunteerForProject
        WHERE
            userId = requestId
                AND projectId = pcs.projectId) AS isVolunteer,
    p.projectName,
    p.projectType
FROM
    project_cards_statusmeter AS pcs
        JOIN
    project AS p
WHERE
    p.projectId = pcs.projectId
        AND pcs.userId = requestId;
    else
 
        SELECT 'Success' AS message, userId,firstName,surName,email, profilePhoto,organisationId,organisationName as organisation,phoneNumber,lattitude, longitude,zipCode from `re_developer` WHERE userId=requestId AND isActive=1;
SELECT 
    *
FROM
    project
WHERE
    userId = requestId;
    end if;
 
END;;


DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `addbeHeardComment` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `addbeHeardComment`(in uId int,in pId int,in cId int,in comments text, in commentType varchar(45),in isDefault boolean)
BEGIN
	if(isDefault = false) then
			if exists(select * from project_cards where cardId = cId and projectId = pId) then
				insert into `be_heard_comments` (userId,projectId,cardId,`comment`) values(uId,pId,cId,comments);
				SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
			else
				select 'Project not found' as message;
			end if;
        else
			if exists(select * from project_static_cards where projectid = pId and staticCardId = cId) then
				insert into `static_be_heard_comments` (userId,projectId,staticCardId,`comment`) values(uId,pId,cId,comments);
				SELECT 'Success' AS message,LAST_INSERT_ID() AS commentId, userId FROM `project` WHERE projectId=pId;
			else
				select 'Project not found' as message;
			end if;
		end if;
END;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getNeighboursAndComments` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getNeighboursAndComments`(IN idsy_list VARCHAR(255),IN idsm_list VARCHAR(255),IN idsn_list VARCHAR(255),IN idsa_list VARCHAR(255))
BEGIN
    IF idsn_list = '' THEN
        -- Logic for handling empty param1
        SET idsn_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsy_list = '' THEN
        -- Logic for handling empty param1
        SET idsy_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsm_list = '' THEN
        -- Logic for handling empty param1
        SET idsm_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsa_list = '' THEN
        -- Logic for handling empty param1
        SET idsa_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    SET @query = CONCAT('select neighbour_survey_answers.answer as relationship,if((SELECT count(*) FROM envelope_details where neighbour_Id = neighbours.userId) > 0, true, false) AS isSupporter, neighbours.* FROM neighbours INNER JOIN neighbour_survey_answers ON neighbour_survey_answers.userId=neighbours.userId and neighbour_survey_answers.questionId=1 and neighbours.userId in (', idsy_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @query = CONCAT('SELECT * FROM neighbours WHERE userId IN (', idsm_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @query = CONCAT('SELECT * FROM neighbours WHERE userId IN (', idsn_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	SET @query = CONCAT('SELECT be_heard_comments.comment, neighbours.firstName FROM be_heard_comments INNER JOIN neighbours ON be_heard_comments.userId=neighbours.userId and neighbours.userId in  (', idsa_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getRequestDetail` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getRequestDetail`(In requestId int ,in requestType varchar(30))
BEGIN

	if requestType='New Developer'then
		select * from re_developer where userId=requestId;
	else
         select * from project where userId = requestId;
	end if;
 END;;

 DELIMITER ;;
 /*!50003 DROP PROCEDURE IF EXISTS `getMyProjectByUserIdNew` */;
 CREATE DEFINER=`yimby`@`%` PROCEDURE `getMyProjectByUserIdNew`(in requestId int,in txt varchar(30))
BEGIN
     IF txt = '' THEN
        -- Logic for handling empty param1
       -- Set to NULL or perform specific actions as needed
        if exists (select * from `re_developer` where userId=requestId and isActive=1) then
           set @organisationId = (select organisationId from re_developer where userId = requestId ) ;
           SELECT p.*,
           (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
           (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
           (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
           (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
           FROM `project` AS p  WHERE userId=requestId  AND isDeleted=0 AND projectStatus = 'active'  ;
           select * from requests where userId=requestId and status!='approved';
        else
           select 'User not found' AS message;
        end if;
ELSE    
         Set txt= concat('%', txt, '%');
        if exists (select * from `re_developer` where userId=requestId and isActive=1) then
           set @organisationId = (select organisationId from re_developer where userId = requestId ) ;
           SELECT p.*,
           (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
           (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
           (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
           (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
           FROM `project` AS p  WHERE userId=requestId  AND isDeleted=0 AND projectStatus = 'active' and (projectName like txt or projectAddress like txt);
            select * from requests where userId=requestId and status!='approved' and (changedData->'$.projectDetails.projectAddress' like txt or changedData->'$.projectDetails.projectName' like txt);
        else
           select 'User not found' AS message;
        end if;  
END IF;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getAllCardsNew` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getAllCardsNew`(in uId int, in txt varchar(30) )
BEGIN
	if txt=''
           then 
                 SELECT * FROM cards WHERE userId = uId and isDeleted = 0;
         else
               Set txt= concat('%', txt, '%');
           
            select * from cards where userId=uId and isDeleted=0 and cardTitle like txt;
		end if;
END;;

use yimbyqadb;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getRequests` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getRequests`(in txt varchar(30) )
BEGIN
	if txt=''  then 
      SELECT r.*,re.firstName,re.surName FROM requests as r INNER JOIN re_developer as re ON r.userId = re.userId WHERE r.status = 'pending';
         else
               Set txt= concat('%', txt, '%');
   SELECT r.*,re.firstName,re.surName FROM requests as r INNER JOIN re_developer as re ON r.userId = re.userId and (requestType like txt or firstName like txt or surName like txt) and r.status = 'pending';
    END IF;
END;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getNeighbours` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getNeighbours`(in txt varchar(30) )
BEGIN
	if txt=''  then 
              SELECT * FROM neighbours where isActive=1;

	else
               Set txt= concat('%', txt, '%');
      SELECT * FROM neighbours where isDeleted = 0  and (firstName like txt or surName like txt or address like txt);
    end if;
END;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getDevelopers` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getDevelopers`(in txt varchar(30) )
BEGIN
	if txt=''  then 
              SELECT * FROM re_developer where isActive=1 AND isApproved = 'approved';

	else
               Set txt= concat('%', txt, '%');
      SELECT * FROM re_developer where isDeleted = 0 AND isApproved = 'approved' and (firstName like txt or surName like txt or address like txt);
    end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `setDeviceToken` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `setDeviceToken`(In uId int ,in uType varchar(30),in _token varchar(255))
BEGIN

	if uType='neighbours' then
		update `neighbours` set `deviceToken`=_token where userId=uId;
		select 'Success' as message;
	elseif uType="re_developer" then
		update `re_developer` set `deviceToken`=_token WHERE userId=uId;
		SELECT 'Success' AS message;
	else 
	    update `admins` set `deviceToken`=_token WHERE userId=uId;
		SELECT 'Success' AS message;
	end if;

END;;


DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `cardAgreeOrDisAgree` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `cardAgreeOrDisAgree`(in uId int,in pId int,in cId int ,in agreeOrDisAgree int, in comment text)
BEGIN
	IF EXISTS(SELECT p.* FROM project p JOIN `re_developer` r ON r.userId = p.userId JOIN `project_cards` pc ON pc.projectId=p.projectId  WHERE p.projectId = pId AND p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1 AND pc.cardId=cId AND pc.projectId=pId) THEN
		if exists(select * from `project_cards_statusmeter` where userId=uId and projectId=pId)then
			#SELECT FIND_IN_SET(cId,CONCAT(IFNULL(disAgreeCardIds,''),',',IFNULL(agreeCardIds,''))) into @result FROM `project_cards_statusmeter` WHERE userId=uId AND projectId=pId;
			#select find_in_set(cId,cardIds) into @result from `project_cards_statusmeter` where userId=uId AND projectId=pId;
			SELECT agreeCardIds FROM`project_cards_statusmeter`WHERE projectId=pId AND userId=uId into @agreeCardIds;
SELECT 
    disAgreeCardIds
FROM
    `project_cards_statusmeter`
WHERE
    projectId = pId AND userId = uId INTO @disAgreeCardIds;
SELECT 
    skipCardIds
FROM
    `project_cards_statusmeter`
WHERE
    projectId = pId AND userId = uId INTO @skipCardIds;
			SELECT JSON_SEARCH(@agreeCardIds, 'one', cId) INTO @agreeResult;
SELECT JSON_SEARCH(@disAgreeCardIds, 'one', cId) INTO @disAgreeResult;
            #select find_in_set(cId,concat(ifNull(@agreeCardIds,''), ',', ifnull(@disAgreeCardIds,''))) into @result;

			if (@agreeResult is null and @disAgreeResult is null) then
				if agreeOrDisAgree='agree' then	
					update`project_cards` set cardAgreeCount=cardAgreeCount+1 where projectId=pId and cardId=cId;
					#update`project_cards_statusmeter` set agreeCardIds= ifnull(concat(agreeCardIds,',',cId),cId) ,cardsReviewedCount=cardsReviewedCount+1 where userId=uId and projectId=pId;
                    if(@agreeCardIds is null) then 
						update `project_cards_statusmeter` set cardsReviewedCount=cardsReviewedCount+1, agreeCardIds=concat('["',cId,'"]'), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId)  where userId=uId and projectId=pId; 
					else 
						update `project_cards_statusmeter` set cardsReviewedCount=cardsReviewedCount+1, agreeCardIds=(SELECT JSON_ARRAY_APPEND(@agreeCardIds,'$',concat(cId))), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) where userId=uId and projectId=pId; 
					end if;
					SELECT 
    'Agree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
				elseif agreeOrDisAgree='disagree' then
					UPDATE `project_cards` SET cardDisAgreeCount=cardDisAgreeCount+1 WHERE projectId=pId AND cardId=cId;
                    if(@disAgreeCardIds is null) then
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, disAgreeCardIds=concat('["',cId,'"]'), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId;
					else 
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, disAgreeCardIds=(SELECT JSON_ARRAY_APPEND(@disAgreeCardIds,'$',concat(cId))), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId; 
                    end if;
					SELECT 
    'DisAgree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
                    elseif agreeOrDisAgree='skip' then
					UPDATE `project_cards` SET cardSkipCount=cardSkipCount+1 WHERE projectId=pId AND cardId=cId;
                    if(@disAgreeCardIds is null) then
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, skipCardIds=concat('["',cId,'"]'), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId;
					else 
						UPDATE `project_cards_statusmeter` SET cardsReviewedCount=cardsReviewedCount+1, skipCardIds=(SELECT JSON_ARRAY_APPEND(@skipCardIds,'$',concat(cId))), cardIds=concat((select cardIds where userId=uId and projectId=pId), ',', cId) WHERE userId=uId AND projectId=pId; 
                    end if;
					SELECT 
    'Skip' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
				
				end if;
			else 
				if(comment != '') then
					insert into `topics_comments` (userId, projectId, cardId, comment) values (uId, pId, cId, comment);
				end if;
				if(agreeOrDisAgree='agree' and @agreeResult is null and @disAgreeResult is not null) then
					SELECT json_search(@disAgreeCardIds, 'one', cId) into @idx;
UPDATE `project_cards_statusmeter` 
SET 
    disAgreeCardIds = (SELECT JSON_REMOVE(@disAgreeCardIds, JSON_UNQUOTE(@idx)))
WHERE
    userId = uId AND projectId = pId;
UPDATE `project_cards` 
SET 
    cardDisAgreeCount = cardDisAgreeCount - 1,
    cardAgreeCount = cardAgreeCount + 1
WHERE
    projectId = pId AND cardId = cId;
                    if(@agreeCardIds is null) then 
                        update `project_cards_statusmeter` set agreeCardIds=concat('["',cId,'"]') where userId=uId and projectId=pId;
					else 
                        update `project_cards_statusmeter` set agreeCardIds=(SELECT JSON_ARRAY_APPEND(@agreeCardIds,'$',concat(cId))) where userId=uId and projectId=pId;
                    end if;
SELECT 
    'Agree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
				elseif(agreeOrDisAgree='disagree' and @agreeResult is not null and @disAgreeResult is null) then
					SELECT json_search(@agreeCardIds, 'one', cId) into @idx;UPDATE `project_cards_statusmeter` 
SET 
    agreeCardIds = (SELECT JSON_REMOVE(@agreeCardIds, JSON_UNQUOTE(@idx)))
WHERE
    userId = uId AND projectId = pId;
UPDATE `project_cards` 
SET 
    cardAgreeCount = cardAgreeCount - 1,
    cardDisAgreeCount = cardDisAgreeCount + 1
WHERE
    projectId = pId AND cardId = cId;
                    if(@disAgreeCardIds is null) then
						UPDATE `project_cards_statusmeter` SET disAgreeCardIds=concat('["',cId,'"]') WHERE userId=uId AND projectId=pId;
					else 
						UPDATE `project_cards_statusmeter` SET disAgreeCardIds=(SELECT JSON_ARRAY_APPEND(@disAgreeCardIds,'$',concat(cId))) WHERE userId=uId AND projectId=pId; 
                    end if;
					SELECT 
    'DisAgree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
                else
					if(agreeOrDisAgree='agree') then
						SELECT 'Agree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
					elseif  (agreeOrDisAgree='disagree') then
						SELECT 'DisAgree' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
                        else
                        SELECT 'Skip' AS message,cardsReviewedCount FROM`project_cards_statusmeter`WHERE userId=uId AND projectId=pId;
					end if;
                end if;
			end if;
		else
			IF agreeOrDisAgree='agree' THEN				
				UPDATE `project_cards` SET cardAgreeCount=cardAgreeCount+1 WHERE projectId=pId AND cardId=cId;
				insert into `project_cards_statusmeter` (userId,projectId,agreeCardIds,cardsReviewedCount,cardIds) values(uId,pId,concat('["',cId,'"]'),1,concat(cId));
				SELECT 
    'Agree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
			ELSEIF agreeOrDisAgree='skip' THEN				
				UPDATE `project_cards` SET cardSkipCount=cardSkipCount+1 WHERE projectId=pId AND cardId=cId;
				insert into `project_cards_statusmeter` (userId,projectId,skipCardIds,cardsReviewedCount,cardIds) values(uId,pId,concat('["',cId,'"]'),1,concat(cId));
				SELECT 
    'Skip' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
                ELSE
				UPDATE `project_cards` SET cardDisAgreeCount=cardDisAgreeCount+1 WHERE projectId=pId AND cardId=cId;
				INSERT INTO `project_cards_statusmeter` (userId,projectId,disAgreeCardIds,cardsReviewedCount,cardIds) VALUES(uId,pId,CONCAT('["',cId,'"]'),1,concat(cId));
				SELECT 
    'DisAgree' AS message, cardsReviewedCount
FROM
    `project_cards_statusmeter`
WHERE
    userId = uId AND projectId = pId;
			END IF;
		end if;
	else
		select 'Invalid request' as message;
	end if;
END;;

USE `yimbyqadb`;
CREATE TABLE `defaultCards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cardTitle` varchar(100),
  `cardDescription` varchar(300),
  `cardIcon` varchar(100),
  PRIMARY KEY (`id`)
) ;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getProjectsForDeveloper` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getProjectsForDeveloper`(in id int, in txt varchar(30) )
BEGIN
	if txt=''  then
SELECT * FROM project as p WHERE isDeleted = 0 AND projectStatus = 'active' AND userId = id AND if((SELECT count(*) FROM project_cards_statusmeter where projectId = p.projectId) > 0, true, if((SELECT count(*) FROM static_project_cards_statusmeter where projectId = p.projectId) > 0 , true,false)) order by modifiedAt desc;
    else
               Set txt= concat('%', txt, '%');
               SELECT * FROM project as p WHERE isDeleted = 0 AND projectStatus = 'active' AND userId = id and (p.projectType like txt or p.projectAddress like txt or p.projectName like txt) AND if((SELECT count(*) FROM static_project_cards_statusmeter where projectId = p.projectId) > 0, true, if((SELECT count(*) FROM project_cards_statusmeter where projectId = p.projectId) > 0 , true,false)) order by modifiedAt desc;
    end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getProjectsForAdmin` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getProjectsForAdmin`(in txt varchar(30) )
BEGIN
	if txt=''  then
              SELECT * FROM project as p WHERE isDeleted = 0 AND projectStatus = 'active' AND if((SELECT count(*) FROM project_cards_statusmeter where projectId = p.projectId) > 0, true, if((SELECT count(*) FROM static_project_cards_statusmeter where projectId = p.projectId) > 0 , true,false)) order by modifiedAt desc;
    else
               Set txt= concat('%', txt, '%');
               SELECT * FROM project as p WHERE isDeleted = 0 AND projectStatus = 'active' and (p.projectType like txt or p.projectAddress like txt or p.projectName like txt) AND if((SELECT count(*) FROM static_project_cards_statusmeter where projectId = p.projectId) > 0, true, if((SELECT count(*) FROM project_cards_statusmeter where projectId = p.projectId) > 0 , true,false)) order by modifiedAt desc;
    end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `requestForDsahboard` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `requestForDsahboard`(in userId1 int , in userType varchar(50) , in duration varchar(250))
BEGIN
	if userType = 're_developer' then
		if duration = 'All Time' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*)as data  FROM requests WHERE userId = userId1 AND requestType != 'New Developer' AND (CURDATE() - INTERVAL 100 YEAR) <= requestTime GROUP BY month;
		elseif duration = '1 year' then 
			SELECT MONTHNAME(requestTime) AS month, COUNT(*)as data  FROM requests WHERE userId = userId1 AND requestType != 'New Developer' AND (CURDATE() - INTERVAL 1 YEAR) <= requestTime GROUP BY month;
		elseif duration = '6 Months' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*)as data  FROM requests WHERE userId = userId1 AND requestType != 'New Developer' AND (CURDATE() - INTERVAL 6 MONTH) <= requestTime GROUP BY month;
		elseif duration = '3 Months' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*) as data FROM requests WHERE userId = userId1 AND requestType != 'New Developer' AND (CURDATE() - INTERVAL 3 MONTH) <= requestTime GROUP BY month;
		else
			SELECT 'time zone did not match' as message;
		end if;
	elseif userType = 'admin' then
		if duration = 'All Time' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*) as data FROM requests WHERE requestType != 'New Developer' AND  (CURDATE() - INTERVAL 100 YEAR) <= requestTime GROUP BY month;
		elseif duration = '1 year' then 
			SELECT MONTHNAME(requestTime) AS month, COUNT(*) as data FROM requests WHERE requestType != 'New Developer' AND  (CURDATE() - INTERVAL 1 YEAR) <= requestTime GROUP BY month;
		elseif duration = '6 Months' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*) as data FROM requests WHERE requestType != 'New Developer' AND  (CURDATE() - INTERVAL 6 MONTH) <= requestTime GROUP BY month;
		elseif duration = '3 Months' then
			SELECT MONTHNAME(requestTime) AS month, COUNT(*) as data FROM requests WHERE requestType != 'New Developer' AND  (CURDATE() - INTERVAL 3 MONTH) <= requestTime GROUP BY month;
		else
			SELECT 'time zone did not match' as message;
		end if;
	else
		SELECT 'invalid user type' as message;
	end if;	
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `usersForDasboard` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `usersForDasboard`(in duration varchar(50))
BEGIN
	if duration = 'All Time' then
		SELECT MONTHNAME(createdOn) AS month, COUNT(*)as data FROM re_developer WHERE isDeleted = 0 AND isActive=1 AND isApproved = 'approved' AND (CURDATE() - INTERVAL 100 YEAR) <= createdOn GROUP BY month;
	elseif duration = '1 year' then 
		SELECT MONTHNAME(createdOn) AS month, COUNT(*)as data  FROM re_developer WHERE isDeleted = 0 AND isActive=1 AND isApproved = 'approved' AND (CURDATE() - INTERVAL 1 YEAR) <= createdOn GROUP BY month;
	elseif duration = '6 Months' then
		SELECT MONTHNAME(createdOn) AS month, COUNT(*)as data  FROM re_developer WHERE isDeleted = 0 AND isActive=1 AND isApproved = 'approved' AND (CURDATE() - INTERVAL 6 MONTH) <= createdOn GROUP BY month;
	elseif duration = '3 Months' then
		SELECT MONTHNAME(createdOn) AS month, COUNT(*)as data  FROM re_developer WHERE isDeleted = 0 AND isActive=1 AND isApproved = 'approved' AND (CURDATE() - INTERVAL 3 MONTH) <= createdOn GROUP BY month;
	else
		SELECT 'time zone did not match' as message;
	end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `projectsForDashbourd` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `projectsForDashbourd`(in userId1 int ,in userType varchar(250) ,  duration varchar(50))
BEGIN
if userType = 're_developer' then
	if duration = 'All Time' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND userId = userId1 AND (CURDATE() - INTERVAL 100 YEAR) <= createdAt GROUP BY month;
	elseif duration = '1 year' then 
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND userId = userId1 AND (CURDATE() - INTERVAL 1 YEAR) <= createdAt GROUP BY month;
	elseif duration = '6 Months' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data  FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND userId = userId1 AND (CURDATE() - INTERVAL 6 MONTH) <= createdAt GROUP BY month;
	elseif duration = '3 Months' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND userId = userId1 AND (CURDATE() - INTERVAL 3 MONTH) <= createdAt GROUP BY month;
	else
		SELECT 'time zone did not match' as message;
	end if;
elseif userType = 'admin' then
	if duration = 'All Time' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND  (CURDATE() - INTERVAL 100 YEAR) <= createdAt GROUP BY month;
	elseif duration = '1 year' then 
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND  (CURDATE() - INTERVAL 1 YEAR) <= createdAt GROUP BY month;
	elseif duration = '6 Months' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND  (CURDATE() - INTERVAL 6 MONTH) <= createdAt GROUP BY month;
	elseif duration = '3 Months' then
		SELECT MONTHNAME(createdAt) AS month, COUNT(*) as data FROM project WHERE  isDeleted = 0 AND projectStatus = 'active' AND  (CURDATE() - INTERVAL 3 MONTH) <= createdAt GROUP BY month;
	else
		SELECT 'time zone did not match' as message;
	end if;
else
	SELECT 'invalid user type' as message;
end if;	
END;;


DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getAllProjectForAdmin` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getAllProjectForAdmin`(in requestId int ,in txt varchar(30))
BEGIN
IF txt = '' THEN
        -- Logic for handling empty param1
       -- Set to NULL or perform specific actions as needed
       if exists (select * from `admins` where userId=requestId and isActive=1 ) then
           SELECT p.*,
           (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
           (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
           (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
           (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
           FROM `project` AS p  WHERE  isDeleted=0 AND projectStatus = 'active' ;
 
           select * from requests where status!='approved' AND requestType!='New Developer';
		else
           select 'User not found' AS message;
        end if;
ELSE    if exists (select * from `admins` where userId=requestId and isActive=1) then
         Set txt= concat('%', txt, '%');
           -- set @organisationId = (select organisationId from re_developer where userId = requestId ) ;
           SELECT p.*,
           (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
           (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
           (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
           (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
           FROM `project` AS p  WHERE  isDeleted=0 and (projectName like txt or projectAddress like txt);
 
            -- select changedData from requests where requestId=requestId and status='pending' and (changedData->'$.projectDetails.projectAddress' like txt or changedData->'$.projectDetails.projectName' like txt);
 
            -- select changedData,status,requestId from requests where userId=requestId and status='pending' and (changedData->'$.projectDetails.projectAddress' like txt or changedData->'$.projectDetails.projectName' like txt);
 
            select * from requests where status!='approved'  AND requestType!='New Developer' and (changedData->'$.projectDetails.projectAddress' like txt or changedData->'$.projectDetails.projectName' like txt);
 
         else
           select 'User not found' AS message;
         end if;  
END IF;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getNeighboursAndComments` */;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getNeighboursAndComments`(IN idsy_list VARCHAR(255),IN idsm_list VARCHAR(255),IN idsn_list VARCHAR(255),IN idsa_list VARCHAR(255), in pId int)
BEGIN
    IF idsn_list = '' THEN
        -- Logic for handling empty param1
        SET idsn_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsy_list = '' THEN
        -- Logic for handling empty param1
        SET idsy_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsm_list = '' THEN
        -- Logic for handling empty param1
        SET idsm_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    IF idsa_list = '' THEN
        -- Logic for handling empty param1
        SET idsa_list = 'null'; -- Set to NULL or perform specific actions as needed
    END IF;
    SET @query = CONCAT('select neighbour_survey_answers.answer as relationship,if((SELECT count(*) FROM envelope_details where neighbour_Id = neighbours.userId) > 0, true, false) AS isSupporter,if((SELECT isVolunteer FROM volunteerforproject where userId = neighbours.userId and projectId=',pId,') > 0, true, false) AS isVolunteer, neighbours.* FROM neighbours INNER JOIN neighbour_survey_answers ON neighbour_survey_answers.userId=neighbours.userId and neighbour_survey_answers.questionId=2 and neighbours.userId in (', idsy_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @query = CONCAT('select neighbour_survey_answers.answer as relationship,if((SELECT count(*) FROM envelope_details where neighbour_Id = neighbours.userId) > 0, true, false) AS isSupporter, neighbours.* FROM neighbours INNER JOIN neighbour_survey_answers ON neighbour_survey_answers.userId=neighbours.userId and neighbour_survey_answers.questionId=2 and neighbours.userId in (', idsm_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @query = CONCAT('select neighbour_survey_answers.answer as relationship,if((SELECT count(*) FROM envelope_details where neighbour_Id = neighbours.userId) > 0, true, false) AS isSupporter, neighbours.* FROM neighbours INNER JOIN neighbour_survey_answers ON neighbour_survey_answers.userId=neighbours.userId and neighbour_survey_answers.questionId=1 and neighbours.userId in (', idsn_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	SET @query = CONCAT('SELECT be_heard_comments.comment, neighbours.firstName FROM be_heard_comments INNER JOIN neighbours ON be_heard_comments.userId=neighbours.userId and be_heard_comments.isDeleted=0 and neighbours.userId in  (', idsa_list, ')');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;;

USE `yimbyqadb`;
CREATE TABLE `oktoContact` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `projectId` int NOT NULL,
  `isOk` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ;

DELIMITER ;;
CREATE DEFINER=`yimby`@`%` PROCEDURE `okToContact`(in _userId int, in _projectId int, in _isOk tinyint)
BEGIN
	if(exists(select * from oktoContact where userId = _userId and projectId = _projectId)) then
		update oktoContact set isOk = _isOk where userId = _userId and projectId = _projectId;
    else
		insert into oktoContact (userId, projectId, isOk) values (_userId, _projectId, _isOk);
    end if;
	if(exists(select * from oktoContact where userId = _userId and projectId = _projectId)) then
		select 'updated successfully' message, true isUpdated;
    else
		select 'failed to update' message, false isUpdated;
    end if;
END
