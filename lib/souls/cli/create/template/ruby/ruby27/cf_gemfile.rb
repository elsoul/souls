module Template
  module Ruby
    module Ruby27
      def self.cf_gemfile
        <<~GEMFILE
          source "https://rubygems.org"

          gem "dotenv", "2.7.6"
          gem "functions_framework", "~> 0.7"
          gem "sinatra", "2.1.0"

        GEMFILE
      end
    end
  end
end
