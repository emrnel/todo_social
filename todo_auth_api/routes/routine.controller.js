import { Routine } from '../models/routine.model.js';

export const createRoutine = async (req, res) => {
  try {
    const { title, description, isPublic, recurrenceType, recurrenceValue } = req.body;
    const userId = req.user.id;

    if (!title || !recurrenceType) {
      return res.status(400).json({
        success: false,
        message: 'Title and recurrence type are required'
      });
    }

    const routineId = await Routine.create({
      userId,
      title,
      description,
      isPublic: isPublic || false,
      recurrenceType,
      recurrenceValue
    });

    const routine = await Routine.findById(routineId);

    res.status(201).json({
      success: true,
      data: { routine }
    });
  } catch (error) {
    console.error('Error creating routine:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};