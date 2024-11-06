const { Upload } = require("@aws-sdk/lib-storage"),
  { S3Client } = require("@aws-sdk/client-s3");

const accessKeyId = process.env.AWS_ACCESS_KEY_ID;
const secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;
const region = process.env.S3_REGION;
const Bucket = process.env.S3_BUCKET;

const uploadDocumentsToS3 = async (document, visitorUNID) => {
  try {
    const originalname = "IMG";
    var buf = Buffer.from(
      document.replace(/^data:image\/\w+;base64,/, ""),
      "base64"
    );
    const type = document.split(";")[0].split("/")[1];
    const documentKey = `visitor_documents/${visitorUNID}/${originalname}.${type}`;

    const uploadResult = await new Upload({
      client: new S3Client({
        credentials: {
          accessKeyId,
          secretAccessKey,
        },
        region,
      }),
      params: {
        Bucket: Bucket,
        Key: documentKey,
        Body: buf,
        ACL: "public-read",
        ContentEncoding: "base64",
        ContentType: `image/${type}`,
      },
    }).done();
    return uploadResult.Location;
  } catch (err) {
    console.log(err);
    return null;
  }
};

const uploadPdfToS3 = async (document, visitorUNID) => {
  try {
    const originalname = "report";
    var buf = Buffer.from(document, "base64");
    const type = "pdf";
    const documentKey = `visitor_documents/reports/${visitorUNID}/${originalname}.${type}`;

    const uploadResult = await new Upload({
      client: new S3Client({
        credentials: {
          accessKeyId,
          secretAccessKey,
        },
        region,
      }),
      params: {
        Bucket: Bucket,
        Key: documentKey,
        Body: buf,
        ACL: "public-read",
        ContentEncoding: "base64",
        ContentType: `application/pdf`,
      },
    }).done();
    return uploadResult.Location;
  } catch (err) {
    console.log(err);
    return null;
  }
};

module.exports = {
  uploadDocumentsToS3,
  uploadPdfToS3,
};
