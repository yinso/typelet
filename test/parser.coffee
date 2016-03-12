Type = require '../src/type'
Parser = require '../src/parser'
{ assert } = require 'chai'

describe 'parser test', ->

  describe 'primitive parser test', ->

    it 'should parse unit', ->
      assert.strictEqual Type.baseEnv.get('unit'), Parser.parse('unit')

    it 'should parse null', ->
      assert.strictEqual Type.baseEnv.get('null'), Parser.parse('null')

    it 'should parse boolean', ->
      assert.strictEqual Type.baseEnv.get('boolean'), Parser.parse('boolean')
      assert.strictEqual Type.baseEnv.get('boolean'), Parser.parse('bool')

    it 'should parse integer', ->
      assert.strictEqual Type.baseEnv.get('integer'), Parser.parse('integer')
      assert.strictEqual Type.baseEnv.get('integer'), Parser.parse('int')

    it 'should parse float', ->
      assert.strictEqual Type.baseEnv.get('float'), Parser.parse('float')

    it 'should parse date', ->
      assert.strictEqual Type.baseEnv.get('date'), Parser.parse('date')

    it 'should parse string', ->
      assert.strictEqual Type.baseEnv.get('string'), Parser.parse('string')

  describe 'array type parser test', ->

    it 'should parse [ int ]', ->
      assert.ok Type.baseEnv.get('array')(Type.baseEnv.get('integer')).equal Parser.parse('[ int ]', { foo: '1', bar: '2'})

  describe 'object type parser test', ->
    it 'should parse { foo: int , bar: float }', ->
      type = Parser.parse('{ foo: int, bar: float }')
      assert.ok Type.baseEnv.get('object')([ Type.baseEnv.get('property')('foo', Type.baseEnv.get('integer')), Type.baseEnv.get('property')('bar', Type.baseEnv.get('float'))]).equal(type)

    it 'should parse { foo: int = 5, bar: string = \'hello\' }', ->
      type = Parser.parse('{ foo: int = 5, bar: string = \'hello\' }')
      assert.ok Type.baseEnv.get('object')([ Type.baseEnv.get('property')('foo', Type.baseEnv.get('integer'), 5), Type.baseEnv.get('property')('bar', Type.baseEnv.get('string'), 'hello')]).equal(type)

  describe 'one-of type parser test', ->

    it 'should parse (int | null)', ->
      type = Parser.parse('(int | null)')
      assert.ok Type.baseEnv.get('oneOf')( [ Type.baseEnv.get('integer'), Type.baseEnv.get('null') ] ).equal type

  describe 'procedure type parser test', ->

    it 'should parse (int, int) -> int', ->
      type = Type.baseEnv.get('procedure')([ Type.baseEnv.get('integer'), Type.baseEnv.get('integer') ], Type.baseEnv.get('integer'))
      parsed = Parser.parse('(int, int) -> int')
      assert.ok type.equal parsed
