require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Glowfic
  ALLOWED_TAGS = ["b", "i", "u", "sub", "sup", "del", "hr", "p", "br", "div", "span", "pre", "code", "h1", "h2", "h3", "h4", "h5", "h6", "ul", "ol", "li", "dl", "dt", "dd", "a", "img", "blockquote", "table", "td", "th", "tr", "strike", "s", "strong", "em", "big", "small", "font"]

  class Application < Rails::Application
    config.assets.enabled = true
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local

    config.action_view.sanitized_allowed_tags = Glowfic::ALLOWED_TAGS
    config.after_initialize do
      ActionView::Base.sanitized_allowed_attributes += ['style', 'target']
    end
    config.middleware.use Rack::Pratchett

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
