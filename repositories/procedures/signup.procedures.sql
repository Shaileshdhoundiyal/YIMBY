
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

USE `yimbyqadb`;

DELIMITER ;
/*!50003 DROP PROCEDURE IF EXISTS `insertNewREDeveloper` */;
DELIMITER ;;
CREATE PROCEDURE `insertNewREDeveloper`(IN _firstName VARCHAR(255), IN _surName varchar(50), IN _email varchar(50), IN _orgName varchar(50),IN _phoneNumber varchar(50),IN _password varchar(50))
BEGIN
	IF EXISTS(SELECT * FROM `re_developer` WHERE email = _email) /*or EXISTS(SELECT * FROM `neighbours` WHERE email = userEmail)*/ THEN
		SELECT 'Email already registered' AS message;
	ELSE
		INSERT INTO `re_developer`(firstName, surName, email, password, organisationName, phoneNumber)VALUES(_firstName, _surName, _email,_password,_orgName,_phoneNumber);
		SELECT LAST_INSERT_ID() INTO @uId; 
		SELECT 'Success' AS message,'re_developer' AS userType,userId,firstName,surName, email,profilePhoto,createdOn,modifiedOn,isActive,lastLoggedAt FROM `re_developer` WHERE userId=@uId;
		select * from templates where id = 4;
	END IF;
END ;;