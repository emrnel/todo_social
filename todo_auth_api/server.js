import express from "express";
import dotenv from "dotenv";
import cors from "cors"; // Import cors for cross-origin requests
import sequelize from "./db.js"; // Import the database connection

// Import our new router file (the "traffic cop")
import authRoutes from "./routes/auth_routes.js";

// Import our model(s) to sync with the database
// This is important so Sequelize knows about the 'User' table
import User from "./src/models/User.model.js";
import Todo from "./src/models/Todo.model.js";
import Routine from "./src/models/Routine.model.js";
import Follower from "./src/models/Follower.model.js";
import setupAssociations from './src/models/associations.js';

// Load environment variables from .env file (you already have this)
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// --- 1. Global Middleware (App-level settings) ---

// Enable CORS (Cross-Origin Resource Sharing)
// This allows your Flutter app (from a different 'origin') to make requests
// to this API (localhost:3000). Required for development.
app.use(cors());

// Enable the express.json() middleware (you already had this)
// This parses incoming JSON requests (like from Flutter) 
// and puts the data in req.body. CRITICAL for POST requests.
app.use(express.json());

// --- 2. Mount Routes ---

// Tell Express to use the 'authRoutes' for any URL starting with '/api/auth'
// This keeps your server.js clean and organized.
// e.g., a request to '/api/auth/register' will be handled by authRoutes.
app.use("/api/auth", authRoutes);

// --- 3. Start Server with Database Connection ---
const startServer = async () => {
  try {
    // First, try to connect to the database
    await sequelize.authenticate();
    console.log("✅ Database connection has been established successfully.");

    // Setup all model associations
    setupAssociations();

    // Sync all defined models with the database.
    // This will create the 'users' table if it doesn't exist.
    // { force: false } (default) won't drop tables if they exist (safe).
    // { force: true } WILL drop and recreate tables (WARNING: data loss!)
    // { alter: true } will try to alter existing tables to match the model.
    //
    // FIX: Use 'alter: true' to add the missing 'username' column to the 'users' table
    // without deleting all data. For a clean slate, you could use 'force: true'.
    await sequelize.sync({ alter: true });
    console.log("✅ Database models synchronized.");

    // Start the Express server only *after* the database is ready
    app.listen(PORT, () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
    });
  } catch (error) {
    // If database connection fails, stop the server from starting
    console.error("❌ Unable to start server:", error);
  }
};

// Run the function to start the server
startServer();