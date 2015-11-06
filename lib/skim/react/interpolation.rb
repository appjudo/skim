module Skim
  module React
    class Interpolation < Skim::Interpolation
      # Handle interpolate expression `[:slim, :interpolate, string]`
      #
      # @param [String] string Static interpolate
      # @return [Array] Compiled temple expression
      def on_slim_interpolate(string)
        # Interpolate variables in text (#{variable}).
        # Split the text into multiple dynamic and static parts.
        block = [:multi]
        static = ''
        begin
          case string
          when /\A\\#\{/
            # Escaped interpolation
            static += $&
            string = $'
          when /\A#\{/
            # Interpolation
            block << [:static, static]
            block << [:code, ' + (']
            string, code = parse_expression($')
            block << [:escape, true, [:dynamic, code]]
            block << [:code, ') + ']
            static = ''
          when /\A([#\\]|[^#\\]*)/
            # Static text
            static += $&
            string = $'
          end
        end until string.empty?
        block << [:static, static]
        block
      end
    end
  end
end