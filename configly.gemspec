lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'configly/version'

Gem::Specification.new do |s|
  s.name        = 'configly'
  s.version     = Configly::VERSION
  s.summary     = 'Minimal, lightweight, multi-YAML settings'
  s.description = 'Minimal, lightweight, multi-YAML settings'
  s.authors     = ['Danny Ben Shitrit']
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/configly'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.7'
  s.metadata['rubygems_mfa_required'] = 'true'
end
