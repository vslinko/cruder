# cruder

> CRUD for express and mongoose.

[![Build Status](https://travis-ci.org/rithis/cruder.png?branch=master)](https://travis-ci.org/rithis/cruder)
[![Coverage Status](https://coveralls.io/repos/rithis/cruder/badge.png?branch=master)](https://coveralls.io/r/rithis/cruder?branch=master)
[![Dependency Status](https://gemnasium.com/rithis/cruder.png)](https://gemnasium.com/rithis/cruder)
[![NPM version](https://badge.fury.io/js/cruder.png)](http://badge.fury.io/js/cruder)

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
resource User, collection: get: query: User.find().sort(username: 1)

app.listen 3000 if require.main is module
```

## Available options and default values

```coffee
options =
  # resource base url
  baseUrl: Model.modelName

  # document field name for Last-Modified header
  modificationTimeField: undefined

  # GET /
  collection:
    get:
      # respond with 405 status if true
      _disabled: false

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
      # respond with 405 status if true
      _disabled: false

      # document factory
      factory: (req, res) ->
        new Model req.body

      # method for state changes before sending response
      beforeSending: (req, res, doc) ->
        doc

      # method to perform actions after sending response
      afterSending: (req, res) ->

    # PUT /
    put:
      # method for state changes before sending response
      beforeSending: (req, res) ->

      # method to perform actions after sending response
      afterSending: (req, res) ->

    # DELETE /
    delete:
      # respond with 405 status if true
      _disabled: false

      # query factory
      query: (req, res) ->
        Model.remove()

      # method for state changes before sending response
      beforeSending: (req, res) ->

      # method to perform actions after sending response
      afterSending: (req, res) ->

  document:
    # GET /:id
    get:
      # respond with 405 status if true
      _disabled: false

      # query factory
      query: (req, res) ->
        Model.findOne _id: req.params.id

      # method for state changes before sending response
      beforeSending: (req, res, doc) ->
        doc

      # method to perform actions after sending response
      afterSending: (req, res) ->

    # POST /:id
    post:
      # method for state changes before sending response
      beforeSending: (req, res) ->

      # method to perform actions after sending response
      afterSending: (req, res) ->

    # PUT /:id
    put:
      # respond with 405 status if true
      _disabled: false

      # query factory
      query: (req, res) ->
        Model.findOne _id: req.params.id

      # method for state changes before saving document
      beforeSaving: (req, res, doc) ->
        data = req.body
        delete data._id
        doc[key] = value for key, value of data
        doc

      # method for state changes before sending response
      beforeSending: (req, res, doc) ->
        doc

      # method to perform actions after sending response
      afterSending: (req, res) ->

    # DELETE /:id
    delete:
      # respond with 405 status if true
      _disabled: false

      # query factory
      query: (req, res) ->
        Model.remove _id: req.params.id

      # method for state changes before sending response
      beforeSending: (req, res) ->

      # method to perform actions after sending response
      afterSending: (req, res) ->
```
