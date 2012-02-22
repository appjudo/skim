this.Skim =
  access: (name) ->
    value = @[name]
    value = value.call(@) if typeof value == "function"
    return [@]            if value == true
    return false          if value == false or !value?
    return [value]        if Object.prototype.toString.call(value) != "[object Array]"
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

    context.escape ||= @escape || (string) ->
      return '' unless string?
      return string if string.skimSafe
      (''+string)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/\//g,'&#47;')

    block.call(context)
