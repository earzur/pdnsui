require_relative '../helper'
#DB.loggers << Logger.new($stdout)
describe "The Records controller" do
  behaves_like :rack_test

  before do
    Domain.filter(:name => 'example.com').destroy
    @domain = Domain.create(:name => 'example.com', :type => 'MASTER')
    @record = Record.new(:domain_id => @domain.id, :name => "0.example.com",
                         :type => "CNAME", :content => "1.example.com").save
  end

  after do
    @record.destroy if @record.exists?
    @domain.destroy
  end

  should 'show records page for a domain' do
    get("/domains/records/#{@domain.id}").status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /<h1>example.com<\/h1>/
  end

  should 'add record for a domain' do
    post('/records/save',
         :domain_id => @domain.id,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Record 'aaaa' created successfully/
  end

  should 'update record for a domain' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => @record.id,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Record 'aaaa' updated successfully/
  end

  should 'delete record for a domain' do
    get("/records/delete/#{@record.id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Record '0.example.com' deleted successfully/
  end

  should 'not add the same record twice' do
    post('/records/save',
         :domain_id => @domain.id,
         :name      => '0.example.com',
         :type      => 'CNAME',
         :content   => '1.example.com').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Record '1.example.com' already exists/
  end
end

