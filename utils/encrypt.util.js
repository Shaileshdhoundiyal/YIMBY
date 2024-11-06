const CryptoJS = require("crypto-js");
const encryptResponse = (originalText, headers) => {
  console.log({ responseObject: JSON.parse(originalText) });
  if (headers["postman-token"]) {
    return { responseObject: JSON.parse(originalText) };
  } else {
    const cypherText = CryptoJS.AES.encrypt(
      originalText,
      process.env.CRYPTOSECRET_KEY
    ).toString();

    return {
      responseObject: cypherText,
    };
  }
};

const encryptPassword = (originalText) => {
  return CryptoJS.AES.encrypt(
    originalText,
    process.env.CRYPTOSECRET_KEY
  ).toString();
};

const decryptPassword = (cypherText) => {
  const pass = CryptoJS.AES.decrypt(
    cypherText,
    process.env.CRYPTOSECRET_KEY
  ).toString(CryptoJS.enc.Utf8);
  return pass[0] === '"' ? JSON.parse(pass) : pass;
};
module.exports = { encryptResponse, encryptPassword, decryptPassword };
