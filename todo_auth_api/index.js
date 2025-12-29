import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import sequelize from './db.js'; // Sequelize bağlantı yapılandırması

// Rota dosyalarını import et
// Not: Proje yapınıza göre bu yolların doğru olduğundan emin olun.
// Artık tüm rotaların Sequelize kullandığından eminiz.
import authRoutes from './routes/auth_routes.js';
import userRoutes from './routes/user_routes.js';
import todoRoutes from './routes/todo_routes.js';
import socialRoutes from './routes/social.routes.js';
import routineRoutes from './routes/routine.routes.js';
import adminRoutes from './routes/admin_routes.js';
import commentRoutes from './routes/comment_routes.js';
import categoryRoutes from './routes/category.routes.js';
import badgeRoutes from './routes/badge.routes.js';
import notificationRoutes from './routes/notification.routes.js';
import searchRoutes from './routes/search.routes.js';
import statisticsRoutes from './routes/statistics.routes.js';
import setupAssociations from './models/associations.js';

// ES Module için __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// .env dosyasındaki değişkenleri yükle
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

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

    // SQLite için tabloları oluştur (sadece mevcut değilse - mevcut verileri koru)
    await sequelize.sync();
    console.log('Veritabanı modelleri senkronize edildi (mevcut veriler korundu).');

  } catch (error) {
    console.error('MySQL bağlantı hatası:', error.message);
    process.exit(1); // Hata durumunda uygulamayı sonlandır
  }
};

// --- Middleware'ler ---
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Static dosyaları servis et (admin panel için)
app.use(express.static(path.join(__dirname, 'public')));

// --- Ana Rotalar ---
// Gelen isteğin yoluna göre ilgili rota dosyasına yönlendirme yap
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/todos', todoRoutes);
app.use('/api/social', socialRoutes);
app.use('/api/routines', routineRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/badges', badgeRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/statistics', statisticsRoutes);

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Todo Social API</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          max-width: 800px;
          margin: 50px auto;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }
        .card {
          background: white;
          color: #333;
          padding: 30px;
          border-radius: 12px;
          box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        h1 { color: #667eea; margin-bottom: 20px; }
        a {
          display: inline-block;
          background: #667eea;
          color: white;
          padding: 12px 24px;
          text-decoration: none;
          border-radius: 8px;
          margin-top: 20px;
          transition: transform 0.2s;
        }
        a:hover { transform: translateY(-2px); }
        .status { color: #28a745; font-weight: bold; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>🎉 Todo Social API</h1>
        <p class="status">✅ API çalışıyor!</p>
        <p>Backend sunucunuz başarıyla çalışıyor. Database bağlantısı aktif.</p>
        <a href="/admin.html">📊 Admin Paneline Git</a>
      </div>
    </body>
    </html>
  `);
});

// --- Sunucuyu Başlat ---
startServer().then(() => {
  app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde başlatıldı.`);
  });
});
