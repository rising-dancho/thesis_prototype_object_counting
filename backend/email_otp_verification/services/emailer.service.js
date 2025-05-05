const nodemailer = require('nodemailer');

function sendEmail(params) {
  const transporter = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    auth: {
      user: 'geraldine83@ethereal.email',
      pass: 'CD4yayK342MNBzPQD4',
    },
  });

  const mailOptions = {
    from: 'zenlaws02@gmail.com',
    to: params.email,
    subject: params.subject,
    text: params.body,
  };

  return new Promise((resolve, reject) => {
    transporter.sendMail(mailOptions, (error, info) => {
      if (error) return reject(error);
      resolve(info.response);
    });
  });
}

module.exports = {
  sendEmail,
};

// const transporter = nodemailer.createTransport({
//   service: 'gmail',
//   auth: {
//     user: process.env.EMAIL_USER,
//     pass: process.env.EMAIL_PASS,
//   },
// });

// const mailOptions = {
//   from: process.env.EMAIL_USER,
//   to: params.email,
//   subject: params.subject,
//   text: params.body,
// };
