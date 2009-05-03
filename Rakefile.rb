$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'vodpod/version'
require 'find'
 
# Don't include resource forks in tarballs on Mac OS X.
ENV['COPY_EXTENDED_ATTRIBUTES_DISABLE'] = 'true'
ENV['COPYFILE_DISABLE'] = 'true'
 
# Gemspec
vodpod_gemspec = Gem::Specification.new do |s|
  s.rubyforge_project = 'vodpod'
 
  s.name = 'vodpod'
  s.version = Vodpod::APP_VERSION
  s.author = Vodpod::APP_AUTHOR
  s.email = Vodpod::APP_EMAIL
  s.homepage = Vodpod::APP_URL
  s.platform = Gem::Platform::RUBY
  s.summary = 'Ruby bindings for the Vodpod API.'
 
  s.files = FileList['{lib}/**/*', 'LICENSE', 'README'].to_a
  s.executables = ['']
  s.require_path = 'lib'
  s.has_rdoc = true
 
  s.required_ruby_version = '>= 1.8.5'
 
  s.add_dependency('json', '~> 1.1.4')
end
 
Rake::GemPackageTask.new(vodpod_gemspec) do |p|
  p.need_tar_gz = true
end
 
Rake::RDocTask.new do |rd|
  rd.main = 'Vodpod'
  rd.title = 'Vodpod'
  rd.rdoc_dir = 'doc'
 
  rd.rdoc_files.include('lib/**/*.rb')
end
 
desc "install Vodpod"
task :install => :gem do
  sh "gem install #{File.dirname(__FILE__)}/pkg/vodpod-#{Vodpod::APP_VERSION}.gem"
end
 
desc "remove end-of-line whitespace"
task 'strip-spaces' do
  Dir['lib/**/*.{css,js,rb,rhtml,sample}'].each do |file|
    next if file =~ /^\./
 
    original = File.readlines(file)
    stripped = original.dup
 
    original.each_with_index do |line, i|
      if line =~ /\s+\n/
        puts "fixing #{file}:#{i + 1}"
        p line
        stripped[i] = line.rstrip
      end
    end
 
    unless stripped == original
      File.open(file, 'w') do |f|
        stripped.each {|line| f.puts(line) }
      end
    end
  end
end
