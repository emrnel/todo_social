import sequelize from '../db.js';
import Category from '../models/Category.js';
import Badge from '../models/Badge.js';
import setupAssociations from '../models/associations.js';

// Setup associations before seeding
setupAssociations();

const categories = [
  {
    name: 'İş',
    icon: '💼',
    color: '#3B82F6',
    description: 'İş ile ilgili görevler',
  },
  {
    name: 'Kişisel',
    icon: '👤',
    color: '#8B5CF6',
    description: 'Kişisel görevler',
  },
  {
    name: 'Sağlık',
    icon: '🏥',
    color: '#10B981',
    description: 'Sağlık ve fitness görevleri',
  },
  {
    name: 'Eğitim',
    icon: '📚',
    color: '#F59E0B',
    description: 'Eğitim ve öğrenme görevleri',
  },
  {
    name: 'Hobi',
    icon: '🎨',
    color: '#EC4899',
    description: 'Hobi ve eğlence görevleri',
  },
  {
    name: 'Alışveriş',
    icon: '🛒',
    color: '#06B6D4',
    description: 'Alışveriş listeleri',
  },
  {
    name: 'Ev İşleri',
    icon: '🏠',
    color: '#84CC16',
    description: 'Ev işleri ve temizlik',
  },
  {
    name: 'Sosyal',
    icon: '🎉',
    color: '#F43F5E',
    description: 'Sosyal etkinlikler ve buluşmalar',
  },
];

const badges = [
  // Todos Completed Badges
  {
    name: 'Başlangıç',
    description: 'İlk 10 görevinizi tamamladınız!',
    icon: '🌟',
    condition: 'todos_completed',
    threshold: 10,
    tier: 'Bronze',
  },
  {
    name: 'Çalışkan',
    description: '50 görev tamamladınız!',
    icon: '💪',
    condition: 'todos_completed',
    threshold: 50,
    tier: 'Silver',
  },
  {
    name: 'Üretken',
    description: '100 görev tamamladınız!',
    icon: '🚀',
    condition: 'todos_completed',
    threshold: 100,
    tier: 'Gold',
  },
  {
    name: 'Efsane',
    description: '500 görev tamamladınız!',
    icon: '👑',
    condition: 'todos_completed',
    threshold: 500,
    tier: 'Platinum',
  },

  // Streak Badges
  {
    name: 'Kararlı',
    description: '7 gün üst üste görev tamamladınız!',
    icon: '🔥',
    condition: 'streak_days',
    threshold: 7,
    tier: 'Bronze',
  },
  {
    name: 'Disiplinli',
    description: '30 gün üst üste görev tamamladınız!',
    icon: '⚡',
    condition: 'streak_days',
    threshold: 30,
    tier: 'Silver',
  },
  {
    name: 'Süper Disiplinli',
    description: '100 gün üst üste görev tamamladınız!',
    icon: '💎',
    condition: 'streak_days',
    threshold: 100,
    tier: 'Gold',
  },

  // Followers Badges
  {
    name: 'Popüler',
    description: '10 takipçiniz var!',
    icon: '👥',
    condition: 'followers_count',
    threshold: 10,
    tier: 'Bronze',
  },
  {
    name: 'İnfluencer',
    description: '50 takipçiniz var!',
    icon: '🌟',
    condition: 'followers_count',
    threshold: 50,
    tier: 'Silver',
  },
  {
    name: 'Yıldız',
    description: '100 takipçiniz var!',
    icon: '⭐',
    condition: 'followers_count',
    threshold: 100,
    tier: 'Gold',
  },

  // XP Badges
  {
    name: 'Yeni Başlayan',
    description: '100 XP kazandınız!',
    icon: '🎯',
    condition: 'xp',
    threshold: 100,
    tier: 'Bronze',
  },
  {
    name: 'Deneyimli',
    description: '500 XP kazandınız!',
    icon: '🏆',
    condition: 'xp',
    threshold: 500,
    tier: 'Silver',
  },
  {
    name: 'Uzman',
    description: '1000 XP kazandınız!',
    icon: '🥇',
    condition: 'xp',
    threshold: 1000,
    tier: 'Gold',
  },
  {
    name: 'Usta',
    description: '5000 XP kazandınız!',
    icon: '💫',
    condition: 'xp',
    threshold: 5000,
    tier: 'Platinum',
  },
];

async function seed() {
  try {
    // Connect to database
    await sequelize.authenticate();
    console.log('Database connected successfully.');

    // Sync database
    await sequelize.sync();
    console.log('Database synced.');

    // Seed categories
    console.log('Seeding categories...');
    for (const category of categories) {
      await Category.findOrCreate({
        where: { name: category.name },
        defaults: category,
      });
    }
    console.log(`✓ ${categories.length} categories seeded.`);

    // Seed badges
    console.log('Seeding badges...');
    for (const badge of badges) {
      await Badge.findOrCreate({
        where: { name: badge.name },
        defaults: badge,
      });
    }
    console.log(`✓ ${badges.length} badges seeded.`);

    console.log('\n✅ Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seed();
