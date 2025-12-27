import bcrypt from 'bcryptjs';

import sequelize from './db.js';

import User from './models/User.js';

import Todo from './models/Todo.js';

import Category from './models/Category.js';

import Routine from './models/Routine.js';

import Follow from './models/Follow.js';

import TodoLike from './models/TodoLike.js';

import Comment from './models/Comment.js';

import setupAssociations from './models/associations.js';

 

// Model ilişkilerini kur

setupAssociations();

 

const seedDatabase = async () => {

  try {

    console.log('🌱 Veritabanı seed işlemi başlıyor...\n');

 

    // Mevcut verileri temizle (opsiyonel)

    console.log('🗑️  Mevcut veriler temizleniyor...');

    await sequelize.sync({ force: true }); // DİKKAT: Tüm verileri siler!

    console.log('✅ Veritabanı temizlendi.\n');

 

    // ==================== KATEGORİLER ====================

    console.log('📁 Kategoriler oluşturuluyor...');

    const categories = await Category.bulkCreate([

      { name: 'Çalışma', icon: '📚', color: '#3B82F6', description: 'Akademik ve profesyonel çalışmalar' },

      { name: 'Spor', icon: '💪', color: '#10B981', description: 'Fitness ve egzersiz' },

      { name: 'Sağlık', icon: '🏥', color: '#EF4444', description: 'Sağlık ve wellness' },

      { name: 'Hobi', icon: '🎨', color: '#F59E0B', description: 'Kişisel hobiler' },

      { name: 'Sosyal', icon: '👥', color: '#8B5CF6', description: 'Sosyal aktiviteler' },

    ]);

    console.log(`✅ ${categories.length} kategori oluşturuldu.\n`);

 

    // ==================== KULLANICILAR ====================

    console.log('👥 Kullanıcılar oluşturuluyor...');

    const users = [];

    for (let i = 1; i <= 3; i++) {

      const salt = await bcrypt.genSalt(10);

      const hashedPassword = await bcrypt.hash(`999user${i}`, salt);

 

      const user = await User.create({

        email: `user${i}@gmail.com`,

        username: `user${i}`,

        password_hash: hashedPassword,

        bio: `Merhaba! Ben user${i}, todo'larımı sizinle paylaşıyorum 🚀`,

        theme: ['light', 'dark', 'light'][i - 1],

        themeColor: ['blue', 'purple', 'green'][i - 1],

        xp: i * 150,

        level: i,

        currentStreak: i * 2,

        longestStreak: i * 5,

        todosCompletedCount: i * 10,

      });

      users.push(user);

      console.log(`  ✅ ${user.username} (${user.email}) oluşturuldu`);

    }

    console.log(`✅ ${users.length} kullanıcı oluşturuldu.\n`);

 

    // ==================== TAKİP İLİŞKİLERİ ====================

    console.log('🔗 Takip ilişkileri kuruluyor...');

    // user1 -> user2 ve user3'ü takip eder

    await Follow.create({ followerId: users[0].id, followingId: users[1].id });

    await Follow.create({ followerId: users[0].id, followingId: users[2].id });

    // user2 -> user1'i takip eder

    await Follow.create({ followerId: users[1].id, followingId: users[0].id });

    // user3 -> user1 ve user2'yi takip eder

    await Follow.create({ followerId: users[2].id, followingId: users[0].id });

    await Follow.create({ followerId: users[2].id, followingId: users[1].id });

 

    // Takip sayılarını güncelle

    await users[0].update({ followersCount: 2, followingCount: 2 });

    await users[1].update({ followersCount: 2, followingCount: 1 });

    await users[2].update({ followersCount: 1, followingCount: 2 });

    console.log('✅ Takip ilişkileri kuruldu.\n');

 

    // ==================== TODO'LAR ====================

    console.log('📝 Todo\'lar oluşturuluyor...');

    const todos = [];

 

    // User1'in todo'ları

    const user1Todos = [

      { title: 'CSE344 Proje Teslimi', description: 'Railway deployment ve README güncellemesi', isPublic: true, isCompleted: true, categoryId: categories[0].id },

      { title: '30 Dakika Koşu', description: 'Sabah sporu rutini', isPublic: true, isCompleted: false, categoryId: categories[1].id },

      { title: 'Kitap Okuma', description: 'Clean Code kitabından 2 bölüm', isPublic: false, isCompleted: false, categoryId: categories[3].id },

      { title: 'Doktor Randevusu', description: 'Diş kontrolü için randevu al', isPublic: true, isCompleted: true, categoryId: categories[2].id },

    ];

 

    // User2'nin todo'ları

    const user2Todos = [

      { title: 'Algoritma Çalışması', description: 'Dynamic programming problemleri çöz', isPublic: true, isCompleted: false, categoryId: categories[0].id },

      { title: 'Yoga Dersi', description: 'Akşam yoga seansı', isPublic: true, isCompleted: true, categoryId: categories[1].id },

      { title: 'Arkadaşlarla Buluşma', description: 'Kahve içmeye git', isPublic: true, isCompleted: false, categoryId: categories[4].id },

    ];

 

    // User3'ün todo'ları

    const user3Todos = [

      { title: 'Flutter Widget Çalışması', description: 'Custom widget oluştur', isPublic: true, isCompleted: true, categoryId: categories[0].id },

      { title: 'Vitamin İçme', description: 'Günlük vitamin takviyesi', isPublic: false, isCompleted: true, categoryId: categories[2].id },

      { title: 'Gitar Pratiği', description: '1 saat gitar çalışması', isPublic: true, isCompleted: false, categoryId: categories[3].id },

    ];

 

    for (const todoData of user1Todos) {

      const todo = await Todo.create({ ...todoData, userId: users[0].id, completedAt: todoData.isCompleted ? new Date() : null });

      todos.push(todo);

    }

    for (const todoData of user2Todos) {

      const todo = await Todo.create({ ...todoData, userId: users[1].id, completedAt: todoData.isCompleted ? new Date() : null });

      todos.push(todo);

    }

    for (const todoData of user3Todos) {

      const todo = await Todo.create({ ...todoData, userId: users[2].id, completedAt: todoData.isCompleted ? new Date() : null });

      todos.push(todo);

    }

    console.log(`✅ ${todos.length} todo oluşturuldu.\n`);

 

    // ==================== RUTİNLER ====================

    console.log('🔄 Rutinler oluşturuluyor...');

    const routines = [];

 

    const routine1 = await Routine.create({

      userId: users[0].id,

      title: 'Sabah Egzersizi',

      description: 'Her sabah 30 dakika koşu',

      isPublic: true,

      recurrenceType: 'daily',

    });

    routines.push(routine1);

 

    const routine2 = await Routine.create({

      userId: users[1].id,

      title: 'Haftalık Code Review',

      description: 'Her pazartesi kod incelemesi',

      isPublic: true,

      recurrenceType: 'weekly',

      recurrenceValue: 'Monday',

    });

    routines.push(routine2);

 

    console.log(`✅ ${routines.length} rutin oluşturuldu.\n`);

 

    // ==================== LİKE'LAR ====================

    console.log('❤️  Like\'lar ekleniyor...');

    // user2 ve user3, user1'in public todo'larını beğenir

    const publicTodos = todos.filter(t => t.isPublic);

    let likeCount = 0;

 

    for (const todo of publicTodos.slice(0, 4)) {

      await TodoLike.create({ userId: users[1].id, todoId: todo.id });

      await todo.increment('likeCount');

      likeCount++;

    }

 

    for (const todo of publicTodos.slice(0, 3)) {

      await TodoLike.create({ userId: users[2].id, todoId: todo.id });

      await todo.increment('likeCount');

      likeCount++;

    }

    console.log(`✅ ${likeCount} like eklendi.\n`);

 

    // ==================== YORUMLAR ====================

    console.log('💬 Yorumlar ekleniyor...');

    const comments = [];

 

    const comment1 = await Comment.create({

      userId: users[1].id,

      todoId: todos[0].id,

      text: 'Harika iş çıkarmışsın! 🎉',

    });

    comments.push(comment1);

    await todos[0].increment('commentCount');

 

    const comment2 = await Comment.create({

      userId: users[2].id,

      todoId: todos[0].id,

      text: 'Railway deployment kolay mıydı?',

    });

    comments.push(comment2);

    await todos[0].increment('commentCount');

 

    const comment3 = await Comment.create({

      userId: users[0].id,

      todoId: todos[4].id,

      text: 'DP çok güzel konu, başarılar! 💪',

    });

    comments.push(comment3);

    await todos[4].increment('commentCount');

 

    console.log(`✅ ${comments.length} yorum eklendi.\n`);

 

    // ==================== ÖZET ====================

    console.log('🎉 Seed işlemi tamamlandı!\n');

    console.log('📊 Özet:');

    console.log(`  👥 Kullanıcılar: ${users.length}`);

    console.log(`  📝 Todo'lar: ${todos.length}`);

    console.log(`  🔄 Rutinler: ${routines.length}`);

    console.log(`  📁 Kategoriler: ${categories.length}`);

    console.log(`  ❤️  Like'lar: ${likeCount}`);

    console.log(`  💬 Yorumlar: ${comments.length}`);

    console.log('\n🔑 Test Kullanıcıları:');

    console.log('  📧 user1@gmail.com / 🔑 999user1');

    console.log('  📧 user2@gmail.com / 🔑 999user2');

    console.log('  📧 user3@gmail.com / 🔑 999user3');

    console.log('\n✨ Artık uygulamayı test edebilirsin!');

 

  } catch (error) {

    console.error('❌ Seed hatası:', error);

  } finally {

    await sequelize.close();

    process.exit(0);

  }

};

 

seedDatabase();