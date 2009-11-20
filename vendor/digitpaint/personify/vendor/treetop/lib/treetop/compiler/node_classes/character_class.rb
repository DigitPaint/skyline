module Treetop
  module Compiler    
    class CharacterClass < AtomicExpression
      def compile(address, builder, parent_expression = nil)
        super
        
        builder.if__ "input.index(Regexp.new(#{single_quote(text_value)},nil,'u'), index) == index" do
          builder << 'next_character = index + input[index..-1].match(/\A(.)/um).end(1)'
          assign_result "instantiate_node(#{node_class_name},input, index...next_character)"
          extend_result_with_inline_module
          builder << "@index = next_character"
        end
        builder.else_ do
          "terminal_parse_failure(#{single_quote(characters)})"
          assign_result 'nil'
        end
      end
    end
  end
end


