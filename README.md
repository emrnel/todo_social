# Todo Social

Gebze Teknik Üniversitesi **CSE344 Software Engineering Project** dersi kapsamında geliştirilen, Flutter (Frontend) ve Node.js/MySQL (Backend) tabanlı bir sosyal motivasyon ve görev yönetimi (to-do) uygulamasıdır.

## 📝 Proje Vizyonu

Kullanıcıların kişisel görevlerini (to-do) ve günlük/haftalık rutinlerini oluşturabildiği, bu ilerlemeyi takip edebildiği ve dilerlerse bu görev/rutinleri takip ettikleri kişilerle paylaşabildiği bir sosyal motivasyon platformu oluşturmak.

## ✨ Temel Özellikler (MVP)

Projenin minimum geçerli ürün (MVP) kapsamındaki hedefleri:

### Kimlik Doğrulama ve Güvenlik
  - 🔐 **Kullanıcı Doğrulaması:** E-posta/şifre ile kayıt, JWT (JSON Web Token) tabanlı güvenli giriş
  - 🔒 **Şifre Güvenliği:** Minimum 6 karakter, en az 1 harf ve 1 rakam içeren şifre validasyonu
  - ✅ **Duplicate Kontrolü:** Email ve kullanıcı adı benzersizlik kontrolü

### Görev ve Rutin Yönetimi
  - ✅ **Görev Yönetimi (CRUD):** Kullanıcıların kişisel görevlerini oluşturması, listelemesi, güncellemesi ve silmesi
  - 🔄 **Rutin Yönetimi:** Günlük, haftalık veya özel periyotlarda tekrarlanan rutinler oluşturabilme
  - 📋 **Rutin Tamamlama:** Rutin tamamlandığında otomatik todo oluşturma ve feed'e ekleme
  - 📊 **Kategori Sistemi:** Görevleri kategorilere ayırabilme ve kategoriye göre filtreleme
  - 🏷️ **Hashtag Sistemi:** Görevlere hashtag ekleyebilme ve hashtag'lere göre arama
  - 🔒 **Görev Gizliliği:** Görevleri "Özel" (Private) veya "Herkese Açık" (Public) olarak ayarlayabilme
  - 📝 **Görev Kopyalama:** Beğenilen görevleri kopyalayabilme (duplicate kontrolü ile)

### Sosyal Özellikler
  - 👥 **Kullanıcı Arama:** Diğer kullanıcıları kullanıcı adına göre arama
  - 🤝 **Takip Sistemi:** Kullanıcıları takip etme/takibi bırakma, takipçi/takip edilen listeleri
  - 📱 **Sosyal Akış (Feed):** Takip edilen kişilerin ve keşfet sekmesindeki tüm kullanıcıların herkese açık görevlerini görme
  - 💬 **Yorum Sistemi:** Görevlere yorum yapabilme ve yorumları görüntüleme
  - ❤️ **Beğeni Sistemi:** Görevleri beğenebilme ve beğeni sayısını görme
  - 📸 **Profil Fotoğrafları:** Base64 formatında profil ve banner fotoğrafı yükleme
  - 👤 **Profil Yönetimi:** Kullanıcıların kendi profil bilgilerini düzenlemesi ve başkalarının profillerini görüntülemesi

### Oyunlaştırma (Gamification)
  - 🏆 **XP Sistemi:** Görev tamamlama, rutin tamamlama, sosyal etkileşimler için XP kazanma
  - 📈 **Seviye Sistemi:** XP biriktirerek seviye atlama
  - 🎯 **Rozet Sistemi:** Çeşitli başarılar için rozet kazanma
  - 📊 **İstatistikler:** Haftalık aktivite, kategori dağılımı, tamamlama oranları
  - 🏅 **Liderlik Tablosu:** Kullanıcılar arası XP sıralaması
  - 🔥 **Streak Sistemi:** Ardışık günlerde aktivite takibi

### Bildirimler
  - 🔔 **Gerçek Zamanlı Bildirimler:** Takip, beğeni, yorum, görev/rutin kopyalama bildirimleri
  - 📬 **Bildirim Merkezi:** Tüm bildirimleri görüntüleme ve yönetme

## 🛠️ Teknoloji Yığını

| Kategori | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Frontend** | Flutter 3.x | Cross-platform mobil uygulama çatısı |
| **State Management** | Flutter Riverpod | Modern, derleme zamanı güvenli state management |
| **Navigasyon** | GoRouter | Flutter için bildirimsel (declarative) yönlendirme |
| **HTTP Client** | Dio | Güçlü HTTP client ve interceptor desteği |
| **Backend** | Node.js (Express.js) | Hızlı ve esnek sunucu tarafı API geliştirme |
| **Veritabanı** | PostgreSQL | İlişkisel veritabanı yönetimi (Railway'de host) |
| **ORM** | Sequelize | Node.js için promise-based ORM |
| **Güvenlik** | JWT, bcrypt.js | Güvenli kullanıcı oturumları ve şifre hash'leme |
| **Image Processing** | Base64 Encoding | Profil fotoğrafları için client-side encoding |
| **Deployment** | Railway | Backend deployment ve PostgreSQL hosting |

## 📁 Proje Yapısı (Monorepo)

Bu proje, hem frontend hem de backend kodunu aynı repoda barındıran bir "Monorepo" yapısındadır:

  - `/` (Root): Flutter projesinin ana dizini (`lib` klasörünü içerir)
  - `/todo_auth_api`: Node.js (Express) backend projesinin dizini
    - `/controllers`: İş mantığı ve API endpoint handler'ları
    - `/models`: Sequelize ORM modelleri (User, Todo, Routine, vb.)
    - `/routes`: Express route tanımlamaları
    - `/migrations`: Veritabanı migration dosyaları
    - `/utils`: Yardımcı fonksiyonlar (XP hesaplama, hashtag işleme, vb.)

### Frontend Klasör Yapısı
```
lib/
├── core/                    # Çekirdek fonksiyonalite
│   ├── api/                # API servisleri ve HTTP client
│   ├── navigation/         # GoRouter yapılandırması
│   ├── theme/              # Tema ve renk tanımlamaları
│   └── widgets/            # Ortak kullanılan widget'lar (ProfileAvatar, vb.)
├── data/                   # Veri modelleri
│   └── models/            # Tüm data model'leri (User, Todo, Routine, vb.)
└── features/              # Özellik tabanlı modüller
    ├── auth/              # Kimlik doğrulama
    ├── todo/              # Görev yönetimi
    ├── routine/           # Rutin yönetimi
    ├── feed/              # Sosyal akış
    ├── social/            # Sosyal özellikler (profil, takip, arama)
    ├── gamification/      # Oyunlaştırma (XP, rozetler, liderlik)
    └── home/              # Ana sayfa ve tab navigasyonu
```

## 📦 Kurulum ve Çalıştırma

Projeyi çalıştırabilmek için hem Backend (Node.js) sunucusunun hem de Frontend (Flutter) uygulamasının aynı anda çalışıyor olması gerekir.

### Gereksinimler

  - Flutter SDK (3.x veya üzeri)
  - Node.js (18.x veya üzeri)
  - Çalışan bir MySQL veritabanı sunucusu

### 1\. Backend Kurulumu (Node.js Sunucusu)

İkinci bir terminal ekranı açın ve backend'i kurun:

```bash
# 1. Backend klasörüne gidin
cd todo-auth-api

# 2. Gerekli Node modüllerini kurun
npm install

# 3. Veritabanı bağlantısı için .env dosyasını oluşturun
# (Proje ekibinden .env.example dosyasını isteyin)
# Örnek .env içeriği:
# PORT=3000
# DB_HOST=localhost
# DB_USER=root
# DB_PASSWORD=sifreniz
# DB_NAME=todo_social

# 4. Veritabanı tablolarını oluşturun (gerekli SQL script'lerini çalıştırın)

# 5. Backend sunucusunu başlatın
node server.js
# VEYA
npm start
```

Terminalde `🚀 Server 3000 portunda çalışıyor` mesajını görmelisiniz.

### 2\. Frontend Kurulumu (Flutter Uygulaması)

Ana terminal ekranında Flutter uygulamasını kurun:

```bash
# 1. Ana dizinde olduğunuzdan emin olun
# (Eğer todo-auth-api klasöründeyseniz: 'cd ..')

# 2. Flutter paketlerini indirin
flutter pub get

# 3. Flutter uygulamasını bir emülatör veya cihazda çalıştırın
flutter run
```

**Not:** Flutter uygulaması, Android Emülatör'de `10.0.2.2:3000` (Node.js sunucusunun adresi) adresine bağlanacak şekilde ayarlanmıştır (`lib/core/api/api_constants.dart`).

## flowchart Git İş Akışı (Git Flow)

Projede **Feature Branch Workflow** kullanılmaktadır:

1.  **`main` Branch'i:** Sadece tamamlanmış, test edilmiş ve TA'ya sunulacak stabil sürümleri içerir. **Doğrudan commit atılmaz.**
2.  **`dev` Branch'i:** Ana geliştirme branch'idir. Tüm tamamlanan özellikler (feature) bu branch'te birleşir. **Doğrudan commit atılmaz.**
3.  **`feature/<jira-id-veya-gorev-adi>` Branch'leri:**
      - Her yeni görev (Task) veya User Story için `dev` branch'inden yeni bir `feature` branch'i oluşturulur.
      - Örnek: `feature/core3-navigation-setup`
      - İş tamamlandığında, `dev` branch'ine bir **Pull Request (PR)** açılır.
      - Kod Gözden Geçirme (Code Review) sonrası PR, `dev` branch'ine **Merge** edilir.

## 👨‍💻 Proje Ekibi

| İsim | Rol |
| :--- | :--- |
| Emre Şenel | Scrum Master / Developer |
| Emre Tuncer | Product Owner / Developer |
| Berke Çalta | Developer (Backend Odaklı) |
| Muhammed Sivri | Developer (Frontend Odaklı) |
| Mharir | Dokümantasyon / Test |