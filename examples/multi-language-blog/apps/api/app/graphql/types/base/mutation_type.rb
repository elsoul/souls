module Types
  class MutationType < Souls::Types::BaseObject
    SoulsHelper.get_tables.each do |t|
      %w[create update delete destroy_delete].each do |a|
        field "#{a}_#{t.singularize.underscore}".to_sym,
              mutation: Object.const_get(
                "Mutations::Base::#{t.singularize.camelize}::#{a.camelize}#{t.singularize.camelize}"
              )
      end
    end

    managers =
      Dir["./app/graphql/mutations/managers/*_manager/*.rb"].map do |file|
        dir_name = file.scan(%r{managers/(.+?)_manager}).flatten[0]
        file_name = file.scan(%r{/([^/]+)/?$}).flatten[0].gsub(".rb", "")
        {
          class: dir_name,
          name: file_name
        }
      end
    managers.each do |file|
      field file[:name].underscore.to_s.to_sym,
            mutation: Object.const_get(
              "Mutations::Managers::#{file[:class].singularize.camelize}Manager::#{file[:name].singularize.camelize}"
            )
    end
  end
end
