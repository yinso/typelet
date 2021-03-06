// Generated by CoffeeScript 1.10.0
(function() {
  var AnyType, ArrayType, TraitType, Type, TypeBinder, util,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  util = require('./util');

  Type = require('./type');

  AnyType = require('./any-type');

  ArrayType = require('./array-type');

  TypeBinder = require('./type-binder');

  TraitType = (function(superClass) {
    extend(TraitType, superClass);

    function TraitType(options) {
      var typeVars;
      if (!(this instanceof TraitType)) {
        return new TraitType(options);
      }
      typeVars = ArrayType(AnyType());
      if (!typeVars.isa(options.types)) {
        throw new Error("Trait.types must be an array of type variables");
      }
      if (!options.name) {
        throw new Error("Trait must be supplied with a name");
      }
      if (!(options.procedures instanceof Object) && Object.keys(options.procedures) > 0) {
        throw new Error("Trait must implement procedures");
      }
      TraitType.__super__.constructor.call(this);
      util._mixin(this, {
        name: options.name,
        types: options.types,
        procedures: options.procedures
      });
    }

    TraitType.prototype.isGeneric = function() {
      return typeVars.length > 0;
    };

    TraitType.prototype.implement = function(options) {
      var binder;
      return binder = new TypeBinder(this.types);
    };

    return TraitType;

  })(Type);

  util._mixin(Type, {
    makeTypeTrait: TraitType
  });

  module.exports = TraitType;

}).call(this);
