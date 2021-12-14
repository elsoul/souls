module Souls
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

      def error(text)
        puts(Paint["🚨 #{text}", :red])
      end

      def warning(text)
        puts(Paint["🚨 #{text}", :yellow])
      end

      def success(text)
        puts(Paint["🎉 #{text}", :green])
      end

      def sync(text)
        puts(Paint % ["✓ %{white_text}", :blue, { white_text: ["Synced #{text}", :white] }])
      end
    end
  end
end
