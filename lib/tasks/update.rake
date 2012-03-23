namespace :redmine do
  namespace :better_imap do
    desc 'Update mail from IMAP server'
    task :update => :environment do
      bug_mail = BugMail.new
      bug_mail.fetch
    end
  end
end
