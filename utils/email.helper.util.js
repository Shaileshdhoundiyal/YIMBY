const nodemailer = require('nodemailer')

let mailTransporter = nodemailer.createTransport({
    service : 'gmail',
    auth : {
        user : process.env.user,
        pass : process.env.pass
    }
});

async function sendMail(data){
    try {
        await mailTransporter.sendMail(data);
    } catch (error) {
        throw error;
    }
}

module.exports = {
    sendMail,
}