require_relative "./generate/index"

module Souls
  class Worker < Thor
    desc "generate [COMMAND]", "souls worker generate Commands"
    subcommand "generate", Generate

    # rubocop:disable Style/StringHashKeys
    map "g" => :generate
    # rubocop:enable Style/StringHashKeys
  end
end
