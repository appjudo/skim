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

    currentNode = nodes = []

    context.skimElement = (type, attrs, children = null) ->
      throw new Error('Element type missing') unless type
      node = [type, attrs]
      currentNode.push node
      if children
        oldNode = currentNode
        currentNode = node
        children.call(this)
        currentNode = oldNode
      null

    context.skimInsertNodes = (elements) ->
      unless elements instanceof Array
        elements = [elements]
      for element in elements
        throw new Error('Element type missing') unless element.type
        currentNode.push(element)

    context.skimInsertNode = (element) ->
      context.skimInsertNodes [element]

    context.skimText = (str) ->
      currentNode.push str
      null

    skimReactNode = (node) ->
      return node unless @isArray(node)
      children = []
      for index in [2..node.length]
        children.push skimReactNode.call(this, node[index])
      React.createElement(node[0], node[1], children...)

    context.skimReact = ->
      switch nodes.length
        when 0
          return null
        when 1
          rootNode = nodes[0]
        else
          rootNode = ['div', null, nodes...]
      skimReactNode.call(this, rootNode)

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

    context.escape ||= @escape || (value) ->
      return null unless value?
      if typeof value == 'function' or value.skimSafe or not /[&<>\"]/.test(value)
        return value

      @safe(('' + value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;'))

    context.mergeValues = (value, escape, delimiter) ->
      if @isArray(value)
        value = @flatten(value)
        value = (item.toString() for item in value when item)
        value = (item for item in value when item.length > 0)
        value = value.join(delimiter)
      if escape then @escape(value) else value

    block.call(context)
