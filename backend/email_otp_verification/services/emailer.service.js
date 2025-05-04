var nodemailer = require('nodemailer');

async function sendEmail(params, callback) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: params.email,
    subject: params.subject,
    text: params.body,
  };

  transporter.sendMail(mailOptions, function (error, info) {
    if (error) {
      return callback(error);
    } else {
      return callback(null, info.response);
    }
  });
}

module.exports = {
  sendEmail,
};
