Gem::Specification.new do |s|
  s.name         = 'i18n_lookup'
  s.summary      = 'I18n Lookup'
  s.description  = 'Prints out the I18n calls'
  s.version      = '0.2.0'
  s.platform     = Gem::Platform::RUBY

  s.license      = 'MIT'

  s.files        = ['i18n_lookup.rb']
  s.test_file    = 'i18n_lookup_spec.rb'
  s.require_path = '.'

  s.author       = 'Thomas Metzmacher'
  s.email        = 'kontakt@thomet.de'
  s.homepage     = 'http://www.thomet.de/'

  s.add_dependency('i18n', ["~> 0.6.9"])

  s.add_development_dependency('rspec', ["~> 2.0"])
  s.add_development_dependency('pry-debugger', ["~> 0.2"])
  s.add_development_dependency('awesome_print', ["~> 1.2"])
  s.add_development_dependency('activemodel', ["~> 4.0.2"])
end
