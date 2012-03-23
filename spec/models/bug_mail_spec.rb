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

  it "should parse project name from email" do
    message = `cat spec/data/email.txt`
    bug_mail = BugMail.new
    bug_mail.match(message, /^To:.*?([\w|-]+)@.*$/, nil).should == 'xxxx'
  end

  it "should parse issue short description from email" do
    message = `cat spec/data/email.txt`
    bug_mail = BugMail.new
    bug_mail.line_match(message, "Issue", nil).should == 'demo111'
  end

  it "should parse long issue description from email" do
    message = `cat spec/data/email.txt`
    bug_mail = BugMail.new
    bug_mail.block_match(message, "Description", nil).should == "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nSed dictum sapien hendrerit turpis feugiat aliquet. Maecenas porta viverra mi\neget posuere. Cras convallis dictum massa a vulputate. Nunc fringilla, purus\nat fringilla feugiat, lectus nisi elementum dolor, nec luctus justo arcu nec\nerat. Suspendisse nibh elit, condimentum nec tincidunt a, congue a urna. Nulla\nfacilisi. In vel metus sem. Quisque id dolor at quam eleifend ullamcorper.\nMaecenas tortor erat, ultricies eu aliquet quis, viverra vel metus. In hac\nhabitasse platea dictumst. Suspendisse potenti. Phasellus ac tortor lectus.\nNam ut velit id lectus blandit lacinia.\n"
  end
end
