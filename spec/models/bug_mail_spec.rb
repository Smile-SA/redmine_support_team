require File.dirname(__FILE__) + '/../spec_helper'

describe BugMail do
  it "should return instance of Hash" do
    file = 'example.yml'
    config = BugMail.new.parse_config(file)

    config.should be_an_instance_of Hash
  end

  it "should parse config" do
    file = 'example.yml'
    config = BugMail.new.parse_config(file)

    config['gmail']['host'].should == 'imap.gmail.com'
    config['gmail']['port'].should == 993
    config['gmail']['ssl'].should be_true
    config['gmail']['username'].should == 'igor.zubkov@gmail.com'
    config['gmail']['password'].should == 'password'
    config['gmail']['folder'].should == 'INBOX'

    config['example']['host'].should == 'example.com'
    config['example']['port'].should == 1111
    config['example']['ssl'].should be_false
    config['example']['username'].should == 'me@example.com'
    config['example']['password'].should == 'anotherpassword'
    config['example']['folder'].should == 'BOX'
  end

  it "should return project name (To:)" do
    data = `cat spec/data/email.txt`
    bug_mail = BugMail.new
    mail = Mail.new(data.to_s)
    bug_mail.project_name(mail).should == 'xxxx'
  end

  it "should return user email (From:)" do
    data = `cat spec/data/email.txt`
    bug_mail = BugMail.new
    mail = Mail.new(data.to_s)
    bug_mail.mail_from(mail).should == 'igor.zubkov@gmail.com'
  end
end
