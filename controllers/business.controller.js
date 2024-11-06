const {
  encrypt,
  AppError,
  queryBuilder,
  queryExecutor,
} = require("../utils");
const EmailHelper = require('./email.controller')
const { ERROR, JWT, SUCCESS } = require("../constants");
const jwt = require("jsonwebtoken");
const validator = require("validator");
const query = require("../repositories/query.json");
const { json } = require("express");

const addBusinessProfile = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let { businessName, businessType, links } = req.body;
      if (!req.body || !businessName || !businessType) {
        throw new AppError(ERROR.messages.businessNameEmpty, 400);
      }
      let _links = {
        email: links.email || null,
        twitter: links.twitter || null,
        website: links.website || null,
        facebook: links.facebook || null,
        linkedIn: links.linkedIn || null,
        instagram: links.instagram || null,
      };
      let businessProfile = {
        name: req.body.businessName,
        type: req.body.businessType,
        description: req.body.bio,
        icon: req.body.icon,
        coverImage: req.body.converImage,
      };
      let insertBusinessProfileQuery =
        queryBuilder.insertBusinessProfileQueryBuilder(businessProfile);
      console.log(insertBusinessProfileQuery);

      let insertLinkQuery;
      if (_linkslinks && Object.keys(_linkslinks).length !== 0) {
        insertLinkQuery = queryBuilder.insertLinksQueryBuilder(_links);
      }
      console.log(insertLinkQuery);
      let result = await queryExecutor("call addBusinessProfile(?, ?)", [
        insertBusinessProfileQuery,
        insertLinkQuery,
      ]);
      console.log(result);
      if (
        result &&
        result?.data[0][0] &&
        result?.data[0][0].message === "failed"
      ) {
        throw new AppError(ERROR[500].afterQuery, 500);
      } else if (result.data[0][0] && result.data[0][0].message === "success") {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              details: {
                message: SUCCESS.messages.businessProfileAdded,
              },
            }),
            req.headers
          )
        );
      }
    } else {
      throw new AppError(ERROR[400].invalidUserType, 403);
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

const editBusinessProfile = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let { id, businessName, businessType, links = {} } = req.body;
      if (!req.body || !id || !businessName || !businessType) {
        throw new AppError(ERROR.messages.businessTypeEmpty, 400);
      }
      let businessProfileInfo = req.body;
      let businessProfile = {
        id: businessProfileInfo.id,
        name: businessProfileInfo.businessName,
        type: businessProfileInfo.businessType,
        description: businessProfileInfo.bio || null,
        icon: businessProfileInfo.icon || null,
        coverImage: businessProfileInfo.converImage || null,
        isDeleted: businessProfileInfo.isDeleted || false,
      };

      let updateBusinessProfileQuery =
        queryBuilder.updateBusinessProfileQueryBuilder(businessProfile);
      console.log(updateBusinessProfileQuery);

      let _links = {
        email: links.email || null,
        twitter: links.twitter || null,
        website: links.website || null,
        facebook: links.facebook || null,
        linkedIn: links.linkedIn || null,
        instagram: links.instagram || null,
      };
      let updateLinkQuery;
      updateLinkQuery = queryBuilder.updateLinksQueryBuilder(
        _links,
        businessProfile.id
      );
      console.log(updateLinkQuery);
      let result = await queryExecutor("call editBusinessProfile(?, ?, ?)", [
        businessProfile.id,
        updateBusinessProfileQuery,
        updateLinkQuery,
      ]);
      if (result && result.data[0][0] && result.data[0][0].status) {
        throw new AppError(ERROR[500].afterQuery, 500);
      } else if (
        result?.data[0][0] &&
        result?.data[0][0].message === "success"
      ) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              details: {
                message: SUCCESS.messages.businessProfileEdited,
              },
            }),
            req.headers
          )
        );
      }
    } else {
      AppError(ERROR[400].invalidUserType, 400);
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

const getBusinessProfile = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "re_developer") {
      let result = await queryExecutor([req.body.tokenDetail.userId]);
      // result && result[0] ? result[0].links =  (result[0].links) : null;
      if (result.data[0]) {
        for (let [key, value] of Object.entries(result.data[0])) {
          if (result.data[0][key] == "null") {
            result.data[0][key] = null;
          }
        }
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              details: {
                message: SUCCESS.messages.businessProfileFetched,
                result: result.data[0] || {},
              },
            }),
            req.headers
          )
        );
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
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
  addBusinessProfile,
  editBusinessProfile,
  getBusinessProfile
};
