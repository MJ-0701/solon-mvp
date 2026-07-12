const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function listPosts() {
  return prisma.post.findMany({ include: { author: true } });
}

async function createPost(data) {
  return prisma.post.create({ data });
}

module.exports = { listPosts, createPost };
