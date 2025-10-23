import express from "express";
import dotenv from "dotenv";
import bcrypt from "bcryptjs";
import db from "./db.js";
import { body, validationResult } from "express-validator";

dotenv.config();
const app = express();
app.use(express.json());

/**
 * POST /api/auth/register
 * Kullanıcı kayıt endpoint'i
 */
app.post(
  "/api/auth/register",
  [
    body("email").isEmail().withMessage("Geçerli bir e-posta giriniz."),
    body("password")
      .isLength({ min: 6 })
      .withMessage("Şifre en az 6 karakter olmalı."),
  ],
  async (req, res) => {
    try {
      // 1️⃣ Validasyon kontrolü
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array().map((err) => err.msg),
        });
      }

      const { email, password } = req.body;

      // 2️⃣ E-posta zaten kayıtlı mı kontrol et
      const [existingUser] = await db.query("SELECT * FROM users WHERE email = ?", [email]);
      if (existingUser.length > 0) {
        return res
          .status(409)
          .json({ success: false, message: "Bu e-posta adresi zaten kayıtlı." });
      }

      // 3️⃣ Şifreyi hash'le
      const hashedPassword = await bcrypt.hash(password, 10);

      // 4️⃣ Yeni kullanıcıyı kaydet
      await db.query("INSERT INTO users (email, password) VALUES (?, ?)", [
        email,
        hashedPassword,
      ]);

      // 5️⃣ Yanıt döndür
      return res.status(201).json({
        success: true,
        message: "Kullanıcı başarıyla oluşturuldu.",
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({
        success: false,
        message: "Sunucu hatası.",
      });
    }
  }
);

app.listen(process.env.PORT, () => {
  console.log(`🚀 Server ${process.env.PORT} portunda çalışıyor`);
});
