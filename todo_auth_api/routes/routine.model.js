import db from '../config/db.js';

export const Routine = {
  create: async ({ userId, title, description, isPublic, recurrenceType, recurrenceValue }) => {
    const query = `
      INSERT INTO routines (user_id, title, description, is_public, recurrence_type, recurrence_value)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    const [result] = await db.execute(query, [
      userId,
      title,
      description,
      isPublic,
      recurrenceType,
      typeof recurrenceValue === 'object' ? JSON.stringify(recurrenceValue) : recurrenceValue
    ]);
    
    return result.insertId;
  },

  findById: async (id) => {
    const [rows] = await db.execute('SELECT * FROM routines WHERE id = ?', [id]);
    return rows[0];
  },

  findByUserId: async (userId) => {
    const [rows] = await db.execute('SELECT * FROM routines WHERE user_id = ? ORDER BY created_at DESC', [userId]);
    return rows;
  }
};