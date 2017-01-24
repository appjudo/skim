_._escape = _.escape

_.escape = (string)->
  return string if string.skimSafe
  result = _._escape(string)
  result.skimSafe = true
  result

this.Skim =
  access: (name) ->
    value = @[name]
    value = value.call(@) if _.isFunction(value)
    return [@]            if value == true
    return false          if value == false or !value?
    return [value]        if _.isArray(value)
    return false          if value.length == 0
    return value

  withContext: (context, block) ->
    create = (o) ->
      F = ->
      F.prototype = o
      new F

    context = create(context)

    context.safe ||= @safe || (value) ->
      return value if value?.skimSafe
      result = new String(value ? '')
      result.skimSafe = true
      result

    context.escape ||= @escape || _.escape

    block.call(context)
