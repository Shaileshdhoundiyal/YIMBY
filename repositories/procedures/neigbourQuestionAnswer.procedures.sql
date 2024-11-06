
/*procedure for adding survey answer */

USE `yimbyqadb`;

DELIMITER ;
/*!50003 DROP PROCEDURE IF EXISTS `addSurveyQuestionsAnswers` */;
DELIMITER ;;
CREATE PROCEDURE `addSurveyQuestionsAnswers`(in survey_queries json, in _userId int)
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