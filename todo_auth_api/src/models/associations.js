// --- Tüm Model İlişkilerini (Associations) Kuran Dosya ---
import User from './User.model.js';
import Todo from './Todo.model.js';
import Routine from './Routine.model.js';
import Follower from './Follower.model.js';

const setupAssociations = () => {
  // --- 1. User-Todo İlişkisi ---
  // Bir kullanıcı birden fazla Todo'ya sahip olabilir. (One-to-Many)
  User.hasMany(Todo, {
    foreignKey: 'userId', // Todo tablosuna eklenecek sütun adı
    as: 'todos', // İlişki adı (Kullanıcıdan Todo'ları çekerken)
    onDelete: 'CASCADE', // Kullanıcı silinirse, görevleri de silinir
  });

  // Bir Todo, tek bir kullanıcıya aittir.
  Todo.belongsTo(User, {
    foreignKey: 'userId',
    as: 'user', // İlişki adı (Todo'dan kullanıcıyı çekerken)
  });

  // --- 2. User-Routine İlişkisi ---
  // Bir kullanıcı birden fazla Routine'e sahip olabilir.
  User.hasMany(Routine, {
    foreignKey: 'userId',
    as: 'routines',
    onDelete: 'CASCADE',
  });

  // Bir Routine, tek bir kullanıcıya aittir.
  Routine.belongsTo(User, {
    foreignKey: 'userId',
    as: 'user',
  });

  // --- 3. User-Follower İlişkisi (Self Many-to-Many) ---
  // Bu, bir kullanıcının diğer kullanıcıları takip etmesi için çoktan çoğa ilişkidir.

  // 'Takipçi' (Follower) olarak ilişki:
  User.belongsToMany(User, {
    as: 'Following', // 'Takip Edilenler' listesi
    through: Follower, // Aracılık eden tablo
    foreignKey: 'followerId', // Bu kullanıcının ID'si Follower tablosunun hangi sütununa gider
    otherKey: 'followingId', // Hedef kullanıcının ID'si Follower tablosunun hangi sütununa gider
  });

  // 'Takip Edilen' (Following) olarak ilişki:
  User.belongsToMany(User, {
    as: 'Followers', // 'Takipçiler' listesi
    through: Follower,
    foreignKey: 'followingId', // Bu kullanıcının ID'si Follower tablosunun hangi sütununa gider
    otherKey: 'followerId', // Kaynak kullanıcının ID'si Follower tablosunun hangi sütununa gider
  });
};

export default setupAssociations;
