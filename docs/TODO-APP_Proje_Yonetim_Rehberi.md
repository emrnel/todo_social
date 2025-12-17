# TODO-APP: Kapsamlı Proje Yönetim ve Görev Planlama Rehberi

## İçindekiler
1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Metodoloji: Çatışmasız (Conflict-Free) Geliştirme](#metodoloji)
3. [Ekip Yapısı ve Sorumluluklar](#ekip-yapısı)
4. [Faz 0: API Sözleşmesi](#faz-0-api-sözleşmesi)
5. [Sprint Planlamaları](#sprint-planlamaları)
   - [Sprint 2: Temel ve Kimlik Doğrulama](#sprint-2)
   - [Sprint 3: Görev Yönetimi (CRUD) & Profil](#sprint-3)
   - [Sprint 4: Sosyal Özellikler](#sprint-4)
   - [Sprint 5: Rutinler, Toparlama ve Final](#sprint-5)
6. [Detaylı Görev Listeleri (Kişi Bazlı)](#detaylı-görev-listeleri)
7. [Scrum Master Sorumlulukları](#scrum-master-sorumlulukları)

---

## Proje Genel Bakış

**Proje Adı:** TODO-APP  
**Teknoloji Stack:**
- **Backend:** Node.js, Express, MySQL, Sequelize
- **Frontend:** Flutter, Riverpod/Provider (State Management), GoRouter (Navigation), Dio (API Client)

**Temel Hedef:** SQL backend'li bir Flutter projesi geliştirirken conflict-free (çatışmasız) bir geliştirme süreci yürütmek.

---

## Metodoloji: Çatışmasız (Conflict-Free) Geliştirme

### Temel Felsefe
**API-First (Önce API Sözleşmesi)** ve **Katmanlı Sorumluluk (Layered Ownership)**

### Katmanlara Göre Geliştirici Ayrımı

| Geliştirici | Sorumluluk | Çalışma Alanı | ❌ Yasak Alan |
|-------------|------------|---------------|---------------|
| **Berke Çalta** | Backend | `todo-auth-api/` | `lib/` (Flutter) |
| **Muhammed Sivri** | Frontend - UI | `lib/features/*/presentation/screens/`<br>`lib/features/*/presentation/widgets/`<br>`lib/core/widgets/`<br>`lib/core/theme/` | `lib/data/`<br>`lib/core/api/`<br>`lib/core/navigation/`<br>`lib/core/services/` |
| **Emre Tuncer** | Frontend - Data/State<br>Product Owner | `lib/data/models/`<br>`lib/data/repositories/`<br>`lib/presentation/providers/` | `lib/presentation/screens/`<br>`lib/presentation/widgets/`<br>`lib/core/navigation/`<br>`todo-auth-api/` |
| **Emre İlhan Şenel** | Frontend - Core/Integration<br>Scrum Master | `lib/core/navigation/`<br>`lib/core/services/`<br>`lib/core/api/` (Interceptor) | `lib/presentation/screens/`<br>`lib/presentation/widgets/`<br>`lib/data/repositories/` |
| **Mharir** | Dokümantasyon<br>Test Yönetimi | `/docs/`<br>Jira<br>Diyagram Araçları | `lib/`<br>`todo-auth-api/` |

### Çatışmasız Kurallar

1. **Muhammed ve Berke:** Asla aynı dosyada çalışmaz
2. **Emre Tuncer ve Muhammed:** Sadece planlı entegrasyon (INT-TASK) görevlerinde birlikte çalışır
3. **Emre Şenel (Core):** `app_router.dart` ve `storage_service.dart` dosyalarının "kapı bekçisi"dir
4. **Berke:** Frontend dosyalarına asla dokunmaz
5. **Mharir:** Kod dosyalarına asla dokunmaz

---

## Ekip Yapısı ve Sorumluluklar

### Scrum Master: Emre İlhan Şenel
- Sprint planlama toplantılarını yönetir
- Daily Scrum toplantılarını organize eder
- Review ve Retrospective toplantılarını planlar
- API_CONTRACT.md'yi "kutsal kitap" olarak korur
- Engelleri (blockers) tespit eder ve çözer

### Product Owner: Emre Tuncer
- User Story'lerin önceliğini belirler
- Kabul kriterlerini (Acceptance Criteria) tanımlar
- Sprint Review'larda özellikleri test eder ve onaylar/reddeder
- Sprint 5'te test sürecini yönetir
- Bug'ları Jira'ya kaydeder

### Dokümantasyon Sorumlusu: Mharir
- Tüm toplantıları kaydeder
- UML diyagramlarını çizer
- Test senaryolarını hazırlar
- Prototip ve Final raporlarını derler
- Bug takibini yapar

---

## Faz 0: API Sözleşmesi

> ⚠️ **KRİTİK:** Tüm kodlamadan önce tamamlanmalıdır!

### Epic: EPIC-CORE
### Story: CORE-0: API Sözleşmesi

**Atanan:** Berke Çalta (Lider), Emre Tuncer (Gözden Geçiren), Mharir (Dokümantasyon)

**Hedef:** Tüm projenin Request ve Response JSON yapılarının, veritabanı modellerinin ve endpoint URL'lerinin tanımlanması.

**Çıktı:** GitHub `/docs/API_CONTRACT.md` dosyası

### Subtask'ler

#### Berke'nin Görevleri:
1. **Task:** User modeli (DB şeması, JSON çıktısı) tanımla
2. **Task:** Todo modeli (DB şeması, JSON çıktısı) tanımla
3. **Task:** Routine modeli (DB şeması, JSON çıktısı) tanımla
4. **Task:** Followers tablosu (DB şeması) tanımla
5. **Task:** Auth Endpoints (`POST /register`, `POST /login`) için req.body ve res.json yapılarını tanımla
6. **Task:** Todo Endpoints (CRUD) için req.body ve res.json yapılarını tanımla
7. **Task:** Social Endpoints (`/search`, `/profile`, `/follow`, `/feed`) için req.body ve res.json yapılarını tanımla

#### Emre Tuncer'in Görevi:
8. **Task:** Tanımlanan tüm JSON yapılarını Flutter `data/models` klasöründe `.dart` dosyalarına (sadece data class'ları, fromJson metotları ile) dök

#### Mharir'in Görevi:
9. **Task:** Tüm bu sözleşmeyi `API_CONTRACT.md` dosyasına dök

---

## Sprint Planlamaları

## Sprint 2: Temel ve Kimlik Doğrulama

**Tarih:** 22 Ekim - 4 Kasım  
**Hedef:** Backend API'ını ayağa kaldırmak ve Frontend'de statik Auth ekranlarını ve temel servisleri oluşturmak. Sprint sonunda entegre etmek.

### Görev Özeti Tablosu

| Atanan Kişi | Katman | İlgili Dosyalar | Görev Sayısı |
|-------------|--------|-----------------|--------------|
| Berke Çalta | Backend | `todo-auth-api/` | BE-TASK-1 → BE-TASK-6 |
| Muhammed Sivri | Frontend (UI) | `lib/features/auth/presentation/`<br>`lib/core/widgets/` | FE-UI-1 → FE-UI-9<br>INT-UI-1 → INT-UI-9 |
| Emre Şenel | Frontend (Core) | `lib/core/navigation/`<br>`lib/core/services/` | FE-CORE-1 → FE-CORE-15<br>SM-TASK-01 → SM-TASK-04 |
| Emre Tuncer | Frontend (Data) | `lib/core/api/`<br>`lib/features/auth/data/` | FE-DATA-1 → FE-DATA-19<br>PO-TASK-01 → PO-TASK-03 |
| Mharir | Dokümantasyon | `/docs/` | DOC-TASK-1 → DOC-TASK-10 |

### Entegrasyon Görevleri (Tüm Ekip)

| Task ID | Açıklama | Sorumlu |
|---------|----------|---------|
| INT-TASK-1 | `auth_provider.dart`'ı oluştur | Emre T. |
| INT-TASK-2 | `auth_provider`'ın `auth_repository`'yi çağırmasını sağla | Emre T. |
| INT-TASK-3 | `login_screen.dart`'taki butonları `auth_provider`'a bağla | Muhammed |
| INT-TASK-4 | `register_screen.dart`'ı `auth_provider`'a bağla | Muhammed |

---

## Sprint 3: Görev Yönetimi (CRUD) & Profil

**Tarih:** 5 Kasım - 18 Kasım (1. Prototip Sunumu)  
**Hedef:** Kullanıcıların görev eklemesi, listelemesi, silmesi/güncellemesi ve kendi profilini görmesi.

### Görev Özeti Tablosu

| Atanan Kişi | Katman | İlgili Dosyalar | Görev Sayısı |
|-------------|--------|-----------------|--------------|
| Berke Çalta | Backend | `todo-auth-api/` | BE-TASK-7 → BE-TASK-13 |
| Muhammed Sivri | Frontend (UI) | `lib/features/home/`<br>`lib/features/todo/` | FE-UI-10 → FE-UI-18<br>INT-UI-10 → INT-UI-20 |
| Emre Şenel | Frontend (Core) | `lib/core/api/`<br>`lib/core/navigation/` | FE-CORE-16 → FE-CORE-31<br>SM-TASK-05 → SM-TASK-08 |
| Emre Tuncer | Frontend (Data) | `lib/features/todo/data/`<br>`lib/features/social/data/` | FE-DATA-20 → FE-DATA-39<br>PO-TASK-04 → PO-TASK-06 |
| Mharir | Dokümantasyon | `/docs/diagrams/` | DOC-TASK-11 → DOC-TASK-22 |

### Entegrasyon Görevleri

| Task ID | Açıklama | Sorumlu |
|---------|----------|---------|
| INT-TASK-5 | `my_todos_tab.dart`'ı `todo_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-6 | `todo_card.dart`'taki Checkbox/Delete'i `todo_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-7 | `add_todo_screen.dart`'ı `todo_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-8 | `user_profile_screen.dart`'ı `social_provider.getMe()`'ye bağla | Muhammed/Emre T. |

---

## Sprint 4: Sosyal Özellikler

**Tarih:** 19 Kasım - 2 Aralık (2. Prototip Sunumu)  
**Hedef:** Kullanıcı arama, takip etme ve temel bir "Feed" oluşturma.

### Görev Özeti Tablosu

| Atanan Kişi | Katman | İlgili Dosyalar | Görev Sayısı |
|-------------|--------|-----------------|--------------|
| Berke Çalta | Backend | `todo-auth-api/` | BE-TASK-14 → BE-TASK-21 |
| Muhammed Sivri | Frontend (UI) | `lib/features/social/`<br>`lib/features/home/` | FE-UI-19 → FE-UI-25<br>INT-UI-21 → INT-UI-31 |
| Emre Şenel | Frontend (Core) | `lib/core/navigation/` | FE-CORE-32 → FE-CORE-41<br>SM-TASK-09 → SM-TASK-12 |
| Emre Tuncer | Frontend (Data) | `lib/features/social/data/` | FE-DATA-40 → FE-DATA-53<br>PO-TASK-07 → PO-TASK-09 |
| Mharir | Dokümantasyon | `/docs/` | DOC-TASK-23 → DOC-TASK-32 |

### Entegrasyon Görevleri

| Task ID | Açıklama | Sorumlu |
|---------|----------|---------|
| INT-TASK-9 | `add_todo_screen`'deki Switch'i `todo_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-10 | `search_screen.dart`'ı `social_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-11 | `user_profile_screen.dart` (Başkası) `social_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-12 | `feed_tab.dart`'ı `feed_provider`'a bağla | Muhammed/Emre T. |

---

## Sprint 5: Rutinler, Toparlama ve Final

**Tarih:** 3 Aralık - 16 Aralık (Final Sunumu)  
**Hedef:** MVP'nin eksik parçası olan "Rutinler"i eklemek, bug'ları çözmek ve final sunuma hazırlanmak.

### Görev Özeti Tablosu

| Atanan Kişi | Katman | İlgili Dosyalar | Görev Sayısı |
|-------------|--------|-----------------|--------------|
| Berke Çalta | Backend | `todo-auth-api/` | BE-TASK-22 → BE-TASK-24<br>BE-TASK-42 → BE-TASK-48 |
| Muhammed Sivri | Frontend (UI) | `lib/features/routine/`<br>`lib/features/todo/` | FE-UI-26 → FE-UI-29<br>INT-UI-32 → INT-UI-37<br>BUGFIX-UI-01 |
| Emre Şenel | Frontend (Core) | `lib/core/` | FE-CORE-42 → FE-CORE-50<br>SM-TASK-13 → SM-TASK-19 |
| Emre Tuncer | Frontend (Data) | `lib/features/routine/` | FE-DATA-54 → FE-DATA-61<br>PO-TASK-10 → PO-TASK-19 |
| Mharir | Dokümantasyon | `/docs/` | DOC-TASK-33 → DOC-TASK-50 |

### Test & Bugfix Görevleri

| Task ID | Açıklama | Sorumlu |
|---------|----------|---------|
| TEST-TASK-1 | `Test_Cases.md`'deki tüm senaryoları manuel test et | Emre T. & Mharir |
| TEST-TASK-2 | Bulunan hataları Jira'ya "Bug" olarak gir | Emre T. |
| BUGFIX-TASK-1 | Jira'daki Bug'ları öncelik sırasına göre çöz | Tüm Ekip |

### Entegrasyon Görevleri

| Task ID | Açıklama | Sorumlu |
|---------|----------|---------|
| INT-TASK-13 | `add_routine_screen.dart`'ı `routine_provider`'a bağla | Muhammed/Emre T. |
| INT-TASK-14 | `my_todos_tab.dart`'ın birleşik listeyi göstermesini sağla | Muhammed/Emre T. |

---

## Detaylı Görev Listeleri (Kişi Bazlı)

# Emre İlhan Şenel - Detaylı Görev Listesi

## Sprint 2: Temel ve Kimlik Doğrulama

### Scrum Master Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| SM-TASK-01 | Sprint 2 Planlama toplantısını yönet, kararları Jira'ya işle | 22 Ekim |
| SM-TASK-02 | Hafta 1 Daily Scrum toplantılarını yönet | 22-24-26 Ekim |
| SM-TASK-03 | Hafta 2 Daily Scrum toplantılarını yönet | 29-31 Ekim, 2 Kasım |
| SM-TASK-04 | Sprint 2 Review ve Retrospective toplantılarını organize et | 4 Kasım |

### Geliştirici (Core/Integration) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-CORE-01 | `go_router` paketini `pubspec.yaml`'a ekle | `pubspec.yaml` |
| FE-CORE-02 | `flutter_secure_storage` paketini `pubspec.yaml`'a ekle | `pubspec.yaml` |
| FE-CORE-03 | `main.dart` dosyasını `runApp(const MyApp())` içerecek şekilde yapılandır | `main.dart` |
| FE-CORE-04 | `app.dart` dosyasını `MaterialApp.router` kullanacak şekilde oluştur | `app.dart` |
| FE-CORE-05 | `lib/core/navigation/routes.dart` oluştur, rota sabitlerini tanımla | `routes.dart` |
| FE-CORE-06 | `lib/core/navigation/app_router.dart` oluştur, GoRouter yapılandırması | `app_router.dart` |
| FE-CORE-07 | `app_router.dart`'a splash route ekle | `app_router.dart` |
| FE-CORE-08 | `app_router.dart`'a login route ekle | `app_router.dart` |
| FE-CORE-09 | `app_router.dart`'a register route ekle | `app_router.dart` |
| FE-CORE-10 | `app_router.dart`'a home route ekle | `app_router.dart` |
| FE-CORE-11 | `lib/core/services/storage_service.dart` oluştur (saveToken, getToken, deleteToken) | `storage_service.dart` |
| FE-CORE-12 | `splash_screen.dart` dosyasını aç | `splash_screen.dart` |
| FE-CORE-13 | `splash_screen.dart`'a `storage_service.getToken()` çağrısı ekle | `splash_screen.dart` |
| FE-CORE-14 | Token kontrol logic'ini yaz (null ise login, değilse home) | `splash_screen.dart` |
| FE-CORE-15 | "Kayıt Ol'a Git" butonuna `context.push(AppRoutes.register)` bağla | `login_screen.dart` |

## Sprint 3: Görev Yönetimi (CRUD) & Profil

### Scrum Master Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| SM-TASK-05 | Sprint 3 Planlama toplantısını yönet | 5 Kasım |
| SM-TASK-06 | Hafta 3 Daily Scrum toplantılarını yönet | 6-8-10 Kasım |
| SM-TASK-07 | Hafta 4 Daily Scrum toplantılarını yönet | 13-15-17 Kasım |
| SM-TASK-08 | Sprint 3 Review (1. Prototip) ve Retrospective organize et | 18 Kasım |

### Geliştirici (Core/Integration) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-CORE-16 | `dio` paketinin `pubspec.yaml`'da olduğunu doğrula | `pubspec.yaml` |
| FE-CORE-17 | `lib/core/api/api_interceptor.dart` oluştur | `api_interceptor.dart` |
| FE-CORE-18 | `AuthInterceptor` sınıfını yaz (Dio Interceptor extend) | `api_interceptor.dart` |
| FE-CORE-19 | `AuthInterceptor`'da `onRequest` metodunu override et | `api_interceptor.dart` |
| FE-CORE-20 | `onRequest`'e `storage_service.getToken()` çağrısı ekle | `api_interceptor.dart` |
| FE-CORE-21 | Token null değilse Authorization header ekle | `api_interceptor.dart` |
| FE-CORE-22 | Emre T.'nin `api_service.dart`'ına `.interceptors.add(AuthInterceptor())` ekle | `api_service.dart` |
| FE-CORE-23 | `routes.dart`'a `myProfile = '/profile'` rotası ekle | `routes.dart` |
| FE-CORE-24 | `app_router.dart`'a `myProfile` GoRoute tanımı ekle | `app_router.dart` |
| FE-CORE-25 | BottomNavigationBar "Profil" ikonuna `context.go(AppRoutes.myProfile)` bağla | `home_screen.dart` |
| FE-CORE-26 | `routes.dart`'a `addTodo = '/add-todo'` rotası ekle | `routes.dart` |
| FE-CORE-27 | `app_router.dart`'a `addTodo` GoRoute tanımı ekle | `app_router.dart` |
| FE-CORE-28 | FAB'ın `onPressed`'ine `context.push(AppRoutes.addTodo)` bağla | `home_screen.dart` |
| FE-CORE-29 | "Çıkış Yap" butonunun `onPressed` eylemini bul | `user_profile_screen.dart` |
| FE-CORE-30 | `storage_service.deleteToken()` çağır | `user_profile_screen.dart` |
| FE-CORE-31 | `context.go(AppRoutes.login)` ile login'e yönlendir | `user_profile_screen.dart` |

## Sprint 4: Sosyal Özellikler

### Scrum Master Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| SM-TASK-09 | Sprint 4 Planlama toplantısını yönet | 19 Kasım |
| SM-TASK-10 | Hafta 5 Daily Scrum toplantılarını yönet | 20-22-24 Kasım |
| SM-TASK-11 | Hafta 6 Daily Scrum toplantılarını yönet | 27-29 Kasım, 1 Aralık |
| SM-TASK-12 | Sprint 4 Review (2. Prototip) ve Retrospective organize et | 2 Aralık |

### Geliştirici (Core/Integration) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-CORE-32 | `routes.dart`'a `search = '/search'` rotası ekle | `routes.dart` |
| FE-CORE-33 | `app_router.dart`'a `search` GoRoute tanımı ekle | `app_router.dart` |
| FE-CORE-34 | BottomNavBar "Arama" ikonuna `context.go(AppRoutes.search)` bağla | `home_screen.dart` |
| FE-CORE-35 | `routes.dart`'a `userProfile = '/user/:username'` dinamik rotası ekle | `routes.dart` |
| FE-CORE-36 | `app_router.dart`'a `userProfile` GoRoute tanımı ekle | `app_router.dart` |
| FE-CORE-37 | Route builder'da `state.params['username']` ile username al | `app_router.dart` |
| FE-CORE-38 | `UserProfileScreen(username: username)` çağrısı yap | `app_router.dart` |
| FE-CORE-39 | `myProfile` route'unu `UserProfileScreen(username: null)` çağıracak şekilde güncelle | `app_router.dart` |
| FE-CORE-40 | `search_screen.dart`'taki arama sonuçları `onTap` eylemini bul | `search_screen.dart` |
| FE-CORE-41 | `context.push('/user/$username')` dinamik yönlendirme bağla | `search_screen.dart` |

## Sprint 5: Rutinler, Toparlama ve Final

### Scrum Master Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| SM-TASK-13 | Sprint 5 Planlama toplantısını yönet | 3 Aralık |
| SM-TASK-14 | Hafta 7 Daily Scrum toplantılarını yönet | 4-6-8 Aralık |
| SM-TASK-15 | Hafta 8 Daily Scrum toplantılarını yönet | 11-13-15 Aralık |
| SM-TASK-16 | Final Sunum ve Final Retrospective organize et | 16 Aralık |
| SM-TASK-17 | Final Raporu'nu gözden geçir, Scrum kısımlarını onayla | - |
| SM-TASK-18 | Demo Senaryosu yaz (Kayıt → Rutin → Feed akışı) | - |
| SM-TASK-19 | Final Sunum Slaytlarını hazırla | - |

### Geliştirici (Core/Integration) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-CORE-42 | `routes.dart`'a `addRoutine = '/add-routine'` rotası ekle | `routes.dart` |
| FE-CORE-43 | `app_router.dart`'a `addRoutine` GoRoute tanımı ekle | `app_router.dart` |
| FE-CORE-44 | FAB'ı bul (SpeedDial/PopupMenu) | `home_screen.dart` |
| FE-CORE-45 | "Rutin Ekle" seçeneğine `context.push(AppRoutes.addRoutine)` bağla | `home_screen.dart` |
| FE-CORE-46 | "Görev Ekle"nin hala çalıştığını doğrula (regresyon testi) | `home_screen.dart` |
| FE-CORE-47 | Jira'da "Core/Navigation/Auth" etiketli Bug'ları filtrele | Jira |
| FE-CORE-48 | `app_router.dart` hatalarını çöz | `app_router.dart` |
| FE-CORE-49 | `storage_service.dart` / `api_interceptor.dart` hatalarını çöz | - |
| FE-CORE-50 | `app_router.dart` refactor, kod tekrarını temizle | `app_router.dart` |

---

# Emre Tuncer - Detaylı Görev Listesi

## Sprint 2: Temel ve Kimlik Doğrulama

### Product Owner (PO) Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| PO-TASK-01 | Sprint 2 Planlama'ya katıl, Sprint Hedefi'ni onayla | 22 Ekim |
| PO-TASK-02 | Mharir'in URD'sini incele, Kabul Kriterleri onayla | - |
| PO-TASK-03 | Sprint 2 Review'u yönet, AUTH story'lerini test et | 4 Kasım |

### Geliştirici (Data/State) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-DATA-01 | `dio` paketini `pubspec.yaml`'a ekle | `pubspec.yaml` |
| FE-DATA-02 | State management paketini ekle (riverpod/provider) | `pubspec.yaml` |
| FE-DATA-03 | `lib/core/api/api_constants.dart` oluştur, baseUrl tanımla | `api_constants.dart` |
| FE-DATA-04 | `lib/core/api/api_service.dart` oluştur, temel Dio client | `api_service.dart` |
| FE-DATA-05 | `auth_response_model.dart` oluştur (token içeren) | `auth_response_model.dart` |
| FE-DATA-06 | `user_model.dart` oluştur (id, username, email) | `user_model.dart` |
| FE-DATA-07 | `auth_repository.dart` oluştur | `auth_repository.dart` |
| FE-DATA-08 | Repository'ye Dio client ve StorageService enjekte et | `auth_repository.dart` |
| FE-DATA-09 | `login(email, password)` fonksiyonunu yaz | `auth_repository.dart` |
| FE-DATA-10 | Login fonksiyonunda `dio.post('/auth/login')` çağrısı yap | `auth_repository.dart` |
| FE-DATA-11 | API cevabını parse et, token'ı `storageService.saveToken()` ile kaydet | `auth_repository.dart` |
| FE-DATA-12 | API hatalarını try-catch ile yakala, Exception fırlat | `auth_repository.dart` |
| FE-DATA-13 | `register(username, email, password)` fonksiyonunu yaz | `auth_repository.dart` |
| FE-DATA-14 | `auth_provider.dart` oluştur (ChangeNotifier/StateNotifier) | `auth_provider.dart` |
| FE-DATA-15 | `isLoading`, `errorMessage` state değişkenleri ekle | `auth_provider.dart` |
| FE-DATA-16 | `loginUser(email, pass)` fonksiyonu ekle, repository çağır | `auth_provider.dart` |
| FE-DATA-17 | `registerUser(...)` fonksiyonu ekle | `auth_provider.dart` |
| FE-DATA-18 | Emre Ş. ile koordine et, `ProviderScope` eklensin | `app.dart` |
| FE-DATA-19 | Muhammed'e provider kullanımını tarif et | - |

## Sprint 3: Görev Yönetimi (CRUD) & Profil

### Product Owner (PO) Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| PO-TASK-04 | Sprint 3 Planlama'yı yönet, TODO-1 ve SOCIAL-1 önceliklerini belirle | 5 Kasım |
| PO-TASK-05 | Haftada 2 kez dev branch'i kontrol et | - |
| PO-TASK-06 | Sprint 3 Review'u yönet, CRUD özelliklerini test et | 18 Kasım |

### Geliştirici (Data/State) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-DATA-20 | Emre Ş.'nin AuthInterceptor'ı eklediğinden emin ol | - |
| FE-DATA-21 | `todo_model.dart` oluştur (API_CONTRACT'a göre) | `todo_model.dart` |
| FE-DATA-22 | `todo_repository.dart` oluştur (Dio enjekte et) | `todo_repository.dart` |
| FE-DATA-23 | `getMyTodos()` fonksiyonunu yaz (GET /todos/mytodos) | `todo_repository.dart` |
| FE-DATA-24 | `addTodo(title, description)` fonksiyonunu yaz | `todo_repository.dart` |
| FE-DATA-25 | `updateTodoStatus(todoId, isCompleted)` fonksiyonunu yaz | `todo_repository.dart` |
| FE-DATA-26 | `deleteTodo(todoId)` fonksiyonunu yaz | `todo_repository.dart` |
| FE-DATA-27 | `todo_provider.dart` oluştur | `todo_provider.dart` |
| FE-DATA-28 | `List<TodoModel> todos`, `isLoading` state'leri ekle | `todo_provider.dart` |
| FE-DATA-29 | `fetchMyTodos()` fonksiyonu ekle | `todo_provider.dart` |
| FE-DATA-30 | `createTodo(title, desc)` fonksiyonu ekle | `todo_provider.dart` |
| FE-DATA-31 | `toggleTodo(todoId, newStatus)` fonksiyonu ekle | `todo_provider.dart` |
| FE-DATA-32 | `removeTodo(todoId)` fonksiyonu ekle | `todo_provider.dart` |
| FE-DATA-33 | `social_repository.dart` oluştur | `social_repository.dart` |
| FE-DATA-34 | `getMe()` fonksiyonunu yaz (GET /users/me) | `social_repository.dart` |
| FE-DATA-35 | `social_provider.dart` oluştur | `social_provider.dart` |
| FE-DATA-36 | `UserModel? myProfile`, `isLoadingProfile` state'leri ekle | `social_provider.dart` |
| FE-DATA-37 | `fetchMyProfile()` fonksiyonu ekle | `social_provider.dart` |
| FE-DATA-38 | Muhammed'e `my_todos_tab.dart`'ta provider kullanımını tarif et | - |
| FE-DATA-39 | Muhammed'e `user_profile_screen.dart`'ta provider kullanımını tarif et | - |

## Sprint 4: Sosyal Özellikler

### Product Owner (PO) Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| PO-TASK-07 | Sprint 4 Planlama'yı yönet, SOCIAL-2 to SOCIAL-6 story'lerini netleştir | 19 Kasım |
| PO-TASK-08 | Sprint ortası Backlog Grooming yap, Sprint 5 ROUTINE detaylarını netleştir | ~25 Kasım |
| PO-TASK-09 | Sprint 4 Review'u yönet, Sosyal özellikleri test et | 2 Aralık |

### Geliştirici (Data/State) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-DATA-40 | `addTodo` fonksiyonunu `bool isPublic` alacak şekilde güncelle | `todo_repository.dart` |
| FE-DATA-41 | `createTodo` fonksiyonunu `isPublic` alacak şekilde güncelle | `todo_provider.dart` |
| FE-DATA-42 | `searchUsers(query)` fonksiyonunu ekle | `social_repository.dart` |
| FE-DATA-43 | `user_profile_model.dart` oluştur (publicTodos, isFollowing içermeli) | `user_profile_model.dart` |
| FE-DATA-44 | `getUserProfile(username)` fonksiyonunu ekle | `social_repository.dart` |
| FE-DATA-45 | `followUser(userId)` fonksiyonunu ekle | `social_repository.dart` |
| FE-DATA-46 | `unfollowUser(userId)` fonksiyonunu ekle | `social_repository.dart` |
| FE-DATA-47 | `getFeed()` fonksiyonunu ekle (GET /feed) | `social_repository.dart` |
| FE-DATA-48 | `social_provider`'ı güncelle: `searchResults`, `currentViewedProfile` ekle | `social_provider.dart` |
| FE-DATA-49 | `search(query)` fonksiyonu ekle | `social_provider.dart` |
| FE-DATA-50 | `fetchUserProfile(username)` fonksiyonu ekle | `social_provider.dart` |
| FE-DATA-51 | `toggleFollow()` fonksiyonu ekle (follow/unfollow logic) | `social_provider.dart` |
| FE-DATA-52 | `feed_provider.dart` oluştur | `feed_provider.dart` |
| FE-DATA-53 | `fetchFeed()` fonksiyonu ve `feedItems` state'i ekle | `feed_provider.dart` |

## Sprint 5: Rutinler, Toparlama ve Final

### Product Owner (PO) Görevleri

| Task ID | Açıklama | Tarih |
|---------|----------|-------|
| PO-TASK-10 | Sprint 5 Planlama'yı yönet, ROUTINE-1, TEST-1, TECH-1 odaklan | 3 Aralık |
| PO-TASK-11 | Mharir'den `Test_Cases.md` dokümanını al | - |
| PO-TASK-12 | Uygulamayı sıfırdan test et (Kayıt, Giriş) | - |
| PO-TASK-13 | CRUD akışlarını test et (Görev Ekle, Tamamla, Sil) | - |
| PO-TASK-14 | Sosyal akışları test et (Ara, Takip Et, Çık) | - |
| PO-TASK-15 | Feed sayfasını kontrol et (sadece takip edilenler mi?) | - |
| PO-TASK-16 | Her hatayı Jira'ya "Bug" olarak gir, ilgili kişiyi etiketle | - |
| PO-TASK-17 | "Fixed" Bug'ları tekrar test et, onayla | - |
| PO-TASK-18 | Final öncesi Demo Senaryosu'nu çalıştır | - |
| PO-TASK-19 | Sprint 5 Review'da projeyi "Tamamlandı" onayla | 16 Aralık |

### Geliştirici (Data/State) Görevleri

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-DATA-54 | `routine_model.dart` oluştur (API_CONTRACT'a göre) | `routine_model.dart` |
| FE-DATA-55 | `routine_repository.dart` oluştur | `routine_repository.dart` |
| FE-DATA-56 | `addRoutine(...)` fonksiyonunu ekle | `routine_repository.dart` |
| FE-DATA-57 | `getMyTodos()`'un Todo+Routine birleşik döndürdüğünü doğrula | `todo_repository.dart` |
| FE-DATA-58 | `task_item_model.dart` ortak yapı oluştur (abstract/enum) | `task_item_model.dart` |
| FE-DATA-59 | `routine_provider.dart` oluştur, `createRoutine()` ekle | `routine_provider.dart` |
| FE-DATA-60 | `todo_provider`'ı TaskItemModel listesi tutacak şekilde refactor et | `todo_provider.dart` |
| FE-DATA-61 | Data/providers katmanındaki Bug'ları çöz | - |

---

# Muhammed Sivri - Detaylı Görev Listesi

## Sprint 2: Temel ve Kimlik Doğrulama

### Faz 1: Statik UI Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-UI-01 | `app_colors.dart` oluştur, ana renkleri tanımla | `app_colors.dart` |
| FE-UI-02 | `app_theme.dart` oluştur, ThemeData tanımla | `app_theme.dart` |
| FE-UI-03 | `custom_textfield.dart` oluştur (TextFormField wrapper) | `custom_textfield.dart` |
| FE-UI-04 | `custom_button.dart` oluştur (ElevatedButton wrapper) | `custom_button.dart` |
| FE-UI-05 | `splash_screen.dart` oluştur (logo/CircularProgressIndicator) | `splash_screen.dart` |
| FE-UI-06 | `login_screen.dart` oluştur | `login_screen.dart` |
| FE-UI-07 | `login_screen`'e 2 CustomTextField, 1 CustomButton, 1 TextButton ekle | `login_screen.dart` |
| FE-UI-08 | `register_screen.dart` oluştur | `register_screen.dart` |
| FE-UI-09 | `register_screen`'e 4 CustomTextField, 1 CustomButton, dön butonu ekle | `register_screen.dart` |

### Faz 2: Entegrasyon (Koordineli)

| Task ID | Açıklama | Dosya | Bağımlılık |
|---------|----------|-------|------------|
| INT-UI-01 | Emre Ş.'nin `AppRoutes.register` tanımlamasını bekle | - | FE-CORE-09 |
| INT-UI-02 | "Kayıt Ol" butonuna `context.push(AppRoutes.register)` bağla | `login_screen.dart` | FE-CORE-09 |
| INT-UI-03 | Emre T.'nin `auth_provider.dart` tamamlamasını bekle | - | FE-DATA-14 |
| INT-UI-04 | `login_screen.dart`'ı ConsumerWidget yap | `login_screen.dart` | - |
| INT-UI-05 | `ref.watch(authProvider)` ile state'i dinle | `login_screen.dart` | - |
| INT-UI-06 | CustomButton'a `loginUser()` fonksiyonunu bağla | `login_screen.dart` | FE-DATA-16 |
| INT-UI-07 | `isLoading` durumuna göre CircularProgressIndicator ekle | `login_screen.dart` | - |
| INT-UI-08 | `errorMessage` null değilse hata mesajı göster | `login_screen.dart` | - |
| INT-UI-09 | `register_screen.dart` için INT-UI-04 to 08 adımlarını tekrarla | `register_screen.dart` | FE-DATA-17 |

## Sprint 3: Görev Yönetimi (CRUD) & Profil

### Faz 1: Statik UI Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-UI-10 | `home_screen.dart` oluştur (Scaffold, AppBar, BottomNavBar, PageView) | `home_screen.dart` |
| FE-UI-11 | `my_todos_tab.dart` oluştur (PageView'in ilk sayfası) | `my_todos_tab.dart` |
| FE-UI-12 | `todo_card.dart` oluştur (widget) | `todo_card.dart` |
| FE-UI-13 | `todo_card`'ı ListTile benzeri tasarla (Checkbox, Text, IconButton) | `todo_card.dart` |
| FE-UI-14 | `my_todos_tab`'a dummy data ile ListView.builder ekle | `my_todos_tab.dart` |
| FE-UI-15 | `add_todo_screen.dart` oluştur (tam sayfa/modal) | `add_todo_screen.dart` |
| FE-UI-16 | `add_todo_screen`'e 2 CustomTextField, 1 CustomButton ekle | `add_todo_screen.dart` |
| FE-UI-17 | `user_profile_screen.dart` oluştur | `user_profile_screen.dart` |
| FE-UI-18 | "Benim Profilim" modu tasarla (username, email, Çıkış butonu) | `user_profile_screen.dart` |

### Faz 2: Entegrasyon (Koordineli)

| Task ID | Açıklama | Dosya | Bağımlılık |
|---------|----------|-------|------------|
| INT-UI-10 | Emre Ş.'nin rotaları tanımlamasını bekle | - | FE-CORE-24, 27 |
| INT-UI-11 | BottomNavBar "Profil" ikonuna rota bağla | `home_screen.dart` | FE-CORE-25 |
| INT-UI-12 | FAB ekle, `addTodo` rotasını bağla | `home_screen.dart` | FE-CORE-28 |
| INT-UI-13 | Emre T.'nin provider'ları bekle | - | FE-DATA-27, 35 |
| INT-UI-14 | `my_todos_tab`'ı ConsumerWidget yap, `fetchMyTodos()` tetikle | `my_todos_tab.dart` | FE-DATA-29 |
| INT-UI-15 | `ref.watch(todoProvider).todos` ile listeyi dinle | `my_todos_tab.dart` | FE-DATA-28 |
| INT-UI-16 | Checkbox.onChanged'e `toggleTodo()` bağla | `todo_card.dart` | FE-DATA-31 |
| INT-UI-17 | IconButton.onPressed'e `removeTodo()` bağla | `todo_card.dart` | FE-DATA-32 |
| INT-UI-18 | "Kaydet" butonuna `createTodo()` bağla, sonra `context.pop()` | `add_todo_screen.dart` | FE-DATA-30 |
| INT-UI-19 | `user_profile_screen`'de `fetchMyProfile()` tetikle, veriyi göster | `user_profile_screen.dart` | FE-DATA-37 |
| INT-UI-20 | "Çıkış" butonuna `logoutUser()` bağla | `user_profile_screen.dart` | FE-CORE-30, 31 |

## Sprint 4: Sosyal Özellikler

### Faz 1: Statik UI Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-UI-19 | `home_screen`'i TabBar (Görevlerim, Akış) içerecek şekilde güncelle | `home_screen.dart` |
| FE-UI-20 | `feed_tab.dart` oluştur | `feed_tab.dart` |
| FE-UI-21 | `social_todo_card.dart` oluştur (@username ile) | `social_todo_card.dart` |
| FE-UI-22 | `feed_tab`'a dummy data ile `social_todo_card` listesi ekle | `feed_tab.dart` |
| FE-UI-23 | `search_screen.dart` oluştur (arama kutusu, sonuç listesi) | `search_screen.dart` |
| FE-UI-24 | `user_profile_screen`'i "Başkası" modu için güncelle (Takip Et, public todos) | `user_profile_screen.dart` |
| FE-UI-25 | `add_todo_screen`'e "Herkese Açık" Switch ekle | `add_todo_screen.dart` |

### Faz 2: Entegrasyon (Koordineli)

| Task ID | Açıklama | Dosya | Bağımlılık |
|---------|----------|-------|------------|
| INT-UI-21 | Switch'i `createTodo(..., isPublic: switchValue)` ile bağla | `add_todo_screen.dart` | FE-DATA-41 |
| INT-UI-22 | Emre T.'nin `feed_provider` bekle | - | FE-DATA-52 |
| INT-UI-23 | `feed_tab`'da `fetchFeed()` tetikle, `feedItems` dinle | `feed_tab.dart` | FE-DATA-53 |
| INT-UI-24 | Emre T.'nin `social_provider` güncellemesini bekle | - | FE-DATA-48 |
| INT-UI-25 | TextField.onChanged'e `search(query)` bağla | `search_screen.dart` | FE-DATA-49 |
| INT-UI-26 | `searchResults` dinle, ListView'a bağla | `search_screen.dart` | - |
| INT-UI-27 | Emre Ş.'nin dinamik rota tanımını bekle | - | FE-CORE-36 |
| INT-UI-28 | ListTile.onTap'e `context.push('/user/$username')` bağla | `search_screen.dart` | FE-CORE-41 |
| INT-UI-29 | `user_profile_screen` initState'de `fetchUserProfile()` tetikle | `user_profile_screen.dart` | FE-DATA-50 |
| INT-UI-30 | `currentViewedProfile` dinle, verileri göster | `user_profile_screen.dart` | - |
| INT-UI-31 | "Takip Et" butonuna `toggleFollow()` bağla, dinamik metin | `user_profile_screen.dart` | FE-DATA-51 |

## Sprint 5: Rutinler, Toparlama ve Final

### Faz 1: Statik UI Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| FE-UI-26 | `add_routine_screen.dart` oluştur | `add_routine_screen.dart` |
| FE-UI-27 | Rutin formunu tasarla (TextField, Switch, DropdownButton/ToggleButtons) | `add_routine_screen.dart` |
| FE-UI-28 | `my_todos_tab`'ı Todo/Rutin ayırt edecek şekilde güncelle (farklı ikon) | `my_todos_tab.dart` |
| FE-UI-29 | FAB'ı SpeedDial/PopupMenu'ye dönüştür (2 seçenek) | `home_screen.dart` |

### Faz 2: Entegrasyon (Koordineli)

| Task ID | Açıklama | Dosya | Bağımlılık |
|---------|----------|-------|------------|
| INT-UI-32 | Emre Ş.'nin `addRoutine` rotasını bekle | - | FE-CORE-43 |
| INT-UI-33 | "Rutin Ekle" seçeneğine rota bağla | `home_screen.dart` | FE-CORE-45 |
| INT-UI-34 | Emre T.'nin `routine_provider` bekle | - | FE-DATA-59 |
| INT-UI-35 | "Kaydet" butonuna `createRoutine()` bağla | `add_routine_screen.dart` | - |
| INT-UI-36 | Emre T.'nin `todo_provider` güncellemesini bekle | - | FE-DATA-60 |
| INT-UI-37 | `my_todos_tab`'ı birleşik listeyi dinleyecek şekilde güncelle | `my_todos_tab.dart` | - |
| BUGFIX-UI-01 | Jira'da "UI/Presentation" etiketli Bug'ları çöz | - | - |

---

# Berke Çalta - Detaylı Görev Listesi

## Sprint 2: Temel ve Kimlik Doğrulama

### Faz 1: API Sözleşmesi (Liderlik)

| Task ID | Açıklama | Çıktı |
|---------|----------|-------|
| BE-CONTRACT-01 | Emre T. ile toplantı, `API_CONTRACT.md` oluştur | `API_CONTRACT.md` |
| BE-CONTRACT-02 | User modeli DB şeması tanımla (id, username, email, password_hash, created_at) | `API_CONTRACT.md` |
| BE-CONTRACT-03 | POST /api/auth/register req/res yapılarını tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-04 | POST /api/auth/login req/res yapılarını tanımla | `API_CONTRACT.md` |

### Faz 2: Backend Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya/Komut |
|---------|----------|-------------|
| BE-TASK-01 | npm init, paketleri kur (express, mysql2, sequelize, bcryptjs, jsonwebtoken, cors, dotenv) | `package.json` |
| BE-TASK-02 | `index.js` oluştur, Express sunucusu kur, cors ve json middleware ekle | `index.js` |
| BE-TASK-03 | `config/db.js` oluştur, MySQL bağlantısı yap (.env'den oku) | `config/db.js` |
| BE-TASK-04 | `models/user.model.js` oluştur, User modelini Sequelize ile tanımla | `user.model.js` |
| BE-TASK-05 | `db.sync()` ekle, users tablosu oluştur | `index.js` |
| BE-TASK-06 | `routes/auth.routes.js` oluştur, POST /register ve /login route'ları tanımla | `auth.routes.js` |
| BE-TASK-07 | `controllers/auth.controller.js` oluştur, register ve login fonksiyonları | `auth.controller.js` |
| BE-TASK-08 | `register` fonksiyonunu kodla (email kontrolü, hash, User.create, 201) | `auth.controller.js` |
| BE-TASK-09 | `utils/jwt.js` oluştur, `generateToken(userId)` fonksiyonu yaz | `jwt.js` |
| BE-TASK-10 | `login` fonksiyonunu kodla (User.findOne, bcrypt.compare, generateToken, 200) | `auth.controller.js` |
| BE-TASK-11 | `index.js`'e `app.use('/api/auth', authRoutes)` ekle | `index.js` |
| BE-TASK-12 | Postman ile /register ve /login test et | Postman |

## Sprint 3: Görev Yönetimi (CRUD) & Profil

### Faz 1: API Sözleşmesi (Güncelleme)

| Task ID | Açıklama | Çıktı |
|---------|----------|-------|
| BE-CONTRACT-05 | Todo modeli şeması tanımla (id, title, description, is_completed, created_at, user_id) | `API_CONTRACT.md` |
| BE-CONTRACT-06 | GET /api/todos/mytodos endpoint tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-07 | POST /api/todos endpoint tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-08 | PATCH /api/todos/:id endpoint tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-09 | DELETE /api/todos/:id endpoint tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-10 | GET /api/users/me endpoint tanımla (şifre hash'i olmadan) | `API_CONTRACT.md` |

### Faz 2: Backend Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| BE-TASK-13 | `middleware/auth.middleware.js` oluştur | `auth.middleware.js` |
| BE-TASK-14 | Authorization header oku, JWT doğrula | `auth.middleware.js` |
| BE-TASK-15 | Token geçerliyse `req.user = { id: userId }`, değilse 401 | `auth.middleware.js` |
| BE-TASK-16 | `models/todo.model.js` oluştur | `todo.model.js` |
| BE-TASK-17 | User-Todo ilişkisi kur (hasMany/belongsTo) | `todo.model.js` |
| BE-TASK-18 | `db.sync()` todos tablosunu oluşturduğunu doğrula | - |
| BE-TASK-19 | `routes/todo.routes.js` oluştur (CRUD route'ları) | `todo.routes.js` |
| BE-TASK-20 | `controllers/todo.controller.js` oluştur | `todo.controller.js` |
| BE-TASK-21 | `createTodo` fonksiyonu yaz (POST /todos, req.user.id kullan) | `todo.controller.js` |
| BE-TASK-22 | `getMyTodos` fonksiyonu yaz (GET /mytodos, sadece user'a ait) | `todo.controller.js` |
| BE-TASK-23 | `updateTodo` ve `deleteTodo` fonksiyonlarını yaz | `todo.controller.js` |
| BE-TASK-24 | **KRİTİK:** Update/Delete'te `todo.userId !== req.user.id` kontrolü ekle (403) | `todo.controller.js` |
| BE-TASK-25 | `routes/user.routes.js` oluştur | `user.routes.js` |
| BE-TASK-26 | `controllers/user.controller.js` oluştur | `user.controller.js` |
| BE-TASK-27 | `getMe` fonksiyonu yaz (GET /users/me, şifre hash'i hariç) | `user.controller.js` |
| BE-TASK-28 | `index.js`'e middleware'li route'ları ekle | `index.js` |
| BE-TASK-29 | Postman'de token ile tüm endpoint'leri test et | Postman |

## Sprint 4: Sosyal Özellikler

### Faz 1: API Sözleşmesi (Güncelleme)

| Task ID | Açıklama | Çıktı |
|---------|----------|-------|
| BE-CONTRACT-11 | Todo modeline `is_public` (Boolean) sütunu ekle | `API_CONTRACT.md` |
| BE-CONTRACT-12 | Followers tablosu tanımla (id, follower_id, following_id) | `API_CONTRACT.md` |
| BE-CONTRACT-13 | GET /api/users/search?q=[query] tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-14 | GET /api/users/profile/:username tanımla (user + publicTodos + isFollowing) | `API_CONTRACT.md` |
| BE-CONTRACT-15 | POST /api/users/follow/:userId tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-16 | DELETE /api/users/unfollow/:userId tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-17 | GET /api/feed tanımla (takip edilenlerin public todoları) | `API_CONTRACT.md` |

### Faz 2: Backend Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| BE-TASK-30 | Todo modeline `is_public` sütunu ekle | `todo.model.js` |
| BE-TASK-31 | `models/follower.model.js` oluştur | `follower.model.js` |
| BE-TASK-32 | User self many-to-many ilişkisi kur (Followers tablosu üzerinden) | `user.model.js` |
| BE-TASK-33 | `db.sync()` yeni sütun ve followers tablosunu doğrula | - |
| BE-TASK-34 | `createTodo`/`updateTodo`'yu `is_public` alacak şekilde güncelle | `todo.controller.js` |
| BE-TASK-35 | `searchUsers` fonksiyonu ekle (GET /users/search, LIKE sorgusu) | `user.controller.js` |
| BE-TASK-36 | `getUserProfile` fonksiyonu ekle (username'e göre user + publicTodos + isFollowing) | `user.controller.js` |
| BE-TASK-37 | `followUser` fonksiyonu ekle (POST /follow/:userId, Follower.create) | `user.controller.js` |
| BE-TASK-38 | `unfollowUser` fonksiyonu ekle (DELETE /unfollow/:userId, Follower.destroy) | `user.controller.js` |
| BE-TASK-39 | `routes/feed.routes.js` ve `controllers/feed.controller.js` oluştur | - |
| BE-TASK-40 | **KRİTİK:** `getFeed` fonksiyonu yaz (3 adım: followingIds al, JOIN query yaz, order DESC) | `feed.controller.js` |
| BE-TASK-41 | Postman'de 2-3 kullanıcı oluştur, takip et, public/private görev ekle, /feed test et | Postman |

## Sprint 5: Rutinler, Toparlama ve Final

### Faz 1: API Sözleşmesi (Güncelleme)

| Task ID | Açıklama | Çıktı |
|---------|----------|-------|
| BE-CONTRACT-18 | Routine modeli tanımla (id, user_id, title, description, is_public, recurrence_type, recurrence_value) | `API_CONTRACT.md` |
| BE-CONTRACT-19 | POST /api/routines tanımla | `API_CONTRACT.md` |
| BE-CONTRACT-20 | GET /api/todos/mytodos güncelleme: birleşik liste (type: 'todo'/'routine') | `API_CONTRACT.md` |

### Faz 2: Backend Geliştirme (Bağımsız)

| Task ID | Açıklama | Dosya |
|---------|----------|-------|
| BE-TASK-42 | `models/routine.model.js` oluştur, User ilişkisi kur | `routine.model.js` |
| BE-TASK-43 | `db.sync()` routines tablosunu doğrula | - |
| BE-TASK-44 | `routes/routine.routes.js` ve `controllers/routine.controller.js` oluştur | - |
| BE-TASK-45 | `createRoutine` fonksiyonu yaz (POST /routines) | `routine.controller.js` |
| BE-TASK-46 | **KRİTİK:** `getMyTodos` refactor (6 adım: todos al, routines al, bugünü bul, filtrele, birleştir, döndür) | `todo.controller.js` |
| BE-TASK-47 | Postman ile 2 görev + 3 rutin ekle, GET /mytodos test et (type etiketi kontrol) | Postman |
| BE-TASK-48 | Jira'da "Backend" etiketli Bug'ları çöz | - |

---

# Mharir - Detaylı Görev Listesi

## Sprint 2: Temel ve Kimlik Doğrulama

| Task ID | Açıklama | Çıktı | Tarih |
|---------|----------|-------|-------|
| DOC-TASK-01 | Sprint 2 Planlama organize et, davet gönder | Google Calendar | 22 Ekim |
| DOC-TASK-02 | Sprint 2 Planlama'yı kaydet, Google Drive'a yükle | Video kaydı | 22 Ekim |
| DOC-TASK-03 | Campagnify URD bölümünü incele, formatı anla | - | - |
| DOC-TASK-04 | `/docs/User_Requirement_Document.md` oluştur | `URD.md` | - |
| DOC-TASK-05 | Emre T. ile 30dk toplantı ayarla | - | - |
| DOC-TASK-06 | "Fonksiyonel Gereksinimleri" listele, URD'ye yaz | `URD.md` | - |
| DOC-TASK-07 | "Fonksiyonel Olmayan Gereksinimleri" listele, URD'ye yaz | `URD.md` | - |
| DOC-TASK-08 | URD'yi tamamla, GitHub'a push et | `URD.md` | - |
| DOC-TASK-09 | Sprint 2 Review ve Retrospective davetleri gönder | Google Calendar | 4 Kasım |
| DOC-TASK-10 | Daily Scrum kayıtlarını topla (en az 2-3 adet) | Ekran görüntüleri | - |

## Sprint 3: Görev Yönetimi (CRUD) & Profil

| Task ID | Açıklama | Çıktı | Tarih |
|---------|----------|-------|-------|
| DOC-TASK-11 | Sprint 3 Planlama organize et, kaydını al | Video kaydı | 5 Kasım |
| DOC-TASK-12 | Campagnify Use Case ve Sequence Diagram'larını incele | - | - |
| DOC-TASK-13 | Diyagram aracı seç (draw.io/Lucidchart/Figma) | - | - |
| DOC-TASK-14 | "Kullanıcı Doğrulama" Use Case Diyagramı çiz | PNG | - |
| DOC-TASK-15 | "Görev Yönetimi" Use Case Diyagramı çiz | PNG | - |
| DOC-TASK-16 | "Kullanıcı Girişi Başarılı" Sequence Diyagramı çiz | PNG | - |
| DOC-TASK-17 | "Yeni Görev Ekleme" Sequence Diyagramı çiz | PNG | - |
| DOC-TASK-18 | Tüm diyagramları `/docs/diagrams/`'a kaydet, push et | PNG dosyaları | - |
| DOC-TASK-19 | `/docs/reports/Prototype_1_Report.md` oluştur | `Prototype_1_Report.md` | - |
| DOC-TASK-20 | Rapora "Giriş" yaz, URD özetle, diyagramları ekle | `Prototype_1_Report.md` | - |
| DOC-TASK-21 | PO/SM'den Login ve Todo ekran görüntülerini al, rapora ekle | `Prototype_1_Report.md` | 17-18 Kasım |
| DOC-TASK-22 | Sprint 3 Review (1. Prototip) ve Retrospective organize et, kaydet | Video kaydı | 18 Kasım |

## Sprint 4: Sosyal Özellikler

| Task ID | Açıklama | Çıktı | Tarih |
|---------|----------|-------|-------|
| DOC-TASK-23 | Sprint 4 Planlama organize et, kaydını al | Video kaydı | 19 Kasım |
| DOC-TASK-24 | "Sosyal Etkileşim" Use Case Diyagramı çiz | PNG | - |
| DOC-TASK-25 | "Kullanıcı Takip Etme" Sequence Diyagramı çiz | PNG | - |
| DOC-TASK-26 | Campagnify Test Cases formatını detaylıca incele | - | - |
| DOC-TASK-27 | `/docs/Test_Cases.md` oluştur, tablo başlıkları ekle | `Test_Cases.md` | - |
| DOC-TASK-28 | "Auth" modülü test senaryoları yaz (TC-AUTH-01 to 04) | `Test_Cases.md` | - |
| DOC-TASK-29 | "Todo" modülü test senaryoları yaz (TC-TODO-01 to 04) | `Test_Cases.md` | - |
| DOC-TASK-30 | "Social" modülü test senaryoları yaz (TC-SOC-01 to 06) | `Test_Cases.md` | - |
| DOC-TASK-31 | `/docs/reports/Prototype_2_Report.md` oluştur, Sprint 4 ekle | `Prototype_2_Report.md` | - |
| DOC-TASK-32 | Sprint 4 Review (2. Prototip) ve Retrospective organize et, kaydet | Video kaydı | 2 Aralık |

## Sprint 5: Rutinler, Toparlama ve Final

| Task ID | Açıklama | Çıktı | Tarih |
|---------|----------|-------|-------|
| DOC-TASK-33 | Sprint 5 Planlama organize et, kaydını al | Video kaydı | 3 Aralık |
| DOC-TASK-34 | "Rutin Yönetimi" Use Case Diyagramı çiz | PNG | - |
| DOC-TASK-35 | "Rutin" modülü test senaryoları ekle (TC-ROUT-01 to 04) | `Test_Cases.md` | - |
| DOC-TASK-36 | Emre T. ile test oturumu planla (TEST-1) | - | - |
| DOC-TASK-37 | Test yürütme sırasında gözlem yap | - | - |
| DOC-TASK-38 | Her bug için Jira'da "Bug" kaydı oluştur (açıklama, ekran görüntüsü) | Jira | - |
| DOC-TASK-39 | `Test_Cases.md`'yi güncelle (Durum: Pass/Fail) | `Test_Cases.md` | - |
| DOC-TASK-40 | "Fixed" Bug'ları tekrar test et (Regression), Done/Re-open yap | Jira | - |
| DOC-TASK-41 | `/docs/Final_Report.md` oluştur | `Final_Report.md` | - |
| DOC-TASK-42 | Rapora "Giriş" bölümü yaz | `Final_Report.md` | - |
| DOC-TASK-43 | URD'den "Gereksinimler" kopyala | `Final_Report.md` | - |
| DOC-TASK-44 | Tüm UML diyagramlarını "Sistem Tasarımı" başlığına ekle | `Final_Report.md` | - |
| DOC-TASK-45 | Emre Ş.'den Jira sprint panolarının görüntülerini al, ekle | `Final_Report.md` | - |
| DOC-TASK-46 | `Test_Cases.md`'yi "Test Süreçleri" başlığına ekle | `Final_Report.md` | - |
| DOC-TASK-47 | Emre T.'den son ekran görüntülerini al, "Proje Çıktıları" ekle | `Final_Report.md` | - |
| DOC-TASK-48 | "Sonuç" bölümü yaz, ekip review'u için gönder | `Final_Report.md` | - |
| DOC-TASK-49 | Final Sunum organize et | - | 16 Aralık |
| DOC-TASK-50 | Final Sunumu kaydet, teslim et | Video kaydı | 16 Aralık |

---

## Scrum Master Sorumlulukları

### Genel Sorumluluklar

1. **API_CONTRACT.md'yi Kutsal Kitap İlan Etmek**
   - Kimsenin bu sözleşme dışına çıkmamasını sağlamak
   - Değişiklikler için tüm ekibin onayını almak

2. **Daily Scrum Yönetimi**
   - Her toplantıda 3 soruyu sormak:
     - Dün ne yaptın?
     - Bugün ne yapacaksın?
     - Bir engelin var mı?
   - Core dosyalarındaki değişiklikleri duyurmak

3. **Engel Yönetimi**
   - Blockers'ı tespit etmek ve çözmek
   - Ekip üyeleri arası koordinasyonu sağlamak

4. **Sprint Ritüelleri**
   - Sprint Planning (Her sprint başı)
   - Daily Scrum (Haftada 3 kez: Pzt-Çrş-Cuma)
   - Sprint Review (Her sprint sonu)
   - Sprint Retrospective (Her sprint sonu)

### Toplantı Takvimi

| Sprint | Planning | Daily Scrum | Review/Retro |
|--------|----------|-------------|--------------|
| Sprint 2 | 22 Ekim | 22,24,26,29,31 Ekim, 2 Kas | 4 Kasım |
| Sprint 3 | 5 Kasım | 6,8,10,13,15,17 Kasım | 18 Kasım |
| Sprint 4 | 19 Kasım | 20,22,24,27,29 Kas, 1 Ara | 2 Aralık |
| Sprint 5 | 3 Aralık | 4,6,8,11,13,15 Aralık | 16 Aralık |

---

## Kritik Başarı Faktörleri

### ✅ Yapılması Gerekenler

1. **API_CONTRACT.md önce tamamlanmalı** - Tüm kodlamadan önce
2. **Her değişiklik Daily Scrum'da duyurulmalı** - Özellikle core dosyalar
3. **Planlı entegrasyonlar dışında çakışma olmamalı** - INT-TASK'ler koordineli
4. **Her özellik kendi katmanında kalmalı** - Boundary'lere saygı
5. **Her sprint sonunda çalışan bir prototip olmalı** - Review için hazır

### ❌ Yapılmaması Gerekenler

1. **API sözleşmesi olmadan kodlama yapmak**
2. **Başkasının katmanına dokunmak**
3. **Koordinasyon olmadan ortak dosyaları değiştirmek**
4. **Sprint hedefinin dışına çıkmak**
5. **Test etmeden "Done" demek**

---

## Ekler

### Test Senaryosu Şablonu

```markdown
| Test ID | Açıklama | Ön Koşullar | Adımlar | Beklenen Sonuç | Gerçekleşen Sonuç | Durum |
|---------|----------|-------------|---------|----------------|-------------------|-------|
| TC-XXX-01 | ... | ... | 1. ...<br>2. ... | ... | ... | Pass/Fail |
```

### Bug Raporu Şablonu (Jira)

```
**Başlık:** [Katman] Kısa açıklama

**Açıklama:**
- Ne yapıldı?
- Ne beklendi?
- Ne oldu?

**Adımlar:**
1. ...
2. ...

**Ekran Görüntüsü:** [Ek]

**Etiketler:** Backend / Frontend-UI / Frontend-Data / Core

**Öncelik:** High / Medium / Low
```

---

## Doküman Versiyonu

**Versiyon:** 1.0  
**Oluşturulma Tarihi:** 29 Ekim 2025  
**Son Güncelleme:** 29 Ekim 2025  
**Hazırlayan:** Proje Ekibi  
**Onaylayan:** Emre İlhan Şenel (Scrum Master), Emre Tuncer (Product Owner)

---

**📌 Not:** Bu doküman, proje boyunca referans olarak kullanılmalı ve tüm ekip üyeleri tarafından düzenli olarak gözden geçirilmelidir. Her sprint öncesi bu dokümanı hatırlatmak, çatışmasız bir geliştirme sürecinin temel taşıdır.
