module Scaffold
  def self.scaffold_delete
    <<~SAMPLEFILE
      class User < ActiveRecord::Base
      end
    SAMPLEFILE
  end
end
