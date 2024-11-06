USE `yimbyqadb`;
/*!50003 DROP PROCEDURE IF EXISTS `insertCard` */;
DELIMITER ;;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertCard`(IN cardTitle1 VARCHAR(255),
 IN cardIcon1 text,
  IN cardDescription1 VARCHAR(255),
  IN userId1 int)
BEGIN
 
    IF EXISTS(SELECT * FROM `cards` WHERE cardTitle = cardTitle1 and userId = userId1 and isDeleted = 0) THEN
 
        SELECT 'Card already registered' AS message;
 
    ELSE
 
        INSERT INTO `cards`(userId,cardTitle,cardIcon,cardDescription) VALUES(userId1,cardTitle1,cardIcon1,cardDescription1);
        SELECT LAST_INSERT_ID() INTO @uId;
        SELECT 'Success' AS message,'cards' AS cardTitle,cardIcon,cardDescription,isDeleted,createdOn,modifiedOn FROM `cards` WHERE id=@uId;
    END IF;
END;;
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `editREDeveloperProfile` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `editREDeveloperProfile`(in uId int ,in uType varchar(30),in fname varchar(255),in sName varchar(255), in `pImg` text, in lat int, in longi int , in zip varchar(20),in adrs varchar(400), in cntry varchar(40), in st varchar(40), in cty varchar(40),in org varchar(255),in _phoneNumber varchar(100))
BEGIN
        BEGIN
        if exists(select * from `re_developer` where userId=uId and isActive=1)then
                update `re_developer` set firstName=fName, surName=sName,profilePhoto=pImg ,`organisationName`=org, phoneNumber=_phoneNumber, latitude=lat, longitude=longi, zipCode=zip , address=adrs, country=cntry, state=st, city=cty where userId=uId;
                select 'Success' as message;
        else
            select 'User not found' as message;
        end if;
END ;;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `editNeighboursProfile` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `editNeighboursProfile`(in uId int,in uType varchar(30),in fName varchar(255),sName varchar(255),in adrs text,in eId varchar(255), in  pImg text,IN lat DECIMAL(9,6),IN `long` DECIMAL(9,6))
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
DELIMITER ;;
 
 
/*!50003 DROP PROCEDURE IF EXISTS `editAdminProfile` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `editAdminProfile`(in uId int ,in uType varchar(30),in fname varchar(255),in sName varchar(255), in `pImg` text, in lat int, in longi int , in zip varchar(20),in cntry varchar(40), in st varchar(40), in cty varchar(40),in address1 varchar(255))
BEGIN
        if exists(select * from `admins` where userId=uId and isActive=1)then
           
                update `admins` set firstName=fName, surName=sName, profilePhoto=pImg, lattitude=lat, longitude=longi, zipCode=zip, country=cntry, state=st, city=cty , address = address1 where userId=uId;
                select 'Success' as message;
           
        else
            select 'User not found' as message;
        end if;
END;;
 
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewREDeveloper` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertNewREDeveloper`(IN _firstName VARCHAR(255), IN _surName varchar(50), IN _email varchar(50), IN _orgName varchar(50),IN _phoneNumber varchar(50),IN _password varchar(50))
 
BEGIN
 
    IF EXISTS(SELECT * FROM `re_developer` WHERE email = _email) /*or EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail)*/ THEN
 
        SELECT 'Email already registered' AS message;
 
    ELSE
 
        INSERT INTO `re_developer`(firstName, surName, email, password, organisationName, phoneNumber)VALUES(_firstName, _surName, _email,_password,_orgName,_phoneNumber);
 
        SELECT LAST_INSERT_ID() INTO @uId;
 
        SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName, email,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE userId=@uId;
 
        select * from templates where id = 4;
 
    END IF;
 
END;;
        -- insert INTO `project_cards` (staticCardId,projectId,cardTitle,cardIcon,cardDescription,cardAgreeCount,cardDisAgreeCount) VALUES(@uId,projectId1,cardTitle1,cardIcon1,cardDescription1,0,0);
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `addSurveyQuestionsAnswers` */;
 
CREATE DEFINER=`yimby`@`%` PROCEDURE `addSurveyQuestionsAnswers`(in survey_queries json, in _userId int)
BEGIN
    set @i = 0;
    if((select count(id) from neighbour_survey_answers where userId = _userId) >= 3) then
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
        if((select count(id) from neighbour_survey_answers where userId = _userId) = 3) then
            select 'added' as message;
        else
            select 'failed' as message;
        end if;
    end if;
END;;
 
use `yimbyqadb`;
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `deleteProject` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `deleteProject`(in uId int,in pId varchar(255))
BEGIN
    if exists(select * from `project` where projectId = pId and isDeleted = 0) then
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
                select 'Success' as message;
            else
                select 'invalid User' as message;
            end if;
        else
            select 'Project Not Found' as message;
        end if;
END;;
 
 
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getMyProjectByUserId` */;
 
CREATE DEFINER=`yimby`@`%` PROCEDURE `getMyProjectByUserId`(in requestId int)
BEGIN
    if exists (select * from `re_developer` where userId=requestId and isActive=1) then
        set @organisationId = (select organisationId from re_developer where userId = requestId);
        SELECT P.*,
        (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
        (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
        (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
        (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
        FROM `project` AS p  WHERE userId=requestId AND isDeleted=0;
    else
        select 'User not found' AS message;
    end if;
END;;
 
DELIMITER ;;
-- create new project procedure new
/*!50003 DROP PROCEDURE IF EXISTS `create_new_project` */;
 
 
CREATE DEFINER=`yimby`@`%` PROCEDURE `create_new_project`(
    in project_query text,
--  in project_Partner json,
  in project_benefit json,
   in project_images json,
    in card_details_query json
    --  in phase_status_query json,
    --   in _newOrganisationQuery text,
    --    in _newPartnerOrganisationsQuery json,
        -- in _newOrganisationName VARCHAR(255),
        --  in _newPartnerOrganisationsNames JSON,
        --   in _organisationId int
          )
BEGIN
    set @projectQuery = project_query;
    set @projectImages = project_images;
    set @projectBenefits = project_benefit;
    -- set @projectPartner = project_Partner;
    -- set @newPartnerOrganisationsNames = _newPartnerOrganisationsNames;
    -- set @newPartnerOrganisationsQuery = _newPartnerOrganisationsQuery;
    -- set @newOrganisationQuery = _newOrganisationQuery;
    -- set @organisationId = _organisationId;
   
   
    -- if((@newOrganisationQuery is not null) and !exists(select * from organisations where name = _newOrganisationName)) then
    --  PREPARE add_new_organisation from @newOrganisationQuery;
    --     EXECUTE add_new_organisation;
    --     DEALLOCATE PREPARE add_new_organisation;
    --     select last_insert_id() into @organisationId;
    -- elseif((@newOrganisationQuery is not null) and exists(select * from organisations where name = _newOrganisationName)) then
    --  select id from organisations where name = _newOrganisationName into @organisationId;
    -- end if;
   
    -- select @organisationId; -- .....................................................
   
    -- if(JSON_LENGTH(_newPartnerOrganisationsNames) > 0 and JSON_LENGTH(_newPartnerOrganisationsQuery) > 0) then
    --  set @i = 0;
    --  while @i < JSON_LENGTH(@newPartnerOrganisationsQuery) do
    --      select JSON_UNQUOTE(JSON_EXTRACT(@newPartnerOrganisationsNames, CONCAT('$[',@i,']'))) into @partnerOrganisationName;
    --      if(!exists(select * from organisations where name = @partnerOrganisationName)) then
    --          select JSON_EXTRACT(_newPartnerOrganisationsQuery, CONCAT('$[',@i,']')) into @newPartnerOrganisation_query;
    --             select replace(@newPartnerOrganisation_query, '\\', '') into @newPartnerOrganisation_query;
    --             select trim('"' from @newPartnerOrganisation_query) into @newPartnerOrganisation_query;
    --             PREPARE add_new_partnerOrganisation from @newPartnerOrganisation_query;
    --             EXECUTE add_new_partnerOrganisation;
    --             DEALLOCATE PREPARE add_new_partnerOrganisation;
    --             if(@projectPartner is null) then
    --              select concat('[', last_insert_id(), ']') into @projectPartner;
    --          else
    --              select replace(@projectPartner, ']', concat(',', last_insert_id(), ']')) into @projectPartner;
    --          end if;
    --      else
    --          if(@ is null) then
    --              select concat('[', id, ']') from organisations where name = @partnerOrganisationName into @projectPartner;
    --             else
    --              select replace(@projectPartner, ']', concat(',', id, ']')) from organisations where name = @partnerOrganisationName into @projectPartner;
    --             end if;
    --      end if;
    --         -- select 'project partner 1', @i, @projectPartner; -- ............................................................
    --         select @i + 1 into @i;
    --     end while;
    -- end if;
   
    PREPARE insert_project from @projectQuery;
    EXECUTE insert_project;
    DEALLOCATE PREPARE insert_project;
       
    SELECT LAST_INSERT_ID() INTO @pId;
 
    if(exists(select * from project where projectId = @pId)) then
        -- update project set phaseStatus = phase_Status, benefit = project_benefit, projectPartner = project_Partner  where projectId = @pId;
        -- if(JSON_LENGTH(phase_status_query) > 0) then
        --  set @i = 0;
        --     while @i < JSON_LENGTH(phase_status_query) DO
        --      select JSON_EXTRACT(phase_status_query, CONCAT('$[',@i,']')) INTO @phaseQuery;
        --         select trim('"' from @phaseQuery) into @phaseQuery;
        --         PREPARE insert_phase_status from @phaseQuery;
        --         EXECUTE insert_phase_status;
        --         DEALLOCATE PREPARE insert_phase_status;
        --         SELECT @i + 1 INTO @i;
        --  end while;
        -- end if;
        #if(JSON_LENGTH(card_details_query) > 0) then
        #   set @i = 0;
        #   while @i < JSON_LENGTH(card_details_query) DO
        #       SELECT JSON_EXTRACT(card_details_query,CONCAT('$[',@i,']')) INTO @cardId;
        #       insert into project_cards (projectId, cardId) values (@pId, @cardId);
        #       SELECT @i + 1 INTO @i;
        #   end while;
        #end if;
        -- if(JSON_LENGTH(card_details_query) > 0) then
        --  set @i = 0;
        --  while @i < JSON_LENGTH(card_details_query) DO
        --      select JSON_EXTRACT(card_details_query, CONCAT('$[',@i,']')) INTO @cardQuery;
        --      select replace(@cardQuery, '\\', '') into @cardQuery;
        --      select trim('"' from @cardQuery) into @cardQuery;
        --      set @j = 0;
        --      while @j < JSON_LENGTH(@cardQuery) DO
        --          select JSON_EXTRACT(@cardQuery, CONCAT('$[',@j,']')) INTO @subQuery;
        --          select trim('"' from @subQuery) into @subQuery;
        --          PREPARE insert_card_and_sub_topic from @subQuery;
        --          EXECUTE insert_card_and_sub_topic;
        --          DEALLOCATE PREPARE insert_card_and_sub_topic;
        --          SELECT @j + 1 INTO @j;
        --      end while;
        --      SELECT @i + 1 INTO @i;
        --  end while;
        -- end if;
        SELECT 'Success' AS message,@pId AS projectId, @phase_Status, project_images;
    else
        select 'failed to insert project';
    end if;
END ;;
 
 
USE `yimbyqadb`;
ALTER TABLE `re_developer` ADD COLUMN
 `otp` varchar(6) DEFAULT NULL;
 ALTER TABLE `re_developer` ADD COLUMN
  `otpExpireAt` timestamp(3) NULL DEFAULT NULL;
 
 
 
 
 
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `forgotPasswordStep2` */;
  CREATE DEFINER=`yimby`@`%` PROCEDURE `forgotPasswordStep2`(in uId int, in tok text, in uType varchar(30), in passcode text, in _otp varchar(6))
BEGIN
    DECLARE otpMatched INT;
 
    -- Check if the token exists in the temporary_session table
    if exists(select * from `temporary_session` where token=tok) then
        -- Check the user type
        if uType = 'neighbours' then
            -- Check if passcode is NULL
            if passcode is NULL then
                -- Check if the provided OTP matches the one in the neighbors table
                select count(*) into otpMatched from neighbours where userId = uId AND otp = _otp;
                if otpMatched = 1 and date_sub(current_timestamp(3), INTERVAL 30 MINUTE) < (select otpExpireAt from neighbours where userId = uId AND otp = _otp) then
                    select 'Success' as message;
                else
                    select 'Incorrect OTP' as message;
                end if;
            else
                -- Check if the provided OTP matches the one in the neighbors table
                select count(*) into otpMatched from neighbours where userId = uId AND otp = _otp;
                if otpMatched = 1 and date_sub(current_timestamp(3), INTERVAL 30 MINUTE) < (select otpExpireAt from neighbours where userId = uId AND otp = _otp) then
                    update `neighbours` set `password` = passcode where userId = uId;
                    DELETE FROM `temporary_session` WHERE token = tok;
                    select 'Success' as message;
                else
                    select 'Incorrect OTP' as message;
                end if;
            end if;
        else
            select count(*) into otpMatched from re_developer where userId = uId AND otp = _otp;
                if otpMatched = 1 and date_sub(current_timestamp(3), INTERVAL 30 MINUTE) < (select otpExpireAt from re_developer where userId = uId AND otp = _otp) then
                    update `re_developer` set `password` = passcode where userId = uId;
                    DELETE FROM `temporary_session` WHERE token = tok;
                    select 'Success' as message;
                else
                    select 'Incorrect OTP' as message;
                end if;
        end if;
    else
        select 'Token not found' as message;
    end if;
END;;
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getMyProjectByUserId` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getMyProjectByUserId`(in requestId int)
BEGIN
    if exists (select * from `re_developer` where userId=requestId and isActive=1) then
        set @organisationId = (select organisationId from re_developer where userId = requestId);
        SELECT p.*,
        (select count(commentId) from be_heard_comments where projectId = p.projectId and isDeleted = 0) AS responses,
        (SELECT COUNT(commentId) FROM `sub_topics_comments` WHERE projectId = p.projectId AND isDeleted = 0) AS unreadMessageCount,
        (select (json_arrayagg(json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted))) from project_phase_status where projectId = p.projectId and isDeleted is false order by id desc)  AS `phase`,
        (select (json_object('phaseId', id, 'phaseName', phaseName, 'phaseBegins', phaseBegins, 'phaseEnds', phaseEnds, 'projectId', projectId, 'isCompleted', isCompleted)) from project_phase_status where id = (select min(id) from project_phase_status where projectId = p.projectId and isCompleted is false and isDeleted is false))  as currentPhase
        FROM `project` AS p  WHERE userId=requestId AND isDeleted=0;
    else
        select 'User not found' AS message;
    end if;
END;;
 
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `deleteCard` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `deleteCard`(in cardId1 int,in userId1 int)
BEGIN
    if exists(select * from `cards` where id = cardId1 and userId = userId1 and isDeleted = 0) then
        update `cards` set isDeleted = 1 where id = cardId1;
        select 'Success' as message;
    else
        select 'card not exists' as message;
    end if;
END;;
 
use `yimbyqadb`;
ALTER TABLE `cards` ADD COLUMN `isRequired` boolean DEFAULT false;

DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertCard` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertCard`(IN cardTitle1 VARCHAR(255),
IN cardIcon1 text,
  IN cardDescription1 VARCHAR(255),
  IN isRequired1 tinyint(1),
  IN userId1 int)
BEGIN
 
	IF EXISTS(SELECT * FROM `cards` WHERE cardTitle = cardTitle1 and userId = userId1 and isDeleted = 0) THEN
 
		SELECT 'Card already registered' AS message;
 
	ELSE
 
		INSERT INTO `cards`(userId,cardTitle,cardIcon,cardDescription,isRequired) VALUES(userId1,cardTitle1,cardIcon1,cardDescription1,isRequired1);
        SELECT LAST_INSERT_ID() INTO @uId;
		SELECT 'Success' AS message,'cards' AS cardTitle,cardIcon,cardDescription,isRequired,isDeleted,createdOn,modifiedOn FROM `cards` WHERE id=@uId;
	END IF;
END
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `updateCard` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `updateCard`(in cardId1 int ,in cardTitle1 text,in cardIcon1 text , in cardDescription1 varchar(255),in isRequired1 tinyint(2),in userId1 int)
BEGIN
	if exists(select * from `cards` where id = cardId1 and userId = userId1 and isDeleted = 0) then 
		update `cards` set cardIcon = cardIcon1 ,cardTitle = cardTitle1, cardDescription = cardDescription1,isRequired = isRequired1 where id = cardId1 and userId = userId1 and isDeleted = 0;
    if exists(select * from `cards` where id = cardId1 and userId = userId1 and isDeleted = 0) then
        update `cards` set cardIcon = cardIcon1 , cardDescription = cardDescription1,isRequired = isRequired1 where id = cardId1 and userId = userId1 and isDeleted = 0;
        select 'Success' as message;
    else
        select 'card does not exist' as message;
    end if;
END;;
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertSessionToken` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertSessionToken`(IN uId INT,IN sessionToken TEXT,IN uType varchar(30))
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
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewNeighbours` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `insertNewNeighbours`(IN userEmail VARCHAR(255), IN password1 text, IN fName VARCHAR(255), IN sName VARCHAR(255), IN adrs text, IN lat DECIMAL(9,6),IN `long` DECIMAL(9,6),in country1 varchar(255),in state1 varchar(255),in city1 varchar(255),in zipcode1 varchar(9))
BEGIN
 
    IF EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail and isActive=1) THEN
 
        SELECT 'Email already registered' AS message;
 
    ELSE
 
        INSERT INTO `neighbours`(email, `password`, firstName, surName,`address`,latitude,longitude,country,`state`,city,zipcode) VALUES(userEmail, password1, fName, sName,adrs,lat,`long`,country1,state1,city1,zipcode1);
 
        SELECT LAST_INSERT_ID() INTO @uId;
 
        SELECT 'Success' AS message,'neighbours' AS userType,userId,firstName,surName,email,`password`,`address`,country,`state`,city,zipCode,`profile`,isActive,createdOn,modifiedOn,lastLoggedAt,isThemesMode FROM `neighbours` WHERE userId=@uId;
 
    END IF;
 
END;;
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewREDeveloper` */;
CREATE DEFINER=`yimby`@`%`PROCEDURE `insertNewREDeveloper`(IN _firstName VARCHAR(255), IN _surName varchar(50), IN _email varchar(50),IN _password varchar(50),IN _phoneNumber varchar(50), IN _orgName varchar(50),in zipcode1 varchar(9),in country1 varchar(255),in state1 varchar(255) , in city1 varchar(255),in address1 varchar(255),in longitude1 decimal(9,6),in latitude1 decimal(9,6))
BEGIN
 
    IF EXISTS(SELECT * FROM `re_developer` WHERE email = _email) /*or EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail)*/ THEN
 
        SELECT 'Email already registered' AS message;
 
    ELSE
 
        INSERT INTO `re_developer`(firstName, surName, email, password, organisationName, phoneNumber,zipCode,country,state,city,address,longitude,lattitude)VALUES(_firstName, _surName, _email,_password,_orgName,_phoneNumber,zipcode1,country1,state1,city1,address1,longitude1,latitude1);
 
        SELECT LAST_INSERT_ID() INTO @uId;
 
        SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName, email,zipCode,country,state,city,address,longitude,lattitude,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE userId=@uId;
 
        select * from templates where id = 4;
 
    END IF;
 
END;;
 
 
DELIMITER ;;
/*!50003 DROP PROCEDURE IF EXISTS `getMyPassword` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `getMyPassword`(in uId int,uType varchar(30))
BEGIN
    if uType='neighbours' then
        if exists(select * from `neighbours` where userId=uId and isActive=1)then
            select 'Success' as message,`neighbours`.`password` from `neighbours` where userId=uId and isActive=1;
        else
            select 'User not found' as message;
        END IF;
    elseif uType="re_developer" then
        IF EXISTS(SELECT * FROM `re_developer` WHERE userId=uId AND isActive=1)THEN
            SELECT 'Success' AS message, password FROM re_developer WHERE userId=uId AND isActive=1;
        ELSE
            SELECT 'User not found' AS message;
        END IF;
    else
        IF exists(select * from `admins` where userId=uId and isActive=1)then
           SELECT 'Success' AS message,`admins`.`password` FROM `admins` WHERE userId=uId AND isActive=1;
        ELSE
            SELECT 'User not found' AS message;
        END IF;
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
/*!50003 DROP PROCEDURE IF EXISTS `forgotPasswordStep1` */;
CREATE DEFINER=`yimby`@`%` PROCEDURE `forgotPasswordStep1`(in eId text, in userType varchar(20), in _otp varchar(6))
BEGIN
	if (userType = 're_developer' and exists(select * from `re_developer` where email=eId and isActive=1 and isApproved = 'approved'))then
    update re_developer set otp = _otp, otpExpireAt = date_add(current_timestamp(3), interval 30 minute) where email=eId;
		select 'Success' as message, 're_developer' as userType,r.userId,t.body,t.subject,concat(r.firstName,' ',r.surName) as userName from  `re_developer` r  join templates t where r.email=eId and t.id = 1;
	elseif (userType = 'neighbour' and exists(select * from `neighbours` where email=eId and isActive=1)) then
		update neighbours set otp = _otp, otpExpireAt = date_add(current_timestamp(3), interval 30 minute) where email=eId;
		select 'Success' as message,'neighbours' as userType ,n.userId,t.body,t.subject,CONCAT(n.firstName,' ',n.surName) as userName from `neighbours`n join  templates t where n.email=eId and t.id = 5;
	else
		select "Email Id doesn't exist" as message;
	end if;
END;;