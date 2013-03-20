# CRUD for express and mongoose

## Usage

```coffeescript
mongoose = require "mongoose"
express = require "express"
cruder = require "cruder"

db = mongoose.createConnection "mongodb://localhost/test"

UserSchema = new mongoose.Schema
  username: type: String, required: true
  password: type: String, required: true

User = db.model "users", UserSchema

app = express()
app.use express.bodyParser()

# Generate all CRUD actions for model User. That equals:
#   app.get "/users", cruder.list User.find().sort(username: 1)
#   app.post "/users", cruder.post User
#   app.get "/users/:id", cruder.get User
#   app.put "/users/:id", cruder.put User
#   app.delete "/users/:id", cruder.delete User
cruder app, User, query: User.find().sort(username: 1)

app.listen 3000 if require.main is module
```
