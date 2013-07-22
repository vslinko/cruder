sequence = require "when/sequence"
mongoose = require "mongoose"
express = require "express"
nodefn = require "when/node/function"
cruder = require ".."


# db
db = mongoose.createConnection "mongodb://localhost/test"

UserSchema = new mongoose.Schema
  username: type: String, required: true
  password: type: String, required: true
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date

UserSchema.pre "save", (next) ->
  @updatedAt = new Date
  next()

PostSchema = new mongoose.Schema
  title: type: String, required: true
  text: type: String, required: true
  user: mongoose.Schema.Types.ObjectId
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date

PostSchema.pre "save", (next) ->
  @updatedAt = new Date
  next()

User = db.model "users", UserSchema
Post = db.model "posts", PostSchema


# app
app = express()
app.use express.bodyParser()


# cruder
resource = cruder app, db
resource "users", modificationTimeField: "updatedAt"

resource "users",
  modificationTimeField: "updatedAt"
  collection:
    url: "/sorted-users"
    get: query: -> @Model.find().sort(username: 1)
.only("get", "collection")

resource "posts",
  locationUrl: "/users/:user/posts/:_id"
  modificationTimeField: "updatedAt"
  collection:
    url: /^\/users\/([A-Fa-f0-9]{24})\/posts\/?$/
    params: ["user"]
  document:
    url: /^\/users\/([A-Fa-f0-9]{24})\/posts\/([A-Fa-f0-9]{24})\/?$/
    params: ["user", "_id"]


# setup
zombie = new User username: "Zombie", password: "Attack"
bobby = new User username: "Bobby", password: "Cobby"
examplePost = new Post title: "example", text: "example", user: bobby
testPost = new Post title: "test", text: "test", user: bobby

promise = sequence [
  nodefn.lift db.on.bind db, "connected"
  nodefn.lift User.remove.bind User
  nodefn.lift Post.remove.bind Post
  nodefn.lift zombie.save.bind zombie
  nodefn.lift bobby.save.bind bobby
  nodefn.lift examplePost.save.bind examplePost
  nodefn.lift testPost.save.bind testPost
  -> nodefn.call app.listen.bind app, 3000 if require.main is module
]

module.exports = promise.then -> app
