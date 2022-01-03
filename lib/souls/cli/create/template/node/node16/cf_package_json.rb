module Template
  module Node::Node16
    def self.cf_package_json
      <<~PACKAGEJSON
        {
          "name": "souls-cf-node16",
          "version": "0.0.1",
          "dependencies": {
            "express": "4.17.2",
            "body-parser": "1.19.1"
          }
        }#{'    '}
      PACKAGEJSON
    end
  end
end
