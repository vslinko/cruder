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

resource = cruder app, db

# first argument is model name or model class, second is resource options
resource "users",
  collection:
    get:
      query: -> @Model.find().sort(username: 1)

app.listen 3000 if require.main is module
```

## Available options and default values

Default values here is pseudo-values used for understanding.

```coffee
options =
  # Document field name used for Last-Modified header.
  # If model has date field and this field updated on every change
  # then you should use name of this field.
  modificationTimeField: undefined

  # Express-like url pattern used for Location header.
  # Url params replaced by document fields.
  # Required if options.document.url is RegExp.
  # Example behaviour:
  # if options.locationUrl is "/:group/users/:_id"
  # and doc._id is "777"
  # and doc.group is "admins"
  # then Location header is "/admins/users/777"
  locationUrl: options.document.url

  # Whole collection actions.
  collection:
    # Collection actions url.
    # Can be express-like url pattern or RegExp.
    url: "/" + Model.modelName

    # Url params definition using for model queries.
    # Requied if options.collection.url is RegExp.
    # Example behaviour:
    # if options.collection.url is "/users/:paramName"
    # and options.collection.params is {"paramName": "modelField"}
    # then options.collection.get.query is
    #   Model.find({modelField: req.params.paramName})
    params: /:([^\/]+)/g.exec options.collection.url

    # GET /
    get:
      # Respond with 405 status if disabled.
      _disabled: false

      # Model query.
      # Can be factory function or query object.
      # Can use @Model for access to resource model.
      query: (req, res) ->
        Model.find()

      # Function used for state changes before sending response.
      # Should return modified documents array.
      beforeSending: (req, res, docs) ->
        docs

      # Function used to perform actions after response is sent.
      afterSending: (req, res, docs) ->

    # POST /
    post:
      # Respond with 405 status if disabled.
      _disabled: false

      # New document factory function.
      # Must return new document object.
      factory: (req, res) ->
        new Model req.body

      # Function used for state changes before sending response.
      # Should return modified document object.
      beforeSending: (req, res, doc) ->
        doc

      # Function used to perform actions after response is sent.
      afterSending: (req, res, doc) ->

    # PUT /
    # Responds with 405 status.
    put:
      # Function used for state changes before sending response.
      beforeSending: (req, res) ->

      # Function used to perform actions after response is sent.
      afterSending: (req, res) ->

    # DELETE /
    delete:
      # Respond with 405 status if disabled.
      _disabled: false

      # Model query.
      # Can be factory function or query object.
      # Can use @Model for access to resource model.
      query: (req, res) ->
        Model.remove()

      # Function used for state changes before sending response.
      beforeSending: (req, res) ->

      # Function used to perform actions after response is sent.
      afterSending: (req, res) ->

  # One document actions.
  document:
    # Document actions url.
    # Can be express-like url pattern or RegExp.
    url: "/" + Model.modelName + "/:id"

    # Url params definition using for model queries.
    # Requied if options.document.url is RegExp.
    # Example behaviour:
    # if options.document.url is "/users/:id"
    # and options.document.params is {"id": "_id"}
    # then options.document.get.query is
    #   Model.findOne({_id: req.params.id})
    params: /:([^\/]+)/g.exec options.document.url

    # GET /:id
    get:
      # Respond with 405 status if disabled.
      _disabled: false

      # Model query.
      # Can be factory function or query object.
      # Can use @Model for access to resource model.
      query: (req, res) ->
        Model.findOne _id: req.params.id

      # Function used for state changes before sending response.
      # Should return modified document.
      beforeSending: (req, res, doc) ->
        doc

      # Function used to perform actions after response is sent.
      afterSending: (req, res, doc) ->

    # POST /:id
    # Responds with 405 status.
    post:
      # Function used for state changes before sending response.
      beforeSending: (req, res) ->

      # Function used to perform actions after response is sent.
      afterSending: (req, res) ->

    # PUT /:id
    put:
      # Respond with 405 status if disabled.
      _disabled: false

      # Model query.
      # Can be factory function or query object.
      # Can use @Model for access to resource model.
      query: (req, res) ->
        Model.findOne _id: req.params.id

      # Function used for state changes before saving document.
      # Must return modified document.
      beforeSaving: (req, res, doc) ->
        data = req.body
        delete data._id
        doc[key] = value for key, value of data
        doc

      # Function used for state changes before sending response.
      # Should return modified document.
      beforeSending: (req, res, doc) ->
        doc

      # Function used to perform actions after response is sent.
      afterSending: (req, res, doc) ->

    # DELETE /:id
    delete:
      # Respond with 405 status if disabled.
      _disabled: false

      # Model query.
      # Can be factory function or query object.
      # Can use @Model for access to resource model.
      query: (req, res) ->
        Model.findOne _id: req.params.id

      # Function used for state changes before sending response.
      beforeSending: (req, res) ->

      # Function used to perform actions after response is sent.
      afterSending: (req, res) ->
```

## Events

Every controller emits event before calling `beforeSaving`, `beforeSending`,
or `afterSending`. You can subscribe to events in four ways:

1. Subscribe to event from all controllers:

    ```coffee
    resource("users").on "beforeSending", (req, res) ->
      res.set "Expires", new Date(Date.now() + 1000 * 60 * 60).toGMTString()
    ```

2. Subscribe to event from collection or document controllers:

    ```coffee
    resource("users").on "document:beforeSending", (req, res, doc) ->
      if doc
        res.set "X-Doc-Id", doc._id
    ```

3. Subscribe to event from concrete method from collection and document
  controllers:

    ```coffee
    resource("users").on "get:afterSending", (req, res, data) ->
      console.log req.url, data
    ```

4. Subscribe to event from concrete controller:

    ```coffee
    resource("users").on "post:collection:afterSending", (req, res, doc) ->
      console.log "Created new document", doc
    ```
