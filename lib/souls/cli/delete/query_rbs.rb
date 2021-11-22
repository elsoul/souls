module Souls
  class Delete < Thor
    desc "query_rbs [CLASS_NAME]", "Delete GraphQL Query RBS"
    def query_rbs(class_name)
      file_path = ""
      Dir.chdir(Souls.get_mother_path.to_s) do
        file_dir = "./sig/api/app/graphql/queries/"
        singularized_class_name = class_name.underscore.singularize
        file_path = "#{file_dir}#{singularized_class_name}*.rbs"
        FileUtils.rm_f(file_path)
        puts(Paint % ["Deleted file! : %{white_text}", :yellow, { white_text: [file_path.to_s, :white] }])
        file_path
      end
    end
  end
end
