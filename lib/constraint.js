// Generated by CoffeeScript 1.10.0
(function() {
  var AndConstraint, Constraint, EnumConstraint, EqualConstraint, GreaterConstraint, HashMap, LessConstraint, MultipleOf, NotConstraint, OrConstraint, PatternConstraint, Ref, UniqueConstraint, objHelper,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  objHelper = require('./object-helper');

  HashMap = require('./hashmap');

  Ref = require('./ref');

  Constraint = (function() {
    function Constraint() {}

    Constraint.compile = function(obj) {};

    Constraint.prototype.check = function(v) {
      return true;
    };

    return Constraint;

  })();

  Constraint.And = AndConstraint = (function(superClass) {
    extend(AndConstraint, superClass);

    AndConstraint.key = '$and';

    function AndConstraint(list) {
      var item, j, len, ref;
      this.list = list != null ? list : [];
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (!(item instanceof Constriant)) {
          throw new Error("$and_must_take_constraint");
        }
      }
    }

    AndConstraint.prototype.check = function(v) {
      var cons, j, len, ref;
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        cons = ref[j];
        if (!cons.check(v)) {
          return false;
        }
      }
      return true;
    };

    return AndConstraint;

  })(Constraint);

  Constraint.Equal = EqualConstraint = (function(superClass) {
    extend(EqualConstraint, superClass);

    function EqualConstraint(inner) {
      this.inner = inner;
    }

    EqualConstraint.prototype.check = function(v) {
      return objHelper.equal(v, this.inner);
    };

    return EqualConstraint;

  })(Constraint);

  Constraint.Enum = EnumConstraint = (function(superClass) {
    extend(EnumConstraint, superClass);

    function EnumConstraint(list) {
      this.list = list != null ? list : [];
    }

    EnumConstraint.prototype.check = function(v) {
      var item, j, len, ref;
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (objHelper.equal(v, item)) {
          return true;
        }
      }
      return false;
    };

    return EnumConstraint;

  })(Constraint);

  Constraint.Greater = GreaterConstraint = (function(superClass) {
    extend(GreaterConstraint, superClass);

    function GreaterConstraint(min, include) {
      this.min = min;
      this.include = include != null ? include : true;
    }

    GreaterConstraint.prototype.check = function(v) {
      return objHelper.greater(v, this.min, this.include);
    };

    return GreaterConstraint;

  })(Constraint);

  Constraint.Less = LessConstraint = (function(superClass) {
    extend(LessConstraint, superClass);

    function LessConstraint(max, include) {
      this.max = max;
      this.include = include != null ? include : true;
    }

    LessConstraint.prototype.check = function(v) {
      return objHelper.less(v, this.max, this.include);
    };

    return LessConstraint;

  })(Constraint);

  NotConstraint = (function(superClass) {
    extend(NotConstraint, superClass);

    function NotConstraint(inner) {
      this.inner = inner;
      if (!(this.inner instanceof Constraint)) {
        throw new Error("not_must_take_constraint");
      }
    }

    NotConstraint.prototype.check = function(v) {
      return !this.inner.check(v);
    };

    return NotConstraint;

  })(Constraint);

  Constraint.MultipleOf = MultipleOf = (function(superClass) {
    extend(MultipleOf, superClass);

    function MultipleOf(value) {
      this.value = value;
    }

    MultipleOf.prototype.check = function(v) {
      return v / this.value % 1 === 0;
    };

    return MultipleOf;

  })(Constraint);

  Constraint.Or = OrConstraint = (function(superClass) {
    extend(OrConstraint, superClass);

    function OrConstraint(list) {
      var item, j, len, ref;
      this.list = list != null ? list : [];
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (!(item instanceof Constriant)) {
          throw new Error("or_must_take_constraint");
        }
      }
    }

    OrConstraint.prototype.check = function(v) {
      var cons, j, len, ref;
      ref = this.list;
      for (j = 0, len = ref.length; j < len; j++) {
        cons = ref[j];
        if (cons.check(v)) {
          return true;
        }
      }
      return false;
    };

    return OrConstraint;

  })(Constraint);

  Constraint.Pattern = PatternConstraint = (function(superClass) {
    extend(PatternConstraint, superClass);

    function PatternConstraint(pattern) {
      this.pattern = pattern;
      if (!(this.pattern instanceof RegEx)) {
        throw new Error("$pattern_must_taken_regex");
      }
    }

    PatternConstraint.prototype.check = function(v) {
      return v.match(this.pattern);
    };

    return PatternConstraint;

  })(Constraint);

  Constraint.Unique = UniqueConstraint = (function(superClass) {
    extend(UniqueConstraint, superClass);

    function UniqueConstraint() {
      return UniqueConstraint.__super__.constructor.apply(this, arguments);
    }

    UniqueConstraint.prototype.check = function(ary) {
      var i, item, j, len, map;
      map = new HashMap();
      for (i = j = 0, len = ary.length; j < len; i = ++j) {
        item = ary[i];
        if (map.has(item)) {
          return false;
        } else {
          map.set(item, item);
        }
      }
      return true;
    };

    return UniqueConstraint;

  })(Constraint);

  module.exports = Constraint;

}).call(this);