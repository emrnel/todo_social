import express from 'express';
import {
  createRoutine,
  getMyRoutines,
  updateRoutine,
  deleteRoutine,
  completeRoutine,
} from '../controllers/routine.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

/**
 * @route   POST /api/routines
 * @desc    Create a new routine
 * @access  Private
 */
router.post('/', createRoutine);

/**
 * @route   GET /api/routines/myroutines
 * @desc    Get all user's routines
 * @access  Private
 */
router.get('/myroutines', getMyRoutines);

/**
 * @route   PATCH /api/routines/:id
 * @desc    Update a routine
 * @access  Private
 */
router.patch('/:id', updateRoutine);

/**
 * @route   DELETE /api/routines/:id
 * @desc    Delete a routine
 * @access  Private
 */
router.delete('/:id', deleteRoutine);

/**
 * @route   POST /api/routines/:id/complete
 * @desc    Mark a routine as completed
 * @access  Private
 */
router.post('/:id/complete', completeRoutine);

export default router;
