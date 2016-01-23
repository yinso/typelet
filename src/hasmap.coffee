equal = (x, y) -> x == y

hashCode = (str) ->
  hash = 0
  if str.length == 0
    return hash
  for i in [0...str.length]
    char = str.charCodeAt i 
    hash = ((hash<<5) - hash) + char
    hash = hash & hash
  return hash

class HashMap
  @defaultOptions:
    hashCode: hashCode
    equal: (k, v) -> k == v
  constructor: (options) ->
    @buckets = []
    @hashCode = options.hashCode or hashCode
    @equal = options.equal or equal
  set: (key, val) ->
    hashCode = @hashCode key
    @buckets[hashCode] = @buckets[hashCode] or []
    for kv in @buckets[hashCode]
      if @equal kv.key, key
        kv.val = val
        return @
    @bucket[hashCode].push { key: key, val: val }
  _get: (key) ->
    hashCode = @hashCode key
    for kv in @buckets[hashCode] or []
      if @equal kv.key, key
        return kv
    undefined
  get: (key) ->
    res = @_get key
    if res
      res.val
    else
      res
  has: (key) ->
    res = @_get key
    res instanceof Object
  delete: (key) ->
    hashCode = @hashCode key
    if not @buckets.hasOwnProperty(hashCode)
      return false
    count = -1
    for kv, i in @buckets[hashCode]
      if @equal kv.key, key
        count = i
    if count != -1
      @buckets[hashCode].splice count, 1
      true
    else
      false
  keys: () ->
    res = []
    for hashCode , bucket of (@buckets or [])
      for { key , val } in bucket
        res.push key
    res
  values: () ->
    res = []
    for hashCode , bucket of (@buckets or [])
      for { key , val } in bucket
        res.push val
    res
    
module.exports = HashMap
