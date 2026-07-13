const express = require('express');
const cors = require('cors');

const app = express();

// permissive CORS (A05)
app.use(cors({ origin: '*' }));

// debug residue (A09)
console.log("booting server");

app.listen(3000);
