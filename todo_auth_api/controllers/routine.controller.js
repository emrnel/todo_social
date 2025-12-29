import Routine from '../models/Routine.js';
import RoutineCompletion from '../models/RoutineCompletion.js';
import User from '../models/User.js';
import { validationResult } from 'express-validator';
import { Op } from 'sequelize';
import { createNotification } from './notification.controller.js';

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

    // Check completion status for each routine
    const routinesWithCompletion = await Promise.all(
      routines.map(async (routine) => {
        const isCompletedToday = await checkRoutineCompletedToday(
          routine.id,
          userId,
          routine.recurrenceType,
          routine.recurrenceValue
        );
        return {
          ...routine.toJSON(),
          isCompletedToday,
        };
      })
    );

    return res.status(200).json({
      success: true,
      message: 'Rutinler başarıyla getirildi',
      data: {
        routines: routinesWithCompletion,
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
const checkRoutineCompletedToday = async (routineId, userId, recurrenceType, recurrenceValue) => {
  const now = new Date();
  let startDate;

  if (recurrenceType === 'daily') {
    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  } else if (recurrenceType === 'weekly') {
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    startDate = new Date(now);
    startDate.setDate(now.getDate() - diff);
    startDate.setHours(0, 0, 0, 0);
  } else if (recurrenceType === 'custom' && recurrenceValue) {
    try {
      const days = typeof recurrenceValue === 'string'
        ? parseInt(recurrenceValue, 10)
        : recurrenceValue;

      if (!isNaN(days) && days > 0) {
        startDate = new Date(now);
        startDate.setDate(now.getDate() - days);
        startDate.setHours(0, 0, 0, 0);
      } else {
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      }
    } catch (e) {
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    }
  } else {
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
    const isAlreadyCompleted = await checkRoutineCompletedToday(id, userId, routine.recurrenceType, routine.recurrenceValue);

    if (isAlreadyCompleted) {
      return res.status(400).json({
        success: false,
        message: 'Bu rutin bu dönem için zaten tamamlanmış',
        error: { code: 'ALREADY_COMPLETED' },
      });
    }

    // Create completion record
    await RoutineCompletion.create({
      routineId: id,
      userId,
      completedAt: new Date(),
    });

    return res.status(200).json({
      success: true,
      message: 'Rutin tamamlandı',
      data: {
        routine: {
          ...routine.toJSON(),
          isCompletedToday: true,
        },
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


export const copyRoutine = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const originalRoutine = await Routine.findByPk(id, {
      include: [
        {
          model: User,
          as: "author",
          attributes: ["id", "username"],
        },
      ],
    });

    if (!originalRoutine) {
      return res.status(404).json({
        success: false,
        message: "Rutin bulunamadı",
        error: { code: "ROUTINE_NOT_FOUND" },
      });
    }

    if (!originalRoutine.isPublic) {
      return res.status(403).json({
        success: false,
        message: "Bu rutin herkese açık değil",
        error: { code: "NOT_PUBLIC" },
      });
    }

    if (originalRoutine.userId === userId) {
      return res.status(400).json({
        success: false,
        message: "Kendi rutininizi kopyalayamazsınız",
        error: { code: "CANNOT_COPY_OWN" },
      });
    }

    // Check if user has already copied this routine
    const existingCopy = await Routine.findOne({
      where: {
        userId,
        title: originalRoutine.title,
        recurrenceType: originalRoutine.recurrenceType,
        recurrenceValue: originalRoutine.recurrenceValue,
      },
    });

    if (existingCopy) {
      return res.status(409).json({
        success: false,
        message: "Bu rutini zaten kopyaladınız",
        error: { code: "ALREADY_COPIED" },
      });
    }

    // Create copy
    const copiedRoutine = await Routine.create({
      userId,
      title: originalRoutine.title,
      description: originalRoutine.description,
      isPublic: false,
      recurrenceType: originalRoutine.recurrenceType,
      recurrenceValue: originalRoutine.recurrenceValue,
      categoryId: originalRoutine.categoryId,
    });

    // Create notification for original author
    await createNotification({
      userId: originalRoutine.userId,
      actorId: userId,
      type: "routine_copied",
      routineId: id,
      message: "rutininizi kopyaladı",
    });

    return res.status(201).json({
      success: true,
      message: "Rutin kopyalandı",
      data: {
        routine: copiedRoutine,
      },
    });
  } catch (error) {
    console.error("Copy Routine Error:", error);
    return res.status(500).json({
      success: false,
      message: "Sunucu hatası: " + error.message,
      error: { code: "INTERNAL_SERVER_ERROR" },
    });
  }
};
