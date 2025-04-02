const sqlite3 = require('sqlite3').verbose();

// Connexion à la base de données SQLite
const db = new sqlite3.Database('./database.sqlite', (err) => {
  if (err) {
    console.error('Erreur lors de la connexion à la base de données :', err.message);
  } else {
    console.log('Connexion à la base de données SQLite réussie.');
  }
});

module.exports = db;