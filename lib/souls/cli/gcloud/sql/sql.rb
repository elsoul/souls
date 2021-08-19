module Souls
  module Gcloud
    module Sql
      class << self
        def create_instance(instance_name: "souls-db", root_pass: "Postgre123!", zone: "asia-northeast1-b")
          puts(
            "gcloud sql instances create #{instance_name} \
              --database-version=POSTGRES_13 --cpu=2 --memory=7680MB --zone=#{zone} \
              --root-password='#{root_pass}' --database-flags cloudsql.iam_authentication=on"
          )
        end
      end
    end
  end
end
