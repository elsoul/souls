module Types
  class MutationType < Types::BaseObject
    workers =
      Dir["./app/graphql/mutations/workers/*.rb"].map do |file|
        file.gsub("./app/graphql/mutations/workers/", "").gsub(".rb", "")
      end
    workers.each do |worker|
      field worker.underscore.to_s.to_sym,
            mutation: Object.const_get("Mutations::Workers::#{worker.singularize.camelize}")
    end
  end
end
