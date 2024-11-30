require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'sys-memory'
  spec.version    = '0.2.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.license    = 'Apache-2.0'
  spec.homepage   = 'https://github.com/djberg96/sys-memory'
  spec.summary    = 'A Ruby interface for providing memory information'
  spec.test_file  = 'spec/sys_memory_spec.rb'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.add_dependency('ffi', '~> 1.1')
  spec.add_development_dependency('activesupport', '~> 6.0')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rake', '~> 13.0')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rspec')

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/sys-memory',
    'bug_tracker_uri'       => 'https://github.com/djberg96/sys-memory/issues',
    'changelog_uri'         => 'https://github.com/djberg96/sys-memory/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/sys-memory/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/sys-memory',
    'wiki_uri'              => 'https://github.com/djberg96/sys-memory/wiki',
    'rubygems_mfa_required' => 'true',
    'github_repo'           => 'https://github.com/djberg96/sys-memory',
    'funding_uri'           => 'https://github.com/sponsors/djberg96'
  }

  spec.description = <<-EOF
    The sys-memory library provides an interface for gathering information
    about your system's memory. Information includes total physical memory,
    swap, free memory, and so on.
  EOF
end
