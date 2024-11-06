USE `yimbyqadb`;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `changeNotification` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `changeNotification`(in uId int,in uType varchar(30),in _isDesktopNotification boolean,in _isEmailNotification boolean,in _isProjectUpdated boolean,in _isNewDeveloperAdded boolean)
BEGIN
if uType="re_developer" then
		update `re_developer` set `isDesktopNotification`=_isDesktopNotification, `isEmailNotification`=_isEmailNotification,`isProjectUpdated`=_isProjectUpdated WHERE userId=uId;
		SELECT 'Success' AS message;
	else 
	    update `admins` set `isDesktopNotification`=_isDesktopNotification, `isEmailNotification`=_isEmailNotification,`isNewProjectAdded`=_isProjectUpdated ,`isNewDeveloperAdded`=_isNewDeveloperAdded WHERE userId=uId;
		SELECT 'Success' AS message;
	end if;
END ;;


DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `updateMyPassword` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `updateMyPassword`(in uId int,in uType varchar(30),in newPassword text)
BEGIN
	if uType='neighbours' then
		update `neighbours` set `password`=newPassword where userId=uId;
		select 'Success' as message;
	elseif uType="re_developer" then
		update `re_developer` set `password`=newPassword WHERE userId=uId;
		SELECT 'Success' AS message;
	else 
	    update `admins` set `password`=newPassword WHERE userId=uId;
		SELECT 'Success' AS message;
	end if;
END ;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getUserProfile` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getUserProfile`(In requestId int ,in uType varchar(30))
BEGIN
    if uType=`neighbours` then
         select `Success` as message, userId,firstName,surName,email,state,zipCode,address,latitude,longitude,city,profile,isThemesMode from `neighbours` where userId=requestId and isActive=1;  
    elseif uType = `re_developer` then
        SELECT `Success` AS message, userId,firstName,surName,email, profilePhoto,address,country,state,city,lattitude,longitude,zipCode,isThemesMode from `re_developer` WHERE userId=requestId AND isActive=1;
    elseif uType = `admins` then
        SELECT `Success` AS message, userId,firstName,surName,email, profilePhoto,address,country,state,city,lattitude,longitude,zipCode,isThemesMode from `admins` where userId = requestId and isActive = 1;
    else
        SELECT `user not found` as message;
    end if;
 
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `changeTheme` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `changeTheme`(In uId int ,in uType varchar(30),in _isThemesMode varchar(60))
BEGIN

	if uType='neighbours' then
		update `neighbours` set `isThemesMode`=_isThemesMode where userId=uId;
		select 'Success' as message;
	elseif uType="re_developer" then
		update `re_developer` set `isThemesMode`=_isThemesMode WHERE userId=uId;
		SELECT 'Success' AS message;
	else 
	    update `admins` set `isThemesMode`=_isThemesMode WHERE userId=uId;
		SELECT 'Success' AS message;
	end if;

END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewNeighbours` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertNewNeighbours`(IN userEmail VARCHAR(255), IN password1 text, IN fName VARCHAR(255), IN sName VARCHAR(255), IN adrs text, IN lat DECIMAL(9,6),IN `long` DECIMAL(9,6),in country1 varchar(255),in state1 varchar(255),in city1 varchar(255),in zipcode1 varchar(9))
BEGIN

	IF EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail and isActive is true) THEN

		SELECT 'Email already registered' AS message;

	ELSEIF exists(SELECT * FROM `re_developer` WHERE email = userEmail and isActive = 1)then
		SELECT 'developer can not be neighbour' AS message;
	ELSE
		INSERT INTO `neighbours`(email, `password`, firstName, surName,address,latitude,longitude,country,state,city,zipcode) VALUES(userEmail, password1, fName, sName,adrs,lat,`long`,country1,state1,city1,zipcode1);

		SELECT LAST_INSERT_ID() INTO @uId;

		SELECT 'Success' AS message,'neighbours' AS userType,userId,firstName,surName,email,`password`,address,country,state,city,zipCode,`profile`,isActive,createdOn,modifiedOn,lastLoggedAt,isThemesMode FROM `neighbours` WHERE userId=@uId;

	END IF;

END;;


DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewREDeveloper` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertNewREDeveloper`(IN _firstName VARCHAR(255), IN _surName varchar(50), IN _email varchar(50),IN _password varchar(50),IN _phoneNumber varchar(50), IN _orgName varchar(50),in zipcode1 varchar(9),in country1 varchar(255),in state1 varchar(255) , in city1 varchar(255),in address1 varchar(255),in longitude1 decimal(9,6),in latitude1 decimal(9,6))
BEGIN

	IF EXISTS(SELECT * FROM `re_developer` WHERE email = _email) /*or EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail)*/ THEN

		SELECT 'Email already registered' AS message;
	ELSEIF exists(SELECT * FROM `neighbours` WHERE email = _email and isActive = 1)then
		SELECT 'neighbour can not be developer' AS message;
	ELSE

		INSERT INTO `re_developer`(firstName, surName, email, `password`, organisationName, phoneNumber,zipCode,country,state,city,address,longitude,lattitude)VALUES(_firstName, _surName, _email,_password,_orgName,_phoneNumber,zipcode1,country1,state1,city1,address1,longitude1,latitude1);

		SELECT LAST_INSERT_ID() INTO @uId; 

		SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName, email,zipCode,country,state,city,address,longitude,lattitude,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE userId=@uId;

		select * from templates where id = 4;

	END IF;

END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewAdmin` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertNewAdmin`(IN userEmail VARCHAR(255), IN password1 text, IN fName VARCHAR(255), IN sName VARCHAR(255))
BEGIN
	IF EXISTS(SELECT * FROM admins WHERE email = userEmail and isActive is true) THEN
		SELECT 'Email already registered' AS message;
	ELSE
		INSERT INTO admins(email, `password`, firstName, surName) VALUES(userEmail, password1, fName, sName);
		SELECT LAST_INSERT_ID() INTO @uId;
		SELECT 'Success' AS message,'admin' AS userType,userId,firstName,surName,email,`password`,isActive,createdOn,modifiedOn,lastLoggedAt FROM admins WHERE userId=@uId;
	END IF;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `fetchRequests` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `fetchRequests`(in requestType varchar(255))
BEGIN
	if(requestType = 'projectApproval') then
        if exists(SELECT * fROM `project` AS p INNER JOIN `re_developer` AS u ON p.userId = u.userId WHERE p.projectStatus = 'Draft')then
            select 'Success' as message,p.projectId as Id,p.projectName,p.modifiedAt as createdAt,p.createdAt as 'creationTime',u.firstName,u.surName,'New Project' as requestType from `project` as p inner join `re_developer` as u ON p.userId = u.UserId where p.projectStatus = 'Draft';
        else
            select 'no project for approval' as message;
        end if;
    elseif(requestType = 'developerApproval') then
        if exists (select * from `re_developer` where isApproved = 'pending') then
            select 'Success' as message,'New Developer'as requestType,r.userId as Id, r.firstName,r.surName,r.createdOn from `re_developer`as r where isApproved = 'pending';
        else
            select 'no request' as message;
        end if;
    else
        select 'Success' as message,p.projectId as Id,p.projectName,p.modifiedAt as createdAt,p.createdAt as 'creationTime',u.firstName,u.surName,'New Project'as requestType from `project` as p inner join `re_developer` as u ON p.userId = u.UserId where p.projectStatus = 'Draft' and p.isDeleted=0;
        select 'Success' as message,r.userId as Id, r.firstName,r.surName,r.createdOn as createdAt, 'New Developer'as requestType from `re_developer`as r where isApproved = 'pending';
    end if;

END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `approveRequest` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `approveRequest`(in requestType varchar(255),in projectId1 int)
BEGIN
	if(requestType = 'New Project' or requestType = 'Updated Project') then
        if exists(SELECT * fROM `project` where projectId = projectId1 and projectStatus = 'Draft' and isDeleted = 0)then
            UPDATE `project` SET projectStatus = 'active',isInDraft = 0 WHERE projectId = projectId1 and isDeleted = 0;
            select 'Success' as message;
        else
            select 'no request' as message;
        end if;
    elseif(requestType = 'New Developer') then
        if exists (select * from `re_developer` where userId = projectId1 and isDeleted = 0 and isApproved = 'pending') then
            Update `re_developer` SET isApproved = 'approved' where userId = projectId1 and isApproved = 'pending';
            select 'Success' as message;
        else
            select 'no request' as message;
        end if;
    else
        select 'invalid request type' as message;
    end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `rejectRequest` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `rejectRequest`(in requestType varchar(255),in projectId1 int)
BEGIN
	if(requestType = 'New Project' or requestType = 'Updated Project') then
        if exists(SELECT * fROM `project` where projectId = projectId1 and projectStatus = 'Draft' and isDeleted = 0)then
            UPDATE `project` SET projectStatus = 'rejected',isInDraft = 0 WHERE projectId = projectId1 and isDeleted = 0;
            select 'Success' as message;
        else
            select 'no request' as message;
        end if;
    elseif(requestType = 'New Developer') then
        if exists (select * from `re_developer` where userId = projectId1 and isDeleted = 0 and isApproved = 'pending') then
            Update `re_developer` SET isApproved = 'rejected' where userId = projectId1 and isApproved = 'pending';
            select 'Success' as message;
        else
            select 'no request' as message;
        end if;
    else
        select 'invalid request type' as message;
    end if;
END;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `doLogin` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `doLogin`(IN eId VARCHAR(255), in user_type varchar(255))
BEGIN
	SET @loggedInUserId = 0;
	IF (EXISTS(SELECT * FROM `neighbours` WHERE email = eId and isActive=1)  and user_type = 'neighbour' and IsApproved = 'approved') THEN
		SELECT userId INTO @loggedInUserId FROM `neighbours` WHERE email = eId and isActive is true;
		SELECT 'Success' AS message,'neighbours' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and  userType='neighbours') AS userExistsToken,*/ userId,firstName,surName,email,`password`,address/*,streetAddress,city,state,zipCode*/ ,`profile`, isThemesMode,createdOn,modifiedOn,isActive,loginAttempts,lastLoggedAt FROM `neighbours` WHERE email = eId and isActive is true LIMIT 1;
	ELSEIF (EXISTS(SELECT * FROM `re_developer` WHERE email = eId) and user_type = 're_developer')THEN
		if exists (SELECT * FROM `re_developer` WHERE email = eId and isApproved = 'approved') then
			SELECT userId INTO @loggedInUserId FROM `re_developer` WHERE email = eId;
			SELECT 'Success' AS message,'re_developer' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and userType='re_developer') AS userExistsToken,*/ userId,`password`,profilePhoto,createdOn,isActive,loginAttempts,lastLoggedAt FROM `re_developer` WHERE email = eId LIMIT 1;
		elseif (exists(SELECT * FROM `re_developer` WHERE email = eId and isApproved = 'pending')) then
			SELECT 'status is pending' as message;
		elseif (exists(SELECT * FROM `re_developer` WHERE email = eId and isApproved = 'rejected')) then
			select 'status is rejected' as message;
		else	
			select 'no user found ' as message;
		end if;
	elseif exists(select * from admins where email = eId and isActive is true) and user_type = 'admin' then
		select userId INTO @loggedInUserId FROM admins WHERE email = eId and isActive is true;
        SELECT 'Success' AS message,'admin' AS userType,/*(SELECT token FROM `session` WHERE userId = @loggedInUserId and userType='re_developer') AS userExistsToken,*/ userId,`password`,createdOn,isActive,lastLoggedAt FROM admins WHERE email = eId and isActive is true LIMIT 1;
	ELSE
		SELECT 'User not found' AS message;
	END IF;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `updateProject` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `updateProject`(in _projectId int, in _userId int, in project_query text, in  project_images text)
BEGIN
	-- DECLARE _isInDraft boolean; 
    set @projectQuery = project_query;
	set @projectImages = project_images;
	set @pId = _projectId;
    set @uId = _userId;
    -- #set @projectPartner = project_Partner;
	-- #set @newPartnerOrganisationsNames = _newPartnerOrganisationsNames;
    -- #set @newPartnerOrganisationsQuery = _newPartnerOrganisationsQuery;
    #select replace(@projectQuery, '\\', '') into @projectQuery;
    #select trim('"' from @projectQuery) into @projectQuery;
    -- select isInDraft into _isInDraft  from project where projectId = _projectId;
    -- select @projectPartner incoming_project_partner;
    -- if(JSON_LENGTH(_newPartnerOrganisationsNames) > 0 and JSON_LENGTH(_newPartnerOrganisationsQuery) > 0) then
		-- select 'inside new partner', JSON_LENGTH(@newPartnerOrganisationsQuery) queryLength;
       --  select @projectPartner `before`; -- /////////////////////////////
		-- set @i = 0;
		-- while @i < JSON_LENGTH(@newPartnerOrganisationsQuery) do
			-- select JSON_UNQUOTE(JSON_EXTRACT(@newPartnerOrganisationsNames, CONCAT('$[',@i,']'))) into @partnerOrganisationName;
			-- if(!exists(select * from organisations where name = @partnerOrganisationName)) then
				-- select JSON_EXTRACT(_newPartnerOrganisationsQuery, CONCAT('$[',@i,']')) into @newPartnerOrganisation_query;
                -- select replace(@newPartnerOrganisation_query, '\\', '') into @newPartnerOrganisation_query;
                -- select trim('"' from @newPartnerOrganisation_query) into @newPartnerOrganisation_query;
                -- PREPARE add_new_partnerOrganisation from @newPartnerOrganisation_query;
                -- EXECUTE add_new_partnerOrganisation;
                -- DEALLOCATE PREPARE add_new_partnerOrganisation;
                -- if(@projectPartner is null) then
					-- select @projectPartner `inside !exists @projectPartner is null`; -- /////////////////////////////
					-- select @i, 'inside partner null' secondIf, 'inside new partner' firstIf;
					-- select concat('[', last_insert_id(), ']') into @projectPartner;
				-- else 
					-- select @projectPartner `inside !exists @projectPartner is not null`; -- /////////////////////////////
					-- select @i, 'inside partner not null' secondIf, 'inside new partner' firstIf, @projectPartner;
					-- select replace(@projectPartner, ']', concat(',', last_insert_id(), ']')) into @projectPartner;
				-- end if;
			-- else 
				-- if(@projectPartner is null) then
					-- select @projectPartner `inside exists @projectPartner is null`; -- /////////////////////////////
					-- select @i, 'inside partner null' secondIf, 'inside exist partner' firstIf;
					-- select concat('[', id, ']') from organisations where name = @partnerOrganisationName into @projectPartner;
                -- else
					-- select @projectPartner `inside exists @projectPartner is not null`; -- /////////////////////////////
					-- select @i, 'inside partner not null' secondIf, 'inside exist partner' firstIf, @projectPartner;
					-- select replace(@projectPartner, ']', concat(',', id, ']')) from organisations where name = @partnerOrganisationName into @projectPartner;
               --  end if;
			-- end if;
            -- select 'project partner 1', @i, @projectPartner; -- ............................................................
            -- select @i + 1 into @i;
        -- end while;
    -- end if;
    -- select @projectPartner `after`; -- /////////////////////////////
    -- if(@projectPartner is not null) then
		-- set @projectPartner = replace(@projectPartner, ' ', '');
	-- end if;
	-- select @pId, @projectQuery; -- //////////////////////////////////////////////
	PREPARE update_project from @projectQuery;
	EXECUTE update_project;
	DEALLOCATE PREPARE update_project;
	-- if(JSON_LENGTH(phase_status_query) > 0) then
		-- set @i = 0;
		-- while @i < JSON_LENGTH(phase_status_query) DO
			-- select JSON_EXTRACT(phase_status_query, CONCAT('$[',@i,']')) INTO @phaseQuery;
			-- select trim('"' from @phaseQuery) into @phaseQuery;
            -- select replace(@phaseQuery, '\\', '') into @phaseQuery;
			-- PREPARE update_phase_status from @phaseQuery;
			-- EXECUTE update_phase_status;
			-- DEALLOCATE PREPARE update_phase_status;
			-- SELECT @i + 1 INTO @i;
		-- end while;
	-- end if;
	-- if(JSON_LENGTH(card_details_query) > 0) then
		-- set @i = 0;
		-- while @i < JSON_LENGTH(card_details_query) DO
			-- select JSON_EXTRACT(card_details_query, CONCAT('$[',@i,']')) INTO @cardQuery;
			-- select replace(@cardQuery, '\\', '') into @cardQuery;
			-- select trim('"' from @cardQuery) into @cardQuery;
			-- set @j = 0;
			-- while @j < JSON_LENGTH(@cardQuery) DO
					-- select JSON_EXTRACT(@cardQuery, CONCAT('$[',@j,']')) INTO @subQuery;
					-- select trim('"' from @subQuery) into @subQuery;
					-- PREPARE insert_card_and_sub_topic from @subQuery;
					-- EXECUTE insert_card_and_sub_topic;
					-- DEALLOCATE PREPARE insert_card_and_sub_topic;
					-- SELECT @j + 1 INTO @j;
			-- end while;
			-- SELECT @i + 1 INTO @i;
		-- end while;
	-- end if;
    SELECT 'Success' AS message,@pId AS projectId;
	-- if (_draftId != _isInDraft and  _isInDraft is false)  Then 
		-- select "CREATE_PROJECT" as message, true isProjectStatusChange;
	-- end if;
	-- if(_draftId != _isInDraft) then
		-- select true isProjectStatusChange;
	-- end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getProjectByProjectId` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getProjectByProjectId`(in pId int ,in uId int , in uType varchar(30))
BEGIN
	if uType='re_developer' then
		IF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 and p.isInDraft=1)THEN
			SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress,p.country,p.state,p.city, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan, p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes, p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds, p.coverImage, p.projectPartner/*(select count(commentId)from`comments`where projectId=pId and isDeleted=0)as commentsDetails,(SELECT JSON_OBJECT('commentId',c.commentId,'comment',c.comment,'commentUserId',c.userId,'commentLikes',c.likes,'commentLikedUserIds',c.commentLikedUserIds) FROM `comments` c WHERE c.projectId=pId AND c.isDeleted=0) AS commentsDetails */FROM `project` p JOIN comments c  WHERE p.projectId=pId AND p.isDeleted=0;
		ELSEIF EXISTS(SELECT p.* FROM `project` p JOIN `re_developer` r ON p.userId=r.userId WHERE p.projectId=pId AND p.isDeleted = 0 AND r.isActive = 1 and p.isInDraft=0)THEN
			SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress,p.country,p.state,p.city,p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds,p.coverImage, p.projectPartner,(SELECT JSON_OBJECT('updatesId',updatesId,'updateTitle',updateTitle,'updateDescription',updateDescription,'updateMedia',updateMedia,'updateCommentLikes',updateCommentLikes,'updateCommentLikedUserIds',updateCommentLikedUserIds,'createdOn',createdOn,'commentsCount',(SELECT COUNT(commentId) FROM `comments` WHERE updatesId=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId ) AND projectId=pId) ,'previousUpdatesCount',(SELECT COUNT(u1.updatesId) FROM `updates` u1  WHERE u1.projectId=pId AND u1.updatesId!=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId )))FROM updates u WHERE  u.projectId=pId AND u.updatesId=(SELECT MAX(updatesId)FROM updates  WHERE projectId=pId))AS updatesDetails  FROM `project` p  WHERE p.projectId=pId AND p.isDeleted=0; 
		else
			SELECT 'ProjectId not found' AS message;
		END IF;
	else
		if exists(select p. * from `project` p join `re_developer` r on p.userId=r.userId where p.projectId=pId and p.isInDraft = 0 AND p.isDeleted = 0 AND r.isActive = 1)then
			SELECT JSON_CONTAINS((SELECT viewedUserId FROM`project`WHERE projectId=pId AND isDeleted=0),CAST(uId AS JSON),'$')into @result;
			if @result=0 then	
				UPDATE `project`p SET p.views=p.views+1, p.viewedUserId=(SELECT * FROM(SELECT JSON_ARRAY_APPEND(viewedUserId,'$',CAST(uId AS JSON))FROM `project` WHERE projectId=pId) AS viewList) WHERE p.projectId=pId; 
			end if;
				SELECT 'Success' AS message, p.projectId,p.projectType, p.projectName, p.projectAddress,p.country,p.state,p.city, p.zipCode, p.latitude, p.longitude,p.buidlingHeight, p.propertySize, p.floorPlan,p.residentialUnits, p.maximumCapacity, p.thisProjectNumberLikes, p.thisProjectNumberLikedUserIds, p.projectDescription, p.projectDescriptionLikes,p.projectDescriptionLikedUserIds, p.presentationVideo, p.projectImage, p.benefit, p.benefitLikes,p.benefitLikedUserIds, p.section, p.sectionLikes, p.sectionLikedUserIds,p.coverImage, p.projectPartner,(SELECT JSON_OBJECT('updatesId',updatesId,'updateTitle',updateTitle,'updateDescription',updateDescription,'updateMedia',updateMedia,'updateCommentLikes',updateCommentLikes,'updateCommentLikedUserIds',updateCommentLikedUserIds,'createdOn',createdOn,'commentsCount',(SELECT COUNT(commentId) FROM `comments` WHERE updatesId=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId ) AND projectId=pId) ,'previousUpdatesCount',(SELECT COUNT(u1.updatesId) FROM `updates` u1  WHERE u1.projectId=pId AND u1.updatesId!=(SELECT MAX(updatesId)FROM updates WHERE projectId=pId )))FROM updates u WHERE  u.projectId=pId AND u.updatesId=(SELECT MAX(updatesId)FROM updates  WHERE projectId=pId))AS updatesDetails  FROM `project` p  WHERE p.projectId=pId AND p.isDeleted=0; 
		else
			select 'ProjectId not found' as message;
		end if;	
	end if;
END;;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getUserDetail` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getUserDetail`(In requestId int ,in uType varchar(30))
BEGIN

	if uType='Neighbour'then

		select 'Success' as message, userId,firstName,surName,email,/*streetAddress,city,state,zipCode*/address,latitude,longitude,`profile`,isThemesMode,if((SELECT count(*) FROM neighbour_survey_answers where userId = requestId) = 4, true, false) isSurveyDone from `neighbours` where userId=requestId and isActive=1;	
		select * from review_details where userId=requestId;
	else

		SELECT 'Success' AS message, userId,firstName,surName,email, profilePhoto,organisationId,organisationName as organisation,phoneNumber,lattitude, longitude,zipCode from `re_developer` WHERE userId=requestId AND isActive=1;	
         select * from project where userId = requestId;
	end if;

END;;
