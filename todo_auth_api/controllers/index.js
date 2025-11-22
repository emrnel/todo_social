import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import sequelize from './config/database.js'; // Sequelize bağlantı yapılandırması

// Rota dosyalarını import et
// Not: Proje yapınıza göre bu yolların doğru olduğundan emin olun.
// Artık tüm rotaların Sequelize kullandığından eminiz.
import authRoutes from './routes/auth_routes.js';
import userRoutes from './routes/user_routes.js';
import todoRoutes from './routes/todo_routes.js'; // Sequelize tabanlı todo rotasını kullan

// .env dosyasındaki değişkenleri yükle
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// --- Veritabanı Bağlantısı (MySQL/Sequelize) ---
const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('MySQL veritabanı bağlantısı başarılı.');
    // Modelleri veritabanıyla senkronize et (gerekirse tabloları oluşturur)
    // await sequelize.sync({ alter: true }); // Geliştirme ortamında kullanılabilir
  } catch (error) {
    console.error('MySQL bağlantı hatası:', error.message);
    process.exit(1); // Hata durumunda uygulamayı sonlandır
  }
};

connectDB();

// --- Middleware'ler ---
app.use(cors());
app.use(express.json());

// --- Ana Rotalar ---
// Gelen isteğin yoluna göre ilgili rota dosyasına yönlendirme yap
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/todos', todoRoutes);

app.get('/', (req, res) => {
  res.send('Todo Social API Çalışıyor!');
});

// --- Sunucuyu Başlat ---
app.listen(PORT, () => {
  console.log(`Sunucu http://localhost:${PORT} adresinde başlatıldı.`);
});