require 'erb'
require 'fileutils'
require 'rake'
require 'yaml'

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
