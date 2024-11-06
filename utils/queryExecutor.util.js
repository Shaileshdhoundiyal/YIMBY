const connection = require("../configs/db.config");
const ERROR = require("../constants/error.json");

const queryExecutor = async (query, params) => {
  try {
    return new Promise((resolve, reject) => {
      connection.getConnection((err, con) => {
        if (err) {
          console.log(err);
          reject({ err });
        } else {
          con.query(query, params, (err, data) => {
            con.release();
            if (err) {
              console.log(err);
              reject({ err });
            }
            resolve({ data });
          });
        }
      });
    });
  } catch (err) {
    return new Promise((resolve, reject) => {
      reject({ err });
    });
  }
};

module.exports = queryExecutor;
