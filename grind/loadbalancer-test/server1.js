const express = require('express');
const cors= require('cors')
const app = express();
const port = 3000;
app.use(cors())
app.get('/', (req, res) => {
  res.send('Hello, World!,server 1');
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});