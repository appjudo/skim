class Context
  constructor: ->
    @var = 'instance'
    @x = 0

  id_helper: ->
    "notice"

  hash: ->
    a: 'The letter a', b: 'The letter b'

  show_first: (show = false) ->
    show

  define_macro: (name, block) ->
    @macro ||= {}
    @macro[name] = block
    ''

  call_macro: (name, args...) ->
    @macro[name](args...)

  hello_world: (text = "Hello World from @env", opts = {}) ->
    text + ("#{key} #{value}" for key, value of opts).join(" ")

  callback: (text, block) ->
    if block
      "#{text} #{block()} #{text}"
    else
      text

  message: (args...) ->
    args.join(' ')

  action_path: (args...) ->
    "/action-#{args.join('-')}"

  in_keyword: ->
    "starts with keyword"

  evil_method: ->
    "<script>do_something_evil();</script>"

  method_which_returns_true: ->
    true

  output_number: ->
    1337

  succ_x: ->
    @x = @x + 1

  person: ->
    [{name: 'Joe'}, {name: 'Jack'}]

  people: ->
    ['Andy', 'Fred', 'Daniel'].map (n) -> new Person(n)

  cities: ->
    ['Atlanta', 'Melbourne', 'Karlsruhe']

  people_with_locations: ->
    @people().map (p, i) =>
      p.location = new Location(@cities()[i])
      p

  constant_object: ->
    @_constant_object ||= {a: 1, b: 2}

  constant_object_size: ->
    i = 0
    i++ for k, v of @constant_object()
    i

class Person
  constructor: (@_name) ->
  name: => @_name
  city: => @location.city()

class Location
  constructor: (@_city) ->
  city: => @_city
