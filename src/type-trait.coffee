util = require './util'
Type = require './type'
AnyType = require './any-type'
ArrayType = require './array-type'
TypeBinder = require './type-binder'

class TraitType extends Type
  constructor: (options) ->
    if not (@ instanceof TraitType)
      return new TraitType options
    typeVars = ArrayType(AnyType())
    if not typeVars.isa options.types
      throw new Error("Trait.types must be an array of type variables")
    if not options.name
      throw new Error("Trait must be supplied with a name")
    if not (options.procedures instanceof Object) and Object.keys(options.procedures) > 0
      throw new Error("Trait must implement procedures")
    super()
    util._mixin @,
      name: options.name
      types: options.types
      procedures: options.procedures
  isGeneric: () ->
    return typeVars.length > 0
  implement: (options) ->
    # when we are implementing - what are we doing?
    # we are providing a particular type's implementation
    # first thing we do is that we need to bind the list of the 
    binder = new TypeBinder @types
    
util._mixin Type,
  makeTypeTrait: TraitType

module.exports = TraitType

