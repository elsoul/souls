require_relative "./generate/index"

module Souls
  class Worker < Thor
    desc "generate [COMMAND]", "souls worker generate Commands"
    subcommand "generate", Generate
  end
end
