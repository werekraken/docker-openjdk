require 'erb'
require 'fileutils'
require 'yaml'

yaml = YAML.load_file('Dockerfile.yml')

yaml['parameters'].each do |parameter|
  parameter.each do |k, v|
    instance_variable_set "@#{k}", v
  end

  path = parameter[yaml['path_from']]

  puts "Generating #{path}/Dockerfile"
  puts ""
  puts "  parameters:"
  parameter.each do |k, v|
    puts "    #{k}: #{v}"
  end
  puts ""

  template = File.read('Dockerfile.erb')
  dockerfile = ERB.new(template, nil, '-').result()
  FileUtils.mkdir_p path
  File.write("#{path}/Dockerfile", dockerfile)
end
