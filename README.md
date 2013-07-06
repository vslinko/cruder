# cruder

> CRUD for express and mongoose.

## Usage

```coffee
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

resource = cruder app
# first argument is model, second is options
resource User, list: query: -> User.find().sort(username: 1)

app.listen 3000 if require.main is module
```

## Available options and default values

```coffee
options =
  # enabled actions
  actions: ["list", "post", "get", "put", "delete"]

  # resource name
  name: Model.modelName

  # GET /
  list:
    # express method
    method: "get"

    # request url
    url: "/#{options.name}"

    # express middlewares
    middlewares: []

    # query factory
    query: (req, res) ->
      Model.find()

    # method for state changes before sending response
    beforeSending: (req, res, docs) ->
      docs

    # method to perform actions after sending response
    afterSending: (req, res) ->

  # POST /
  post:
    # express method
    method: "post"

    # request url
    url: "/#{options.name}"

    # express middlewares
    middlewares: []

    # document factory
    doc: (req, res) ->
      new Model req.body

    # method for state changes before sending response
    beforeSending: (req, res, doc) ->
      res.set "Location", "/#{Model.modelName}/#{doc._id}"
      doc

    # method to perform actions after sending response
    afterSending: (req, res) ->

  # GET /:id
  get:
    # express method
    method: "get"

    # request url
    url: "/#{options.name}/:id"

    # express middlewares
    middlewares: []

    # query factory
    query: (req, res) ->
      Model.findOne _id: req.params.id

    # method for state changes before sending response
    beforeSending: (req, res, doc) ->
      doc

    # method to perform actions after sending response
    afterSending: (req, res) ->

  # PUT /:id
  put:
    # express method
    method: "put"

    # request url
    url: "/#{options.name}/:id"

    # express middlewares
    middlewares: []

    # query factory
    query: (req, res) ->
      Model.findOne _id: req.params.id

    # method for state changes before saving document
    beforeSaving: (req, res, doc) ->
      data = req.body
      delete data._id
      merge doc, data

    # method for state changes before sending response
    beforeSending: (req, res, doc) ->
      doc

    # method to perform actions after sending response
    afterSending: (req, res) ->

  # DELETE /:id
  delete:
    # express method
    method: "delete"

    # request url
    url: "/#{options.name}/:id"

    # express middlewares
    middlewares: []

    # query factory
    query: (req, res) ->
      Model.remove _id: req.params.id

    # method for state changes before sending response
    beforeSending: (req, res) ->

    # method to perform actions after sending response
    afterSending: (req, res) ->
```
