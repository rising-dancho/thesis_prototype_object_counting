const otpGenerator = require('otp-generator');
const crypto = require('crypto');
const key = process.env.OTP_KEY;
const emailSerice = require('./emailer.service');

async function sendOTP(params, callback) {
  const otp = otpGenerator.generate(4, {
    digits: true,
  });

  const ttl = 5 * 60 * 1000; // 5 mins expiry
  const expires = Date.now() + ttl;
  const data = `${params.email}.${otp}.${expires}`;
  const hash = crypto.createHmac('sha256', key).update(data).digest('hex');
  const fullHash = `${hash}.${expires}`;

  var otpMessage = `Hi! Welcome to TecTags! Here is you one time password ${otp} for your registration`;
  var model = {
    email: params.email,
    subject: 'TecTags: Registration OTP',
    body: otpMessage,
  };

  emailSerice.sendEmail(model, (error, result) => {
    if (error) {
      return callback(error);
    }

    return callback(null, fullHash);
  });
}

async function verifyOTP(params, callback) {
  let [hashValue, expires] = params.hash.split('.');
  let now = Date.now();

  if (now > parseInt(expires)) return callback('OTP Expired');

  let data = `${params.email}.${params.otp}.${expires}`;
  let newCalculatedHash = crypto
    .createHmac('sha256', key)
    .update(data)
    .digest('hex');

  if (newCalculatedHash === hashValue) {
    return callback(null, 'Success!');
  }

  return callback('Invalid OTP');
}

module.exports = {
  sendOTP,
  verifyOTP,
};
