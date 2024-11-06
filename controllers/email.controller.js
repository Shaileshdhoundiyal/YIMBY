const { SESClient, SendEmailCommand } = require("@aws-sdk/client-ses");
const config = {
  region: process.env.S3_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
};

const ses = new SESClient(config);

const sendEmail = async (req) => {
  try {
    const { to, subject, text } = req;

    const params = {
      Destination: {
        ToAddresses: [to],
      },
      Message: {
        Body: {
          Text: {
            Data: text,
          },
        },
        Subject: {
          Data: subject,
        },
      },
      Source: process.env.Email,
    };

    const command = new SendEmailCommand(params);
    const sesResult = await ses.send(command);
    return sesResult;
  } catch (error) {
    throw error;
  }
};

module.exports = { sendEmail };
