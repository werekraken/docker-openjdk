require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'open3'
require 'rubocop/rake_task'
require 'yaml'

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

desc "Check yaml syntax"
task :yaml do
  FileList['*.yml'].each do |yaml|
    puts "---> syntax:#{yaml}"
    begin
      YAML.load_file(yaml)
    rescue => e
      STDERR.puts e.message
      exit 1
    end
  end
end

desc "Run erb and rubocop"
task :test => [
  :erb,
  :yaml,
  :rubocop,
]
