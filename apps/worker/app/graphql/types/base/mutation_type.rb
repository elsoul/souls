module Types
  class MutationType < SOULs::Types::BaseObject
    workers =
      Dir["./app/graphql/mutations/*.rb"].map do |file|
        file.gsub("./app/graphql/mutations/", "").gsub(".rb", "")
      end
    workers.each do |worker|
      field worker.underscore.to_s.to_sym,
            mutation: Object.const_get("Mutations::#{worker.singularize.camelize}")
    end
  end
end
