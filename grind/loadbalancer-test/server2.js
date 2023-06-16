const express = require('express');
const cors=require('cors')
const app = express();
const port = 4000;
app.use(cors())
app.get('/', (req, res) => {
  res.send('Hello, World! , server2');
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});