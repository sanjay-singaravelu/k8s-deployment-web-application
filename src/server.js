const express = require('express');
const app = express();
const port = 3008;

app.get('/', (req, res) => {
  res.send('Hello, Kubernetes!');
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});

