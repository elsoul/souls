module Souls
  module Docker
    class << self
      def psql
        system(
          "docker run --rm -d \
            -p 5433:5432 \
            -v postgres-tmp:/var/lib/postgresql/data \
            -e POSTGRES_USER=postgres \
            -e POSTGRES_PASSWORD=postgres \
            -e POSTGRES_DB=souls_test \
            postgres:13-alpine"
        )
        system("docker ps")
      end
  
      def mysql
        system(
          "docker run --rm -d \
            -p 3306:3306 \
            -v mysql-tmp:/var/lib/mysql \
            -e MYSQL_USER=mysql \
            -e MYSQL_ROOT_PASSWORD=mysql \
            -e MYSQL_DB=souls_test \
            mysql:latest"
        )
        system("docker ps")
      end
    end
  end
end