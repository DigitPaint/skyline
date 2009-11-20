require 'test_helper'
require File.dirname(__FILE__) + "/../vendor/treetop/lib/treetop"
Treetop.load "../lib/parser/personify"
# require File.dirname(__FILE__) + "/../personify"

class ParserTest < Test::Unit::TestCase
  include ParserTestHelper
  context "The parser" do
    setup do
      @parser = PersonifyLanguageParser.new
    end
    context "parsing text" do
      should "eval text" do
        assert_equal "text", parse("text").eval()
        assert_equal "t", parse("t").eval()
        assert_equal "t\n1\n2", parse("t\n1\n2").eval()       
      end
      
      should "eval UTF8 text" do
        assert_equal "financiële", parse("financiële").eval()
      end
  
      should "eval empty text" do
        assert_equal "", parse("").eval()
      end
  
      should "eval '[bla]' as text" do
        assert_equal "[bla]", parse("[bla]").eval()
      end

      should "eval '[KE bla' as text" do
        assert_equal "[KE bla", parse("[KE bla").eval()
      end

      should "eval nested brackets as text" do
        assert_equal "[[BLA]]", parse("[[BLA]]").eval
      end

      should "eval '[BLA]' as text on nil 'bla' " do
        assert_equal "[BLA]", parse("[BLA]").eval()
      end
    end
    context "parsing expressions" do  
      should "eval simple expression" do
        assert_equal "var", parse("[VAR]").eval("var" => "var")
        assert_equal "a var b", parse("a [VAR] b").eval("var" => "var")
        assert_equal "var\nvar", parse("[VAR]\n[VAR]").eval("var" => "var")              
      end
      
      should "eval simple expression with empty substitution" do
        assert_equal "", parse("[VAR]").eval("var" => "")
      end
      
      should "eval expressions careless of whitespace" do
        assert_equal "k1",parse("[ K1]").eval("k1" => "k1")
        assert_equal "k1",parse("[ K1 ]").eval("k1" => "k1")
        assert_equal "k1",parse("[K1 | K2]").eval("k1" => "k1")
      end   
     
      context "with alternatives" do    
        should "eval alternative expression on first empty" do       
          assert_equal "k2", parse("[K1|K2]").eval("k2" => "k2")
          assert_equal "k2", parse("[K1|K2]").eval("k2" => "k2")
          assert_equal "k3", parse("[K1|K2|K3]").eval("k1" => nil,"k2" => nil, "k3" => "k3")
        end

        should "eval first expression on first nonempty" do       
          assert_equal "k2", parse("[K1|K2]").eval("k2" => "k2")
          assert_equal "k2", parse("[K1|K2]").eval("k2" => "k2")
          assert_equal "k3", parse("[K1|K2|K3]").eval("k2" => nil, "k3" => "k3")
        end     

        should "eval strings in alternative expression" do 
          assert_equal "str", parse("[K1|str]").eval
          assert_equal "str", parse("[K1|\"str\"]").eval
          assert_equal "str", parse("[K1|\"str\"]").eval          
          assert_equal " str", parse("[K1|\" str\"]").eval
        end
        
        should "eval implicit strings in alternative expression" do 
          assert_equal "str", parse("[K1|str]").eval
        end        
      end
      
      context "with function" do
        should "eval with single parameter" do
          assert_equal "v", parse("[FUNC(K1)]").eval("func" => Proc.new{|v| v }, "k1" => "v")
        end
        should "eval with multiple parameters" do
          assert_equal "v1v2", parse("[FUNC(K1,K2)]").eval("func" => Proc.new{|*v| v.join }, "k1" => "v1", "k2" => "v2")
        end
        should "eval with string parameters" do
          assert_equal "str", parse("[FUNC(\"str\")]").eval("func" => Proc.new{|v| v }, "k1" => "v1", "k2" => "v2")
        end
        should "eval with implicit string parameters" do
          assert_equal "str", parse("[FUNC(str)]").eval("func" => Proc.new{|v| v }, "k1" => "v1", "k2" => "v2")
        end        
        should "eval with too much parameters" do
          assert_equal "v1+v2v3", parse("[FUNC(\"v1\",\"v2\",\"v3\")]").eval("func" => Proc.new{|v1,*v2| v1 + "+" + v2.join })
        end
        should "eval with alternative expression" do
          assert_equal "fb", parse("[FUNC()|\"fb\"]").eval("func" => Proc.new{ false })
          assert_equal "fb", parse("[FUNC()|\"fb\"]").eval("func" => Proc.new{ nil })
        end
      end
      
    end
  end
end
