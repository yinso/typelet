// Generated by CoffeeScript 1.10.0
(function() {
  var equal, equalArray, equalObject, inside, isSubClassOf;

  equal = function(o1, o2) {
    if (o1 === o2) {
      return true;
    } else if (o1 instanceof Array) {
      if (o2 instanceof Array) {
        return equalArray(o1, o2);
      } else {
        return false;
      }
    } else {
      return equalObject(o1, o2);
    }
  };

  equalObject = function(o1, o2) {
    var key, keys1, keys2, val;
    keys1 = Object.keys(o1);
    keys2 = Object.keys(o2);
    if (keys1.length !== keys2.length) {
      return false;
    } else {
      for (key in o1) {
        val = o1[key];
        if (o1.hasOwnProperty(key)) {
          if (!deepEqual(val, o2[key])) {
            return false;
          }
        }
      }
      return true;
    }
  };

  equalArray = function(a1, a2) {
    var i, item, j, len;
    if (a1.length !== a2.length) {
      return false;
    } else {
      for (i = j = 0, len = a1.length; j < len; i = ++j) {
        item = a1[i];
        if (!deepEqual(item, a2[i])) {
          return false;
        }
      }
      return true;
    }
  };

  inside = function(a, list) {
    var item, j, len;
    for (j = 0, len = list.length; j < len; j++) {
      item = list[j];
      if (equal(a, item)) {
        return true;
      }
    }
    return false;
  };

  isSubClassOf = function(A, B) {
    return (A.prototype instanceof B) || A === B;
  };

  module.exports = {
    equal: equal,
    inside: inside,
    isSubClassOf: isSubClassOf
  };

}).call(this);
