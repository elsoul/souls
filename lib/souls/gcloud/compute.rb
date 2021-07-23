module Souls
  module Gcloud
    class << self
      def auth_login(project_id: "souls-app")
        system("gcloud config set project #{project_id}")
        system("gcloud auth login")
      end

      def enable_permissions
        system("gcloud services enable compute.googleapis.com")
        puts("Operating permission to compute.googleapis.com ...")
        system("gcloud services enable iam.googleapis.com")
        puts("Operating permission to iam.googleapis.com ...")
        system("gcloud services enable dns.googleapis.com")
        puts("Operating permission to dns.googleapis.com ...")
        system("gcloud services enable sqladmin.googleapis.com")
        puts("Operating permission to sqladmin.googleapis.com ...")
        system("gcloud services enable sql-component.googleapis.com")
        puts("Operating permission to sql-component.googleapis.com ...")
        system("gcloud services enable servicenetworking.googleapis.com")
        puts("Operating permission to servicenetworking.googleapis.com ...")
        system("gcloud services enable containerregistry.googleapis.com")
        puts("Operating permission to containerregistry.googleapis.com")
        system("gcloud services enable run.googleapis.com")
        puts("Operating permission to run.googleapis.com")
      end

      
      def create_sql_instance(instance_name: "souls-db", root_pass: "Postgre123!", zone: "asia-northeast1-b")
        system(
          "gcloud sql instances create #{instance_name}
            --database-version=POSTGRES_13 --cpu=2 --memory=7680MB --zone=#{zone}
            --root-password='#{root_pass}' --database-flags cloudsql.iam_authentication=on"
        )
      end
    end
  end
end
