require_relative '../helper'

describe "The Domains controller" do
  behaves_like :rack_test

  before do
    Domain.new(:name => '0.example.com').save
  end

  after do
    Domain.filter(:name => '0.example.com').destroy
    Domain.filter(:name => '1.example.com').destroy
  end

  should 'show domains list' do
    get('/domains/').status.should == 200
    last_response.should =~ /0.example.com/
  end

  should 'add domain' do
    post('/domains/save',
         :name => '1.example.com',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect! 
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Domain '1.example.com' created successfully/

    # THINK: may be check if attributes are fine ?
  end

  should 'update domain' do
    id = Domain.filter(:name => '0.example.com').first[:id]

    # THINK: Well, this should probably be made illegal
    # or handled properly, e.g. rename all records for this domain
    post('/domains/save',
         :domain_id   => id,
         :name =>'1.example.com',
         :type => 'MASTER',
         :master => '4.3.2.1').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.should =~ /Domain '1.example.com' updated successfully/
   end

  should 'delete domain' do
    id = Domain.filter(:name => '0.example.com').first[:id]

    get("/domains/delete/#{id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.should =~ /Domain '0.example.com' deleted successfully/
   end


  should 'not add the same domain twice' do
    post('/domains/save',
         :name => '0.example.com',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Domain '0.example.com' already exists/
  end
end
