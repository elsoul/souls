module Test
  def self.hey
    "HEY"
  end
end

class A
  def a_method
    :a
  end
end

class B < A
  def b_method
    :b
  end
end
a = B.new
puts a.a_method