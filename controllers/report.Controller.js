const { encrypt, AppError, queryExecutor } = require("../utils");
const { ERROR, SUCCESS } = require("../constants");
const query = require("../repositories/query.json");
 
const fs = require("fs-extra");
 
const hbs = require("handlebars");
const path = require("path");
const moment = require("moment/moment");
const { pid } = require("process");
const { log } = require("handlebars/runtime");
const { json } = require("body-parser");
 
function haversineDistanceAsync(lat1, lon1, lat2, lon2) {
  // Radius of the Earth in kilometers
  const R = 3959;
 
  // Convert latitude and longitude from degrees to radians
  const lat1Rad = toRadians(lat1);
  const lon1Rad = toRadians(lon1);
  const lat2Rad = toRadians(lat2);
  const lon2Rad = toRadians(lon2);
 
  // Calculate the differences between latitude and longitude
  const dLat = lat2Rad - lat1Rad;
  const dLon = lon2Rad - lon1Rad;
 
  // Haversine formula
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1Rad) *
      Math.cos(lat2Rad) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
 
  // Distance in kilometers
  distance = R * c;
  if (distance < 5) return "within 5mi";
  else if (distance < 10) return "within 10mi";
  else return `within ${distance?.toFixed(0)}mi`;
}
 
function toRadians(degrees) {
  return degrees * (Math.PI / 180);
}
 
// Example usage:
// (async () => {
//     try {
//         const distance = await haversineDistanceAsync(37.7749, -122.4194, 34.0522, -118.2437);
//         console.log(`Distance: ${distance} km`);
//     } catch (error) {
//         console.error(error);
//     }
// })();
 
const getNeighboursForAdmin = async (req, res) => {
    try {
      if (req.body.tokenDetail.userType === "admin") {
        let result = [];
        let tempCard = [];
        let tempCard2 = [];
        let pId = req?.query?.queryRequest?.projectId;
        console.log(pId);
        let result1 = [];
        let result2 = [];
        let result3 = [];
        let staticAgree = new Map();
        result1 = await queryExecutor(
          "SELECT cardId FROM project_cards where isDeleted=0 and projectId=?",
          [pId]
        );
        result2 = await queryExecutor(
          "SELECT staticCardId, cardAgreeCount, cardDisAgreeCount,cardSkipCount FROM project_static_cards where isDeleted=0 and projectId=?",
          [pId]
        );
        result1.data.forEach((element) => {
          tempCard.push(element.cardId);
        });
        result2?.data?.forEach((element) => {
          tempCard2.push(element?.staticCardId);
        });
 
        result = await queryExecutor(
          "SELECT * FROM project_cards_statusmeter where projectId=?",
          [pId]
        );
        result3 = await queryExecutor(
          "SELECT * FROM static_project_cards_statusmeter where projectId=?",
          [pId]
        );
 
        if(tempCard.length>0)
        {
          result3?.data?.forEach((element)=>{
            staticAgree.set(element?.userId, element?.agreeCardIds?.length);
          })
        }
        else
        {result3?.data?.forEach((element)=>{
          staticAgree.set(element?.userId, element?.agreeCardIds?.length);
          result.data.push({userId:element?.userId})
        })}
       
 
        console.log(result.data);
        let cardDetails = [];
 
       // let totalCards = result.data[0].cardIds;
       // let arr = totalCards.split(",");
 
        let size = tempCard?.length + tempCard2.length;
        let ageeMap = new Map();
        let disagreeMap = new Map();
        let skipMap=new Map();
        let idsy = [];
        let idsm = [];
        let idsn = [];
        let cards = [];
        let staticCard=[];
         if(tempCard.length>0)
        cards = await queryExecutor(
          "SELECT * FROM cards where id in " + "(" + tempCard.toString() + ")"
        );
        if(tempCard2.length > 0)
           staticCard = await queryExecutor(
          "SELECT * FROM static_cards where staticCardId in " + "(" + tempCard2.toString() + ")"
        );
        console.log(JSON.stringify(cards.data));
        let project = await queryExecutor(
          "SELECT projectId,projectName,projectAddress,projectPartner,createdAt,latitude,longitude FROM project where projectId=?",
          [pId]
        );
        let lat = project.data[0].latitude;
        let lon = project.data[0].longitude;
        result.data.map((item) => {
          for (let i = 0; i < item.agreeCardIds?.length; i++) {
            if (!tempCard.includes(item.agreeCardIds[i])) continue;
            let y = ageeMap.get(item?.agreeCardIds[i]);
            if (y === undefined) y = 0;
            ageeMap.set(item?.agreeCardIds[i], ++y);
          }
 
          for (let i = 0; i < item.disAgreeCardIds?.length; i++) {
            if (!tempCard.includes(item.disAgreeCardIds[i])) continue;
            let z = disagreeMap.get(item.disAgreeCardIds[i]);
            if (z === undefined) z = 0;
            disagreeMap.set(item.disAgreeCardIds[i], ++z);
          }
          for (let i = 0; i < item.skipCardIds?.length; i++) {
              if (!tempCard.includes(item.skipCardIds[i])) continue;
              let z = skipMap.get(item.skipCardIds[i]);
              if (z === undefined) z = 0;
              skipMap.set(item.skipCardIds[i], ++z);
            }
        });
        ageeMap.forEach((value, key, map) => {
          let rslt = cards.data.find((x) => x.id == key);
          const disagree =
            disagreeMap.get(key) === undefined ? 0 : disagreeMap.get(key);
          const skip=  skipMap.get(key) === undefined ? 0 : skipMap.get(key);
          cardDetails.push({
            title: rslt?.cardTitle,
            icon: rslt?.cardIcon,
            agree: value,
            disagree,
            skip,
            total: value + disagree+skip,
          });
        });
        disagreeMap.forEach((value, key, map) => {
          let rslt = cards.data.find((x) => x.id == key);
          const agree = ageeMap.get(key) === undefined ? 0 : ageeMap.get(key);
          const skip=  skipMap.get(key) === undefined ? 0 : skipMap.get(key);
          if (agree === 0 && skip===0) {
            cardDetails.push({
              title: rslt?.cardTitle,
              icon: rslt?.cardIcon,
              agree,
              disagree: value,
              skip,
              total: value + agree+skip,
            });
          }
        });
        skipMap.forEach((value, key, map) => {
          let rslt = cards.data.find((x) => x.id == key);
          const agree = ageeMap.get(key) === undefined ? 0 : ageeMap.get(key);
          const disAgree = disagreeMap.get(key) === undefined ? 0 : disagreeMap.get(key);
          if (agree === 0 && disAgree===0) {
            cardDetails.push({
              title: rslt?.cardTitle,
              icon: rslt?.cardIcon,
              agree,
              disAgree,
              skip:value,
              total: value + agree+disAgree,
            });
          }
        });
        result2?.data?.forEach((element)=>{
          let rslt=staticCard.data.find((x)=>x.staticCardId==element.staticCardId);
          cardDetails.push({
            title: rslt?.cardTitle,
            icon: rslt?.cardIcon,
            agree: element.cardAgreeCount,
            disagree:element.cardDisAgreeCount,
            skip:element.cardSkipCount,
            total: element.cardAgreeCount+element.cardDisAgreeCount+element.cardSkipCount,
          });
        })
       
      yimby = result.data.filter((item) => {
       
        return ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0))>= 0.6 * size && idsy.push(item.userId);
      });
     
      mimby = result.data.filter((item) => {
 
        return (
          ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) >= 0.4 * size &&
          ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) < 0.6 * size &&
          idsm.push(item.userId)
        );
      });
      nimby = result.data.filter((item) => {
        return ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) < (0.4 * size )&& idsn.push(item.userId);
      });
 
 
      let idsA = [...idsy, ...idsm, ...idsn];
      console.log(idsA.toString()+"checking the all ids array");
     
      let surveyAns = await queryExecutor(
        "select answer from neighbour_survey_answers where questionId=3 and userId in " +
          "(" +
          idsA.toString() +
          ")"
      );
      console.log(JSON.stringify(surveyAns));
      let liveInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Live");
      });
      let playInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Play");
      });
      let workInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Work");
      });
      let test = await queryExecutor(query.postLogin.getNeighboursAndComments, [
        idsy.toString(),
        idsm.toString(),
        idsn.toString(),
        idsA.toString(),
        pId,
      ]);
     
      test.data[3].push(...test?.data[4])
      test.data[0] = test.data[0].map((item) => {
        return {
          ...item,
          NeighbourType: "Yimby",
          distance: haversineDistanceAsync(
            lat,
            lon,
            item.latitude,
            item.longitude
          ),
        };
      });
      test.data[1] = test.data[1].map((item) => {
        return {
          ...item,
          NeighbourType: "Mimby",
          distance: haversineDistanceAsync(
            lat,
            lon,
            item.latitude,
            item.longitude
          ),
        };
      });
      if (idsn?.length > 0)
        test.data[2] = test.data[2].map((item) => {
          return {
            ...item,
            NeighbourType: "Nimby",
            distance: haversineDistanceAsync(
              lat,
              lon,
              item.latitude,
              item.longitude
            ),
          };
        });
      let yimbyCount = test.data[0]?.length;
      test.data[0].push(...test.data[1]);
      if (idsn.length > 0) test.data[0].push(...test.data[2]);
 
      if (!test.data[0]) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        console.log(JSON.stringify(test.data[0]));
        const details = {
          playInArea: playInArea?.length,
          workInArea: workInArea?.length,
          liveInArea: liveInArea?.length,
          totalCount: test.data[0]?.length,
          yimbyCount: yimbyCount,
          mimbyCount: test.data[1]?.length,
          nimbyCount: test.data[2]?.length,
          cardDetail: cardDetails,
          projectDetail: project.data[0],
          data: test.data[0],
          comments: test.data[3],
        };
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details,
            }),
            req.headers
          )
        );
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};
 
const getNeighboursForDev = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = [];
      let tempCard = [];
      let tempCard2 = [];
      let pId = req?.query?.queryRequest?.projectId;
      console.log(pId);
      let result1 = [];
      let result2 = [];
      let result3 = [];
      let staticAgree = new Map();
      result1 = await queryExecutor(
        "SELECT cardId FROM project_cards where isDeleted=0 and projectId=?",
        [pId]
      );
      result2 = await queryExecutor(
        "SELECT staticCardId, cardAgreeCount, cardDisAgreeCount,cardSkipCount FROM project_static_cards where isDeleted=0 and projectId=?",
        [pId]
      );
      result1.data.forEach((element) => {
        tempCard.push(element.cardId);
      });
     
      result2?.data?.forEach((element) => {
        tempCard2.push(element?.staticCardId);
      });
 
      result = await queryExecutor(
        "SELECT * FROM project_cards_statusmeter where projectId=?",
        [pId]
      );
      result3 = await queryExecutor(
        "SELECT * FROM static_project_cards_statusmeter where projectId=?",
        [pId]
      );
 
   
      if(tempCard.length>0)
        {
          result3?.data?.forEach((element)=>{
            staticAgree.set(element?.userId, element?.agreeCardIds?.length);
          })
        }
        else
        {result3?.data?.forEach((element)=>{
          staticAgree.set(element?.userId, element?.agreeCardIds?.length);
          result.data.push({userId:element?.userId})
        })}
 
      console.log(result.data);
      let cardDetails = [];
 
     // let totalCards = result.data[0].cardIds;
     // let arr = totalCards.split(",");
 
      let size = tempCard?.length + tempCard2.length;
      let ageeMap = new Map();
      let disagreeMap = new Map();
      let skipMap=new Map();
      let idsy = [];
      let idsm = [];
      let idsn = [];
      let cards = [];
      let staticCard=[];
      console.log("sizeeeeeeeeeee is "+size);
      if(tempCard.length>0)
      cards = await queryExecutor(
        "SELECT * FROM cards where id in " + "(" + tempCard.toString() + ")"
      );
      if(tempCard2.length > 0)
         staticCard = await queryExecutor(
        "SELECT * FROM static_cards where staticCardId in " + "(" + tempCard2.toString() + ")"
      );
      console.log(JSON.stringify(cards.data));
      let project = await queryExecutor(
        "SELECT projectId,projectName,projectAddress,projectPartner,createdAt,latitude,longitude FROM project where projectId=?",
        [pId]
      );
      let lat = project.data[0].latitude;
      let lon = project.data[0].longitude;
      result.data.map((item) => {
        for (let i = 0; i < item.agreeCardIds?.length; i++) {
          if (!tempCard.includes(item.agreeCardIds[i])) continue;
          let y = ageeMap.get(item?.agreeCardIds[i]);
          if (y === undefined) y = 0;
          ageeMap.set(item?.agreeCardIds[i], ++y);
        }
 
        for (let i = 0; i < item.disAgreeCardIds?.length; i++) {
          if (!tempCard.includes(item.disAgreeCardIds[i])) continue;
          let z = disagreeMap.get(item.disAgreeCardIds[i]);
          if (z === undefined) z = 0;
          disagreeMap.set(item.disAgreeCardIds[i], ++z);
        }
        for (let i = 0; i < item.skipCardIds?.length; i++) {
            if (!tempCard.includes(item.skipCardIds[i])) continue;
            let z = skipMap.get(item.skipCardIds[i]);
            if (z === undefined) z = 0;
            skipMap.set(item.skipCardIds[i], ++z);
          }
      });
      ageeMap.forEach((value, key, map) => {
        let rslt = cards.data.find((x) => x.id == key);
        const disagree =
          disagreeMap.get(key) === undefined ? 0 : disagreeMap.get(key);
        const skip=  skipMap.get(key) === undefined ? 0 : skipMap.get(key);
        cardDetails.push({
          title: rslt?.cardTitle,
          icon: rslt?.cardIcon,
          agree: value,
          disagree,
          skip,
          total: value + disagree+skip,
        });
      });
      disagreeMap.forEach((value, key, map) => {
        let rslt = cards.data.find((x) => x.id == key);
        const agree = ageeMap.get(key) === undefined ? 0 : ageeMap.get(key);
        const skip=  skipMap.get(key) === undefined ? 0 : skipMap.get(key);
        if (agree === 0 && skip===0) {
          cardDetails.push({
            title: rslt?.cardTitle,
            icon: rslt?.cardIcon,
            agree,
            disagree: value,
            skip,
            total: value + agree+skip,
          });
        }
      });
      skipMap.forEach((value, key, map) => {
        let rslt = cards.data.find((x) => x.id == key);
        const agree = ageeMap.get(key) === undefined ? 0 : ageeMap.get(key);
        const disAgree = disagreeMap.get(key) === undefined ? 0 : disagreeMap.get(key);
        if (agree === 0 && disAgree===0) {
          cardDetails.push({
            title: rslt?.cardTitle,
            icon: rslt?.cardIcon,
            agree,
            disAgree,
            skip:value,
            total: value + agree+disAgree,
          });
        }
      });
      result2?.data?.forEach((element)=>{
        let rslt=staticCard.data.find((x)=>x.staticCardId==element.staticCardId);
        cardDetails.push({
          title: rslt?.cardTitle,
          icon: rslt?.cardIcon,
          agree: element.cardAgreeCount,
          disagree:element.cardDisAgreeCount,
          skip:element.cardSkipCount,
          total: element.cardAgreeCount+element.cardDisAgreeCount+element.cardSkipCount,
        });
      })
     
      yimby = result.data.filter((item) => {
       
        return ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0))>= 0.6 * size && idsy.push(item.userId);
      });
     
      mimby = result.data.filter((item) => {
       
        return (
          ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) >= 0.4 * size &&
          ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) < 0.6 * size &&
          idsm.push(item.userId)
        );
      });
      nimby = result.data.filter((item) => {
       
        return ((item.agreeCardIds?.length ?? 0) + (staticAgree?.get(item.userId) ?? 0)) < (0.4 * size )&& idsn.push(item.userId);
      });
     
 
      let idsA = [...idsy, ...idsm, ...idsn];
      let test = await queryExecutor(query.postLogin.getNeighboursAndComments, [
        idsy.toString(),
        idsm.toString(),
        idsn.toString(),
        idsA.toString(),
        pId,
      ]);
 
      test.data[0] = test.data[0].map((item) => {
        return {
          ...item,
          distance: haversineDistanceAsync(
            lat,
            lon,
            item.latitude,
            item.longitude
          ),
        };
      });
      let surveyAns = await queryExecutor(
        "select answer from neighbour_survey_answers where questionId=3 and userId in " +
          "(" +
          idsA.toString() +
          ")"
      );
      test.data[3].push(...test?.data[4])
 
      console.log(JSON.stringify(surveyAns));
      let liveInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Live");
      });
      let playInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Play");
      });
      let workInArea = surveyAns.data.filter((item) => {
        return item.answer.includes("Work");
      });
      if (!test.data[0]) {
        throw new AppError(ERROR.messages.invalidUser, 400);
      } else {
        const details = {
          playInArea: playInArea?.length,
          workInArea: workInArea?.length,
          liveInArea: liveInArea?.length,
          totalCount: idsA?.length,
          yimbyCount: test.data[0]?.length,
          mimbyCount: test.data[1]?.length,
          nimbyCount: test.data[2]?.length,
          projectDetail: project.data[0],
          cardDetail: cardDetails,
          data: test.data[0],
          comments: test.data[3],
        };
 
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.success,
              details,
            }),
            req.headers
          )
        );
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 400);
    }
  } catch (error) {
    console.log(error);
    res.status(error.statusCode || 500).json(
      encrypt.encryptResponse(
        JSON.stringify({
          status: false,
          message: error.explanation || ERROR.messages.unExpectedError,
        }),
        req.headers
      )
    );
  }
};
 
module.exports = {
  getNeighboursForDev,
  getNeighboursForAdmin,
};