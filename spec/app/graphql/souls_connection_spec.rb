RSpec.describe(SOULs::SOULsConnection) do
  describe "total_count" do
    it "should return total count" do
      connection = SOULs::SOULsConnection.__send__(:new, [1, 2], 5)
      allow_any_instance_of(Array).to(receive(:items).and_return([1, 2]))
      result = connection.total_count
      expect(result).to(eq(2))
    end
  end

  describe "total_pages" do
    it "should return total pages" do
      connection = SOULs::SOULsConnection.__send__(:new, [1, 2], 5)
      allow_any_instance_of(Array).to(receive(:items).and_return([1, 2, 3, 4, 5, 6]))
      allow_any_instance_of(Array).to(receive(:max_page_size).and_return(2))
      result = connection.total_pages
      expect(result).to(eq(4))
    end
  end
end
