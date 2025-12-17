import Routine from '../models/Routine.js';

export const createRoutine = async (req, res) => {
  try {
    const { title, description, isPublic, recurrenceType, recurrenceValue } = req.body;
    
    // Assuming req.user is populated by auth middleware
    const userId = req.user.id;

    const newRoutine = await Routine.create({
      userId,
      title,
      description,
      isPublic: isPublic || false,
      recurrenceType,
      recurrenceValue: (recurrenceValue && typeof recurrenceValue === 'object') ? JSON.stringify(recurrenceValue) : recurrenceValue,
    });

    res.status(201).json({
      success: true,
      data: {
        routine: newRoutine,
      },
    });
  } catch (error) {
    console.error('Error creating routine:', error);
    res.status(500).json({
      success: false,
      message: 'Server Error',
    });
  }
};