Object.prototype.clone = function(deepClone) {
  var result = new this.constructor()
  for (var property in this) {
    if (deepClone && typeof(this[property]) == 'object') {
      result[property] = this[property].clone(deepClone)
    } else {
      result[property] = this[property]
    }
  }
  return(result)
}

Object.prototype.extend = function(other) {
  if (!this.mixins) this.mixins = []
  this.mixins.push(other)
  for (var property in other)
    if (!this.hasOwnProperty(property))
      this[property] = other[property]
}

Object.prototype.cmp = function(other) {
  if (this < other) return(-1)
  if (this > other) return(+1)
  return(0)
}

Object.prototype.valuesAt = function() {
  var obj = this
  return(arguments.toArray().map(function(index) {
    return(obj[index])
  }))
}

Object.prototype.toArray = function() {
  if (!this.length) throw("Can't convert")
  var result = []
  for (var i = 0; i < this.length; i++)
    result.push(this[i])
  return(result)
}

Object.prototype.hash = function() {
  return(this.toSource().hash())
}

Object.prototype.instanceOf = function(klass) {
  return(this.constructor == klass)
}

Object.prototype.isA = Object.prototype.kindOf = function(klass) {
  if (this.instanceOf(klass)) return(true)
  if (this["mixins"] != undefined && this.mixins.includes(klass))
    return(true)
  return(false)
}

Object.prototype.methods = function() {
  var result = []
  for (var property in this)
    if (typeof(this[property]) == "function")
      result.push(property)
  return(result)
}

Object.prototype.respondTo = function(method) {
  return(this.methods().includes(method))
}

Object.prototype.send = function(method) {
  var rest = arguments.toArray().last(-1)
  if (!this.respondTo(method)) throw("undefined method")
  return(this[method].apply(this, rest))
}

Object.prototype.instanceEval = function(code) {
  if (code.isA(Function))
    return(code.apply(this))
  return(eval(code.toString()))
}

Number.prototype.times = function(block) {
  for (var i = 0; i < this; i++) block(i)
}

Number.prototype.upto = function(other, block) {
  for (var i = this; i <= other; i++) block(i)
}

Number.prototype.downto = function(other, block) {
  for (var i = this; i >= other; i--) block(i)
}

Number.prototype.towards = function(other, block) {
  var step = this.cmp(other)
  for (var i = this; i !== other - step; i -= step)
    block(i) 
}

Number.prototype.succ = function() { return(this + 1) }
Number.prototype.pred = function() { return(this - 1) }

Number.prototype.chr = function() { return(String.fromCharCode(this)) }

var enumerable = new Object()
enumerable.eachWindow = function(window, block) {
  if (!window.isA(Range)) window = range(0, window)
  var elements = [], pushed = 0
  this.each(function(item, index) {
    elements.push(item)
    pushed += 1
    if (pushed % window.rend == 0) {
      var start = [0, window.start - window.rend + pushed].max()
      var end = [0, window.rend + pushed].max()
      block(elements.fetch(xrange(start, end)), index)
    }
  })
}

enumerable.collect = enumerable.map = function(block) {
  var result = []
  this.each(function(item, index) {
    result.push(block(item, index))
  })
  return(result)
}

enumerable.toArray = enumerable.entries = function() {
  return(this.map(function(item) { return(item) }))
}

enumerable.inject = function(firstArg) {
  var state, block, first = true
  if (arguments.length == 1) {
    block = firstArg
  } else {
    state = firstArg
    block = arguments[1]
  }
  this.each(function(item, index) {
    if (first && typeof(state) == "undefined")
      state = item, first = false
    else
      state = block(state, item, index)
  })
  return(state)
}

enumerable.find = enumerable.detect = function(block) {
  var result, done
  this.each(function(item, index) {
    if (!done && block(item, index)) {
      result = item
      done = true
    }
  })
  return(result)
}

enumerable.findAll = enumerable.select = function(block) {
  return(this.inject([], function(result, item, index) {
    return(block(item, index) ? result.add(item) : result)
  }))
}

enumerable.grep = function(obj) {
  return(this.findAll(function(item) {
    return(obj.test(item))
  }))
}

enumerable.reject = function(block) {
  return(this.select(function(item, index) {
    return(!block(item, index))
  }))
}

enumerable.compact = function() {
  return(this.select(function(item) {
    return(typeof(item) != "undefined")
  }))
}

enumerable.nitems = function() { return(this.compact().length) }

enumerable.sortBy = function(block) {
  return(this.map(function(item, index) {
    return([block(item, index), item])
  }).sort(function(a, b) {
    return(a[0].cmp(b[0]))
  }).map(function(item) {
    return(item[1])
  }))
}

enumerable.all = function(block) {
  return(this.findAll(block).length == this.length)
}

enumerable.any = function(block) {
  return(typeof(this.find(block)) != "undefined")
}

enumerable.includes = function(obj) {
  return(this.any(function(item) {
    return(item === obj)
  }))
}

enumerable.index = function(obj) {
  var result
  this.find(function(item, index) {
    if (obj == item) {
      result = index
      return(true)
    } else {
      return(false)
    }
  })
  return(result)
}

enumerable.uniq = function() {
  return(this.inject([], function(result, item) {
    return(result.includes(item) ? result : result.add(item))
  }))
}

enumerable.max = function(block) {
  if (!block) block = function(a, b) { return(a.cmp(b)) }
  return(this.sort(block).last())
}

enumerable.min = function(block) {
  if (!block) block = function(a, b) { return(a.cmp(b)) }
  return(this.sort(block).first())
}

enumerable.partition = function(block) {
  var positives = [], negatives = []
  this.each(function(item, index) {
    if (block(item, index))
      positives.push(item)
    else
      negatives.push(item)
  })
  return([positives, negatives])
}

enumerable.zip = function() {
  var ary = arguments.toArray()
  ary.unshift(this)
  return(ary.transpose())
}

enumerable.flatten = function(depth) {
  if (depth == undefined) depth = -1
  if (!depth) return(this)
  return(this.inject([], function(result, item) {
    var flatItem = item.respondTo("flatten") ? item.flatten(depth - 1) : [item]
    return(result.merge(flatItem))
  }))
}

Array.fromObject = function(obj) {
  if (!obj.length) throw("Can't convert")
  var result = []
  for (var i = 0; i < obj.length; i++)
    result.push(obj[i])
  return(result)
}

Array.prototype.transpose = function() {
  var result, length = -1
  this.each(function(item, index) {
    if (length < 0) {	/* first element */
      length = item.length
      result = Array.withLength(length, function() {
        return(new Array(this.length))
      })
    } else if (length != item.length) {
      throw("Element sizes differ")
    }
    item.each(function(iitem, iindex) {
      result[iindex][index] = iitem
    })
  })
  return(result)
}

Array.withLength = function(length, fallback) {
  var result = [null].mul(length)
  result.fill(fallback)
  return(result)
}

Array.prototype.each = function(block) {
  for (var index = 0; index < this.length; ++index) {
    var item = this[index]
    block(item, index)
  }
  return(this)
}
Array.prototype.extend(enumerable)

Array.prototype.isEmpty = function() { return(this.length == 0) }

Array.prototype.at = Array.prototype.fetch = function(index, length) {
  if (index.isA(Range)) {
    var end = index.rend + (index.rend < 0 ? this.length : 0)
    index = index.start
    length = end - index + 1
  }
  if (length == undefined) length = 1
  if (index < 0) index += this.length
  var result = this.slice(index, index + length)
  return(result.length == 1 ? result[0] : result)
}

Array.prototype.first = function(amount) {
  if (amount == undefined) amount = 1
  return(this.at(xrange(0, amount)))
}

Array.prototype.last = function(amount) {
  if (amount == undefined) amount = 1
  return(this.at(range(-amount, -1)))
}

Array.prototype.store = function(index) {
  var length = 1, obj
  arguments = arguments.toArray()
  arguments.shift()
  if (arguments.length == 2)
    length = arguments.shift()
  obj = arguments.shift()
  if (!obj.isA(Array)) obj = [obj]
  if (index.isA(Range)) {
    var end = index.rend + (index.rend < 0 ? this.length : 0)
    index = index.start
    length = end - index + 1
  }
  if (index < 0) index += this.length
  this.replace(this.slice(0, index).merge(obj).merge(this.slice(index + length)))
  return(this)
}

Array.prototype.insert = function(index) {
  var values = arguments.toArray().last(-1)
  if (index < 0) index += this.length + 1
  return(this.store(index, 0, values))
}

Array.prototype.update = function(other) {
  var obj = this
  other.each(function(item) { obj.push(item) })
  return(obj)
}

Array.prototype.merge = Array.prototype.concat
Array.prototype.add = function(item) { return(this.merge([item])) }

Array.prototype.clear = function() {
  var obj = this
  this.length.times(function(index) {
    delete obj[index]
  })
  this.length = 0
}

Array.prototype.replace = function(obj) {
  this.clear()
  this.update(obj)
}

Array.prototype.mul = function(count) {
  var result = []
  var obj = this
  count.times(function() { result = result.merge(obj) })
  return(result)
}

Array.prototype.fill = function(value) {
  var old_length = this.length
  var obj = this
  this.clear()
  var block
  if (typeof(value) != "function")
    block = function() { return(value) }
  else
    block = value

  old_length.times(function(i) {
    obj.push(block(i))
  })
}

Array.prototype.removeAt = function(targetIndex) {
  var result = this[targetIndex]
  var newArray = this.reject(function(item, index) {
    return(index == targetIndex)
  })
  this.replace(newArray)
  return(result)
}

Array.prototype.remove = function(obj) {
  this.removeAt(this.index(obj))
}

Array.prototype.removeIf = function(block) {
  this.replace(this.reject(block))
}

function Range(start, end, excludeEnd) {
  this.begin = this.start = start
  this.end = end
  this.excludeEnd = excludeEnd
  this.rend = excludeEnd ? end.pred() : end
  this.length = this.toArray().length
}

function range(start, end) { return(new Range(start, end)) }
function xrange(start, end) { return(new Range(start, end, true)) }

Range.prototype.toString = function() {
  return("" + this.start + (this.excludeEnd ? "..." : "..") + this.end)
}

Range.prototype.each = function(block) {
  var index = 0
  this.start.towards(this.rend, function(i) {return(block(i, index++))})
}
Range.prototype.extend(enumerable)

Range.prototype.includes = function(item) {
  return(this.start.cmp(item) == -1 && this.rend.cmp(item) == +1)
}

function Hash(defaultBlock) {
  this.defaultBlock = defaultBlock
  this.keys = []
  this.values = []
  this.length = 0
}

Hash.fromArray = function(array) {
  var result = new Hash()
  array.each(function(item) {
    var key = item[0], value = item[1]
    result.store(key, value)
  })
  return(result)
}

Hash.prototype.at = Hash.prototype.fetch = function(key, block) {
  if (this.hasKey(key))
    return this["item_" + key.hash()]
  else if (block)
    return block(key)
  else
    return defaultBlock(key)
}

Hash.prototype.store = function(key, value) {
  this.keys.push(key)
  this.values.push(value)
  this.length++
  return(this["item_" + key.hash()] = value)
}

Hash.prototype.toA = function() {
  return(this.keys.zip(this.values))
}

Hash.prototype.isEmpty = function() {
  return(this.length == 0)
}

Hash.prototype.has = Hash.prototype.includes = Hash.prototype.hasKey = function(key) {
  return(hasOwnProperty("item_" + key.hash()))
}

Hash.prototype.hasValue = function(value) {
  return(this.values.includes(value))
}

Hash.prototype.each = function(block) {
  this.toA().each(function (pair) {
    return(block(pair[1], pair[0]))
  })
}

Hash.prototype.extend(enumerable)

Hash.prototype.merge = function(other) {
  other.each(function(value, key) {
    this.store(key, value)
  })
}

Hash.prototype.remove = function(key) {
  var valueIndex = this.keys.index(key)
  var value = this.values[valueIndex]
  this.keys.remove(key)
  this.values.removeAt(valueIndex)
  delete(this["item_" + key.hash()])
  this.length--
  return([key, value])
}

Hash.prototype.removeIf = function(block) {
  this.each(function(value, key) {
    if (block(value, key))
      this.remove(key)
  })
}

Hash.prototype.shift = function() {
  return(this.remove(this.keys[0]))
}

Hash.prototype.clear = function() {
  var obj = this
  this.length.times(function() {obj.shift()})
}

Hash.prototype.replace = function(obj) {
  this.clear()
  this.merge(obj)
}

Hash.prototype.invert = function() {
  return(Hash.fromArray(this.map(function(value, key) {
    return([value, key])
  })))
}

Hash.prototype.rehash = function() {
  var result = new Hash(this.defaultBlock)
  this.each(function(value, key) {
    result.store(key, value)
  })
  this.replace(result)
}

function MatchData(matches, str, pos) {
  this.matches = matches, this.string = str
  this.begin = this.position = pos
  this.match = matches[0]
  this.captures = matches.slice(1)
  this.end = pos + this.match.length
  this.length = matches.length
  this.preMatch = str.substr(0, pos)
  this.postMatch = str.substr(this.end)
}

MatchData.prototype.toString = function() { return(this.match) }
MatchData.prototype.at = function(index) {
  return(this.matches.at(index))
}
MatchData.prototype.toArray = function() { return(this.matches) }

RegExp.prototype.match = function(str) {
  var matches = this.exec(str)
  if (matches) {
    var pos = str.search(this)
    return(new MatchData(matches, str, pos))
  }
}

String.prototype.clone = function() { return(new String(this)) }

String.prototype.each = function(block) {
  this.split("\n").each(block)
}

String.prototype.extend(enumerable)

String.prototype.toArray = function() { return(this.split("\n")) }

String.prototype.towards = function(other, block) {
  var item = this
  while (item.cmp(other) <= 0) {
    block(item)
    item = item.succ()
  }
}

String.prototype.hash = function() {
  var result = 0
  this.split("").each(function(item) {
    result += item.charCodeAt(0)
    result += (result << 10)
    result ^= (result >> 6)
  })
  result += (result << 3)
  result ^= (result >> 11)
  result += (result << 15)
  return(result)
}

String.prototype.chars = function() { return(this.split("")) }

String.prototype.at = String.prototype.fetch = function(index, length) {
  if (index.isA(Range)) {
    var end = index.rend + (index.rend < 0 ? this.length : 0)
    index = index.start
    length = end - index + 1
  }
  if (length == undefined) length = 1
  if (index < 0) index += this.length
  return(this.substr(index, length))
}

String.prototype.store = String.prototype.change = function(index) {
  var length = 1, obj
  arguments = arguments.toArray()
  arguments.shift()
  if (arguments.length == 2)
    length = arguments.shift()
  obj = arguments.shift()
  if (index.isA(Range)) {
    var end = index.rend + (index.rend < 0 ? this.length : 0)
    index = index.start
    length = end - index + 1
  }
  if (index < 0) index += this.length
  return(this.substr(0, index) + obj + this.substr(index + length))
}

String.prototype.reverse = function() {
  return(this.split("").reverse().join(""))
}

String.prototype.scan = function(pattern) {
  var str = this, result = [], oldPos = -1, match, offset = 0
  while (match = pattern.match(str)) {
    if (match.end == match.begin)
      throw("Can't have null length matches with scan()")
    var newMatch = new MatchData(match.matches, match.string, match.position + offset)
    result.push(newMatch)
    str = match.postMatch
    offset += match.toString().length
  }
  return(result)
}

String.prototype.sub = function(what, by, global) {
  var block = typeof(by) == "function" ? by : function() { return(by) }
  var matches = this.scan(what), result = this, offset = 0
  if (!global && !by.global) matches = matches.slice(0, 1)
  matches.each (function(match) {
    var replacement = block(match)
    offset += replacement.length - match.toString().length
    result = result.change(match.begin + offset, match.toString().length, replacement)
  })
  return(result)
}
String.prototype.gsub = function(what, by) { return(this.sub(what, by, true)) }

String.prototype.tr = function(from, to) {
  var map = Hash.fromArray(from.chars().zip(to.chars()))
  return(this.chars().map(function(chr) {
    return(map.includes(chr) ? map.fetch(chr) : chr)
  }).join(""))
}

String.prototype.mul = function(other) {
  var result = "", str = this
  other.times(function() { result += str })
  return(result)
}

String.prototype.isUpcase = function() { return(this == this.upcase()) }
String.prototype.isDowncase = function() { return(this == this.downcase()) }
String.prototype.isCapitalized = function() {
  return(this.fetch(0).isUpcase() && this.fetch(range(1, -1)).isDowncase())
}
String.prototype.upcase = String.prototype.toUpperCase
String.prototype.downcase = String.prototype.toLowerCase
String.prototype.capitalize = function() {
  return(this.fetch(0).upcase() + this.fetch(range(1, -1)).downcase())
}
String.prototype.swapcase = function() {
  return(this.chars().map(function(chr) {
    if (chr.isUpcase()) return(chr.downcase())
    if (chr.isDowncase()) return(chr.upcase())
    return(chr)
  }).join(""))
}
String.prototype.ord = function() { return(this.charCodeAt(0)) }

String.prototype.isEmpty = function() { return(this.length == 0) }

String.prototype.succ = function() {
  if (this.isEmpty()) return(this)
  /* numerics */
  if (/^\d+$/.test(this))
    return((Number(this) + 1).toString())
  /* just one character */
  if (this.length == 1) {
    /* letters */
    if (/[A-Za-z]/.test(this)) {
      var lastLetter = this.isUpcase() ? 'Z' : 'z'
      var firstLetter = this.isUpcase() ? 'A' : 'a'
      return((this == lastLetter) ? firstLetter.mul(2) : (this.ord() + 1).chr())
    }
    return(this == (-1).chr() ? 0.0.chr().mul(2) : (this.ord() + 1).chr())
  }
  /* multiple characters */
  var result = this
  for (var index = this.length; --index >= 0; ) {
    var chr = this.at(index)
    if (chr.succ().length == 1 || index == 0)
      return(result.change(index, chr.succ()))
    result = result.change(index, chr.succ().at(-1))
  }
  return(result);
}

String.prototype.ljust = function(length, fill) {
  if (!fill) fill = " "
  if (fill.length > 1) throw("TODO: Make fills with length > 1 work.")
  return(this + fill.mul(length / fill.length - this.length))
}
