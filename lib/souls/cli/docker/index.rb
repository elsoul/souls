module Souls
  class Docker < Thor
    desc "psql", "Run PostgreSQL13 Docker Container"
    def psql
      system(
        "docker run --rm -d \
          --name souls-psql \
          -p 5433:5432 \
          -v postgres-tmp:/var/lib/postgresql/data \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=postgres \
          -e POSTGRES_DB=souls_test \
          postgres:13-alpine"
      )
      system("docker ps")
    end

    desc "mysql", "Run MySQL Docker Container"
    def mysql
      system(
        "docker run --rm -d \
          --name souls-mysql \
          -p 3306:3306 \
          -v mysql-tmp:/var/lib/mysql \
          -e MYSQL_USER=mysql \
          -e MYSQL_ROOT_PASSWORD=mysql \
          -e MYSQL_DB=souls_test \
          mysql:latest"
      )
      system("docker ps")
    end

    desc "redis", "Run Redis Docker Container"
    def redis
      system("docker run --rm -d --name souls-redis -p 6379:6379 redis:latest")
      system("docker ps")
    end
  end
end
