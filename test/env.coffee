class Env
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
