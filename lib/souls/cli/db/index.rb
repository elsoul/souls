module Souls
  class Db < Thor
    namespace :db

    desc "migrate", "db migrate"
    def migrate
      p 2
    end
  end
end
