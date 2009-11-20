module PersonifyLanguage
  class Literal < Treetop::Runtime::SyntaxNode
    def eval(env={})
      text_value
    end
  end
end