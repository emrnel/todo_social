import express from 'express';
import { createRoutine } from '../controllers/routine.controller.js';
import authMiddleware from '../controllers/auth.middleware.js';

const router = express.Router();

// POST /api/routines
router.post('/', authMiddleware, createRoutine);

export default router;