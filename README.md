# Todo Social

Gebze Teknik Üniversitesi **CSE344 Software Engineering Project** dersi kapsamında geliştirilen, Flutter (Frontend) ve Node.js/MySQL (Backend) tabanlı bir sosyal motivasyon ve görev yönetimi (to-do) uygulamasıdır.

## 📝 Proje Vizyonu

Kullanıcıların kişisel görevlerini (to-do) ve günlük/haftalık rutinlerini oluşturabildiği, bu ilerlemeyi takip edebildiği ve dilerlerse bu görev/rutinleri takip ettikleri kişilerle paylaşabildiği bir sosyal motivasyon platformu oluşturmak.

## ✨ Temel Özellikler (MVP)

Projenin minimum geçerli ürün (MVP) kapsamındaki hedefleri:

  - 🔐 **Kullanıcı Doğrulaması:** E-posta/şifre ile kayıt, JWT (JSON Web Token) tabanlı güvenli giriş.
  - ✅ **Görev Yönetimi (CRUD):** Kullanıcıların kişisel görevlerini oluşturması, listelemesi, güncellemesi ve silmesi.
  - 🔄 **Rutin Yönetimi:** Günlük veya haftalık tekrarlanan rutinler oluşturabilme.
  - 🔒 **Görev Gizliliği:** Görevleri "Özel" (Private) veya "Herkese Açık" (Public) olarak ayarlayabilme.
  - 👥 **Sosyal Özellikler:** Diğer kullanıcıları kullanıcı adına göre arama, takip etme ve takibi bırakma.
  - 📱 **Sosyal Akış (Feed):** Ana sayfada, sadece takip edilen kişilerin "Herkese Açık" olarak paylaştığı görevleri kronolojik olarak görme.
  - 👤 **Profil Yönetimi:** Kullanıcıların kendi profil bilgilerini ve başkalarının profillerini (ve herkese açık görevlerini) görüntüleyebilmesi.

## 🛠️ Teknoloji Yığını

| Kategori | Teknoloji | Açıklama |
| :--- | :--- | :--- |
| **Frontend** | Flutter 3.x | Cross-platform mobil uygulama çatısı. |
| **State Management** | Flutter Riverpod | Modern, derleme zamanı güvenli state management. |
| **Navigasyon** | GoRouter | Flutter için bildirimsel (declarative) yönlendirme. |
| **Backend** | Node.js (Express.js) | Hızlı ve esnek sunucu tarafı API geliştirme. |
| **Veritabanı** | MySQL | İlişkisel veritabanı yönetimi. |
| **Güvenlik** | JWT, bcrypt.js | Güvenli kullanıcı oturumları ve şifre hash'leme. |

## 📁 Proje Yapısı (Monorepo)

Bu proje, hem frontend hem de backend kodunu aynı repoda barındıran bir "Monorepo" yapısındadır:

  - `/` (Root): Flutter projesinin ana dizini (`lib` klasörünü içerir).
  - `/todo-auth-api`: Node.js (Express) backend projesinin dizini.

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