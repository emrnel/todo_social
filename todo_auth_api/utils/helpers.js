import Hashtag from '../models/Hashtag.js';
import TodoHashtag from '../models/TodoHashtag.js';
import Notification from '../models/Notification.js';

/**
 * Extract hashtags from text
 */
export const extractHashtags = (text) => {
  if (!text) return [];

  // Match hashtags (# followed by alphanumeric characters and underscores)
  const hashtagRegex = /#([a-zA-Z0-9_çğıöşüÇĞİÖŞÜ]+)/g;
  const matches = text.match(hashtagRegex);

  if (!matches) return [];

  // Remove # and convert to lowercase, remove duplicates
  const hashtags = [...new Set(matches.map(tag => tag.substring(1).toLowerCase()))];

  return hashtags;
};

/**
 * Process and save hashtags for a todo
 */
export const processHashtags = async (todoId, text) => {
  try {
    const hashtagTexts = extractHashtags(text);

    if (hashtagTexts.length === 0) return;

    // Find or create hashtags
    const hashtagPromises = hashtagTexts.map(async (tag) => {
      const [hashtag, created] = await Hashtag.findOrCreate({
        where: { tag },
        defaults: { tag, usageCount: 0 },
      });

      // Increment usage count
      if (!created) {
        await hashtag.increment('usageCount');
      } else {
        await hashtag.update({ usageCount: 1 });
      }

      return hashtag;
    });

    const hashtags = await Promise.all(hashtagPromises);

    // Create TodoHashtag relationships
    const todoHashtagPromises = hashtags.map((hashtag) =>
      TodoHashtag.findOrCreate({
        where: { todoId, hashtagId: hashtag.id },
      })
    );

    await Promise.all(todoHashtagPromises);
  } catch (error) {
    console.error('Error processing hashtags:', error);
  }
};

/**
 * Calculate XP for an action
 */
export const calculateXP = (action) => {
  const xpValues = {
    todo_completed: 10,
    todo_created_public: 5,
    received_like: 2,
    received_comment: 3,
    todo_copied_by_others: 5,
  };

  return xpValues[action] || 0;
};

/**
 * Calculate level from XP
 */
export const calculateLevel = (xp) => {
  // Level formula: level = floor(sqrt(xp / 100)) + 1
  // Level 1: 0-99 XP
  // Level 2: 100-399 XP
  // Level 3: 400-899 XP
  // Level 4: 900-1599 XP
  // etc.
  return Math.floor(Math.sqrt(xp / 100)) + 1;
};

/**
 * Update user XP and level
 */
export const addXP = async (user, xpAmount) => {
  try {
    const oldLevel = user.level;
    const newXP = user.xp + xpAmount;
    const newLevel = calculateLevel(newXP);

    await user.update({
      xp: newXP,
      level: newLevel,
    });

    // Create notification if user leveled up
    if (newLevel > oldLevel) {
      await Notification.create({
        userId: user.id,
        type: 'level_up',
        message: `Tebrikler! Seviye ${newLevel}'e ulaştınız!`,
      });
    }

    return { xp: newXP, level: newLevel, leveledUp: newLevel > oldLevel };
  } catch (error) {
    console.error('Error adding XP:', error);
    return null;
  }
};

/**
 * Update streak for user
 */
export const updateStreak = async (user) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const lastActivity = user.lastActivityDate;

    if (!lastActivity) {
      // First activity
      await user.update({
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: today,
      });
      return 1;
    }

    const lastActivityDate = new Date(lastActivity).toISOString().split('T')[0];

    if (lastActivityDate === today) {
      // Already completed a todo today
      return user.currentStreak;
    }

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    let newStreak;
    if (lastActivityDate === yesterdayStr) {
      // Consecutive day
      newStreak = user.currentStreak + 1;
    } else {
      // Streak broken, restart
      newStreak = 1;
    }

    const newLongestStreak = Math.max(user.longestStreak, newStreak);

    await user.update({
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: today,
    });

    return newStreak;
  } catch (error) {
    console.error('Error updating streak:', error);
    return null;
  }
};
