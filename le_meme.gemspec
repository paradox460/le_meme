# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'le_meme/version'

Gem::Specification.new do |spec|
  spec.name          = 'le_meme'
  spec.version       = LeMeme::VERSION
  spec.authors       = ['Jeff Sandberg']
  spec.email         = ['paradox460@gmail.com']
  spec.summary       = 'Dank memes, in gem form'
  spec.description   = 'A gem that generates memes. Can be used as a library or command-line executable.'
  spec.homepage      = 'http://github.com/paradox460/le_meme'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'rmagick', '~> 2.15'
  spec.add_runtime_dependency 'word_wrapper', '~> 0.5.0'
end
