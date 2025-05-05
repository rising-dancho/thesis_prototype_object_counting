const otpService = require('../services/otp.service');

exports.otpLogin = async (req, res, next) => {
  try {
    const results = await otpService.sendOTP(req.body);
    return res.status(200).json({
      message: 'Success!',
      data: results,
    });
  } catch (error) {
    return res.status(400).json({
      message: 'error',
      data: error,
    });
  }
};

exports.verifyOTP = async (req, res, next) => {
  try {
    const results = await otpService.verifyOTP(req.body);
    return res.status(200).json({
      message: 'Success!',
      data: results,
    });
  } catch (error) {
    return res.status(400).json({
      message: 'error',
      data: error,
    });
  }
};
