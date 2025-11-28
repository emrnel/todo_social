import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import sequelize from './db.js'; // Sequelize bağlantı yapılandırması

// Rota dosyalarını import et
// Not: Proje yapınıza göre bu yolların doğru olduğundan emin olun.
// Artık tüm rotaların Sequelize kullandığından eminiz.
import authRoutes from './routes/auth_routes.js';
import userRoutes from './routes/user_routes.js';
import todoRoutes from './routes/todo_routes.js';
import socialRoutes from './routes/social.routes.js';
import setupAssociations from './models/associations.js';

// .env dosyasındaki değişkenleri yükle
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// --- Veritabanı Bağlantısı (MySQL/Sequelize) ---
const startServer = async () => {
  try {
    // Veritabanı bağlantısını doğrula
    await sequelize.authenticate();
    console.log('MySQL veritabanı bağlantısı başarılı.');

    // Tüm model ilişkilerini kur
        // Model ilişkileri kuruldu
    setupAssociations();
    console.log('Model ilişkileri (associations) kuruldu.');

    // SQLite için tabloları otomatik oluştur
    await sequelize.sync({ alter: true });
    console.log('Veritabanı modelleri senkronize edildi.');

  } catch (error) {
    console.error('MySQL bağlantı hatası:', error.message);
    process.exit(1); // Hata durumunda uygulamayı sonlandır
  }
};

// --- Middleware'ler ---
app.use(cors());
app.use(express.json());

// --- Ana Rotalar ---
// Gelen isteğin yoluna göre ilgili rota dosyasına yönlendirme yap
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/todos', todoRoutes);
app.use('/api/social', socialRoutes);

app.get('/', (req, res) => {
  res.send('Todo Social API Çalışıyor!');
});

// --- Sunucuyu Başlat ---
startServer().then(() => {
  app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde başlatıldı.`);
  });
});