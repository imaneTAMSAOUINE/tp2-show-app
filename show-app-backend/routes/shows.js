const express = require('express');
const router = express.Router();
const { check, validationResult } = require('express-validator');
const multer = require('multer');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();

// Configuration de multer pour le stockage des images
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// Configuration de SQLite
const db = new sqlite3.Database('./database.sqlite');

// Route pour obtenir tous les shows
router.get('/', (req, res) => {
    db.all('SELECT * FROM shows', [], (err, rows) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.json(rows); // Retourne les données sous forme de JSON
    });
  });

// Route pour ajouter un nouveau show
router.post('/', upload.single('image'), [
  check('title').not().isEmpty().withMessage('Title is required'),
  check('description').not().isEmpty().withMessage('Description is required'),
  check('category').not().isEmpty().withMessage('Category is required'),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { title, description, category } = req.body;
  const image = req.file ? req.file.path : null;

  const sql = 'INSERT INTO shows (title, description, category, image) VALUES (?, ?, ?, ?)';
  const params = [title, description, category, image];

  db.run(sql, params, function (err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(201).json({ id: this.lastID, title, description, category, image });
  });
});

// Route pour supprimer un show
router.delete('/:id', (req, res) => {
  const { id } = req.params;

  const sql = 'DELETE FROM shows WHERE id = ?';
  db.run(sql, id, function (err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: 'Show not found' });
    }
    res.status(204).end();
  });
});

module.exports = router;