callbacks = require "when/callbacks"
chai = require "chai"


describe "users", ->
  chai.use require "chai-as-promised"
  chai.use require "chai-http"
  chai.should()

  request = null
  zombieId = null
  bobbyId = null
  goodId = null
  postId = null

  before (callback) ->
    @timeout 0
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
        res.body[0].username.should.equal "Zombie"
        res.body[1].username.should.equal "Bobby"
        zombieId = res.body[0]._id
        bobbyId = res.body[1]._id
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
        goodId = res.body._id
      .then ->
        makeRequest request.get "/users"
      .then (res) ->
        res.body.length.should.equal 3
      .should.notify callback

  describe "PUT /users", ->
    it "should respond with 405", (callback) ->
      req = request.put "/users"

      makeRequest(req).then (res) ->
        res.should.have.status 405
      .should.notify callback

  describe "GET /users/:id", ->
    it "should respond with user", (callback) ->
      makeRequest(request.get "/users/#{goodId}").then (res) ->
        res.should.have.status 200
        res.body.username.should.equal "Good"
        res.body.password.should.equal "Day"
        res.body._id.should.equal goodId
      .should.notify callback

  describe "POST /users/:id", ->
    it "should respond with 405", (callback) ->
      req = request.post "/users/#{goodId}"

      makeRequest(req).then (res) ->
        res.should.have.status 405
      .should.notify callback

  describe "PUT /users/:id", ->
    it "should update user data", (callback) ->
      req = request.put "/users/#{goodId}"
      
      req.req (req) ->
        req.send username: "Bad"

      makeRequest(req).then (res) ->
        res.should.have.status 200
        res.body.username.should.equal "Bad"
        res.body.password.should.equal "Day"
        res.body._id.should.equal goodId
      .should.notify callback

  describe "DELETE /users/:id", ->
    it "should delete user", (callback) ->
      makeRequest(request.del "/users/#{goodId}").then (res) ->
        res.should.have.status 200
        res.body.should.not.have.property "username"
        res.body.should.not.have.property "password"
        res.body.should.not.have.property "_id"
      .then ->
        makeRequest request.get "/users"
      .then (res) ->
        res.body.length.should.equal 2
      .should.notify callback

  describe "GET /sorted-users", ->
    it "should respond with users sorted by username", (callback) ->
      makeRequest(request.get "/sorted-users").then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 2
        res.body[0].username.should.equal "Bobby"
        res.body[1].username.should.equal "Zombie"
      .should.notify callback

  describe "GET /users/:user/posts", ->
    it "should respond with user posts", (callback) ->
      makeRequest(request.get "/users/#{bobbyId}/posts").then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 2
        res.body[0].title.should.equal "example"
        res.body[1].title.should.equal "test"
      .then ->
        makeRequest request.get "/users/#{zombieId}/posts"
      .then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 0
      .should.notify callback

  describe "POST /users/:user/posts", ->
    it "should create new user post", (callback) ->
      req = request.post "/users/#{zombieId}/posts"

      req.req (req) ->
        req.send title: "message", text: "message"

      makeRequest(req).then (res) ->
        res.should.have.status 201
        res.body.should.have.property "title"
        res.body.should.have.property "text"
        res.body.should.have.property "_id"
        postId = res.body._id
      .then ->
        makeRequest request.get "/users/#{zombieId}/posts"
      .then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 1
      .then ->
        makeRequest request.get "/users/#{bobbyId}/posts"
      .then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 2
      .should.notify callback

  describe "PUT /users/:user/posts", ->
    it "should respond with 405", (callback) ->
      makeRequest(request.put "/users/#{bobbyId}/posts").then (res) ->
        res.should.have.status 405
      .should.notify callback

  describe "GET /users/:user/posts/:id", ->
    it "should respond with user post", (callback) ->
      makeRequest(request.get "/users/#{bobbyId}/posts/#{postId}").then (res) ->
        res.should.have.status 404
      .then ->
        makeRequest request.get "/users/#{zombieId}/posts/#{postId}"
      .then (res) ->
        res.should.have.status 200
      .should.notify callback

  describe "POST /users/:user/posts/:id", ->
    it "should respond with 405", (callback) ->
      makeRequest(request.post "/users/#{bobbyId}/posts/#{postId}")
      .then (res) ->
        res.should.have.status 405
      .should.notify callback

  describe "PUT /users/:user/posts/:id", ->
    it "should update user post", (callback) ->
      req = request.put "/users/#{zombieId}/posts/#{postId}"

      req.req (req) ->
        req.send text: "egassem"

      makeRequest(req).then (res) ->
        res.should.have.status 200
        res.body.should.have.property "title"
        res.body.should.have.property "text"
        res.body.should.have.property "_id"
        res.body.title.should.equal "message"
        res.body.text.should.equal "egassem"
      .should.notify callback

  describe "DELETE /users/:user/posts/:id", ->
    it "should delete user post", (callback) ->
      makeRequest(request.del "/users/#{bobbyId}/posts/#{postId}").then (res) ->
        res.should.have.status 404
      .then ->
        makeRequest request.del "/users/#{zombieId}/posts/#{postId}"
      .then (res) ->
        res.should.have.status 200
      .then ->
        makeRequest request.get "/users/#{zombieId}/posts"
      .then (res) ->
        res.should.have.status 200
        res.body.length.should.equal 0
      .should.notify callback

  describe "DELETE /users/:user/posts", ->
    it "should delete user posts", (callback) ->
      makeRequest(request.del "/users/#{bobbyId}/posts").then (res) ->
        res.should.have.status 200
      .then ->
        makeRequest request.get "/users/#{bobbyId}/posts"
      .then (res) ->
        res.body.length.should.equal 0
      .should.notify callback

  describe "DELETE /users", ->
    it "should delete users", (callback) ->
      makeRequest(request.del "/users").then (res) ->
        res.should.have.status 200
      .then ->
        makeRequest request.get "/users"
      .then (res) ->
        res.body.length.should.equal 0
      .should.notify callback
