# coding: utf-8
require 'helper'
require 'open3'
require 'tempfile'

class TestSkimCommands < Minitest::Test
  # nothing complex
  STATIC_TEMPLATE = "p Hello World!\n"

  # requires a `name` variable to exist at render time
  DYNAMIC_TEMPLATE = "p Hello \#{name}!\n"

  # a more complex example
  LONG_TEMPLATE = "h1 Hello\np\n  | World!\n  small Tiny text"

  # exception raising example
  INVALID_TEMPLATE = '- if true'

  def test_option_help
    out, err = exec_skim '--help'
    assert err.empty?
    assert_match /Show this help message/, out
  end

  def test_option_version
    out, err = exec_skim '--version'
    assert err.empty?
    assert_match /\ASkim #{Regexp.escape Skim::VERSION}$/, out
  end

  def test_export
    prepare_common_test STATIC_TEMPLATE, '--export' do |out, err|
      assert err.empty?
      assert_equal "<p>Hello World!</p>", evaluate_node(out, 'module.exports()')
    end
  end

  def test_assign_variable
    prepare_common_test STATIC_TEMPLATE, '--assign', 'myFunction' do |out, err|
      assert err.empty?
      assert_equal "<p>Hello World!</p>", evaluate(out, 'myFunction()')
    end
  end

  def test_assign_object
    with_tempfile STATIC_TEMPLATE do |in_file|
      out, err = exec_skim '--assign-object', 'myObject', in_file
      assert err.empty?
      key = in_file.chomp(File.extname(in_file))
      assert_equal "<p>Hello World!</p>", evaluate(out, "myObject[#{key.inspect}]()")
    end
  end

  def test_jst
    with_tempfile STATIC_TEMPLATE do |in_file|
      out, err = exec_skim '--jst', in_file
      assert err.empty?
      key = in_file.chomp(File.extname(in_file))
      assert_equal "<p>Hello World!</p>", evaluate(out, "JST[#{key.inspect}]()")
    end
  end

  def test_node_global
    prepare_common_test STATIC_TEMPLATE, '--node-global', '--assign', 'myFunction' do |out, err|
      assert err.empty?
      assert_match /global\.Skim/, out
      assert_equal "<p>Hello World!</p>", evaluate_node(out, 'global.myFunction()')
    end
  end

  def test_asset_only
    out, err = exec_skim '--asset-only'
    assert err.empty?
    assert_match %r{withContext\: function}, out
  end

  def test_omit_asset
    prepare_common_test STATIC_TEMPLATE, '--omit-asset' do |out, err|
      assert err.empty?
      refute_match %r{withContext\: function}, out
    end
  end

  def test_require
    with_tempfile 'puts "Not in skim"', 'rb' do |lib|
      prepare_common_test STATIC_TEMPLATE, '--require', lib, stdin_file: false, file_file: false do |out, err|
        assert err.empty?
        assert_match %r{\ANot in skim\n}, out
      end
    end
  end

  def test_error
    prepare_common_test INVALID_TEMPLATE, stdin_file: false do |out, err|
      assert out.empty?
      assert_match /SyntaxError/, err
      assert_match /Use --trace for backtrace/, err
    end
  end

  def test_trace_error
    prepare_common_test INVALID_TEMPLATE, '--trace', stdin_file: false do |out, err|
      assert out.empty?
      assert_match /SyntaxError/, err
      assert_match /bin\/skim/, err
    end
  end

private

  # Executes a test (given as block) four times:
  #
  # 1. Read from $stdin, write to $stdout
  # 2. Read from file, write to $stdout
  # 3. Read from $stdin, write to file
  # 4. Read from file, write to file
  #
  # Each of the above test executions yields a tuple (out, err).
  # Any args given are passed to the skim command (before input/output args).
  def prepare_common_test(content, *args)
    options = Hash === args.last ? args.pop : {}

    # case 1. $stdin → $stdout
    unless options[:stdin_stdout] == false
      out, err = exec_skim *args, '--stdin' do |i|
        i.write content
      end
      yield out, err
    end

    # case 2. file → $stdout
    unless options[:file_stdout] == false
      with_tempfile content do |in_file|
        out, err = exec_skim *args, in_file
        yield out, err
      end
    end

    # case 3. $stdin → file
    unless options[:stdin_file] == false
      with_tempfile content do |out_file|
        _, err = exec_skim *args, '--stdin', out_file do |i|
          i.write content
        end
        yield File.read(out_file), err
      end
    end

    # case 4. file → file
    unless options[:file_file] == false
      with_tempfile '' do |out_file|
        with_tempfile content do |in_file|
          _, err = exec_skim *args, in_file, out_file do |i|
            i.write content
          end
          yield File.read(out_file), err
        end
      end
    end
  end

  def evaluate(src, expression)
    ExecJS.compile(src).eval(expression)
  end

  def evaluate_node(src, expression)
    evaluate("var module = {};\nvar global = this;\n" + src, expression)
  end

  # Calls bin/skim as a subprocess.
  #
  # Yields $stdin to the caller and returns a tupel (out, err) with the
  # contents of $stdout and $stderr.
  def exec_skim(*args)
    out, err = nil, nil

    Open3.popen3 'ruby', 'bin/skim', *args do |stdin, stdout, stderr, wait_thread|
      yield stdin if block_given?
      stdin.close
      out, err = stdout.read, stderr.read
    end

    return out, err
  end

  # Creates a temporary file with the given content and yield the path
  # to this file. The file itself is only available inside the block and
  # will be deleted afterwards.
  def with_tempfile(content=nil, extname='skim')
    f = Tempfile.new ['skim', ".#{extname}"]
    if content
      f.write content
      f.flush # ensure content is actually saved to disk
      f.rewind
    end

    yield f.path
  ensure
    f.close
    f.unlink
  end

end
