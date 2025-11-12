import jwt from 'jsonwebtoken';

// Load JWT secret key from .env file. Use a temporary key if not defined.
const JWT_SECRET = process.env.JWT_SECRET || 'your-temporary-strong-secret-key-123!';

/**
 * @name   authMiddleware
 * @desc   Middleware to protect endpoints by verifying the JWT token.
 *         Will be used for all protected routes for Sprint 3 and beyond.
 */
const authMiddleware = async (req, res, next) => {
  // 1. Get the 'Authorization' header from the request.
  // Example: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  const authHeader = req.header('Authorization');

  // 2. If token is missing or has the wrong format, return a 401 Unauthorized error.
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Yetkilendirme gerekli. Token bulunamadı.',
      error: { code: 'UNAUTHORIZED' }
    });
  }

  try {
    // 3. Get only the token by removing the "Bearer " prefix.
    const token = authHeader.replace('Bearer ', '');

    // 4. Verify the token.
    const decoded = jwt.verify(token, JWT_SECRET);

    // 5. If the token is valid, add its payload (user info) to the request object.
    // Now, all subsequent controllers handling this request can access req.user.
    req.user = { id: decoded.userId, email: decoded.email };
    
    // 6. If everything is okay, proceed to the next middleware or route handler.
    next();
  } catch (error) {
    // If the token is invalid or expired, jwt.verify will throw an error.
    return res.status(401).json({
      success: false,
      message: 'Geçersiz veya süresi dolmuş token.',
      error: { code: 'UNAUTHORIZED' }
    });
  }
};

export default authMiddleware;