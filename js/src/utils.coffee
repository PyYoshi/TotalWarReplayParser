## ロガー
_l = (msg)->
  if DEBUG == true
    if (typeof window.console.log == 'undefined')
      window.console.info(msg)
    else
      window.console.log(msg)
  return

_i = (msg)->
  if DEBUG == true then window.console.info(msg)
  return

_d = (msg)->
  if DEBUG == true
    if (typeof window.console.debug == 'undefined')
      window.console.info(msg)
    else
      window.console.debug(msg)
  return

_w = (msg)->
  if DEBUG == true then window.console.warn(msg)
  return

_e = (msg)->
  if DEBUG == true then window.console.error(msg)
  return

_g = (msgs=[], logMethod=_l)->
  if DEBUG == true
    if (typeof window.console.group == 'undefined')
      logMethod('-- Start Group Log --')
      logMethod('\t'+msg) for msg in msgs
      logMethod('--- End Group Log ---')
    else
      window.console.group()
      logMethod(msg) for msg in msgs
      window.console.groupEnd()
  return

# @see http://www.discoded.com/2012/04/05/my-favorite-javascript-string-extensions-in-coffeescript/
if (typeof String::startsWith != 'function')
  String::startsWith = (str) ->
    return this.slice(0, str.length) == str

if (typeof String::endsWith != 'function')
  String::endsWith = (str) ->
    return this.slice(-str.length) == str

if (typeof String::addCommas != 'function')
  String::addCommas = ->
    str = this
    str += ''
    x = str.split('.')
    x1 = x[0]
    x2 = if x.length > 1 then '.' + x[1] else ''
    rgx = /(\d+)(\d{3})/
    while (rgx.test(x1))
      x1 = x1.replace(rgx, '$1' + ',' + '$2')
    x1 + x2

if (typeof String::lpad != 'function')
  String::lpad = (padString, length) ->
    str = this
    while str.length < length
      str = padString + str
    return str

if (typeof String::rpad != 'function')
  String::rpad = (padString, length) ->
    str = this
    while str.length < length
      str = str + padString
    return str

if (typeof String::trim != 'function')
  String::trim = ->
    this.replace(/^\s+|\s+$/g, '')

###

###
isArguments = (obj)->
  return Object.prototype.toString.call(obj) == '[object Arguments]'
isFunction = (obj)->
  return Object.prototype.toString.call(obj) == '[object Function]'
isString = (obj)->
  return Object.prototype.toString.call(obj) == '[object String]'
isNumber = (obj)->
  return Object.prototype.toString.call(obj) == '[object Number]'
isDate = (obj)->
  return Object.prototype.toString.call(obj) == '[object Date]'
isRegExp = (obj)->
  return Object.prototype.toString.call(obj) == '[object RegExp]'
isObject = (obj)->
  return obj == Object(obj)
isArray = Array.isArray || (obj)->
  return Object.prototype.toString.call(obj) == '[object Array]'
isElement = (obj)->
  return !!(obj && obj.nodeType == 1)

###
  CoffeeScript's implementation of Python's range()
###
range = (start=null, end=null)->
  if start == null then throw new TypeError('range() takes 1 or 2 arguments')
  result = []
  if isNumber(start) && end == null
    for i in [0...start]
      result.push(i)
  else if isNumber(start) && end != null
    for i in [start...end]
      result.push(i)
  return result