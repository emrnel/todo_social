import Routine from '../models/Routine.js';
import { validationResult } from 'express-validator';

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
 * @desc   Get all routines for the logged-in user
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

    return res.status(200).json({
      success: true,
      message: 'Rutinler başarıyla getirildi',
      data: {
        routines,
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
