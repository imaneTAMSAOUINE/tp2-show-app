const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');

console.log('Démarrage du serveur...');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const loadData = () => {
  console.log('Chargement des données...');
  const data = fs.readFileSync('data.json', 'utf8');
  return JSON.parse(data);
};

const saveData = (data) => {
  console.log('Sauvegarde des données...');
  fs.writeFileSync('data.json', JSON.stringify(data, null, 2));
};

app.get('/', (req, res) => {
  res.send('API Backend fonctionne!');
  console.log('Route / appelée');
});

// Route GET pour obtenir tous les produits
app.get('/products', (req, res) => {
  const data = loadData();
  res.json(data.products);
  console.log('Route /products appelée');
});

// Route POST pour ajouter un produit
app.post('/products', (req, res) => {
  const data = loadData();
  const newProduct = req.body;
  data.products.push(newProduct);
  saveData(data);
  res.status(201).send('Produit ajouté');
  console.log('Route /products POST appelée');
});

// Route GET pour obtenir toutes les commandes
app.get('/orders', (req, res) => {
  const data = loadData();
  res.json(data.orders);
  console.log('Route /orders appelée');
});

// Route POST pour ajouter une commande
app.post('/orders', (req, res) => {
  const data = loadData();
  const newOrder = req.body;
  data.orders.push(newOrder);
  saveData(data);
  res.status(201).send('Commande créée');
  console.log('Route /orders POST appelée');
});

app.listen(port, () => {
  console.log(`Serveur API démarré sur http://localhost:${port}`);
});