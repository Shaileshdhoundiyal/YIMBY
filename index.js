require("dotenv").config();
const express = require("express");
const app = express();
const session = require("express-session");
const cors = require("cors");
const devRoutes = require("./routes/dev.route");
const middlewares = require("./middlewares");
const path = require("path");
const firebase = require("firebase-admin");
const serviceAccount = require("./yimby_firebase_config.json");
firebase.initializeApp({
  credential: firebase.credential.cert(serviceAccount),
});
app.use(cors());
app.use(express.static(path.join(__dirname, "templates/assets")));
app.use(express.json({ limit: "50mb" }));
app.use(
  express.urlencoded({ extended: true, limit: "50mb", parameterLimit: 50000 })
);
app.use(
  session({ secret: "dert456yv7656", resave: true, saveUninitialized: true })
);
app.use(middlewares.decryptMiddleware);
app.use(middlewares.AuthenticateUser.auth);
app.use("/dev", devRoutes);

app.listen(4000, () => {
  console.log("Listening at port 4000");
});
