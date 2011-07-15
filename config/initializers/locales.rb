# Add our own locales to load_path

skyline_locales = Dir[Skyline.root + "config/locales/*.{yml,rb}"]

puts I18n.load_path.inspect

# We'll be inserting our locales before the default config/locales directive
idx = I18n.load_path.index(I18n.load_path.grep(/#{Rails.root}\/config\/locales.+/).first)

if idx
  I18n.load_path.insert(idx,*skyline_locales)
else
  skyline_locales.each do |locale|
    I18n.load_path << locale
  end
end

# And we set a default (this can be overridden in an intializer)
I18n.locale = "en-US"
I18n.default_locale = "en-US"