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

    context.isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

    context.flatten = flatten = (array) ->
      flattened = []
      for element in array
        if element instanceof Array
          flattened = flattened.concat flatten element
        else
          flattened.push element
      flattened

    context.escape ||= @escape || (string) ->
      return '' unless string?
      if string.skimSafe or not /[&<>\"]/.test(string)
        return string

      @safe(('' + string)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;'))

    block.call(context)
