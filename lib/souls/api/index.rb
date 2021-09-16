require_relative "./generate/index"
require_relative "./update/index"
module Souls
  class Api < Thor
    desc "generate [COMMAND]", "souls api generate Commands"
    subcommand "generate", Generate

    desc "update [COMMAND]", "souls api update Commands"
    subcommand "update", Update

    # rubocop:disable Style/StringHashKeys
    map "g" => :generate
    # rubocop:enable Style/StringHashKeys
  end

  # module Api::Update
  # end
end
