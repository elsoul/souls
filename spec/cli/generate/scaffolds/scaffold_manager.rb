module Scaffold
  def self.scaffold_manager
    <<~MANAGER
      module Mutations
        module Managers::UserManager
          class User < BaseMutation
            description "user description"
            ## Edit `argument` and `field`
            argument :argument, String, required: false

            field :response, String, null: false

            def resolve(args)
              # Define Here
              { response: "success!" }
            end
          end
        end
      end
    MANAGER
  end
end
