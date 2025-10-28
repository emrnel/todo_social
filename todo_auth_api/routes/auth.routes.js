const express = require('express');
const { body, validationResult } = require('express-validator');
const bcrypt = require('bcryptjs');
const pool = require('../db'); // db.js exports the mysql2 promise pool

const router = express.Router();

router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Please enter a valid email address.'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long.'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    try {
      // CRUM-28: Check if email exists
      // FIX: Changed '$1' to '?' (MySQL placeholder)
      const [existingUsers] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
      if (existingUsers.length > 0) {
        return res.status(409).json({ message: 'Email is already registered.' });
      }

      // CRUM-29: Hash password
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      // CRUM-30: Save new user
      // FIX: Changed '$1', '$2' to '?', '?'
      const [result] = await pool.query(
        'INSERT INTO users (email, password) VALUES (?, ?)',
        [email, hashedPassword]
      );

      const insertedUserId = result.insertId;

      // Optional: Fetch the newly created user (without password)
      // FIX: Changed '$1' to '?'
      const [newUserRows] = await pool.query('SELECT id, email, created_at FROM users WHERE id = ?', [insertedUserId]);

      if (newUserRows.length === 0) {
           return res.status(500).json({ message: 'Error fetching user after registration.' });
      }

      res.status(201).json({
        message: 'User registered successfully!',
        user: newUserRows[0],
      });

    } catch (error) {
      console.error('Error registering user:', error);
      res.status(500).json({ message: 'Server error during registration.' });
    }
  }
);

module.exports = router;