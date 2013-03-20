supertest = require "supertest"
chai = require "chai"


describe "users", ->
  example = null
  test = null
  id = null

  chai.should()

  before (callback) ->
    example = require "../../examples/users/index"
    test = supertest example.app
    example.db.on "fixtured", callback

  describe "GET /users", ->
    it "should respond with users sorted by username", (callback) ->
      req = test.get "/users"
      req.end (err, res) ->
        res.body.length.should.equal 2
        res.body[0].username.should.equal "Bobby"
        res.body[1].username.should.equal "Zombie"
        callback()

  describe "POST /users", ->
    it "should create new user", (callback) ->
      req = test.post "/users"
      req.send username: "Good", password: "Day"
      req.end (err, res) ->
        res.status.should.equal 201
        res.body.username.should.equal "Good"
        res.body.password.should.equal "Day"
        res.body.should.have.property "_id"
        id = res.body._id

        req = test.get "/users"
        req.end (err, res) ->
          res.body.length.should.equal 3
          callback()

  describe "GET /users/:id", ->
    it "should respond with user", (callback) ->
      req = test.get "/users/#{id}"
      req.end (err, res) ->
        res.status.should.equal 200
        res.body.username.should.equal "Good"
        res.body.password.should.equal "Day"
        res.body._id.should.equal id
        callback()

  describe "PUT /users/:id", ->
    it "should update user data", (callback) ->
      req = test.put "/users/#{id}"
      req.send username: "Bad"
      req.end (err, res) ->
        res.status.should.equal 200
        res.body.username.should.equal "Bad"
        res.body.password.should.equal "Day"
        res.body._id.should.equal id
        callback()

  describe "DELETE /users/:id", ->
    it "should delete user", (callback) ->
      req = test.del "/users/#{id}"
      req.end (err, res) ->
        res.status.should.equal 200
        res.body.should.not.have.property "username"
        res.body.should.not.have.property "password"
        res.body.should.not.have.property "_id"

        req = test.get "/users"
        req.end (err, res) ->
          res.body.length.should.equal 2
          callback()
