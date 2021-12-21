RSpec.describe(Souls::DB) do
  describe "migrate" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.migrate).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.migrate
    end
  end

  describe "create" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.create).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.create
    end
  end

  describe "seed" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.seed).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.seed
    end
  end

  describe "migrate_reset" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.migrate_reset).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.migrate_reset
    end
  end

  describe "migrate_reset" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.reset).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.reset
    end
  end

  describe "add_column" do
    it "should create migration with correct file" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db).to(receive(:system).with("rake db:create_migration NAME=add_column_to_users"))
      db.add_column("user")
    end
  end

  describe "rename_column" do
    it "should create migration with correct file" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db).to(receive(:system).with("rake db:create_migration NAME=rename_column_to_users"))
      db.rename_column("user")
    end
  end

  describe "change_column" do
    it "should create migration with correct file" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db).to(receive(:system).with("rake db:create_migration NAME=change_column_to_users"))
      db.change_column("user")
    end
  end

  describe "remove_column" do
    it "should create migration with correct file" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db).to(receive(:system).with("rake db:create_migration NAME=remove_column_to_users"))
      db.remove_column("user")
    end
  end

  describe "drop_table" do
    it "should create migration with correct file" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db).to(receive(:system).with("rake db:create_migration NAME=drop_table_to_users"))
      db.drop_table("user")
    end
  end

  describe "db_system" do
    it "should receive db:migrate with true" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(true))
      expect(db.__send__(:db_system, "ls")).to(eq(true))
    end

    it "should raise an exception with false" do
      db = Souls::DB.new
      allow(db).to(receive(:system).and_return(false))
      allow(Souls::Painter).to(receive(:error).and_return(true))
      expect(Souls::Painter).to(receive(:error))
      db.__send__(:db_system, "ls")
    end
  end
end
