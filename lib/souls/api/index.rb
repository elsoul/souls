require_relative "./generate/index"
# require_relative "./update/index"
module Souls
  class Api < Thor
    desc "generate [COMMAND]", "souls api generate Commands"
    subcommand "generate", Generate
  end

  # module Api::Update
  # end
end
