const CryptoJS = require("crypto-js");

const decryptRequest = (req, res, next) => {
  try {
    if (req.headers["postman-token"]) {
      next();
    } else {
      const { bodyRequest } = req.body;
      if (bodyRequest != undefined) {
        const body = CryptoJS.AES.decrypt(
          bodyRequest,
          process.env.CRYPTOSECRET_KEY
        ).toString(CryptoJS.enc.Utf8);
        req.body = body == "" ? {} : JSON.parse(body);
        next();
      } else {
        if (req.method === "GET") {
          let { queryRequest } = req.query;
          let data = CryptoJS.AES.decrypt(
            decodeURIComponent(queryRequest),
            process.env.CRYPTOSECRET_KEY
          ).toString(CryptoJS.enc.Utf8);
          req.query = { queryRequest: JSON.parse(data) };
          next();
        } else {
          next();
        }
      }
    }
  } catch (err) {
    next();
  }
};
module.exports = decryptRequest;
