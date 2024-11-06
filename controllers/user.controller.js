const { queryExecutor, encrypt, AppError } = require("../utils");
const query = require("../repositories/query.json");
const { SUCCESS, ERROR } = require("../constants");
const validator = require("validator");
const { uploadDocumentsToS3 } = require("../utils/s3.controller");

const getUserProfile = async (req, res) => {
  try {
    const { tokenDetail } = req.body;
    if (tokenDetail.userType === "neighbours") {
      const result = await queryExecutor(
        "SELECT * FROM neighbours WHERE userId = ? AND isActive = 1",
        [tokenDetail.userId]
      );
      if (result?.data.length === 0) {
        throw new AppError(ERROR[404].invalidUser, 404);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.userDataFetched,
              userDetail: result?.data[0],
            }),
            req.headers
          )
        );
      }
    } else if (tokenDetail.userType === "re_developer") {
      const result = await queryExecutor(
        "SELECT * FROM re_developer WHERE userId = ? AND isActive = 1",
        [tokenDetail.userId]
      );
      if (result?.data.length === 0) {
        throw new AppError(ERROR[404].invalidUser, 404);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.userDataFetched,
              userDetail: result?.data[0],
            }),
            req.headers
          )
        );
      }
    } else {
      const result = await queryExecutor(
        "SELECT * FROM admins WHERE userId = ? AND isActive = 1",
        [tokenDetail.userId]
      );
      if (result?.data.length === 0) {
        throw new AppError(ERROR[404].invalidUser, 404);
      } else {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.userDataFetched,
              userDetail: result?.data[0],
            }),
            req.headers
          )
        );
      }
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

const editNeighboursProfile = async (req, res) => {
  try {
    let {
      firstName,
      surName,
      // streetAddress,
      // city,
      // state,
      // zipCode,
      address,
      latitude,
      longitude,
      email,
      profilePhoto,
      tokenDetail,
    } = req.body;
    firstName = firstName ? (firstName.trim() ? firstName.trim() : "") : "";
    surName = surName ? (surName.trim() ? surName.trim() : "") : "";
    address = address ? (address.trim() ? address.trim() : "") : "";
    latitude = latitude ? latitude : "";
    longitude = longitude ? longitude : "";
    email = email ? (email.trim() ? email.toLowerCase().trim() : "") : "";
    if (!firstName && firstName === "") {
      throw new AppError(ERROR.messages.firstNameRequired, 400);
    } else if (!surName && surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    } else if (!address || address === "") {
      throw new AppError(ERROR.messages.addressRequired, 400);
    } else if (
      !latitude ||
      (latitude === "" && !longitude) ||
      longitude === ""
    ) {
      throw new AppError(ERROR.messages.locationEmpty, 400);
    } else if (!email && email === "") {
      throw new AppError(ERROR.messages.emailRequired, 400);
    } else if (!validator.isEmail(email)) {
      throw new AppError(ERROR[400].invalidEmailFormat, 400);
    } else {
      let { err, data: result } = await queryExecutor(
        query.postLogin.editNeighboursProfile,
        [
          tokenDetail.userId,
          tokenDetail.userType,
          firstName,
          surName,
          address /*streetAddress, city, state, zipCode*/,
          email,
          profilePhoto ? profilePhoto.trim() : null,
          latitude,
          longitude,
        ]
      );
      try {
        if (result && result[0] && result[0][0]) {
          let userDetails = result[0][0];
          if (userDetails.message === "Email exist") {
            throw new AppError(ERROR.messages.mailAlreadyExist, 400);
          } else if (userDetails.message === "User not found") {
            throw new AppError(ERROR.messages.userIdNotFound, 404);
          } else if (userDetails.message === "Success") {
            res.status(200).json(
              encrypt.encryptResponse(
                JSON.stringify({
                  status: true,
                  message: SUCCESS.messages.userDetailsUpdated,
                }),
                req.headers
              )
            );
          }
        } else {
          throw new AppError(ERROR[500].afterQuery, 500);
        }
      } catch (err) {
        throw new AppError(ERROR.messages.unExpectedError, 500);
      }
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

const deleteAccount = async (req, res) => {
  try {
    const { tokenDetail } = req.body;
    let result = await queryExecutor(query.postLogin.deleteAccount, [
      tokenDetail.userId,
      tokenDetail.userType,
      tokenDetail.email,
    ]);
    if (
      result &&
      result?.data[0] &&
      result?.data[0][0] &&
      result?.data[0][0]?.message
    ) {
      if (result?.data[0][0].message === "Success") {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.accountDeleted,
            }),
            req.headers
          )
        );
      } else if (result?.data[0][0]?.message === "user Does not exist") {
        throw new AppError(ERROR.messages.userIdNotFound, 404);
      }
    } else {
      throw new AppError(ERROR[500].afterQuery, 500);
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

const editUserProfile = async (req, res) => {
  try {
    let {
      firstName,
      surName,
      city,
      state,
      zipCode,
      address,
      country,
      profilePhoto,
      tokenDetail,
      organisation,
      phoneNumber
    } = req.body;
    firstName = firstName ? (firstName.trim() ? firstName.trim() : "") : "";
    surName = surName ? (surName.trim() ? surName.trim() : "") : "";
    address = address ? (address.trim() ? address.trim() : "") : "";
    // latitude = latitude ? latitude : "";
    // longitude = longitude ? longitude : "";
    if (!firstName && firstName === "") {
      throw new AppError(ERROR.messages.firstNameRequired, 400);
    } else if (!surName && surName === "") {
      throw new AppError(ERROR.messages.surNameRequired, 400);
    }
    // else if (!address || address === "") {
    //   throw new AppError(ERROR.messages.addressRequired, 400);
    // }
    //  else if (
    //   !latitude ||
    //   (latitude === "" && !longitude) ||
    //   longitude === ""
    // ) {
    //   throw new AppError(ERROR.messages.locationEmpty, 400);
    // }
    else {
      let result;
      if (tokenDetail.userType === "re_developer") {
        if (profilePhoto && profilePhoto?.includes("https://")) {
          result = await queryExecutor(query.postLogin.editREDeveloperProfile, [
            tokenDetail.userId,
            tokenDetail.userType,
            firstName,
            surName,
            profilePhoto ? profilePhoto.trim() : "",
            34,
            34,
            zipCode ?? "",
            address ?? "",
            country ?? "",
            state ?? "",
            city ?? "",
            organisation ?? "",
            phoneNumber ?? ""
          ]);
        } else if (profilePhoto && profilePhoto?.includes("base64")) {
          const photo = await uploadDocumentsToS3(
            profilePhoto,
            req.body.tokenDetail.userId + Date.now()
          );

          result = await queryExecutor(query.postLogin.editREDeveloperProfile, [
            tokenDetail.userId,
            tokenDetail.userType,
            firstName,
            surName,
            photo,
            34,
            34,
            zipCode ?? "",
            address ?? "",
            country ?? "",
            state ?? "",
            city ?? "",
            organisation ?? "",
            phoneNumber ?? ""
          ]);
        } else {
          result = await queryExecutor(query.postLogin.editREDeveloperProfile, [
            tokenDetail.userId,
            tokenDetail.userType,
            firstName,
            surName,
            profilePhoto,
            34,
            34,
            zipCode ?? "",
            address ?? "",
            country ?? "",
            state ?? "",
            city ?? "",
            organisation ?? "",
            phoneNumber ?? ""
          ]);
        }
      } else if (tokenDetail.userType === "admin") {
        result = await queryExecutor(query.postLogin.editAdminProfile, [
          tokenDetail.userId,
          tokenDetail.userType,
          firstName,
          surName,
          // email,
          //address /*streetAddress, city, state, zipCode*/,
          profilePhoto ? profilePhoto.trim() : null,
          34,
          34,
          zipCode ?? "",
          country ?? "",
          state ?? "",
          city ?? "",
          address ?? "",
          // "",
        ]);
      }
      if (result && result?.data[0] && result?.data[0][0]) {
        let userDetails = result?.data[0][0];
        if (userDetails.message === "Email exist") {
          throw new AppError(ERROR.messages.mailAlreadyExist, 400);
        } else if (userDetails.message === "User not found") {
          throw new AppError(ERROR.messages.userIdNotFound, 404);
        } else if (userDetails.message === "Success") {
          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.userDetailsUpdated,
              }),
              req.headers
            )
          );
        }
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
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

const updateTheme = async (req, res) => {
  try {
    const { theme } = req.body;
    if (!theme || theme == " ") {
      throw new AppError(ERROR.messages.ThemeNotound, 404);
    } else {
      const result = await queryExecutor(query.postLogin.changeTheme, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        theme,
      ]);
      if (
        result &&
        result?.data[0] &&
        result?.data[0][0] &&
        result?.data[0][0].message === "Success"
      ) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.ThemeUpdated,
            }),
            req.headers
          )
        );
      } else if (result?.data[0][0]?.message === "User not found") {
        throw new AppError(ERROR.messages.userIdMissing, 404);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
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

const setDeviceToken = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token || token == " ") {
      throw new AppError(ERROR.messages.TokenNotFound, 404);
    } else {
      const result = await queryExecutor(query.postLogin.setDeviceToken, [
        req.body.tokenDetail.userId,
        req.body.tokenDetail.userType,
        token,
      ]);
      if (
        result &&
        result?.data[0] &&
        result?.data[0][0] &&
        result?.data[0][0].message === "Success"
      ) {
        res.status(200).json(
          encrypt.encryptResponse(
            JSON.stringify({
              status: true,
              message: SUCCESS.messages.tokenUpdated,
            }),
            req.headers
          )
        );
      } else if (result?.data[0][0]?.message === "User not found") {
        throw new AppError(ERROR.messages.userIdMissing, 404);
      } else {
        throw new AppError(ERROR[500].afterQuery, 500);
      }
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
const updateNotification = async (req, res) => {
  try {
    const {
      isDesktopNotification,
      isEmailNotification,
      isProjectUpdated,
      isNewDeveloperAdded,
    } = req.body;

    const result = await queryExecutor(query.postLogin.changeNotification, [
      req.body.tokenDetail.userId,
      req.body.tokenDetail.userType,
      isDesktopNotification,
      isEmailNotification,
      isProjectUpdated,
      isNewDeveloperAdded,
    ]);
    if (
      result &&
      result?.data[0] &&
      result?.data[0][0] &&
      result?.data[0][0].message === "Success"
    ) {
      res.status(200).json(
        encrypt.encryptResponse(
          JSON.stringify({
            status: true,
            message: SUCCESS.messages.ThemeUpdated,
          }),
          req.headers
        )
      );
    } else if (result?.data[0][0]?.message === "User not found") {
      throw new AppError(ERROR.messages.userIdMissing, 404);
    } else {
      throw new AppError(ERROR[500].afterQuery, 500);
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
  getUserProfile,
  editNeighboursProfile,
  deleteAccount,
  editUserProfile,
  updateTheme,
  updateNotification,
  setDeviceToken,
};
