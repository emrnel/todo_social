// --- IMPORTS ---
// Import the database connection instance
import sequelize from '../db.js';

// Import all models
import User from './models/User.model.js';
import Todo from './models/Todo.model.js';
import Routine from './models/Routine.model.js';
import Follower from './models/Follower.model.js';

// Import the associations function to ensure they are loaded
import setupAssociations from './models/associations.js';

// Call the function to set up all model relationships
setupAssociations();

// --- TEST FUNCTION ---

/**
 * Runs a test to create related data and verify associations.
 * 1. Clears all tables (in the correct order).
 * 2. Creates a test user.
 * 3. Creates a todo for that user.
 * 4. Creates a routine for that user.
 * 5. Creates another test user.
 * 6. Makes the first user follow the second user.
 * 7. Logs success.
 */
async function runTest() {
  console.log('--- Starting Model Relationship Test ---');

  try {
    // 1. Sync all models (optional, good for safety check)
    // await sequelize.sync({ alter: true }); // Use alter to be safe

    // 2. Clear all tables in the correct order to avoid Foreign Key errors
    // We must delete from "child" tables (which have the foreign key) first.
    
    // FIX: Replaced 'truncate: true' with 'where: {}'
    // This uses the 'DELETE' command instead of 'TRUNCATE',
    // which correctly handles foreign key constraints.
    console.log('Clearing child tables (using DELETE)...');
    await Todo.destroy({ where: {} });
    await Routine.destroy({ where: {} });
    await Follower.destroy({ where: {} });

    // Now it is safe to clear the "parent" table (User)
    console.log('Clearing parent table (using DELETE)...');
    await User.destroy({ where: {} });

    console.log('All tables cleared.');

    // 3. Create Users
    console.log('Creating users...');

    // FIX #2: Changed field name 'password' to 'password_hash'
    // This matches the User.model.js definition (from API_CONTRACT.md).
    const user1 = await User.create({
      username: 'test_user_1',
      email: 'user1@test.com',
      password_hash: 'testpassword123', // <-- This is the fix
    });

    const user2 = await User.create({
      username: 'test_user_2',
      email: 'user2@test.com',
      password_hash: 'testpassword123', // <-- This is the fix
    });

    // 4. Test User -> Todo relationship
    console.log('Testing Todo relationship...');
    const todo = await user1.createTodo({
      title: 'Test Todo',
      description: 'This is a test todo item.',
    });
    // Verify the todo was created with the correct userId
    if (todo.userId !== user1.id) {
      throw new Error('Todo creation failed: userId mismatch.');
    }

    // 5. Test User -> Routine relationship
    console.log('Testing Routine relationship...');
    const routine = await user1.createRoutine({
      title: 'Test Routine',
      recurrenceType: 'daily',
    });
    // Verify the routine was created with the correct userId
    if (routine.userId !== user1.id) {
      throw new Error('Routine creation failed: userId mismatch.');
    }

    // 6. Test User -> Follower (Self-Many-to-Many) relationship
    // user1 will follow user2
    console.log('Testing Follower relationship...');
    await user1.addFollowing(user2);

    // Verify the relationship
    const followingList = await user1.getFollowing();
    if (followingList.length === 0 || followingList[0].id !== user2.id) {
      throw new Error('Follow relationship failed.');
    }

    // --- SUCCESS ---
    console.log('\n✅✅✅ --- ALL RELATIONSHIPS ARE WORKING SUCCESSFULLY! --- ✅✅✅');
    console.log(`User 1 (${user1.username}) created a todo and a routine.`);
    console.log(`User 1 is now following User 2 (${user2.username}).`);

  } catch (error) {
    console.error('\n❌❌❌ --- TEST FAILED --- ❌❌❌');
    console.error(error);
  } finally {
    // 7. Close the database connection
    await sequelize.close();
    console.log('\n--- Test complete, connection closed. ---');
  }
}

// --- EXECUTE TEST ---
runTest();
