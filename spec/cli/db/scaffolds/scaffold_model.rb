module Scaffold
  def self.scaffold_model
    <<~MODEL
    class User < ActiveRecord::Base
    end
MODEL
  end
end
