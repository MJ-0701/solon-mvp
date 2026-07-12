const express = require('express');
const postsRouter = require('./routes/posts');

const app = express();
app.use('/posts', postsRouter);

app.get('/health', (req, res) => res.send('ok'));

app.listen(process.env.PORT || 3000);
