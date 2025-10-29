import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken'; // Now this package should be found!
import { validationResult } from 'express-validator';

// Import the User model (to interact with the 'users' table)
import User from '../models/User.js';

// Load the secret key from your .env file
const JWT_SECRET = process.env.JWT_SECRET || 'your-temporary-strong-secret-key-123!';
const JWT_EXPIRES_IN = '1d'; // Token will be valid for 1 day

/**
 * @name   register
 * @desc   Handles new user registration.
 * @route  POST /api/auth/register
 */
export const register = async (req, res) => {
  try {
    // 1. Check for validation errors (defined in routes/auth_routes.js)
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array().map((err) => err.msg), 
      });
    }

    const { email, password } = req.body; 

    // 2. Check if email is already in use (The Sequelize Way)
    const existingUser = await User.findOne({ where: { email: email } });
    
    if (existingUser) {
      // 409 Conflict
      return res
        .status(409) 
        .json({ success: false, message: "This email address is already registered." });
    }

    // 3. Hash the password (CRITICAL SECURITY STEP)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 4. Create the new user (The Sequelize Way)
    await User.create({
      email: email,
      password: hashedPassword,
    });

    // 5. Send a success response
    return res.status(201).json({ // 201 Created
      success: true,
      message: "User created successfully.",
    });

  } catch (error) {
    console.error("Register Error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};


/**
 * @name   login
 * @desc   Handles existing user login and returns a JWT token. (Task AUTH-2)
 * @route  POST /api/auth/login
 */
export const login = async (req, res) => {
  try {
    // 1. Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array().map((err) => err.msg),
      });
    }

    const { email, password } = req.body;

    // 2. Find the user by email
    const user = await User.findOne({ where: { email: email } });
    if (!user) {
      // 401 Unauthorized.
      return res
        .status(401) 
        .json({ success: false, message: "Invalid email or password." });
    }

    // 3. Compare the provided password with the stored hash
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      // 401 Unauthorized. Password did not match.
      return res
        .status(401)
        .json({ success: false, message: "Invalid email or password." });
    }

    // --- Credentials are VALID! ---

    // 4. Create JWT (JSON Web Token) Payload
    const payload = {
      user: {
        id: user.id, // The user's ID
        email: user.email,
      },
    };

    // 5. Sign the JWT Token
    const token = jwt.sign(
      payload,
      JWT_SECRET,   // The secret key (from .env)
      { expiresIn: JWT_EXPIRES_IN } // Expires in 1 day
    );

    // 6. Send the token back to the client (Flutter app)
    return res.status(200).json({
      success: true,
      message: "Login successful.",
      token: token, // This is the token the Flutter app will save
      user: {
        id: user.id,
        email: user.email,
      }
    });

  } catch (error) {
    console.error("Login Error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};