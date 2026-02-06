const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// DB connection
const db = mysql.createConnection({
    host: "localhost",
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});

db.connect(err => {
    if (err) {
        console.error("❌ DB connection failed:", err.message);
    } else {
        console.log("✅ Database connected");
    }
});

// Health check
app.get("/api/health", (req, res) => {
    res.json({ status: "Backeng running properly." });
});

// Sample DB API
app.get("/api/time", (req, res) => {
    db.query("SELECT NOW() AS time", (err, result) => {
        if (err) return res.status(500).json(err);
        res.json(result[0]);
    });
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Backend running on port ${PORT}`);
});
