require 'yaml'

class BugMail
  def parse_config(file = nil)
    unless file
      file = "/path/to/config.yml"
    end
    config = YAML.load_file('example.yml')
    config
  end
end
