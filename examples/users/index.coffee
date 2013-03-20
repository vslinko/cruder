mongoose = require "mongoose"
express = require "express"
crud = require "../../crud"


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
app.get "/users", crud.list(User.find().sort(username: 1)).make()
app.post "/users", crud.post(User).make()
app.get "/users/:id", crud.get(User).make()
app.put "/users/:id", crud.put(User).make()
app.delete "/users/:id", crud.delete(User).make()

app.listen 3000 if require.main is module
