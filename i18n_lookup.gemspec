Gem::Specification.new do |s|
  s.name          = 'i18n_lookup'
  s.summary       = 'I18n Lookup'
  s.description   = 'A toolset for I18n handling'
  s.version       = '0.3.1'
  s.platform      = Gem::Platform::RUBY

  s.license       = 'MIT'

  s.files         = Dir['lib/**/*']
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = %w{lib}

  s.author        = 'Thomas Metzmacher'
  s.email         = 'kontakt@thomet.de'
  s.homepage      = 'http://www.thomet.de/'

  s.add_dependency('i18n', [">= 0"])

  s.add_development_dependency('rspec', ["~> 2.0"])
  s.add_development_dependency('awesome_print', ["~> 1.2"])
  s.add_development_dependency('activemodel', ["~> 4.0.2"])
end
