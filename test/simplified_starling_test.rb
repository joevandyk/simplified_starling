require 'test/unit'

class SimplifiedStarlingTest < Test::Unit::TestCase

  def test_array_class_is_not_affected_by_method_overwrite
    a = [ "a", "b", "c" ]
    a.push("d", "e", "f")
    assert_equal a, ["a", "b", "c", "d", "e", "f"]
  end

end