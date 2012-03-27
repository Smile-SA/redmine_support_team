require 'rubygems'
require 'yaml'
require 'net/imap'
require 'mail'

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
      rescue Net::IMAP::NoResponseError
        puts "Login or password incorrect"
        imap.disconnect
        next
      end

      begin
        imap.select(c['folder'])
      # A Net::IMAP::NoResponseError is raised if the mailbox does not exist
      # or is for some reason non-examinable
      rescue Net::IMAP::NoResponseError
        puts "Can't select folder"
        imap.disconnect
        next
      end

      imap.search(['NOT', 'SEEN']).each do |message_id|
      #   data = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      #   puts "Receiving message #{message_id}"
      #   process(data)
      #   puts "Message #{message_id} successfully processed"
      end

      # imap.expunge

      imap.disconnect
    end
  end

  def process(data)
    mail = Mail.new(data.to_s)

    projectname = project_name(mail)
    from = mail_from(mail)
    subject = mail.subject
    body = mail.body
    cc_list = mail.cc

    status = IssueStatus.first
    tracker = Tracker.first
    priority = IssuePriority.find(:first, :conditions => { :is_default => true })
    category = nil

    # TODO: add iconv support
    # ic = Iconv.new('UTF-8', 'UTF-8')

    project = Project.find_by_identifier(projectname)
    unless project
      puts "Unable to find project [#{projectname}]"
      next
    end

#     priorities = IssuePriority.all
#     @DEFAULT_PRIORITY = priorities[0]
#     @DEFAULT_TRACKER = p.trackers.find_by_position(1) || Tracker.find_by_position(1)
#     @PRIORITY_MAPPING = {}
#     priorities.each { |prio| @PRIORITY_MAPPING[prio.name] = prio }
#
    user = User.find_by_mail(from)

    unless user
      puts "Unable to find user"
      next
    end

#     puts "Searching for issue [#{@issue}]" if @debug
#     i = Issue.find_by_id(@issue)
#
#     if(i == nil)

      prio = @PRIORITY_MAPPING[@priority] || @DEFAULT_PRIORITY
      st = IssueStatus.find_by_name(@status) || IssueStatus.default
      t = p.trackers.find_by_name(@tracker) || @DEFAULT_TRACKER
      c = p.issue_categories.find_by_name(@category)
      issue = Issue.create(:priority => priority,
                           :status => status,
                           :tracker => tracker,
                           :project => project,
                           :category => category,
                           :start_date => Date.today, # TODO: check time zome stuff
                           :author => user,
                           :description => body,
                           :subject => subject) # TODO: iconv stuff

      unless issue.save
        puts "Failed to save new issue"
        next
      end
#     else
#       puts "Issue exists, adding comment..."
#       n = Journal.new(:notes => ic.iconv(@desc),
#                       :journalized => i,
#                       :user => u);
#       if(!n.save)
#         puts "Failed to add comment"
#         return false
#       end
#     end
  end

  def project_name(mail)
    mail.to.first.split('@')[0]
  end

  def mail_from(mail)
    mail.from.first
  end
end
