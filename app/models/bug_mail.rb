require 'yaml'
require 'net/imap'

class BugMail
  def parse_config(file = nil)
    file = "config/better_imap.yml" unless file

    options = YAML.load_file(file)
    options
  end

  def fetch
    options = self.parse_config
    options.each do |hash|
      c = hash.last
      puts "Fetching emails for #{c['username']}"

      begin
        imap = Net::IMAP.new(c['host'], c['port'], c['ssl'], nil, false)
        # TODO: rescue for login incorrect
        imap.login(c['username'], c['password'])
        begin
          imap.examine(c['folder'])
          imap.select(c['folder'])
        rescue Net::IMAP::NoResponseError
          puts "Can't select folder"
        end
        imap.disconnect
      rescue
        puts "Bad"
      end

      # imap.search(['NOT', 'SEEN']).each do |message_id|
      #   msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      #   puts "Receiving message #{message_id}"
      #   process(msg)
      #   puts "Message #{message_id} successfully processed"
      # end
      # 
      # imap.expunge


    end
  end
end
