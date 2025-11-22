import request from 'supertest';
import { expect } from 'chai';

// Test edilecek Express uygulamasını import etmemiz gerekiyor.
// Bunun için index.js dosyasını export edilebilir hale getirmeliyiz.
// Şimdilik, sunucunun çalıştığını varsayarak endpoint'lere istek atacağız.
const app = 'http://localhost:3000'; // Sunucunuzun adresi (npm start çıktısıyla aynı olmalı)

describe('Todo Social API Test Suite', () => {
  let authToken; // Testler arasında JWT token'ı saklamak için
  let firstUserId;
  let createdTodoId; // Oluşturulan todo'nun ID'sini saklamak için
  const testUser = {
    username: `testuser_${Date.now()}`,
    email: `test_${Date.now()}@example.com`,
    password: 'password123',
  };

  // İkinci kullanıcı (takip etme senaryoları için)
  let secondAuthToken;
  let secondUserId;
  const secondUser = {
    username: `seconduser_${Date.now()}`,
    email: `second_${Date.now()}@example.com`,
    password: 'password456',
  };


  // --- 1. Auth Endpoints ---
  describe('POST /api/auth', () => {
    it('should register a new user', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          username: testUser.username,
          email: testUser.email,
          password: testUser.password,
        });
      expect(res.statusCode).to.equal(201);
      expect(res.body.success).to.be.true;
      expect(res.body.data.user).to.have.property('id');
      expect(res.body.data.user.email).to.equal(testUser.email);
    });

    it('should log in the new user and get a token', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: testUser.email,
          password: testUser.password,
        });
      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data).to.have.property('token');
      authToken = res.body.data.token; // Token'ı sonraki testler için sakla
    });
  });

  // --- 2. User Profile Endpoint ---
  describe('GET /api/users/me', () => {
    it('should fail without a token', async () => {
      const res = await request(app).get('/api/users/me');
      expect(res.statusCode).to.equal(401);
    });

    it('should get user profile with a valid token', async () => {
      const res = await request(app)
        .get('/api/users/me')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.user.email).to.equal(testUser.email);
      firstUserId = res.body.data.user.id; // Takip senaryoları için ID'yi sakla
    });
  });

  // --- 3. Todo CRUD Endpoints ---
  describe('/api/todos', () => {
    it('POST / - should create a new PRIVATE todo for the logged-in user', async () => {
      const res = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'My First PRIVATE Todo',
          description: 'This is a private test todo.',
          isPublic: false, // Explicitly set as private
        });
      expect(res.statusCode).to.equal(201);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todo.title).to.equal('My First PRIVATE Todo');
      expect(res.body.data.todo.isPublic).to.be.false;
    });

    it('POST / - should create a new PUBLIC todo for the logged-in user', async () => {
      const res = await request(app)
        .post('/api/todos')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'My First PUBLIC Todo',
          description: 'This is a public test todo for the feed.',
          isPublic: true, // Explicitly set as public
        });
      expect(res.statusCode).to.equal(201);
      expect(res.body.data.todo.isPublic).to.be.true;
      createdTodoId = res.body.data.todo.id; // ID'yi güncelleme ve silme testleri için sakla
    });

    it('GET /mytodos - should get all todos for the user', async () => {
      const res = await request(app)
        .get('/api/todos/mytodos')
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todos).to.be.an('array');
      expect(res.body.data.todos.length).to.be.greaterThan(1); // We created two todos
    });

    it('PATCH /:id - should update the created public todo', async () => {
      const res = await request(app)
        .patch(`/api/todos/${createdTodoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Updated Public Todo',
          isCompleted: true,
        });
      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
      expect(res.body.data.todo.title).to.equal('Updated Public Todo');
      expect(res.body.data.todo.isCompleted).to.be.true;
    });

    it('DELETE /:id - should delete the created todo', async () => {
      const res = await request(app)
        .delete(`/api/todos/${createdTodoId}`)
        .set('Authorization', `Bearer ${authToken}`);
      expect(res.statusCode).to.equal(200);
      expect(res.body.success).to.be.true;
    });

    it('GET /:id - should confirm the todo is deleted', async () => {
        // mytodos listesinde silinen todo'nun olmadığını kontrol edelim.
        const res = await request(app)
            .get('/api/todos/mytodos')
            .set('Authorization', `Bearer ${authToken}`);
        
        const deletedTodoExists = res.body.data.todos.some(todo => todo.id === createdTodoId);
        expect(deletedTodoExists).to.be.false;
    });
  });

  // --- 4. Social and User Interaction Endpoints ---
  describe('Social Features', () => {
    // Bu test grubundan önce ikinci kullanıcıyı oluştur ve giriş yap
    before(async () => {
      // Register second user
      await request(app).post('/api/auth/register').send(secondUser);

      // Login second user and get token
      const loginRes = await request(app).post('/api/auth/login').send({
        email: secondUser.email,
        password: secondUser.password,
      });
      secondAuthToken = loginRes.body.data.token;

      // Get second user's ID
      const meRes = await request(app).get('/api/users/me').set('Authorization', `Bearer ${secondAuthToken}`);
      secondUserId = meRes.body.data.user.id;
    });

    it('GET /api/users/search - should find the first user', async () => {
      const res = await request(app)
        .get(`/api/users/search?q=${testUser.username}`)
        .set('Authorization', `Bearer ${secondAuthToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.users).to.be.an('array');
      expect(res.body.data.users.length).to.be.greaterThan(0);
      expect(res.body.data.users[0].username).to.equal(testUser.username);
    });

    it('POST /api/social/follow/:userId - should not allow a user to follow themselves', async () => {
      const res = await request(app)
        .post(`/api/social/follow/${firstUserId}`)
        .set('Authorization', `Bearer ${authToken}`); // First user's token
      
      expect(res.statusCode).to.equal(400);
      expect(res.body.message).to.equal('Kendinizi takip edemezsiniz.');
    });

    it('POST /api/social/follow/:userId - second user should follow the first user', async () => {
      const res = await request(app)
        .post(`/api/social/follow/${firstUserId}`)
        .set('Authorization', `Bearer ${secondAuthToken}`); // Second user's token

      expect(res.statusCode).to.equal(200);
      expect(res.body.message).to.include('Kullanıcı başarıyla takip edildi');
    });

    it('GET /api/users/:userId - should show correct follower/following counts', async () => {
      const res = await request(app)
        .get(`/api/users/${firstUserId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.user.followerCount).to.equal(1);
      expect(res.body.data.user.followingCount).to.equal(0);
    });

    it('GET /api/social/feed - should show the first user\'s public todo in the second user\'s feed', async () => {
      // Akışın güncellenmesi için küçük bir bekleme
      await new Promise(resolve => setTimeout(resolve, 100)); 

      const res = await request(app)
        .get('/api/social/feed')
        .set('Authorization', `Bearer ${secondAuthToken}`); // Second user's token

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.todos).to.be.an('array');
      expect(res.body.data.todos.length).to.be.greaterThan(0);

      // Akışta sadece public todo'ların olduğunu doğrula
      const publicTodo = res.body.data.todos.find(todo => todo.title.includes('PUBLIC'));
      const privateTodo = res.body.data.todos.find(todo => todo.title.includes('PRIVATE'));

      expect(publicTodo).to.exist;
      expect(privateTodo).to.not.exist;
      expect(publicTodo.User.username).to.equal(testUser.username);
    });

    it('DELETE /api/social/unfollow/:userId - second user should unfollow the first user', async () => {
      const res = await request(app)
        .delete(`/api/social/unfollow/${firstUserId}`)
        .set('Authorization', `Bearer ${secondAuthToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.message).to.equal('Kullanıcı takipten çıkarıldı.');
    });

    it('GET /api/social/feed - should show an empty feed after unfollowing', async () => {
      const res = await request(app)
        .get('/api/social/feed')
        .set('Authorization', `Bearer ${secondAuthToken}`);

      expect(res.statusCode).to.equal(200);
      expect(res.body.data.todos).to.be.an('array').that.is.empty;
    });
  });
});
