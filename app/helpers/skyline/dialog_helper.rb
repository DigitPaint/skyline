module Skyline::DialogHelper
  
  def dialog(title,*args,&block)   
    options_for_render = args.extract_options!
    options_for_render.reverse_merge! :width => "auto", :height => "auto"
    
    if args.any?
      content = args.last 
      options = options_for_render
    else
      options = options_for_render.slice!(:partial, :locals)   
      content = render(options_for_render)
    end
    
    options.each do |k,v|
      options[k] = case v
        when String,Symbol : "'" + escape_javascript(v.to_s) + "'"
        when Hash : options_for_javascript(v)
        else v
      end
    end    
    
    p =  "(function(){"
    p << "var sd = new Skyline.Dialog(#{options_for_javascript(options)});"
    p << "sd.setTitle('#{escape_javascript(title)}');"
    p << "sd.setContent('#{escape_javascript(content)}');"
    p << "sd.setup(); sd.show();"
    p << "})()"
  end
  
end