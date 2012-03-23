require_relative '../helper'

describe "The Records controller" do
  behaves_like :rack_test

  before do
    Domain.filter(:name => 'example.com').destroy
    @domain = Domain.create(:name => 'example.com', :type => 'MASTER')
  end

  after do
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
    # TODO: Write me
    false
  end

  should 'delete record for a domain' do
    # TODO: Write me
    false
  end

  should 'not add the same record twite' do
    # TODO: Write me
    false
  end
end

