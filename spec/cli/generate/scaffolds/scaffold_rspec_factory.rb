module Scaffold
  def self.scaffold_rspec_factory
    <<~MUTATIONRSPECFACTORY
FactoryBot.define do
  factory :user do
  end
end
MUTATIONRSPECFACTORY
  end
end
