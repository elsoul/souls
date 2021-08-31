require_relative "./iam/index"
require_relative "./pubsub/index"
require_relative "./run/index"
require_relative "./sql/index"
require_relative "./compute/index"

module Souls
  module Gcloud
    class << self
      def auth_login(project_id: "")
        project_id = Souls.configuration.project_id if project_id.blank?
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
        system("gcloud services enable vpcaccess.googleapis.com")
        puts("Operating permission to vpcaccess.googleapis.com")
      end
    end
    module Iam
    end

    module Pubsub
    end

    module Run
    end

    module Sql
    end
  end
end
