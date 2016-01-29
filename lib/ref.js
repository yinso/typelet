// Generated by CoffeeScript 1.10.0
(function() {
  var CallRef, MemberRef, Ref,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  Ref = (function() {
    function Ref() {}

    Ref.prototype.ref = function() {};

    return Ref;

  })();

  Ref.Call = CallRef = (function(superClass) {
    extend(CallRef, superClass);

    function CallRef(func, args1) {
      this.func = func;
      this.args = args1;
    }

    CallRef.prototype.ref = function(v) {
      return this.func.ref(v).apply(v, this.args);
    };

    return CallRef;

  })(Ref);

  MemberRef = (function(superClass) {
    extend(MemberRef, superClass);

    function MemberRef(inner, key) {
      this.inner = inner;
      this.key = key;
    }

    MemberRef.prototype.value = function() {
      var name, object, v;
      v = this.inner[this.name];
      if (typeof v === 'function' || (v instanceof Function)) {
        object = this.inner;
        name = this.key;
        return function() {
          var args;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          return object[name].apply(object, args);
        };
      } else {
        return v;
      }
    };

    return MemberRef;

  })(Ref);

  module.exports = Ref;

}).call(this);