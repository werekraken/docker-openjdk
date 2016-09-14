require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'open3'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc "Check erb syntax"
task :erb do
  FileList['*.erb'].each do |template|
    puts "---> syntax:#{template}"
    Open3.popen3('ruby -c') do |stdin, stdout, stderr|
    stdin.puts(ERB.new(File.read(template), nil, '-').src)
    stdin.close
    error = stderr.readline rescue false
    if error
      puts error
      puts stderr.read
      exit 1
    end
    stdout.close rescue false
    stderr.close rescue false
    end
  end
end

desc "Run erb and rubocop"
task :test => [
  :erb,
  :rubocop,
]
