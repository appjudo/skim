require 'skim'
require 'optparse'

module Skim
  class Command
    def initialize(args)
      @args = args
      @options = {}
    end

    # Run command
    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process
    end

    private

    # Configure OptionParser
    def set_opts(opts)
      opts.on('-s', '--stdin', 'Read input from standard input instead of an input file') do
        @input = $stdin
      end

      opts.on('-e', '--export', 'Assign to module.exports for CommonJS require') do
        @export = true
      end

      opts.on('-n', '--node-global', 'Use Node.js global object for global assignments') do
        @node_global = true
      end

      opts.on('--jst', 'Assign to global JST object keyed by truncated filename') do
        @assign_object_name = 'JST'
      end

      opts.on('--assign variableName', 'Assign to a global variable') do |str|
        @assign_variable_name = str
      end

      opts.on('--assign-object objectName', 'Assign to a global object keyed by truncated filename') do |str|
        @assign_object_name = str
      end

      opts.on('--asset-only', 'Output only the Skim preamble asset') do
        @asset_only = true
      end

      opts.on('--omit-asset', 'Omit Skim preamble asset from output') do
        @options[:use_asset] = true
      end

      opts.on('--trace', 'Show a full traceback on error') do
        @trace = true
      end

      opts.on('-o', '--option name=code', String, 'Set skim option') do |str|
        parts = str.split('=', 2)
        Engine.options[parts.first.gsub(/\A:/, '').to_sym] = eval(parts.last)
      end

      opts.on('-r', '--require library', "Load library or plugin") do |lib|
        require lib.strip
      end

      opts.on_tail('-h', '--help', 'Show this help message') do
        puts opts
        exit
      end

      opts.on_tail('-v', '--version', 'Print version number') do
        puts "Skim #{VERSION}"
        exit
      end
    end

    # Process command
    def process
      args = @args.dup
      result = if @asset_only
        CoffeeScript.compile(Skim::Template.skim_src)
      else
        unless @input
          filename = args.shift
          if filename
            @filename = filename
            @input = File.open(filename, 'r')
          else
            @filename = 'STDIN'
            @input = $stdin
          end
        end

        locals = @options.delete(:locals) || {}
        Template.new(@filename, @options) { @input.read }.render(nil, locals)
      end

      result = prepend_assignment(result)

      rescue Exception => ex
        raise ex if @trace || SystemExit === ex
        $stderr.print "#{ex.class}: " if ex.class != RuntimeError
        $stderr.puts ex.message
        $stderr.puts '  Use --trace for backtrace.'
        exit 1
      else
        unless @options[:output]
          filename = args.shift
          @options[:output] = filename ? File.open(filename, 'w') : $stdout
        end
        @options[:output].puts(result)
        exit 0
    end

    def prepend_assignment(result)
      assignment = ''
      initialization = ''

      global = 'this'
      if @node_global
        global = 'global'
        result.sub!(/(this)(\.Skim =)/) {"#{global}#{$2}"}
      end

      assignment += "module.exports = " if @export
      assignment += "#{global}.#{@assign_variable_name} = " if @assign_variable_name
      if @assign_object_name
        object_name = "#{global}.#{@assign_object_name}"
        initialization = "#{object_name} || (#{object_name} = {});\n"
        assignment += "#{object_name}[#{truncated_filename.inspect}] = "
      end

      assignment.empty? ? result : (initialization + assignment + result)
    end

    def truncated_filename
      @filename.sub(/\.[^#{File::SEPARATOR}]*\Z/, '')
    end
  end
end
