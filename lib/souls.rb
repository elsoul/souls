require "souls/version"
require "active_support/core_ext/string/inflections"
require "souls/init"
require "souls/generate"
require "json"
require "fileutils"

module Souls
  class Error < StandardError; end
    class << self
      attr_accessor :configuration

      def run_psql
        `docker run --rm -d \
          -p 5433:5432 \
          -v postgres-tmp:/var/lib/postgresql/data \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_DB=souls_test \
          postgres:13-alpine`
        puts `docker ps`
      end

      def run_awake
        app = Souls.configuration.app
        `gcloud scheduler jobs create http #{app}-awake --schedule "0,10,20,30,40,50 * * * *" --uri "https://#{app}.el-soul.com" --http-method GET`
      end

      def deploy_local
        `docker network create --driver bridge shared`

        `docker run -d --name proxy \
         -p 80:80 -p 443:443 \
         -v "/var/run/docker.sock:/tmp/docker.sock:ro" \
         -v "$pwd/certs:/etc/nginx/certs:ro" \
         -v "/etc/nginx/vhost.d" \
         -v "/usr/share/nginx/html" \
         --network shared \
         --restart always \
         jwilder/nginx-proxy`

        `docker run -d --name letsencrypt \
        -v "/home/certs:/etc/nginx/certs" \
        -v "/var/run/docker.sock:/var/run/docker.sock:ro" \
        --volumes-from proxy \
        --network shared \
        --restart always \
        jrcs/letsencrypt-nginx-proxy-companion`

        `docker run -d --name nginx \
        -p 80:80 \
        -e VIRTUAL_HOST=souls.el-soul.com \
        -e LETSENCRYPT_HOST=souls.el-soul.com \
        -e LETSENCRYPT_EMAIL=info@gmail.com \
        --network shared \
        --link web \
        poppinfumi/ruby-nginx:latest`

        `docker run -d --name web \
         -p 3000:3000 \
         --network shared \
         poppinfumi/souls_api`
      end
    end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :app

    def initialize
      @app = nil
    end
  end
end
