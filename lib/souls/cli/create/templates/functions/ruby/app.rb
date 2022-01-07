module Template
  module Ruby
    def self.app(file_name)
      <<~APP
        require "functions_framework"
        require "sinatra/base"
        require "dotenv/load"

        class App < Sinatra::Base
          get "/souls-functions-get/:name" do
            "SOULs Functions Job Done! - \#{params['name']}"
          end

          post "/souls-functions-post" do
            params = JSON.parse(request.body.read)
            "SOULs Functions Job Done! - \#{params['name']}"
          end
        end

        FunctionsFramework.http(\"#{file_name}\") do |request|
          App.call(request.env)
        end
      APP
    end
  end
end
