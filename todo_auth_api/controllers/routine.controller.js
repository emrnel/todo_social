import Routine from '../models/Routine.js';
import RoutineCompletion from '../models/RoutineCompletion.js';
import Todo from '../models/Todo.js';
import User from '../models/User.js';
import { validationResult } from 'express-validator';
import { Op } from 'sequelize';

/**
 * @name   createRoutine
 * @desc   Create a new routine
 * @route  POST /api/routines
 * @access Private
 */
export const createRoutine = async (req, res) => {
  try {
    const { title, description, isPublic, recurrenceType, recurrenceValue } = req.body;
    const userId = req.user.id;

    // Validate recurrenceType
    const validTypes = ['daily', 'weekly', 'custom'];
    if (!validTypes.includes(recurrenceType)) {
      return res.status(400).json({
        success: false,
        message: 'Geçersiz recurrenceType. "daily", "weekly", veya "custom" olmalı.',
        error: { code: 'INVALID_RECURRENCE_TYPE' },
      });
    }

    const newRoutine = await Routine.create({
      userId,
      title,
      description: description || null,
      isPublic: isPublic || false,
      recurrenceType,
      recurrenceValue: recurrenceValue
        ? typeof recurrenceValue === 'object'
          ? JSON.stringify(recurrenceValue)
          : recurrenceValue
        : null,
    });

    res.status(201).json({
      success: true,
      message: 'Rutin oluşturuldu',
      data: {
        routine: newRoutine,
      },
    });
  } catch (error) {
    console.error('Error creating routine:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   getMyRoutines
 * @desc   Get all routines for the logged-in user with completion status
 * @route  GET /api/routines/myroutines
 * @access Private
 */
export const getMyRoutines = async (req, res) => {
  try {
    const userId = req.user.id;

    const routines = await Routine.findAll({
      where: { userId: userId },
      order: [['createdAt', 'DESC']],
    });

    // Filter out routines that are already completed for the current period
    const incompleteRoutines = [];

    for (const routine of routines) {
      const isCompletedToday = await checkRoutineCompletedToday(routine.id, userId, routine.recurrenceType);

      // Only include routines that haven't been completed for this period
      if (!isCompletedToday) {
        incompleteRoutines.push({
          ...routine.toJSON(),
          isCompletedToday: false,
        });
      }
    }

    return res.status(200).json({
      success: true,
      message: 'Rutinler başarıyla getirildi',
      data: {
        routines: incompleteRoutines,
      },
    });
  } catch (error) {
    console.error('Get Routines Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * Helper function to check if routine is completed for current period
 */
const checkRoutineCompletedToday = async (routineId, userId, recurrenceType) => {
  const now = new Date();
  let startDate;

  if (recurrenceType === 'daily') {
    // Check if completed today
    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  } else if (recurrenceType === 'weekly') {
    // Check if completed this week (week starts on Monday)
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Adjust for Monday start
    startDate = new Date(now);
    startDate.setDate(now.getDate() - diff);
    startDate.setHours(0, 0, 0, 0);
  } else {
    // For custom recurrence, check today
    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  }

  const completion = await RoutineCompletion.findOne({
    where: {
      routineId,
      userId,
      completedAt: {
        [Op.gte]: startDate,
      },
    },
  });

  return !!completion;
};

/**
 * @name   updateRoutine
 * @desc   Update an existing routine
 * @route  PATCH /api/routines/:id
 * @access Private
 */
export const updateRoutine = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { title, description, isPublic, recurrenceType, recurrenceValue } = req.body;

    const routine = await Routine.findByPk(id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Rutin bulunamadı',
        error: { code: 'ROUTINE_NOT_FOUND' },
      });
    }

    if (routine.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Bu rutini güncelleme yetkiniz yok',
        error: { code: 'FORBIDDEN' },
      });
    }

    const updatedRoutine = await routine.update({
      title: title !== undefined ? title : routine.title,
      description: description !== undefined ? description : routine.description,
      isPublic: isPublic !== undefined ? isPublic : routine.isPublic,
      recurrenceType: recurrenceType !== undefined ? recurrenceType : routine.recurrenceType,
      recurrenceValue:
        recurrenceValue !== undefined
          ? typeof recurrenceValue === 'object'
            ? JSON.stringify(recurrenceValue)
            : recurrenceValue
          : routine.recurrenceValue,
    });

    return res.status(200).json({
      success: true,
      message: 'Rutin güncellendi',
      data: { routine: updatedRoutine },
    });
  } catch (error) {
    console.error('Update Routine Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   deleteRoutine
 * @desc   Delete a routine
 * @route  DELETE /api/routines/:id
 * @access Private
 */
export const deleteRoutine = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const routine = await Routine.findByPk(id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Rutin bulunamadı',
        error: { code: 'ROUTINE_NOT_FOUND' },
      });
    }

    if (routine.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Bu rutini silme yetkiniz yok',
        error: { code: 'FORBIDDEN' },
      });
    }

    await routine.destroy();

    return res.status(200).json({
      success: true,
      message: 'Rutin silindi',
    });
  } catch (error) {
    console.error('Delete Routine Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};

/**
 * @name   completeRoutine
 * @desc   Mark a routine as completed for the current period
 * @route  POST /api/routines/:id/complete
 * @access Private
 */
export const completeRoutine = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const routine = await Routine.findByPk(id);

    if (!routine) {
      return res.status(404).json({
        success: false,
        message: 'Rutin bulunamadı',
        error: { code: 'ROUTINE_NOT_FOUND' },
      });
    }

    if (routine.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Bu rutini tamamlama yetkiniz yok',
        error: { code: 'FORBIDDEN' },
      });
    }

    // Check if already completed for this period
    const isAlreadyCompleted = await checkRoutineCompletedToday(id, userId, routine.recurrenceType);

    if (isAlreadyCompleted) {
      return res.status(400).json({
        success: false,
        message: 'Bu rutin bu dönem için zaten tamamlanmış',
        error: { code: 'ALREADY_COMPLETED' },
      });
    }

    const completedAt = new Date();

    // Create completion record
    await RoutineCompletion.create({
      routineId: id,
      userId,
      completedAt,
    });

    // Create a completed todo for this routine completion
    // This allows the completion to appear in the user's profile
    // NOTE: We set isPublic to false so routine completions don't appear in feed
    // They should only show in user's profile as completed tasks
    const completedTodo = await Todo.create({
      userId,
      title: routine.title,
      description: routine.description,
      isCompleted: true,
      isPublic: false, // Always private - routine completions shouldn't appear in feed
      completedAt,
      categoryId: null, // Routines don't have categories
    });

    // Award XP and update user stats
    const user = await User.findByPk(userId);
    if (user) {
      const xpGained = 10; // XP for completing a routine
      const newXp = user.xp + xpGained;
      const newLevel = Math.floor(Math.sqrt(newXp / 100)) + 1;
      const newTodosCompletedCount = user.todosCompletedCount + 1;

      // Update streak
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const lastActivity = user.lastActivityDate ? new Date(user.lastActivityDate) : null;

      let newStreak = user.currentStreak || 0;
      let newLongestStreak = user.longestStreak || 0;

      if (lastActivity) {
        lastActivity.setHours(0, 0, 0, 0);
        const diffDays = Math.floor((today - lastActivity) / (1000 * 60 * 60 * 24));

        if (diffDays === 0) {
          // Same day, keep streak
        } else if (diffDays === 1) {
          // Consecutive day, increment streak
          newStreak += 1;
          if (newStreak > newLongestStreak) {
            newLongestStreak = newStreak;
          }
        } else {
          // Streak broken, reset to 1
          newStreak = 1;
        }
      } else {
        // First activity
        newStreak = 1;
        newLongestStreak = 1;
      }

      await user.update({
        xp: newXp,
        level: newLevel,
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastActivityDate: today,
        todosCompletedCount: newTodosCompletedCount,
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Rutin tamamlandı',
      data: {
        routine: {
          ...routine.toJSON(),
          isCompletedToday: true,
        },
        xpGained: 10,
        completedTodo: completedTodo,
      },
    });
  } catch (error) {
    console.error('Complete Routine Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Sunucu hatası: ' + error.message,
      error: { code: 'INTERNAL_SERVER_ERROR' },
    });
  }
};
