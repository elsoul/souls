module Scaffold
  def self.scaffold_souls_helper
    <<~SOULSHELPER
module SoulsHelper
  def self.export_csv: (untyped model_name) -> (String? | StandardError )
  def self.export_model_to_csv: (untyped model_name) -> (untyped | StandardError )
  def self.upload_to_gcs: (String file_path, String upload_path) -> untyped
  def self.get_selenium_driver: (?:chrome mode) -> untyped
end
module CSV
  def self.open: (*untyped){(untyped) -> nil} -> untyped
end
module Selenium
  module WebDriver
    def self.for: (*untyped) -> untyped
    module Chrome
      module Options
        def self.new: ()-> untyped
      end
    end
    module Remote
      module Capabilities
        def self.firefox: ()-> untyped
      end
    end
  end
end
module Google
  module Cloud
    module Storage
      def self.new: ()-> untyped
    end
  end
end
    SOULSHELPER
  end
end
