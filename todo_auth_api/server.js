const express = require('express');
const authRoutes = require('./routes/auth.routes'); // We'll create this file

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware to parse JSON bodies
app.use(express.json());

// Mount the authentication routes
app.use('/api/auth', authRoutes);

// Basic error handling middleware (optional but good practice)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});