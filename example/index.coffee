sequence = require "when/sequence"
mongoose = require "mongoose"
express = require "express"
nodefn = require "when/node/function"
cruder = require ".."
w = require "when"


# db
db = mongoose.createConnection "mongodb://localhost/test"

UserSchema = new mongoose.Schema
  username: type: String, required: true
  password: type: String, required: true

User = db.model "users", UserSchema

# app
app = express()
app.use express.bodyParser()
cruder app, User, query: User.find().sort(username: 1)

# setup
zombie = new User username: "Zombie", password: "Attack"
bobby = new User username: "Bobby", password: "Cobby"

promise = sequence [
  nodefn.lift db.on.bind db, "connected"
  nodefn.lift User.remove.bind User
  nodefn.lift zombie.save.bind zombie
  nodefn.lift bobby.save.bind bobby
  -> nodefn.call app.listen.bind app, 3000 if require.main is module
]

module.exports = promise.then -> app
