Type = require '../src/type'
Parser = require '../src/parser'
{ assert } = require 'chai'

describe 'parser test', ->

  describe 'primitive parser test', ->

    it 'should parse unit', ->
      assert.strictEqual Type.Unit, Parser.parse('unit')
    
    it 'should parse null', ->
      assert.strictEqual Type.Null, Parser.parse('null')

    it 'should parse boolean', ->
      assert.strictEqual Type.Boolean, Parser.parse('boolean')
      assert.strictEqual Type.Boolean, Parser.parse('bool')

    it 'should parse integer', ->
      assert.strictEqual Type.Integer, Parser.parse('integer')
      assert.strictEqual Type.Integer, Parser.parse('int')
    
    it 'should parse float', ->
      assert.strictEqual Type.Float, Parser.parse('float')

    it 'should parse date', ->
      assert.strictEqual Type.Date, Parser.parse('date')

    it 'should parse string', ->
      assert.strictEqual Type.String, Parser.parse('string')

  describe 'array type parser test', ->

    it 'should parse [ int ]', ->
      assert.ok Type.ArrayType(Type.Integer).equal Parser.parse('[ int ]', { foo: '1', bar: '2'})
  
  describe 'object type parser test', ->
    it 'should parse { foo: int , bar: float }', ->
      type = Parser.parse('{ foo: int, bar: float }')
      assert.ok Type.ObjectType([ Type.PropertyType('foo', Type.Integer), Type.PropertyType('bar', Type.Float)]).equal(type)
  
    it 'should parse { foo: int = 5, bar: string = \'hello\' }', ->
      type = Parser.parse('{ foo: int = 5, bar: string = \'hello\' }')
      assert.ok Type.ObjectType([ Type.PropertyType('foo', Type.Integer, 5), Type.PropertyType('bar', Type.String, 'hello')]).equal(type)

  describe 'one-of type parser test', ->

    it 'should parse (int | null)', ->
      type = Parser.parse('(int | null)')
      assert.ok Type.OneOfType(Type.Integer, Type.Null).equal type

  describe 'procedure type parser test', ->

    it 'should parse (int, int) -> int', ->
      type = Type.ProcedureType([ Type.Integer, Type.Integer ], Type.Integer)
      parsed = Parser.parse('(int, int) -> int')
      assert.ok type.equal parsed

