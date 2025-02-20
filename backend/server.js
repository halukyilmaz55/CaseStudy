const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const app = express();
app.use(cors());
const port = 5000;

const pool = new Pool({
  user: "halukuser",
  host: "postgres.database.svc.cluster.local",
  database: "halukyilmaz55",
  password: "Ale3duysunkr@lSa3sun",
  port: 5432,
});

// Root endpoint
app.get("/", (req, res) => {
  res.send("Backend API is running...");
});

// Users endpoint
app.get("/users", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.listen(port, () => {
  console.log(`Backend is running on http://localhost:${port}`);
});
