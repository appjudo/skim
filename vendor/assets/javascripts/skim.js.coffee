this.Skim =
  access: (name) ->
    value = @[name]
    value = value.call(@) if typeof value == "function"
    return [@]            if value == true
    return false          if value == false or !value?
    return [value]        if Object.prototype.toString.call(value) != "[object Array]"
    return false          if value.length == 0
    return value

  safe: (value) ->
      return value if value?.skimSafe
      result = new String(value ? '')
      result.skimSafe = true
      result

  escape: (string) ->
    return '' unless string?
    return string if string.skimSafe
    (''+string)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/\//g,'&#47;')