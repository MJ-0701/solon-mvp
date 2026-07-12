const express = require('express');
const postService = require('../services/postService');

const router = express.Router();

router.get('/', async (req, res) => {
  res.json(await postService.listPosts());
});

router.post('/', async (req, res) => {
  res.json(await postService.createPost(req.body));
});

module.exports = router;
