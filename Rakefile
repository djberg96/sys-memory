require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.rbx')

RSpec::Core::RakeTask.new(:spec)

namespace 'gem' do
  desc "Create the sys-memory gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('sys-memory.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the sys-memory gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

task :default => :spec
