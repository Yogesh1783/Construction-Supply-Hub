// Create token and save in the cookie
export default (user, statusCode, res) => {
    // Create JWT Token
    const token = user.getJwtToken();
  
    const isProduction = process.env.NODE_ENV === "PRODUCTION";

    // Options for cookie
    const options = {
      expires: new Date(
        Date.now() + process.env.COOKIE_EXPIRES_TIME * 24 * 60 * 60 * 1000
      ),
      httpOnly: true,
      secure: isProduction,         // HTTPS-only in production
      sameSite: isProduction ? "none" : "lax", // 'none' needed for cross-origin + credentials
    };
  
    res.status(statusCode).cookie("token", token, options).json({
      token,
      user:user
    });
  };