# Add our own locales to load_path

skyline_locales = Dir[Skyline.root + "config/locales/*.{yml,rb}"]

# We'll be inserting our locales before the default config/locales directive
idx = I18n.load_path.index(I18n.load_path.grep(/#{Rails.root}\/config\/locales.+/).first)
I18n.load_path.insert(idx,*skyline_locales)

# And we set a default (this can be overridden in an intializer)
I18n.locale = "en-US"
I18n.default_locale = "en-US"