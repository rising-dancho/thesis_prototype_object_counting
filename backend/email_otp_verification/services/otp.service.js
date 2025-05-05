const otpGenerator = require('otp-generator');
const crypto = require('crypto');
const key = process.env.OTP_KEY || 'test123';
const emailService = require('./emailer.service');

async function sendOTP(params) {
  const otp = otpGenerator.generate(4, {
    digits: true,
    lowerCaseAlphabets: false,
    upperCaseAlphabets: false,
    specialChars: false,
  });

  const ttl = 5 * 60 * 1000; // 5 mins expiry
  const expires = Date.now() + ttl;
  const data = `${params.email}.${otp}.${expires}`;
  const hash = crypto.createHmac('sha256', key).update(data).digest('hex');
  const fullHash = `${hash}.${expires}`;

  const otpMessage = `Hi! Welcome to TecTags! ${otp} is your one-time password (OTP) to verify your email.`;
  const model = {
    email: params.email,
    subject: 'TecTags: Registration OTP',
    body: otpMessage,
  };

  // Wrap the callback in a Promise
  await emailService.sendEmail(model); // now awaits correctly

  return fullHash;
}

async function verifyOTP(params) {
  const [hashValue, expires] = params.hash.split('.');
  const now = Date.now();

  if (now > parseInt(expires)) {
    throw new Error('OTP Expired');
  }

  const data = `${params.email}.${params.otp}.${expires}`;
  const newCalculatedHash = crypto
    .createHmac('sha256', key)
    .update(data)
    .digest('hex');

  if (newCalculatedHash === hashValue) {
    return 'Success!';
  }

  throw new Error('Invalid OTP');
}

module.exports = {
  sendOTP,
  verifyOTP,
};
