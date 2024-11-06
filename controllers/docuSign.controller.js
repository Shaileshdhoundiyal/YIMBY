const docusign = require("docusign-esign");
const fs = require("fs");
const { encryptResponse } = require("../utils/encrypt.util");
const { ERROR, SUCCESS } = require("../constants");
const path = require("path");
const query = require("../repositories/query.json");
const signerClientId = 1000;
const { queryExecutor, encrypt, AppError } = require("../utils");

const SCOPES = ["signature", "impersonation"];

const makeRecipientViewRequest = (email, name) => {
  let viewRequest = new docusign.RecipientViewRequest();
  viewRequest.returnUrl = "app://yimby";
  viewRequest.authenticationMethod = "none";
  viewRequest.email = email;
  viewRequest.userName = name;
  viewRequest.clientUserId = process.env.DOCUSIGN_CLIENT_ID;
  return viewRequest;
};

const getDetailsDocusign = async (req) => {
  try {
    const { projectId, tokenDetail } = req.body;

    const result = await queryExecutor(query.postLogin.getDetailsDocusign, [
      tokenDetail?.userId,
      projectId,
    ]);
    let details = {};
    if (!result?.data[0].length) {
      return {
        status: false,
        statusCode: 404,
        message: ERROR[404].neighbourUserNotFound,
      };
    } else if (!result?.data[1].length) {
      return {
        status: false,
        statusCode: 404,
        message: ERROR[404].re_developerUserNotFound,
      };
    } else if (!result?.data[2].length) {
      return {
        status: false,
        statusCode: 404,
        message: ERROR[404].projectNotFound,
      };
    } else {
      details.neighbour = result?.data[0][0];
      details.re_developer = result?.data[1][0];
      details.project = result?.data[2][0];
      details.envelope = result?.data[3] ? result?.data[3][0] : null;
      details.req = req.body;
      details.status = true;
      return details;
    }
  } catch (er) {
    return {
      status: false,
      statusCode: 500,
      message: ERROR[500].serverError,
    };
  }
};

const makeEnvelope = (neighbour) => {
  let env = new docusign.EnvelopeDefinition();
  env.templateId = process.env.DOCUSIGN_TEMPLATE_ID;

  let signer1 = docusign.TemplateRole.constructFromObject({
    email: neighbour.email,
    name: `${neighbour.firstName} ${neighbour.surName}`,
    clientUserId: process.env.DOCUSIGN_CLIENT_ID,
    roleName: "Neighbours",
  });

  env.templateRoles = [signer1];
  env.status = "sent";
  return env;
};

const getArgs = (
  apiAccountId,
  accessToken,
  basePath,
  neighbour,
  project,
  req,
  envelope
) => {
  const ids = {
    projectId: project.projectId,
    neighbourId: neighbour.userId,
  };

  let queryRequest = encrypt.encryptPassword(
    JSON.stringify({
      projectId: ids.projectId,
      userId: ids.neighbourId,
      documentId: req.documentId,
    })
  );

  const envelopeArgs = {
    signerEmail: "ashutosh.namdev@hexaviewtech.com",
    signerName: "Ashutosh Namdev",
    signerClientId: signerClientId,
    dsReturnUrl: `https://bkcorxojr7.execute-api.us-east-1.amazonaws.com/dev/updateEnvelopeDetails?queryRequest=${queryRequest}`,
    dsPingUrl: "http://pingUrl",
    ids,
    queryRequest,
    documentId: req?.documentId || envelope?.documentId,
    // doc1File: path.resolve(docsPath, doc1File),
  };
  const args = {
    accessToken: accessToken,
    basePath: basePath,
    accountId: apiAccountId,
    envelopeArgs: envelopeArgs,
    neighbour: neighbour,
  };

  return args;
};

const authentication1 = async () => {
  const jwtLifeSec = 30 * 60,
    dsApi = new docusign.ApiClient();
  dsApi.setOAuthBasePath(
    process.env.DOCUSIGN_O_AUTH_SERVER.replace("https://", "")
  );
  let rsaKey = fs.readFileSync(path.join(__dirname, "../private.key"));

  const results = await dsApi.requestJWTUserToken(
    process.env.DOCUSIGN_INTEGRATION_KEY,
    process.env.DOCUSIGN_USER_ID,
    SCOPES,
    rsaKey,
    jwtLifeSec
  );

  // access token
  const accessToken = results.body;

  //user info
  let userInfoResults = await dsApi.getUserInfo(accessToken.access_token);
  if (userInfoResults) {
    userInfoResults.accounts = userInfoResults.accounts.find(
      (account) => account.isDefault === "true"
    );
  }
  return {
    accessToken: results.body.access_token,
    apiAccountId: userInfoResults.accounts.accountId,
    basePath: `${userInfoResults.accounts.baseUri}/restapi`,
  };
};

const sendEnvelopeForEmbeddedSigningExistingEnvelope = async (
  args,
  envelopeId
) => {
  let dsApiClient = new docusign.ApiClient();
  dsApiClient.setBasePath(args.basePath);
  dsApiClient.addDefaultHeader("Authorization", "Bearer " + args.accessToken);
  let envelopesApi = new docusign.EnvelopesApi(dsApiClient);
  let envelopeDetails = await getViewRequestUrl(
    args,
    envelopeId,
    envelopesApi
  ).catch((err) => {
    if (err.response) {
      return {
        statusCode: err.response.statusCode || 400,
        message: err.response.body.message,
      };
    } else {
      return { statusCode: err.statusCode || 400, message: err.message };
    }
  });
  return envelopeDetails;
};

const docuSign = async (req, res) => {
  try {
    const usersDetails = await getDetailsDocusign(req);
    if (usersDetails?.status === false) {
      res.status(usersDetails?.statusCode).json(
        encryptResponse(
          JSON.stringify({
            status: false,
            message: usersDetails?.message,
          }),
          req.headers
        )
      );
    } else {
      console.log("ascasdasdasdads", usersDetails);
      let envelope;

      const accountInfo = await authentication1();
      let args = getArgs(
        accountInfo.apiAccountId,
        accountInfo.accessToken,
        accountInfo.basePath,
        usersDetails?.neighbour,
        usersDetails?.project,
        usersDetails?.req,
        usersDetails?.envelope
      );

      if (usersDetails.envelope && usersDetails.envelope.expiresIn > 0) {
        envelope = await sendEnvelopeForEmbeddedSigningExistingEnvelope(
          args,
          usersDetails.envelope.envelopeId
        );
        console.log(envelope);
        if (!envelope.envelopeId) {
          console.log({
            status: false,
            message: envelope,
          });
          res.status(500).json(
            encryptResponse(
              JSON.stringify({
                status: false,
                message: envelope,
              }),
              req.headers
            )
          );
          return;
        }
      } else if (
        usersDetails.envelope &&
        usersDetails.envelope.status === "completed" &&
        usersDetails.envelope.expiresIn < 1
      ) {
        envelope = {
          pdfUrl: usersDetails.envelope.envelopePdfUrl,
          pdfKey: usersDetails.envelope.envelopePdfKey,
          isEnvelopeExpired: true,
        };
        resolve(envelope);
        return;
      } else {
        let s3Pdf = fs.readFileSync(path.join(__dirname, "../Docusign.pdf"));
        envelope = await sendEnvelopeForEmbeddedSigning(args, s3Pdf);
      }
      let envelopUsers = {
        re_devId: usersDetails.re_developer.userId,
        neighbourId: usersDetails.neighbour.userId,
        projectId: usersDetails.project.projectId,
        documentId: usersDetails.envelope
          ? usersDetails.envelope.documentId
          : usersDetails.req.documentId,
      };
      let envelopeInDB = {};
      let resp = {};
      if (envelope.envelopeDetails) {
        resp = await updateEnvelopeDetails({
          event: envelope.envelopeDetails,
          envelopUsers,
        });
      }
      envelopeInDB = resp;
      envelope.updatedInDatabase = envelopeInDB;
      res.status(200).json(
        encryptResponse(
          JSON.stringify({
            status: true,
            message: resp.message,
            data: envelope,
          }),
          req.headers
        )
      );
    }
  } catch (err) {
    console.error(err);
    res.status(500).json(
      encryptResponse(
        JSON.stringify({
          status: false,
          message: ERROR[500].serverError,
        }),
        req.headers
      )
    );
  }
};

async function sendEnvelopeForEmbeddedSigning(args, doc1PdfBytes) {
  let dsApiClient = new docusign.ApiClient();
  dsApiClient.setBasePath(args.basePath);
  dsApiClient.addDefaultHeader("Authorization", "Bearer " + args.accessToken);
  let envelopesApi = new docusign.EnvelopesApi(dsApiClient),
    results = null;

  let envelope = makeEnvelope(args.neighbour);

  results = await envelopesApi.createEnvelope(args.accountId, {
    envelopeDefinition: envelope,
  });

  let envelopeId = results.envelopeId;
  console.log(`Envelope was created. EnvelopeId ${envelopeId}`);

  let envelopeDetails = await getViewRequestUrl(args, envelopeId, envelopesApi);

  return envelopeDetails;
}

const getViewRequestUrl = async (args, envelopeId, envelopesApi) => {
  const { neighbour } = args;
  let viewRequest = makeRecipientViewRequest(
    neighbour.email,
    `${neighbour.firstName} ${neighbour.surName}`
  );

  let results = await envelopesApi.createRecipientView(
    args.accountId,
    envelopeId,
    { recipientViewRequest: viewRequest }
  );

  // envelopeId = '4b7a5e7e-61fb-40b6-b079-f0b397510b1b';
  let envelopeDetails = await getEnvelopeDetails(
    args.accountId,
    envelopeId,
    envelopesApi
  );

  return { envelopeId, redirectUrl: results.url, envelopeDetails };
};

const getEnvelopeDetails = async (accountId, envelopeId, envelopesApi) => {
  return await envelopesApi.getEnvelope(accountId, envelopeId, null);
};

const updateEnvelopeDetails = async (args) => {
  console.log(args);
  let { envelopUsers } = args;
  let {
    envelopeId,
    createdDateTime,
    lastModifiedDateTime,
    expireDateTime,
    initialSentDateTime,
    statusChangedDateTime,
    certificateUri,
    envelopeUri,
    notificationUri,
    recipientsUri,
    signingLocation,
    status,
    completedDateTime,
  } = args.event;
  let { accountId, email, userId } = args.event.sender;
  let { re_devId, neighbourId, projectId, documentId } = envelopUsers;

  const { err, data: result } = await queryExecutor(
    query.postLogin.envelopeDetails,
    [
      envelopeId,
      createdDateTime,
      lastModifiedDateTime,
      expireDateTime,
      initialSentDateTime,
      statusChangedDateTime,
      certificateUri,
      envelopeUri,
      notificationUri,
      recipientsUri,
      accountId,
      email,
      userId,
      signingLocation,
      status,
      projectId,
      re_devId,
      neighbourId,
      completedDateTime,
      documentId,
    ]
  );
  if (err) {
    return {
      status: false,
      statusCode: 500,
      message: config.settings.errors[500].afterQuery,
    };
  }
  return { status: true, statusCode: 200, message: result[0][0].message };
};

const neighbourSignStatus = async (req, res) => {
  try {
    if (req.body.tokenDetail.userType === "neighbours") {
      console.log(req.query);
      if (req.body) {
        let { projectId } = req.query.queryRequest;
        var quer =
          " select * from envelope_details where neighbour_Id = ? and projectId = ?";
        // let result = await queryExecutor(`call getDetailsDocusign(?, ?)`, [

        let result = await queryExecutor(quer, [
          req.body.tokenDetail.userId,
          projectId,
        ]);
        if (result?.data?.length > 0) {
          // let details = {};
          // if (!result.data[0].length) {
          //   throw new AppError(ERROR[404].neighbourUserNotFound, 404);
          // } else if (!result.data[1].length) {
          //   throw new AppError(ERROR[404].re_developerUserNotFound, 404);
          // } else if (!result.data[2].length) {
          //   throw new AppError(ERROR[404].projectNotFound, 404);
          // } else {
          // details.neighbour = result.data[0][0];
          // details.re_developer = result.data[1][0];
          // details.project = result.data[2][0];
          // details.envelope = result.data[3] ? result.data[3][0] : null;

          // let isNewPdf;

          // if (!details.envelope) isNewPdf = true;
          // else if (
          //   details.envelope.expiresIn > 0 ||
          //   details.envelope.status === "completed"
          // )
          //   isNewPdf = false;
          // else if (details.envelope.expiresIn < 1) isNewPdf = true;
          // else isNewPdf = true;

          // details.isNewPdf = isNewPdf;

          res.status(200).json(
            encrypt.encryptResponse(
              JSON.stringify({
                status: true,
                message: SUCCESS.messages.success,
                details: result?.data,
              }),
              req.headers
            )
          );
          // }
        } else {
          throw new AppError(ERROR[400].contentNotAvailable, 400);
        }
      } else {
        throw new AppError(ERROR[400].contentNotAvailable, 400);
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
  docuSign,
  neighbourSignStatus,
};
