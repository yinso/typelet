equal = (o1, o2) ->
  if o1 == o2
    true
  else if o1 instanceof Array
    if o2 instanceof Array
      equalArray o1, o2
    else
      false
  else
    equalObject o1, o2

equalObject = (o1, o2) ->
  keys1 = Object.keys o1
  keys2 = Object.keys o2
  if keys1.length != keys2.length
    false
  else
    for key, val of o1
      if o1.hasOwnProperty(key)
        if not deepEqual(val, o2[key])
          return false
    true

equalArray = (a1, a2) ->
  if a1.length != a2.length
    false
  else
    for item, i in a1
      if not deepEqual(item, a2[i])
        return false
    true

inside = (a, list) ->
  for item in list
    if equal(a, item)
      return true
  false

isSubClassOf = (A, B) ->
  (A.prototype instanceof B) or A == B

module.exports =
  equal: equal
  inside: inside
  isSubClassOf: isSubClassOf


