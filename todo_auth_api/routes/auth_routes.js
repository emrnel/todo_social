import { Router } from 'express';
import { body } from 'express-validator';
// Import the functions from our new controller
import { register, login } from '../controllers/auth_controller.js';

// Create a new router instance
const router = Router();

// --- Auth Routes ---

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  [
    // Validation rules (from your original server.js)
    body('email', 'Please provide a valid email').isEmail(),
    body('password', 'Password must be at least 6 characters').isLength({ min: 6 }),
  ],
  register // If validation passes, call the 'register' function
);

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user & get token
 * @access  Public
 */
router.post(
  '/login',
  [
    // Validation rules for login
    body('email', 'Please provide a valid email').isEmail(),
    body('password', 'Password is required').notEmpty(),
  ],
  login // If validation passes, call the 'login' function
);

// Export the router to be used by server.js
export default router;