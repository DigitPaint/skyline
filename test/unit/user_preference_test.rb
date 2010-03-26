require 'test_helper'

class UserPreferenceTest < ActiveSupport::TestCase
  context "User preferences" do
    setup do  
      @user_preferences1 = Factory(:user_preference, :key => "a.", :encoded_value => 1.to_yaml)
      @user_preferences2 = Factory(:user_preference, :key => "b.a.", :encoded_value => 2.to_yaml)
      @user_preferences3 = Factory(:user_preference, :key => "b.b.", :encoded_value => 3.to_yaml)
    end
    
    should "accept individual key=>value pairs" do
      initial_count = Skyline::UserPreference.count
      assert Skyline::UserPreference.set("t", 5)
      assert_equal(initial_count + 1, Skyline::UserPreference.count)
      assert Skyline::UserPreference.has_key?("t")
      assert_equal(5, Skyline::UserPreference.get("t"))
    end
    
    should "accept nested key=>value pairs and store individual values" do
      initial_count = Skyline::UserPreference.count
      assert Skyline::UserPreference.set("t",{"a" => 1, "b" => 2})
      assert_equal(initial_count + 2,  Skyline::UserPreference.count)
      assert Skyline::UserPreference.has_key?("t.a")
      assert_equal(1, Skyline::UserPreference.get("t.a"))
      assert_equal(2, Skyline::UserPreference.get("t.b"))
      assert Skyline::UserPreference.has_key?("t.b")
    end
    
    should "not accept nested key if key is value" do
      assert Skyline::UserPreference.set("t",5)
      assert_raise(ArgumentError){Skyline::UserPreference.set("t.a", 5)}
    end
    
    should "should accept nested key if key is hash" do
      assert Skyline::UserPreference.set("t",{"a" => 5})
      assert Skyline::UserPreference.set("t.b", 6)
    end
    
    should "overwrite individual key=>value pair" do
      initial_count = Skyline::UserPreference.count
      assert Skyline::UserPreference.set("a", 5)
      assert_equal(initial_count, Skyline::UserPreference.count)
      assert_equal(5, Skyline::UserPreference.get("a"))
    end
    
    should "be able to return individual value" do
      assert_equal(1, Skyline::UserPreference.get("a"))
    end
    
    should "be able to return individual nested value" do
      assert_equal(2, Skyline::UserPreference.get("b.a"))
    end
    
    should "be able to return a hash of values" do
      assert_equal({"a" => 2, "b" => 3},  Skyline::UserPreference.get("b"))
    end
    
     should "accept nil as value" do
      initial_count = Skyline::UserPreference.count
      assert Skyline::UserPreference.set("t", nil)
      assert_equal(initial_count + 1, Skyline::UserPreference.count)
      assert_nil Skyline::UserPreference.get("t")
      assert Skyline::UserPreference.has_key?("t")
    end
    
    should "delete all nested preferences if value of parent is nil" do
      initial_count = Skyline::UserPreference.count
      assert Skyline::UserPreference.set("b", nil)
      assert_equal(initial_count - 1, Skyline::UserPreference.count)
      assert_nil Skyline::UserPreference.get("b")
      assert !Skyline::UserPreference.has_key?("b.a")
      assert !Skyline::UserPreference.has_key?("b.b")
    end
    
    should "accept boolean as value and return boolean" do
      assert Skyline::UserPreference.set("t", false)
      assert_equal(false,  Skyline::UserPreference.get("t"))
    end
    
    should "accept array as value and return array" do
      assert Skyline::UserPreference.set("t", [1,2,3])
      assert_equal([1,2,3],  Skyline::UserPreference.get("t"))      
    end
    
    should "accept complex arrays and return correct values" do
      test_time = Time.now
      test_date = Date.today
      assert Skyline::UserPreference.set("t", [1,{"a"=> {"a" => 1, "b" => 2, "c" => {"a" => 1, "b" => 2}}},"string", ["a","b","c"], test_date, test_time])
      assert_equal([1, {"a"=> {"a" => 1, "b" => 2, "c" => {"a" => 1, "b" => 2}}},"string", ["a","b","c"], test_date, test_time],  Skyline::UserPreference.get("t"))
    end
    
    should "return nil if a key does not exist" do
      assert_nil Skyline::UserPreference.get("t.a")
    end 
    
    should "return true if has_key? is queried on existing key" do
      assert Skyline::UserPreference.has_key?("a")
    end
    
    should "return true if has_key? is queried on key with children" do
      assert Skyline::UserPreference.has_key?("b")
    end
    
    should "return true if has_key? is queried on a nested key" do
      assert Skyline::UserPreference.has_key?("b.a")
    end
    
    should "return false if has_key? is queried on non existing key" do
      assert !Skyline::UserPreference.has_key?("t")
    end
    
    should "delete a key" do
      Skyline::UserPreference.remove("a")
      assert !Skyline::UserPreference.has_key?("a")
    end
    
    should "delete a key and its children" do
      Skyline::UserPreference.remove("b")
      assert !Skyline::UserPreference.has_key?("b.a")
      assert !Skyline::UserPreference.has_key?("b")
    end
  end
end
