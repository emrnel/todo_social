import request from 'supertest';
import { expect } from 'chai';

const app = 'http://localhost:3000'; // API sunucunuzun adresi

describe('Todo Social API Test Suite', () => {
  // --- Değişkenler ---
  // Birinci kullanıcı için bilgiler
  const testUser = {
    username: `testuser_${Date.now()}`,
    email: `test_${Date.now()}@example.com`,
    password: 'password123',
  };
  let testUserToken;
  let testUserId;

  // İkinci kullanıcı için bilgiler (sosyal etkileşim testleri için)
  const secondUser = {
    username: `seconduser_${Date.now()}`,
    email: `second_${Date.now()}@example.com`,
    password: 'password456',
  };
  let secondUserToken;
  let secondUserId;

  // Testler arasında kullanılacak Todo ID'leri
  let publicTodoId;
  let privateTodoId;

  // --- Test Kurulumu ---
  // Tüm testler başlamadan önce her iki kullanıcıyı da oluştur ve token'larını al.
  before(async () => {
    // Birinci kullanıcıyı kaydet
    await request(app).post('/api/auth/register').send(testUser);
    // Birinci kullanıcı ile giriş yap ve token'ını al
    const loginRes1 = await request(app).post('/api/auth/login').send({ email: testUser.email, password: testUser.password });
    testUserToken = loginRes1.body.data.token;
    testUserId = loginRes1.body.data.user.id;

    // İkinci kullanıcıyı kaydet
    await request(app).post('/api/auth/register').send(secondUser);
    // İkinci kullanıcı ile giriş yap ve token'ını al
    const loginRes2 = await request(app).post('/api/auth/login').send({ email: secondUser.email, password: secondUser.password });
    secondUserToken = loginRes2.body.data.token;
    secondUserId = loginRes2.body.data.user.id;
  });

  // --- 1. AUTHENTICATION ---
  describe('Authentication (/api/auth)', () => {
    it('should register a new user', async () => {
      // Bu test, before() bloğunda kullanıcıların zaten oluşturulduğunu doğrular.
      // Yeni bir kullanıcı oluşturarak testin tekrar edilebilirliğini bozarız,
      // bu yüzden sadece token'ların varlığını kontrol ediyoruz.
      expect(testUserToken).to.be.a('string');
      expect(secondUserToken).to.be.a('string');
    });

    it('should log in an existing user and get a token', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: testUser.password });

      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data).to.have.property('token');
    });

    it('should fail to log in with wrong credentials', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ email: testUser.email, password: 'wrongpassword' });

      expect(res.statusCode).to.equal(401);
      expect(res.body.error.code).to.equal('INVALID_CREDENTIALS');
    });
  });

  // --- 2. USER ENDPOINTS ---
  describe('User Endpoints (/api/users)', () => {
    it('should fail without a token', async () => {
      const res = await request(app).get('/api/users/me');
      expect(res.statusCode).to.equal(401);
      expect(res.body.error.code).to.equal('UNAUTHORIZED');
    });

    it('should get user profile with a valid token', async () => {
      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.user.email).to.equal(testUser.email);
      expect(res.body.data.user.id).to.equal(testUserId);
    });
  });

  // --- 3. TODO CRUD ---
  describe('Todo CRUD Endpoints (/api/todos)', () => {
    it('POST / - should create a new PRIVATE todo for the logged-in user', async () => {
      const res = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${testUserToken}`)
        .send({
          title: 'My First PRIVATE Todo',
          description: 'This is a private test todo.',
          isPublic: false,
        });

      expect(res.statusCode).to.equal(201);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todo.title).to.equal('My First PRIVATE Todo');
      expect(res.body.data.todo.isPublic).to.be.false;
      privateTodoId = res.body.data.todo.id;
    });

    it('POST / - should create a new PUBLIC todo for the logged-in user', async () => {
      const res = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${testUserToken}`)
        .send({
          title: 'My First PUBLIC Todo',
          description: 'This is a public test todo for the feed.',
          isPublic: true,
        });

      expect(res.statusCode).to.equal(201);
      expect(res.body.data.todo.isPublic).to.be.true;
      publicTodoId = res.body.data.todo.id;
    });

    it('GET /mytodos - should get all todos for the user', async () => {
      const res = await request(app)
        .get('/api/todos/mytodos')
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todos).to.be.an('array');
      expect(res.body.data.todos.length).to.be.at.least(2);
    });

    it('PATCH /:id - should update the created public todo', async () => {
      const res = await request(app)
        .patch(`/api/todos/${publicTodoId}`)
        .set('Authorization', `Bearer ${testUserToken}`)
        .send({
          title: 'Updated Public Todo',
          isCompleted: true,
        });

      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todo.title).to.equal('Updated Public Todo');
      expect(res.body.data.todo.isCompleted).to.be.true;
    });

    it('PATCH /:id - [CRITICAL] should FAIL to update a todo belonging to another user (403 Forbidden)', async () => {
      const res = await request(app)
        .patch(`/api/todos/${publicTodoId}`) // First user's todo
        .set('Authorization', `Bearer ${secondUserToken}`) // Second user's token
        .send({ title: 'Attempt to hack' });

      expect(res.statusCode).to.equal(403);
      expect(res.body.error.code).to.equal('FORBIDDEN');
    });

    it('DELETE /:id - should delete the created todo', async () => {
      const res = await request(app)
        .delete(`/api/todos/${publicTodoId}`)
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
    });

    it('DELETE /:id - [CRITICAL] should FAIL to delete a todo belonging to another user (403 Forbidden)', async () => {
      const res = await request(app)
        .delete(`/api/todos/${privateTodoId}`) // First user's other todo
        .set('Authorization', `Bearer ${secondUserToken}`); // Second user's token

      expect(res.statusCode).to.equal(403);
      expect(res.body.error.code).to.equal('FORBIDDEN');
    });

    it('GET /:id - should confirm the todo is deleted', async () => {
      const res = await request(app)
        .get('/api/todos/mytodos')
        .set('Authorization', `Bearer ${testUserToken}`);

      const deletedTodoExists = res.body.data.todos.some(todo => todo.id === publicTodoId);
      expect(deletedTodoExists).to.be.false;
    });
  });

  // --- 4. SOCIAL FEATURES ---
  describe('Social Features', () => {
    it('GET /api/users/search - should find the first user', async () => {
      const res = await request(app)
        .get(`/api/users/search?q=${testUser.username}`)
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.users).to.be.an('array');
      expect(res.body.data.users.length).to.be.greaterThan(0);
      expect(res.body.data.users[0].username).to.equal(testUser.username);
    });

    it('POST /api/social/follow/:userId - should FAIL to follow themselves', async () => {
      const res = await request(app)
        .post(`/api/social/follow/${testUserId}`)
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(res.statusCode).to.equal(400);
      expect(res.body.message).to.equal('Kendinizi takip edemezsiniz.');
    });

    it('POST /api/social/follow/:userId - second user should follow the first user', async () => {
      const res = await request(app)
        .post(`/api/social/follow/${testUserId}`)
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.message).to.include('Kullanıcı başarıyla takip edildi');
    });

    it('POST /api/social/follow/:userId - should FAIL to follow an already followed user (409 Conflict)', async () => {
      const res = await request(app)
        .post(`/api/social/follow/${testUserId}`)
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(409);
      expect(res.body.message).to.equal('Bu kullanıcı zaten takip ediliyor.');
    });

    it('GET /api/users/:userId - should show correct follower/following counts', async () => {
      // Birinci kullanıcının profilini kontrol et (1 takipçisi olmalı)
      const res1 = await request(app)
        .get(`/api/users/${testUserId}`)
        .set('Authorization', `Bearer ${testUserToken}`);

      expect(res1.statusCode).to.equal(200);
      expect(res1.body.data.user.followerCount).to.equal(1);
      expect(res1.body.data.user.followingCount).to.equal(0);

      // İkinci kullanıcının profilini kontrol et (1 kişiyi takip ediyor olmalı)
      const res2 = await request(app)
        .get(`/api/users/${secondUserId}`)
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res2.statusCode).to.equal(200);
      expect(res2.body.data.user.followerCount).to.equal(0);
      expect(res2.body.data.user.followingCount).to.equal(1);
    });

    it("GET /api/social/feed - should show the first user's public todo in the second user's feed", async () => {
      // Birinci kullanıcı, feed'de görünecek yeni bir public todo oluştursun.
      // Bu, testlerin birbirinden bağımsızlığını artırır.
      const todoRes = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${testUserToken}`)
        .send({ title: 'A fresh PUBLIC todo for the feed', isPublic: true });
      const newPublicTodoId = todoRes.body.data.todo.id;

      const res = await request(app)
        .get('/api/social/feed')
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.feed).to.be.an('array');
      expect(res.body.data.feed.length).to.be.greaterThan(0);

      // Feed'de doğru todonun ve doğru yazarın olduğunu doğrula
      const publicTodo = res.body.data.feed.find(todo => todo.id === newPublicTodoId);

      expect(publicTodo).to.exist;
      expect(publicTodo.author.username).to.equal(testUser.username);

      // Feed'de private todo'ların olmadığını doğrula
      const privateTodo = res.body.data.feed.find(todo => todo.id === privateTodoId);
      expect(privateTodo).to.not.exist;
    });

    it('DELETE /api/social/unfollow/:userId - second user should unfollow the first user', async () => {
      const res = await request(app)
        .delete(`/api/social/unfollow/${testUserId}`)
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.message).to.equal('Kullanıcı takipten çıkarıldı.');
    });

    it('GET /api/social/feed - should show an empty feed after unfollowing', async () => {
      const res = await request(app)
        .get('/api/social/feed')
        .set('Authorization', `Bearer ${secondUserToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.feed).to.be.an('array').that.is.empty;
    });
  });
});
