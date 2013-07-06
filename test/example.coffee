callbacks = require "when/callbacks"
chai = require "chai"


describe "users", ->
  chai.use require "chai-as-promised"
  chai.use require "chai-http"
  chai.should()

  request = null
  id = null

  before (callback) ->
    promise = require "../example"

    promise.then (app) ->
      request = chai.request app
    .should.notify callback

  makeRequest = (req) ->
    callbacks.call req.res.bind req

  describe "GET /users", ->
    it "should respond with users sorted by username", (callback) ->
      makeRequest(request.get "/users").then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 2
        res.body[0].username.should.equal "Bobby"
        res.body[1].username.should.equal "Zombie"
      .should.notify callback

  describe "POST /users", ->
    it "should create new user", (callback) ->
      req = request.post "/users"

      req.req (req) ->
        req.send username: "Good", password: "Day"

      makeRequest(req).then (res) ->
        res.should.have.status 201
        res.body.username.should.equal "Good"
        res.body.password.should.equal "Day"
        res.body.should.have.property "_id"
        id = res.body._id
      .then ->
        makeRequest request.get "/users"
      .then (res) ->
        res.body.length.should.equal 3
      .should.notify callback

  describe "GET /users/:id", ->
    it "should respond with user", (callback) ->
      makeRequest(request.get "/users/#{id}").then (res) ->
        res.should.have.status 200
        res.body.username.should.equal "Good"
        res.body.password.should.equal "Day"
        res.body._id.should.equal id
      .should.notify callback

  describe "PUT /users/:id", ->
    it "should update user data", (callback) ->
      req = request.put "/users/#{id}"
      
      req.req (req) ->
        req.send username: "Bad"

      makeRequest(req).then (res) ->
        res.should.have.status 200
        res.body.username.should.equal "Bad"
        res.body.password.should.equal "Day"
        res.body._id.should.equal id
      .should.notify callback

  describe "DELETE /users/:id", ->
    it "should delete user", (callback) ->
      makeRequest(request.del "/users/#{id}").then (res) ->
        res.should.have.status 200
        res.body.should.not.have.property "username"
        res.body.should.not.have.property "password"
        res.body.should.not.have.property "_id"
      .then ->
        makeRequest request.get "/users"
      .then (res) ->
        res.body.length.should.equal 2
      .should.notify callback
