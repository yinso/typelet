Type = require '../src/type'
require '../src/primitive-type'
{ assert } = require 'chai'

typeEnv = Type.baseEnv

describe 'Primitive Type Test', ->

  describe 'Unit test', ->

    it 'can check', ->
      assert.ok typeEnv.get('unit').isa()

    it 'can resolve', ->
      assert.ok typeEnv.get('unit').equal Type.resolve()

  describe 'Null test', ->

    it 'can check', ->
      assert.ok typeEnv.get('null').isa null

    it 'can resolve', ->
      assert.ok typeEnv.get('null').equal Type.resolve null

  describe 'Boolean test', ->

    it 'can check', ->
      assert.ok typeEnv.get('boolean').isa true
      assert.ok typeEnv.get('boolean').isa false

    it 'can resolve', ->
      assert.ok typeEnv.get('boolean').equal Type.resolve true
      assert.ok typeEnv.get('boolean').equal Type.resolve false

    it 'can convert', ->
      assert.ok typeEnv.get('boolean').convert 'true'

    it 'can assign from', ->
      assert.ok typeEnv.get('boolean').canAssignFrom typeEnv.get('boolean')

  describe 'Integer test', ->

    it 'can check integer', ->

      assert.ok typeEnv.get('integer').isa 1
      assert.notOk typeEnv.get('integer').isa 1.5
      assert.notOk typeEnv.get('integer').isa null
      assert.notOk typeEnv.get('integer').isa true
      assert.notOk typeEnv.get('integer').isa '1'

    it 'can assert', ->

      typeEnv.get('integer').assert 1
      assert.throws -> typeEnv.get('integer').assert 1.5
      assert.throws -> typeEnv.get('integer').assert null

    it 'can resolve', ->
      assert.ok typeEnv.get('integer').equal Type.resolve 1

    it 'can convert', ->
      assert.equal 5, typeEnv.get('integer').convert '5'
      assert.equal 6, typeEnv.get('integer').convert 5.5 # this is explicit in the sense that users will call this function directly.
      #assert.throws -> typeEnv.get('integer').convert 5.5, { path : '$', isExplicit: false } # this is implicit in the sense that it afford programmatic way to control an implicit behavior
      assert.throws -> typeEnv.get('integer').convert null

    it 'can assign from', ->
      assert.ok typeEnv.get('integer').canAssignFrom typeEnv.get('integer')
      assert.notOk typeEnv.get('integer').canAssignFrom typeEnv.get('float')

  describe 'Float test', ->

    it 'can check', ->
      assert.ok typeEnv.get('float').isa 1.5
      assert.notOk typeEnv.get('float').isa null

    it 'can assert', ->
      typeEnv.get('float').assert 1.5
      assert.throws -> typeEnv.get('float').assert 'hello'

    it 'can resolve', ->
      assert.ok typeEnv.get('float').equal Type.resolve 1.5

    it 'can assign from', ->
      assert.ok typeEnv.get('float').canAssignFrom typeEnv.get('float')
      #assert.ok typeEnv.get('float').canAssignFrom typeEnv.get('integer')

  describe 'Date test', ->
    it 'can check', ->
      assert.ok typeEnv.get('date').isa new Date()
    it 'can resolve', ->
      assert.ok typeEnv.get('date').equal Type.resolve new Date()
    it 'can convert', ->
      assert.throws -> typeEnv.get('date').convert 'hello'


  describe 'String test', ->
    it 'can check', ->
      assert.ok typeEnv.get('string').isa 'this is a string'
    it 'can resolve', ->
      assert.ok typeEnv.get('string').equal Type.resolve 'this is a string'
