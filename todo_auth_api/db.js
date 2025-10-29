const mysql = require('mysql2');

// Create a connection pool
const pool = mysql.createPool({
  host: 'localhost',           // Usually 'localhost'
  user: 'root',     // Your MySQL username
  password: '1234', // Your MySQL passwordd
  database: 'todo_db', // Your MySQL database name
  waitForConnections: true,
  connectionLimit: 10,         // Adjust as needed
  queueLimit: 0
});

// Optional: Test the connection
pool.getConnection((err, connection) => {
  if (err) {
    console.error('Error connecting to MySQL database:', err);
    if (err.code === 'PROTOCOL_CONNECTION_LOST') {
      console.error('Database connection was closed.');
    }
    if (err.code === 'ER_CON_COUNT_ERROR') {
      console.error('Database has too many connections.');
    }
    if (err.code === 'ECONNREFUSED') {
      console.error('Database connection was refused.');
    }
    return;
  }
  if (connection) {
    console.log('Connected to MySQL database!');
    connection.release(); // Release the connection back to the pool
  }
});

// Export the pool promise-based interface
module.exports = pool.promise();