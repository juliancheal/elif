require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"

require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "elif.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:test]

Rake::TestTask.new do |test|
	test.libs       << "test"
	test.test_files = [ "test/ts_all.rb" ]
	test.verbose    = true
end

Rake::RDocTask.new do |rdoc|
	rdoc.main     = "README"
	rdoc.rdoc_dir = "doc/html"
	rdoc.title    = "Elif Documentation"
	rdoc.rdoc_files.include( "README",  "INSTALL",
	                         "TODO",    "CHANGELOG",
	                         "AUTHORS", "COPYING",
	                         "LICENSE", "lib/" )
end

desc "Upload current documentation to Rubyforge"
task :upload_docs => [:rdoc] do
	sh "scp -r doc/html/* " +
	   "bbazzarrakk@rubyforge.org:/var/www/gforge-projects/elif/"
end

desc "Show library's code statistics"
task :stats do
	require 'code_statistics'
	CodeStatistics.new( ["Elif", "lib"], 
	                    ["Units",     "test"] ).to_s
end

spec = Gem::Specification.new do |spec|
	spec.name    = "elif"
	spec.version = version

	spec.platform = Gem::Platform::RUBY
	spec.summary  = "Elif allows you to read a file line by line in reverse."

	# spec.test_suite_file = "test/ts_all.rb"
	spec.files           = Dir.glob("{lib}/**/*.rb").
	                           reject { |item| item.include?(".svn") } +
	                       ["Rakefile", "setup.rb"]

	spec.has_rdoc         = true
	spec.extra_rdoc_files = %w[ AUTHORS COPYING README INSTALL TODO CHANGELOG
	                            LICENSE ]
	spec.rdoc_options     << "--title" << "Elif Documentation" <<
	                         "--main"  << "README"

	spec.require_path = "lib"

	spec.author            = "James Edward Gray II"
	spec.email             = "james@grayproductions.net"
	spec.rubyforge_project = "elif"
	spec.homepage          = "http://elif.rubyforge.org"
	spec.description       = <<END_DESC
A port of File::ReadBackwards, the Perl module by Uri Guttman, for reading a
file in reverse, line by line. This can often be helpful for things like log
files, where the interesting information is usually at the end.
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.need_zip = true
	pkg.need_tar = true
end

desc "Add new files to Subversion"
task :add_to_svn do
  sh %Q{svn status | ruby -nae 'system "svn add \#{$F[1]}" if $F[0] == "?"' }
end
