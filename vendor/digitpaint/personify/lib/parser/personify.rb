module PersonifyLanguage
  include Treetop::Runtime

  def root
    @root || :template
  end

  module Template0
    def eval(env={})
      elements.map{|e| e.eval(env) }.join("")
    end
  end

  def _nt_template
    start_index = index
    if node_cache[:template].has_key?(index)
      cached = node_cache[:template][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      r1 = _nt_part
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
    r0.extend(Template0)

    node_cache[:template][start_index] = r0

    return r0
  end

  def _nt_part
    start_index = index
    if node_cache[:part].has_key?(index)
      cached = node_cache[:part][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_text
    if r1
      r0 = r1
    else
      r2 = _nt_substitutable
      if r2
        r0 = r2
      else
        r3 = _nt_tail_part
        if r3
          r0 = r3
        else
          self.index = i0
          r0 = nil
        end
      end
    end

    node_cache[:part][start_index] = r0

    return r0
  end

  module TailPart0
    def part
      elements[1]
    end
  end

  module TailPart1
    def eval(env)
      "[" + part.eval(env)
    end
  end

  def _nt_tail_part
    start_index = index
    if node_cache[:tail_part].has_key?(index)
      cached = node_cache[:tail_part][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('[', index) == index
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('[')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_part
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(TailPart0)
      r0.extend(TailPart1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:tail_part][start_index] = r0

    return r0
  end

  module Substitutable0
    def space
      elements[1]
    end

    def expressions
      elements[2]
    end

    def space
      elements[3]
    end

  end

  module Substitutable1
    def eval(env)
      last_eval = expressions.eval(env)
      if last_eval.nil?
        text_value
      else
        last_eval
      end
    end
  end

  def _nt_substitutable
    start_index = index
    if node_cache[:substitutable].has_key?(index)
      cached = node_cache[:substitutable][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index('[', index) == index
      r1 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('[')
      r1 = nil
    end
    s0 << r1
    if r1
      r2 = _nt_space
      s0 << r2
      if r2
        r3 = _nt_expressions
        s0 << r3
        if r3
          r4 = _nt_space
          s0 << r4
          if r4
            if input.index(']', index) == index
              r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
              @index += 1
            else
              terminal_parse_failure(']')
              r5 = nil
            end
            s0 << r5
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Substitutable0)
      r0.extend(Substitutable1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:substitutable][start_index] = r0

    return r0
  end

  module Expressions0
    def space
      elements[0]
    end

    def space
      elements[2]
    end

    def expression_or_string
      elements[3]
    end
  end

  module Expressions1
    def expression
      elements[0]
    end

    def alternatives
      elements[1]
    end
  end

  module Expressions2
    def eval(env)
      last_value = nil
      expressions.detect do |exp|
        last_value = exp.eval(env)
      end
      last_value
    end
    
    def expressions
      [expression] + alternatives.elements.map {|elt| elt.expression_or_string}
    end
  end

  def _nt_expressions
    start_index = index
    if node_cache[:expressions].has_key?(index)
      cached = node_cache[:expressions][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_expression
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        r4 = _nt_space
        s3 << r4
        if r4
          if input.index("|", index) == index
            r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure("|")
            r5 = nil
          end
          s3 << r5
          if r5
            r6 = _nt_space
            s3 << r6
            if r6
              r7 = _nt_expression_or_string
              s3 << r7
            end
          end
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(Expressions0)
        else
          self.index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Expressions1)
      r0.extend(Expressions2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:expressions][start_index] = r0

    return r0
  end

  def _nt_expression
    start_index = index
    if node_cache[:expression].has_key?(index)
      cached = node_cache[:expression][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_function
    if r1
      r0 = r1
    else
      r2 = _nt_key
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:expression][start_index] = r0

    return r0
  end

  def _nt_expression_or_string
    start_index = index
    if node_cache[:expression_or_string].has_key?(index)
      cached = node_cache[:expression_or_string][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    r1 = _nt_expression
    if r1
      r0 = r1
    else
      r2 = _nt_string
      if r2
        r0 = r2
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:expression_or_string][start_index] = r0

    return r0
  end

  module Function0
    def key
      elements[0]
    end

    def space
      elements[1]
    end

    def space
      elements[3]
    end

    def parameters
      elements[4]
    end

    def space
      elements[5]
    end

  end

  module Function1
    def eval(env={})
      if fn = key.eval(env)
        if fn.respond_to?(:call)
          values = parameters.eval(env)
          fn.call(*values)
        else
          fn
        end
      end
    end
  end

  def _nt_function
    start_index = index
    if node_cache[:function].has_key?(index)
      cached = node_cache[:function][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_key
    s0 << r1
    if r1
      r2 = _nt_space
      s0 << r2
      if r2
        if input.index("(", index) == index
          r3 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure("(")
          r3 = nil
        end
        s0 << r3
        if r3
          r4 = _nt_space
          s0 << r4
          if r4
            r5 = _nt_parameters
            s0 << r5
            if r5
              r6 = _nt_space
              s0 << r6
              if r6
                if input.index(")", index) == index
                  r7 = instantiate_node(SyntaxNode,input, index...(index + 1))
                  @index += 1
                else
                  terminal_parse_failure(")")
                  r7 = nil
                end
                s0 << r7
              end
            end
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Function0)
      r0.extend(Function1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:function][start_index] = r0

    return r0
  end

  module Parameters0
    def space
      elements[0]
    end

    def space
      elements[2]
    end

    def expression_or_string
      elements[3]
    end
  end

  module Parameters1
    def expression_or_string
      elements[0]
    end

    def more_expressions
      elements[1]
    end
  end

  module Parameters2
    def eval(env={})
      self.parameters.map{|param| param.eval(env) }
    end
    def parameters
      [expression_or_string] + more_expressions.elements.map {|elt| elt.expression_or_string}
    end
  end

  def _nt_parameters
    start_index = index
    if node_cache[:parameters].has_key?(index)
      cached = node_cache[:parameters][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_expression_or_string
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        i3, s3 = index, []
        r4 = _nt_space
        s3 << r4
        if r4
          if input.index(",", index) == index
            r5 = instantiate_node(SyntaxNode,input, index...(index + 1))
            @index += 1
          else
            terminal_parse_failure(",")
            r5 = nil
          end
          s3 << r5
          if r5
            r6 = _nt_space
            s3 << r6
            if r6
              r7 = _nt_expression_or_string
              s3 << r7
            end
          end
        end
        if s3.last
          r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
          r3.extend(Parameters0)
        else
          self.index = i3
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Parameters1)
      r0.extend(Parameters2)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:parameters][start_index] = r0

    return r0
  end

  module Key0
  end

  module Key1
    
    def eval(env)
      env[self.to_s]
    end
          
    def name
      text_value
    end
    
    def to_s
      self.name.downcase.to_s
    end
  end

  def _nt_key
    start_index = index
    if node_cache[:key].has_key?(index)
      cached = node_cache[:key][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index(Regexp.new('[A-Z]',nil,'u'), index) == index
      next_character = index + input[index..-1].match(/\A(.)/um).end(1)
      r1 = instantiate_node(SyntaxNode,input, index...next_character)
      @index = next_character
    else
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if input.index(Regexp.new('[A-Z0-9]',nil,'u'), index) == index
          next_character = index + input[index..-1].match(/\A(.)/um).end(1)
          r3 = instantiate_node(SyntaxNode,input, index...next_character)
          @index = next_character
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      if s2.empty?
        self.index = i2
        r2 = nil
      else
        r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      end
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Key0)
      r0.extend(Key1)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:key][start_index] = r0

    return r0
  end

  module String0
    def string_value
      elements[1]
    end

  end

  module String1
    def eval(env={})
      string_value.eval(env)
    end
  end

  def _nt_string
    start_index = index
    if node_cache[:string].has_key?(index)
      cached = node_cache[:string][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0 = index
    i1, s1 = index, []
    if input.index('"', index) == index
      r2 = instantiate_node(SyntaxNode,input, index...(index + 1))
      @index += 1
    else
      terminal_parse_failure('"')
      r2 = nil
    end
    s1 << r2
    if r2
      r3 = _nt_string_value
      s1 << r3
      if r3
        if input.index('"', index) == index
          r4 = instantiate_node(SyntaxNode,input, index...(index + 1))
          @index += 1
        else
          terminal_parse_failure('"')
          r4 = nil
        end
        s1 << r4
      end
    end
    if s1.last
      r1 = instantiate_node(SyntaxNode,input, i1...index, s1)
      r1.extend(String0)
      r1.extend(String1)
    else
      self.index = i1
      r1 = nil
    end
    if r1
      r0 = r1
    else
      r5 = _nt_implicit_string
      if r5
        r0 = r5
      else
        self.index = i0
        r0 = nil
      end
    end

    node_cache[:string][start_index] = r0

    return r0
  end

  def _nt_implicit_string
    start_index = index
    if node_cache[:implicit_string].has_key?(index)
      cached = node_cache[:implicit_string][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      if input.index(Regexp.new('[^|\\],)]',nil,'u'), index) == index
        next_character = index + input[index..-1].match(/\A(.)/um).end(1)
        r1 = instantiate_node(SyntaxNode,input, index...next_character)
        @index = next_character
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(Literal,input, i0...index, s0)

    node_cache[:implicit_string][start_index] = r0

    return r0
  end

  def _nt_string_value
    start_index = index
    if node_cache[:string_value].has_key?(index)
      cached = node_cache[:string_value][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      if input.index(Regexp.new('[^"]',nil,'u'), index) == index
        next_character = index + input[index..-1].match(/\A(.)/um).end(1)
        r1 = instantiate_node(SyntaxNode,input, index...next_character)
        @index = next_character
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(Literal,input, i0...index, s0)

    node_cache[:string_value][start_index] = r0

    return r0
  end

  module Text0
  end

  def _nt_text
    start_index = index
    if node_cache[:text].has_key?(index)
      cached = node_cache[:text][index]
      @index = cached.interval.end if cached
      return cached
    end

    i0, s0 = index, []
    if input.index(Regexp.new('[^\\[]',nil,'u'), index) == index
      next_character = index + input[index..-1].match(/\A(.)/um).end(1)
      r1 = instantiate_node(SyntaxNode,input, index...next_character)
      @index = next_character
    else
      r1 = nil
    end
    s0 << r1
    if r1
      s2, i2 = [], index
      loop do
        if input.index(Regexp.new('[^\\[]',nil,'u'), index) == index
          next_character = index + input[index..-1].match(/\A(.)/um).end(1)
          r3 = instantiate_node(SyntaxNode,input, index...next_character)
          @index = next_character
        else
          r3 = nil
        end
        if r3
          s2 << r3
        else
          break
        end
      end
      r2 = instantiate_node(SyntaxNode,input, i2...index, s2)
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(Literal,input, i0...index, s0)
      r0.extend(Text0)
    else
      self.index = i0
      r0 = nil
    end

    node_cache[:text][start_index] = r0

    return r0
  end

  def _nt_space
    start_index = index
    if node_cache[:space].has_key?(index)
      cached = node_cache[:space][index]
      @index = cached.interval.end if cached
      return cached
    end

    s0, i0 = [], index
    loop do
      if input.index(Regexp.new('[ \\n]',nil,'u'), index) == index
        next_character = index + input[index..-1].match(/\A(.)/um).end(1)
        r1 = instantiate_node(SyntaxNode,input, index...next_character)
        @index = next_character
      else
        r1 = nil
      end
      if r1
        s0 << r1
      else
        break
      end
    end
    r0 = instantiate_node(SyntaxNode,input, i0...index, s0)

    node_cache[:space][start_index] = r0

    return r0
  end

end

class PersonifyLanguageParser < Treetop::Runtime::CompiledParser
  include PersonifyLanguage
end
