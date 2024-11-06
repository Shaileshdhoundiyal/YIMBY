const mysql = require("mysql2");

connection = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  multipleStatements: false,
  connectionLimit: 10,
  connectTimeout: 30 * 1000,
});

module.exports = connection;
