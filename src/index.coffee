Type = require './type'
require './primitive-type'
require './any-type'
require './array-type'
require './property-type'
require './object-type'
require './oneof-type'
require './procedure-type'
require './type-trait'
require './json-schema'

util = require './util'

parser = require('./parser')
util._mixin Type,
  Parser: parser
  parse: (exps) ->
    parser.parse exps

module.exports = Type

