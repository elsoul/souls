module SOULs
  module Painter
    class << self
      def create_file(text)
        puts(Paint % ["✓ %{white_text}", :green, { white_text: ["Created file #{text}", :white] }])
      end

      def update_file(text)
        puts(Paint % ["✓ %{white_text}", :yellow, { white_text: ["Updated file #{text}", :white] }])
      end

      def delete_file(text)
        puts(Paint % ["✓ %{white_text}", :red, { white_text: ["Deleted file #{text}", :white] }])
      end

      def error(text, emoji = nil)
        if emoji
          puts(Paint["#{emoji} #{text}", :red])
        else
          puts(Paint["🚨 #{text}", :red])
        end
      end

      def warning(text, emoji = nil)
        if emoji
          puts(Paint["#{emoji} #{text}", :yellow])
        else
          puts(Paint["🚨 #{text}", :yellow])
        end
      end

      def success(text, emoji = nil)
        if emoji
          puts(Paint["#{emoji} #{text}", :green])
        else
          puts(Paint["🎉 #{text}", :green])
        end
      end

      def sync(text)
        puts(Paint % ["✓ %{white_text}", :blue, { white_text: ["Synced #{text}", :white] }])
      end
    end
  end
end
