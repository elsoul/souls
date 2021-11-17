module Scaffold
  def self.scaffold_model_rbs
    <<~MODELRBS
      class User < ActiveRecord::Base
      end
    MODELRBS
  end
end
