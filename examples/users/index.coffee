mongoose = require "mongoose"
express = require "express"
cruder = require "../../lib/cruder"


module.exports.app = app = express()
module.exports.db = db = mongoose.createConnection "mongodb://localhost/test"

UserSchema = new mongoose.Schema
  username: type: String, required: true
  password: type: String, required: true

User = db.model "users", UserSchema

db.on "connected", ->
  User.remove ->
    user = new User username: "Zombie", password: "Attack"
    user.save ->
      user = new User username: "Bobby", password: "Cobby"
      user.save ->
        db.emit "fixtured"

app.use express.bodyParser()
cruder app, User, query: User.find().sort(username: 1)

app.listen 3000 if require.main is module
