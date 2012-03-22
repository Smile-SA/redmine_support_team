require 'yaml'

class BugMail
  def parse_config(file = nil)
    unless file
      file = "config/better_imap.yml"
    end
    config = YAML.load_file(file)
    config
  end
end
