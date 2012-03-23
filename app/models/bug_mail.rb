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
      rescue Errno::ECONNREFUSED,        # connection refused by host or an intervening firewall.
             Errno::ETIMEDOUT,           # connection timed out (possibly due to packets being dropped by an intervening firewall).
             Errno::ENETUNREACH,         # there is no route to that network.
             SocketError,                # hostname not known or other socket error.
             Net::IMAP::ByeResponseError # we connected to the host, but they immediately said goodbye to us.
        puts "Can't connect to IMAP server"
        next
      end

      begin
        imap.login(c['username'], c['password'])
      ensure
        imap.disconnect
      rescue Net::IMAP::NoResponseError
        puts "Login or password incorrect"
        next
      end

      begin
        imap.examine(c['folder'])
        imap.select(c['folder'])
      ensure
        imap.disconnect
      # A Net::IMAP::NoResponseError is raised if the mailbox does not exist
      # or is for some reason non-examinable
      rescue Net::IMAP::NoResponseError
        puts "Can't select folder"
        next
      end
      imap.disconnect

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
