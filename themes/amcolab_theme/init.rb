# public/themes/amcolab/init.rb

Rails.application.config.to_prepare do
  Redmine::Themes.register :amcolab_theme do |theme|
    theme.version     = '0.1'
    theme.author      = 'ChienLM'
    theme.description = 'Redmine theme custom for Am Co Lab'
    theme.stylesheets << 'amcolab_theme/assets/stylesheet'
  end
end
