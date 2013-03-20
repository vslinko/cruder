sinon = require "sinon"
crud = require "../crud"
chai = require "chai"


describe "ListAction", ->
  chai.should()
  chai.use require "sinon-chai"

  describe "#constructor()", ->
    it "should define methods for query chaining", ->
      model = find: sinon.stub()
      listAction = new crud.ListAction model
      model.find.should.have.been.calledOnce
      listAction.sort.should.be.a "function"
