// Generated by CoffeeScript 1.10.0
(function() {
  var Type, TypeClass,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Type = require('./type');

  TypeClass = (function(superClass) {
    extend(TypeClass, superClass);

    function TypeClass() {
      this.types = [];
    }

    TypeClass.prototype.addType = function() {};

    return TypeClass;

  })(Type);

  module.exports = TypeClass;

}).call(this);