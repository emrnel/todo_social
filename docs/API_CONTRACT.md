# TODO-APP API CONTRACT

**Proje:** Todo Social  
**Backend:** Node.js + Express + MySQL + Sequelize  
**Frontend:** Flutter  
**Versiyon:** 1.0  
**Son Güncelleme:** 3 Kasım 2025  
**Durum:** ✅ Sprint 2 Tamamlandı, Sprint 3-5 için Referans

---

## 📋 İÇİNDEKİLER

1. [Genel Kurallar](#genel-kurallar)
2. [Database Models](#database-models)
3. [Authentication Endpoints](#authentication-endpoints)
4. [User Endpoints](#user-endpoints)
5. [Todo Endpoints](#todo-endpoints)
6. [Routine Endpoints](#routine-endpoints)
7. [Social Endpoints](#social-endpoints)
8. [Feed Endpoints](#feed-endpoints)
9. [Error Handling](#error-handling)
10. [Status Codes Referansı](#status-codes-referansı)

---

## 🔒 GENEL KURALLAR

### Base URL
```
Development: http://localhost:3000
Production: TBD
```

### Request Headers
```http
Content-Type: application/json
Authorization: Bearer {JWT_TOKEN}  # Korumalı endpoint'ler için gerekli
```

### Response Format
Tüm API yanıtları JSON formatındadır:
```json
{
  "success": true/false,
  "message": "İşlem açıklaması",
  "data": { ... }  // Başarılı yanıtlarda
  "error": { ... }  // Hatalı yanıtlarda
}
```

### Authentication
- JWT (JSON Web Token) kullanılır
- Token geçerlilik süresi: **24 saat**
- Token payload: `{ userId: number, email: string }`
- Secret Key: `.env` dosyasında `JWT_SECRET` olarak saklanır

### Pagination (Gelecek Sprint'ler için)
```
?page=1&limit=20
```

---

## 🗄️ DATABASE MODELS

### 1. Users Table

```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Sequelize Model Fields:**
```javascript
{
  id: { type: INTEGER, primaryKey: true, autoIncrement: true },
  username: { type: STRING(50), allowNull: false, unique: true },
  email: { type: STRING(100), allowNull: false, unique: true },
  password_hash: { type: STRING(255), allowNull: false },
  createdAt: { type: DATE },
  updatedAt: { type: DATE }
}
```

**JSON Response Format (password_hash HARİÇ):**
```json
{
  "id": 1,
  "username": "emresenel",
  "email": "emre@example.com",
  "createdAt": "2025-10-22T10:30:00.000Z",
  "updatedAt": "2025-10-22T10:30:00.000Z"
}
```

---

### 2. Todos Table

```sql
CREATE TABLE todos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT false,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**Sequelize Model Fields:**
```javascript
{
  id: { type: INTEGER, primaryKey: true, autoIncrement: true },
  userId: { type: INTEGER, allowNull: false, references: { model: 'users', key: 'id' } },
  title: { type: STRING(200), allowNull: false },
  description: { type: TEXT, allowNull: true },
  isCompleted: { type: BOOLEAN, defaultValue: false },
  isPublic: { type: BOOLEAN, defaultValue: false },
  createdAt: { type: DATE },
  updatedAt: { type: DATE }
}
```

**JSON Response Format:**
```json
{
  "id": 1,
  "userId": 1,
  "title": "Flutter projesi tamamla",
  "description": "Auth ekranlarını bitir",
  "isCompleted": false,
  "isPublic": false,
  "createdAt": "2025-11-01T14:20:00.000Z",
  "updatedAt": "2025-11-01T14:20:00.000Z"
}
```

---

### 3. Routines Table

```sql
CREATE TABLE routines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  recurrence_type ENUM('daily', 'weekly', 'custom') NOT NULL,
  recurrence_value VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**Sequelize Model Fields:**
```javascript
{
  id: { type: INTEGER, primaryKey: true, autoIncrement: true },
  userId: { type: INTEGER, allowNull: false, references: { model: 'users', key: 'id' } },
  title: { type: STRING(200), allowNull: false },
  description: { type: TEXT, allowNull: true },
  isPublic: { type: BOOLEAN, defaultValue: false },
  recurrenceType: { type: ENUM('daily', 'weekly', 'custom'), allowNull: false },
  recurrenceValue: { type: STRING(255), allowNull: true },
  createdAt: { type: DATE },
  updatedAt: { type: DATE }
}
```

**recurrence_value Format:**
- `daily`: `null` veya `""`
- `weekly`: JSON array `["mon", "wed", "fri"]`
- `custom`: JSON array (gelecekte tanımlanacak)

**JSON Response Format:**
```json
{
  "id": 1,
  "userId": 1,
  "title": "Sabah koşusu",
  "description": "5km koş",
  "isPublic": true,
  "recurrenceType": "weekly",
  "recurrenceValue": "[\"mon\",\"wed\",\"fri\"]",
  "createdAt": "2025-12-05T09:00:00.000Z",
  "updatedAt": "2025-12-05T09:00:00.000Z"
}
```

---

### 4. Followers Table

```sql
CREATE TABLE followers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  follower_id INT NOT NULL,
  following_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_follow (follower_id, following_id),
  CHECK (follower_id != following_id)
);
```

**Sequelize Model Fields:**
```javascript
{
  id: { type: INTEGER, primaryKey: true, autoIncrement: true },
  followerId: { type: INTEGER, allowNull: false, references: { model: 'users', key: 'id' } },
  followingId: { type: INTEGER, allowNull: false, references: { model: 'users', key: 'id' } },
  createdAt: { type: DATE }
}
```

**JSON Response Format:**
```json
{
  "id": 1,
  "followerId": 1,
  "followingId": 2,
  "createdAt": "2025-11-20T16:45:00.000Z"
}
```

---

## 🔐 AUTHENTICATION ENDPOINTS

### POST /api/auth/register
**Sprint:** 2  
**Açıklama:** Yeni kullanıcı kaydı  
**Auth:** ❌ Gerekli değil

**Request Body:**
```json
{
  "username": "emresenel",
  "email": "emre@example.com",
  "password": "SecurePass123"
}
```

**Validation Rules:**
- `username`: 3-50 karakter, alfanumerik + underscore, **unique**
- `email`: Geçerli email formatı, **unique**
- `password`: Minimum 6 karakter

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Kullanıcı başarıyla oluşturuldu",
  "data": {
    "user": {
      "id": 1,
      "username": "emresenel",
      "email": "emre@example.com",
      "createdAt": "2025-10-22T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**

**400 Bad Request** - Validasyon hatası
```json
{
  "success": false,
  "message": "Validasyon hatası",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "email",
        "message": "Geçerli bir email adresi giriniz"
      }
    ]
  }
}
```

**409 Conflict** - Email/Username zaten kayıtlı
```json
{
  "success": false,
  "message": "Bu email adresi zaten kayıtlı",
  "error": {
    "code": "EMAIL_ALREADY_EXISTS"
  }
}
```

---

### POST /api/auth/login
**Sprint:** 2  
**Açıklama:** Kullanıcı girişi  
**Auth:** ❌ Gerekli değil

**Request Body:**
```json
{
  "email": "emre@example.com",
  "password": "SecurePass123"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Giriş başarılı",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "emresenel",
      "email": "emre@example.com"
    }
  }
}
```

**Error Responses:**

**401 Unauthorized** - Hatalı kimlik bilgileri
```json
{
  "success": false,
  "message": "Email veya şifre hatalı",
  "error": {
    "code": "INVALID_CREDENTIALS"
  }
}
```

**400 Bad Request** - Eksik alan
```json
{
  "success": false,
  "message": "Email ve şifre gereklidir",
  "error": {
    "code": "MISSING_FIELDS"
  }
}
```

---

## 👤 USER ENDPOINTS

### GET /api/users/me
**Sprint:** 3  
**Açıklama:** Oturum açmış kullanıcının profil bilgileri  
**Auth:** ✅ JWT Token gerekli

**Request Headers:**
```http
Authorization: Bearer {JWT_TOKEN}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "username": "emresenel",
      "email": "emre@example.com",
      "createdAt": "2025-10-22T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**

**401 Unauthorized** - Token eksik/geçersiz
```json
{
  "success": false,
  "message": "Yetkilendirme gerekli",
  "error": {
    "code": "UNAUTHORIZED"
  }
}
```

---

### GET /api/users/search?q={query}
**Sprint:** 4  
**Açıklama:** Kullanıcı adına göre arama  
**Auth:** ✅ JWT Token gerekli

**Query Parameters:**
- `q`: Arama terimi (minimum 2 karakter)

**Example Request:**
```
GET /api/users/search?q=emre
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "username": "emresenel",
        "email": "emre@example.com"
      },
      {
        "id": 5,
        "username": "emretuncer",
        "email": "emret@example.com"
      }
    ],
    "count": 2
  }
}
```

**Error Responses:**

**400 Bad Request** - Query çok kısa
```json
{
  "success": false,
  "message": "Arama terimi en az 2 karakter olmalıdır",
  "error": {
    "code": "INVALID_QUERY"
  }
}
```

---

### GET /api/users/profile/:username
**Sprint:** 4  
**Açıklama:** Belirli bir kullanıcının profili ve herkese açık görevleri  
**Auth:** ✅ JWT Token gerekli

**URL Parameters:**
- `username`: Görüntülenecek kullanıcı adı

**Example Request:**
```
GET /api/users/profile/berkecalta
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 3,
      "username": "berkecalta",
      "email": "berke@example.com",
      "createdAt": "2025-10-25T12:00:00.000Z"
    },
    "isFollowing": true,
    "followerCount": 15,
    "followingCount": 23,
    "publicTodos": [
      {
        "id": 10,
        "title": "Backend API tamamla",
        "description": "Sprint 3 için tüm endpoint'leri yaz",
        "isCompleted": false,
        "createdAt": "2025-11-05T09:30:00.000Z"
      },
      {
        "id": 12,
        "title": "Database optimize et",
        "description": null,
        "isCompleted": true,
        "createdAt": "2025-11-03T14:20:00.000Z"
      }
    ]
  }
}
```

**Error Responses:**

**404 Not Found** - Kullanıcı bulunamadı
```json
{
  "success": false,
  "message": "Kullanıcı bulunamadı",
  "error": {
    "code": "USER_NOT_FOUND"
  }
}
```

---

### POST /api/users/follow/:userId
**Sprint:** 4  
**Açıklama:** Bir kullanıcıyı takip et  
**Auth:** ✅ JWT Token gerekli

**URL Parameters:**
- `userId`: Takip edilecek kullanıcının ID'si

**Example Request:**
```
POST /api/users/follow/3
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Kullanıcı takip edildi",
  "data": {
    "followerId": 1,
    "followingId": 3
  }
}
```

**Error Responses:**

**400 Bad Request** - Kendini takip etme
```json
{
  "success": false,
  "message": "Kendinizi takip edemezsiniz",
  "error": {
    "code": "CANNOT_FOLLOW_SELF"
  }
}
```

**409 Conflict** - Zaten takip ediliyor
```json
{
  "success": false,
  "message": "Bu kullanıcıyı zaten takip ediyorsunuz",
  "error": {
    "code": "ALREADY_FOLLOWING"
  }
}
```

**404 Not Found** - Kullanıcı bulunamadı
```json
{
  "success": false,
  "message": "Kullanıcı bulunamadı",
  "error": {
    "code": "USER_NOT_FOUND"
  }
}
```

---

### DELETE /api/users/unfollow/:userId
**Sprint:** 4  
**Açıklama:** Bir kullanıcıyı takipten çık  
**Auth:** ✅ JWT Token gerekli

**URL Parameters:**
- `userId`: Takipten çıkılacak kullanıcının ID'si

**Example Request:**
```
DELETE /api/users/unfollow/3
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Takipten çıkıldı"
}
```

**Error Responses:**

**404 Not Found** - Takip kaydı bulunamadı
```json
{
  "success": false,
  "message": "Bu kullanıcıyı takip etmiyorsunuz",
  "error": {
    "code": "NOT_FOLLOWING"
  }
}
```

---

## ✅ TODO ENDPOINTS

### GET /api/todos/mytodos
**Sprint:** 3  
**Açıklama:** Oturum açmış kullanıcının tüm görevlerini listele  
**Auth:** ✅ JWT Token gerekli

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "todos": [
      {
        "id": 1,
        "userId": 1,
        "title": "Flutter projesi tamamla",
        "description": "Auth ekranlarını bitir",
        "isCompleted": false,
        "isPublic": false,
        "createdAt": "2025-11-01T14:20:00.000Z",
        "updatedAt": "2025-11-01T14:20:00.000Z"
      },
      {
        "id": 2,
        "title": "Backend test et",
        "description": null,
        "isCompleted": true,
        "isPublic": true,
        "createdAt": "2025-10-30T10:15:00.000Z",
        "updatedAt": "2025-11-02T09:30:00.000Z"
      }
    ],
    "count": 2
  }
}
```

---

### POST /api/todos
**Sprint:** 3 (Sprint 4'te isPublic eklendi)  
**Açıklama:** Yeni görev oluştur  
**Auth:** ✅ JWT Token gerekli

**Request Body (Sprint 3):**
```json
{
  "title": "Yeni görev",
  "description": "Görev açıklaması"
}
```

**Request Body (Sprint 4+):**
```json
{
  "title": "Yeni görev",
  "description": "Görev açıklaması",
  "isPublic": false
}
```

**Validation Rules:**
- `title`: **Zorunlu**, 1-200 karakter
- `description`: Opsiyonel, max 5000 karakter
- `isPublic`: Opsiyonel, boolean (default: false)

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Görev oluşturuldu",
  "data": {
    "todo": {
      "id": 15,
      "userId": 1,
      "title": "Yeni görev",
      "description": "Görev açıklaması",
      "isCompleted": false,
      "isPublic": false,
      "createdAt": "2025-11-05T16:45:00.000Z",
      "updatedAt": "2025-11-05T16:45:00.000Z"
    }
  }
}
```

**Error Responses:**

**400 Bad Request** - Validasyon hatası
```json
{
  "success": false,
  "message": "Başlık gereklidir",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "title",
        "message": "Başlık boş olamaz"
      }
    ]
  }
}
```

---

### PATCH /api/todos/:id
**Sprint:** 3  
**Açıklama:** Görev güncelle (tamamlanma durumu veya diğer alanlar)  
**Auth:** ✅ JWT Token gerekli

**URL Parameters:**
- `id`: Güncellenecek görevin ID'si

**Request Body (Tüm alanlar opsiyonel):**
```json
{
  "title": "Güncellenmiş başlık",
  "description": "Yeni açıklama",
  "isCompleted": true,
  "isPublic": true
}
```

**Minimum Request (Sadece tamamlama durumu):**
```json
{
  "isCompleted": true
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Görev güncellendi",
  "data": {
    "todo": {
      "id": 15,
      "userId": 1,
      "title": "Güncellenmiş başlık",
      "description": "Yeni açıklama",
      "isCompleted": true,
      "isPublic": true,
      "createdAt": "2025-11-05T16:45:00.000Z",
      "updatedAt": "2025-11-06T10:20:00.000Z"
    }
  }
}
```

**Error Responses:**

**404 Not Found** - Görev bulunamadı
```json
{
  "success": false,
  "message": "Görev bulunamadı",
  "error": {
    "code": "TODO_NOT_FOUND"
  }
}
```

**403 Forbidden** - Başkasının görevi
```json
{
  "success": false,
  "message": "Bu görevi güncelleme yetkiniz yok",
  "error": {
    "code": "FORBIDDEN"
  }
}
```

---

### DELETE /api/todos/:id
**Sprint:** 3  
**Açıklama:** Görev sil  
**Auth:** ✅ JWT Token gerekli

**URL Parameters:**
- `id`: Silinecek görevin ID'si

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Görev silindi"
}
```

**Error Responses:**

**404 Not Found** - Görev bulunamadı
```json
{
  "success": false,
  "message": "Görev bulunamadı",
  "error": {
    "code": "TODO_NOT_FOUND"
  }
}
```

**403 Forbidden** - Başkasının görevi
```json
{
  "success": false,
  "message": "Bu görevi silme yetkiniz yok",
  "error": {
    "code": "FORBIDDEN"
  }
}
```

---

## 🔄 ROUTINE ENDPOINTS

### POST /api/routines
**Sprint:** 5  
**Açıklama:** Yeni rutin oluştur  
**Auth:** ✅ JWT Token gerekli

**Request Body:**
```json
{
  "title": "Sabah koşusu",
  "description": "5km koş",
  "isPublic": true,
  "recurrenceType": "weekly",
  "recurrenceValue": "[\"mon\",\"wed\",\"fri\"]"
}
```

**Validation Rules:**
- `title`: **Zorunlu**, 1-200 karakter
- `description`: Opsiyonel
- `isPublic`: Opsiyonel, boolean (default: false)
- `recurrenceType`: **Zorunlu**, enum: `daily` | `weekly` | `custom`
- `recurrenceValue`: 
  - `daily` için: `null` veya `""`
  - `weekly` için: JSON array `["mon", "tue", "wed", "thu", "fri", "sat", "sun"]`

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Rutin oluşturuldu",
  "data": {
    "routine": {
      "id": 1,
      "userId": 1,
      "title": "Sabah koşusu",
      "description": "5km koş",
      "isPublic": true,
      "recurrenceType": "weekly",
      "recurrenceValue": "[\"mon\",\"wed\",\"fri\"]",
      "createdAt": "2025-12-05T09:00:00.000Z",
      "updatedAt": "2025-12-05T09:00:00.000Z"
    }
  }
}
```

**Error Responses:**

**400 Bad Request** - Geçersiz recurrenceValue
```json
{
  "success": false,
  "message": "Geçersiz tekrarlama değeri",
  "error": {
    "code": "INVALID_RECURRENCE"
  }
}
```

---

### GET /api/todos/mytodos (Güncellenmiş - Sprint 5)
**Sprint:** 5  
**Açıklama:** Oturum açmış kullanıcının tüm görevlerini VE o günün rutinlerini listele  
**Auth:** ✅ JWT Token gerekli

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "tasks": [
      {
        "type": "todo",
        "id": 1,
        "userId": 1,
        "title": "Flutter projesi tamamla",
        "description": "Auth ekranlarını bitir",
        "isCompleted": false,
        "isPublic": false,
        "createdAt": "2025-11-01T14:20:00.000Z",
        "updatedAt": "2025-11-01T14:20:00.000Z"
      },
      {
        "type": "routine",
        "id": 1,
        "userId": 1,
        "title": "Sabah koşusu",
        "description": "5km koş",
        "isPublic": true,
        "recurrenceType": "weekly",
        "recurrenceValue": "[\"mon\",\"wed\",\"fri\"]",
        "todayDate": "2025-12-05"
      }
    ],
    "count": 2
  }
}
```

**Not:** Backend, bugünün gününü kontrol eder (örn: Cuma) ve sadece o güne denk gelen rutinleri döndürür.

---

## 👥 SOCIAL ENDPOINTS

### GET /api/feed
**Sprint:** 4  
**Açıklama:** Takip edilen kullanıcıların herkese açık görevleri  
**Auth:** ✅ JWT Token gerekli

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "feed": [
      {
        "id": 45,
        "userId": 3,
        "username": "berkecalta",
        "title": "Database optimize et",
        "description": "Index'leri düzenle",
        "isCompleted": false,
        "isPublic": true,
        "createdAt": "2025-11-20T10:30:00.000Z"
      },
      {
        "id": 38,
        "userId": 5,
        "username": "emretuncer",
        "title": "UI refactor",
        "description": null,
        "isCompleted": true,
        "isPublic": true,
        "createdAt": "2025-11-19T14:20:00.000Z"
      }
    ],
    "count": 2
  }
}
```

**Not:** 
- Sadece `isPublic: true` görevler döner
- Sadece takip edilen kullanıcıların görevleri döner
- `createdAt` azalan sırada (en yeni önce)

**Error Responses:**

**200 OK (Boş liste)** - Henüz kimseyi takip etmiyor veya paylaşım yok
```json
{
  "success": true,
  "data": {
    "feed": [],
    "count": 0
  }
}
```

---

## ⚠️ ERROR HANDLING

### Genel Error Response Yapısı
```json
{
  "success": false,
  "message": "İnsan okunabilir hata mesajı",
  "error": {
    "code": "ERROR_CODE",
    "details": []  // Opsiyonel, validasyon hatalarında kullanılır
  }
}
```

### Error Codes Listesi

| Code | Açıklama | HTTP Status |
|------|----------|-------------|
| `VALIDATION_ERROR` | Request body validasyon hatası | 400 |
| `MISSING_FIELDS` | Gerekli alan eksik | 400 |
| `INVALID_CREDENTIALS` | Email veya şifre hatalı | 401 |
| `UNAUTHORIZED` | Token eksik veya geçersiz | 401 |
| `FORBIDDEN` | Yetkisiz işlem (başkasının kaynağı) | 403 |
| `USER_NOT_FOUND` | Kullanıcı bulunamadı | 404 |
| `TODO_NOT_FOUND` | Görev bulunamadı | 404 |
| `NOT_FOUND` | Kaynak bulunamadı | 404 |
| `EMAIL_ALREADY_EXISTS` | Email zaten kayıtlı | 409 |
| `USERNAME_ALREADY_EXISTS` | Kullanıcı adı zaten kayıtlı | 409 |
| `ALREADY_FOLLOWING` | Kullanıcı zaten takip ediliyor | 409 |
| `NOT_FOLLOWING` | Kullanıcı takip edilmiyor | 404 |
| `CANNOT_FOLLOW_SELF` | Kendini takip edemezsin | 400 |
| `INTERNAL_SERVER_ERROR` | Sunucu hatası | 500 |

---

## 📊 STATUS CODES REFERANSI

| Status Code | Anlamı | Kullanım |
|-------------|--------|----------|
| **200** | OK | Başarılı GET, PATCH, DELETE |
| **201** | Created | Başarılı POST (kayıt oluşturma) |
| **400** | Bad Request | Validasyon hatası, eksik alan |
| **401** | Unauthorized | Token eksik/geçersiz |
| **403** | Forbidden | Yetkisiz işlem |
| **404** | Not Found | Kaynak bulunamadı |
| **409** | Conflict | Kaynak çakışması (duplicate) |
| **500** | Internal Server Error | Sunucu hatası |

---

## 🔧 IMPLEMENTATION NOTES

### Backend (Berke)

**Middleware:**
```javascript
// middleware/auth.middleware.js
const authMiddleware = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Yetkilendirme gerekli',
      error: { code: 'UNAUTHORIZED' }
    });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.userId, email: decoded.email };
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Geçersiz token',
      error: { code: 'UNAUTHORIZED' }
    });
  }
};
```

**Password Hashing:**
```javascript
const bcrypt = require('bcryptjs');
const saltRounds = 10;

// Kayıt sırasında
const password_hash = await bcrypt.hash(password, saltRounds);

// Giriş sırasında
const isMatch = await bcrypt.compare(password, user.password_hash);
```

### Frontend (Emre Tuncer)

**Model Classes (Flutter):**
```dart
// lib/data/models/user_model.dart
class UserModel {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

```dart
// lib/data/models/todo_model.dart
class TodoModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

---

## ✅ SPRINT COMPLETION CHECKLIST

### Sprint 2 ✅
- [x] POST /api/auth/register
- [x] POST /api/auth/login
- [x] JWT token generation
- [x] Password hashing with bcryptjs

### Sprint 3 🔄
- [ ] GET /api/users/me
- [ ] GET /api/todos/mytodos
- [ ] POST /api/todos
- [ ] PATCH /api/todos/:id
- [ ] DELETE /api/todos/:id
- [ ] authMiddleware implementation

### Sprint 4 ⏳
- [ ] GET /api/users/search
- [ ] GET /api/users/profile/:username
- [ ] POST /api/users/follow/:userId
- [ ] DELETE /api/users/unfollow/:userId
- [ ] GET /api/feed
- [ ] Todo `isPublic` field added

### Sprint 5 ⏳
- [ ] POST /api/routines
- [ ] GET /api/todos/mytodos (updated with routines)

---

## 📝 VERSION HISTORY

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 3 Kasım 2025 | İlk taslak oluşturuldu | Berke Çalta |
| 1.1 | TBD | Sprint 3 tamamlandı, endpoint'ler güncellendi | Berke Çalta |
| 1.2 | TBD | Sprint 4 sosyal özellikler eklendi | Berke Çalta |
| 1.3 | TBD | Sprint 5 rutinler eklendi | Berke Çalta |

---

## 🎯 KULLANIM ÖNERİLERİ

1. **Backend geliştirme sırasında:** Her endpoint'i yazdıktan sonra bu dokümandaki format ile karşılaştır
2. **Frontend geliştirme sırasında:** Model class'larını bu dokümandaki JSON yapısına göre oluştur
3. **Test sırasında:** Postman collection'ını bu dokümana göre hazırla
4. **Değişiklik yapılırsa:** Mutlaka bu dokümanı güncelle ve ekibe duyur
5. **Daily Scrum'da:** API değişikliklerini duyur

---

**🔒 BU DOKÜMAN PROJENİN "KUTSAL KİTABI"DIR**  
**Herhangi bir değişiklik tüm ekibin onayı ile yapılmalıdır!**

---

*Hazırlayan: Berke Çalta (Backend Lead)*  
*Gözden Geçiren: Emre Tuncer (Product Owner)*  
*Onaylayan: Emre İlhan Şenel (Scrum Master)*
