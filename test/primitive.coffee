Type = require '../src/type'
require '../src/primitive-type'
{ assert } = require 'chai'

describe 'Primitive Type Test', ->

  describe 'Unit test', ->

    it 'can check', ->
      assert.ok Type.Unit.isa()

    it 'can resolve', ->
      assert.ok Type.Unit.equal Type.resolve()

  describe 'Null test', ->

    it 'can check', ->
      assert.ok Type.Null.isa null

    it 'can resolve', ->
      assert.ok Type.Null.equal Type.resolve null
  
  describe 'Boolean test', ->

    it 'can check', ->
      assert.ok Type.Boolean.isa true
      assert.ok Type.Boolean.isa false

    it 'can resolve', ->
      assert.ok Type.Boolean.equal Type.resolve true
      assert.ok Type.Boolean.equal Type.resolve false

    it 'can convert', ->
      assert.ok Type.Boolean.convert 'true'
      
  describe 'Integer test', ->

    it 'can check integer', ->

      assert.ok Type.Integer.isa 1
      assert.notOk Type.Integer.isa 1.5
      assert.notOk Type.Integer.isa null
      assert.notOk Type.Integer.isa true
      assert.notOk Type.Integer.isa '1'

    it 'can assert', ->

      Type.Integer.assert 1
      assert.throws -> Type.Integer.assert 1.5
      assert.throws -> Type.Integer.assert null

    it 'can resolve', ->
      assert.ok Type.Integer.equal Type.resolve 1

  describe 'Float test', ->

    it 'can check', ->
      assert.ok Type.Float.isa 1.5
      assert.notOk Type.Float.isa null

    it 'can assert', ->
      Type.Float.assert 1.5
      assert.throws -> Type.Float.assert 'hello'

    it 'can resolve', ->
      assert.ok Type.Float.equal Type.resolve 1.5

  describe 'Date test', ->
    it 'can check', ->
      assert.ok Type.Date.isa new Date()
    it 'can resolve', ->
      assert.ok Type.Date.equal Type.resolve new Date()

  describe 'String test', ->
    it 'can check', ->
      assert.ok Type.String.isa 'this is a string'
    it 'can resolve', ->
      assert.ok Type.String.equal Type.resolve 'this is a string'

