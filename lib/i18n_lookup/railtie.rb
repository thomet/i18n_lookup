require 'i18n_lookup'
require 'rails'

module I18nLookup
  class Railtie < Rails::Railtie
    railtie_name :i18n_lookup

    rake_tasks do
      load "tasks/i18n_normalize.rake"
      load "tasks/i18n_missing_keys.rake"
    end
  end
end
