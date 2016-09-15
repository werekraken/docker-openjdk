require 'rubygems'
require 'bundler/setup'

require 'docker'
require 'erb'
require 'fileutils'
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

desc "Run dockerfile_lint"
task :lint do
  project_root = File.expand_path(File.dirname(__FILE__))
  image = Docker::Image.create('fromImage' => 'projectatomic/dockerfile-lint')
  FileList['**/Dockerfile'].exclude(/^vendor/).each do |dockerfile|
    puts "---> lint:#{dockerfile}"
    container = Docker::Container.create({
      :Cmd        => [ 'dockerfile_lint', '-r', '.dockerfile_lint.yml', '-f', dockerfile ],
      :Image      => image.id,
      :HostConfig => {
        :Privileged => true,
      },
      :Tty        => true,
    })

    container.start({
      :Binds => [ "#{project_root}:/root" ],
    })

    status_code = container.wait['StatusCode']
    puts container.logs(stdout: true)

    container.remove

    if status_code.nonzero?
      exit status_code
    end
  end
end

desc "Generate Dockerfiles"
task :update do
  FileList['*.yml'].each do |dockerfile_yml|
    dockerfile_erb = File.basename(dockerfile_yml,'.yml') + '.erb'
    unless File.exist?(dockerfile_erb)
      STDERR.puts "Template '#{dockerfile_erb}' not found. Skipping '#{dockerfile_yml}'."
      next
    end

    puts "Processing #{dockerfile_yml}."

    variant = File.basename(dockerfile_yml,'.yml')[11..-1]
    config = YAML.load_file(dockerfile_yml)

    config['parameters'].each do |parameter|
      parameter.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      path = parameter[config['path_from']]
      path = File.join(path, variant) if variant

      puts "Generating #{path}/Dockerfile"
      puts ""
      puts "  parameters:"
      parameter.each do |k, v|
        puts "    #{k}: #{v}"
      end
      puts ""

      template = File.read(dockerfile_erb)
      dockerfile = ERB.new(template, nil, '-').result()
      FileUtils.mkdir_p path
      File.write("#{path}/Dockerfile", dockerfile)
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
  :lint,
  :rubocop,
]
