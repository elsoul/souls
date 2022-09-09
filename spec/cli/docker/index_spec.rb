RSpec.describe(SOULs::Docker) do
  describe "psql" do
    it "should send the docker commad for psql" do
      cli = SOULs::Docker.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "docker run --restart always -d --name souls-psql -p 5433:5432 -v postres-tmp:/var/lib/postgresql/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=souls_test postgres:14-alpine"
        )
      )

      cli.psql
    end
  end

  describe "mysql" do
    it "should send the docker command for mysql" do
      cli = SOULs::Docker.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(
        receive(:system).with(
          "docker run --restart always -d \
          --name souls-mysql \
          -p 3306:3306 \
          -v mysql-tmp:/var/lib/mysql \
          -e MYSQL_USER=mysql \
          -e MYSQL_ROOT_PASSWORD=mysql \
          -e MYSQL_DB=souls_test \
          mysql:latest"
        )
      )

      cli.mysql
    end
  end

  describe "redis" do
    it "should send the docker command for redis" do
      cli = SOULs::Docker.new
      allow(cli).to(receive(:system).and_return(true))

      expect(cli).to(receive(:system).with("docker run --rm -d --name souls-redis -p 6379:6379 redis:latest"))

      cli.redis
    end
  end
end
