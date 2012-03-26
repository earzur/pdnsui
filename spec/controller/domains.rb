require_relative '../helper'

describe "The Domains controller" do
  behaves_like :rack_test

  before do
    @domain = Domain.new(:name => '0.example.com', :type => 'MASTER').save
    Domain.new(:name => 'zzzz.example.com', :type => 'MASTER').save
  end

  after do
    Domain.filter(:name => '0.example.com').destroy
    Domain.filter(:name => '1.example.com').destroy
    Domain.filter(:name => 'zzzz.example.com').destroy
  end

  should 'show domains list' do
    get('/domains/').status.should == 200
    last_response.should =~ /0.example.com/
  end

  # FIXME: Well, this will always pass if #domains < :paginate[:limit]
  should 'show domains list in descending order' do
    get('/domains/', :order => 'desc').status.should == 200
    last_response.should =~ /zzzz.example.com/
  end

  should 'show records page' do
    get("/domains/records/#{@domain.id}").status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /<h1>0.example.com<\/h1>/
  end

  should 'show records page in descending order' do
    # Fixtures
    ('zzya'..'zzzz').each do |t|
      @domain.add_record(:name => "#{t}.0.example.com",
                         :type => 'A', :content => '1.2.3.4')
    end
    # Test
    get("/domains/records/#{@domain.id}", :order => 'desc').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /zzzz.0.example.com/
  end

  should 'not show a records for a non-existent domain' do
    get("/domains/records/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Sorry, the domain id '99999' doesn't exist/
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
    last_response.should =~ /Entry 1.example.com created successfully/

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
    last_response.should =~ /Entry 1.example.com updated successfully/
   end

  should 'not update a non-existent domain' do
    post('/domains/save',
         :domain_id   => 999999,
         :name =>'1.example.com',
         :type => 'MASTER',
         :master => '4.3.2.1').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.should =~ /Can not update this domain/
  end

  should 'delete domain' do
    id = Domain.filter(:name => '0.example.com').first[:id]

    get("/domains/delete/#{id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Entry 0.example.com deleted successfully/
  end

  should 'not delete a non-existent domain' do
    get("/domains/delete/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Sorry, the domain id '99999' doesn't exist/
  end

  should 'not add the same domain twice' do
    post('/domains/save',
         :name => '0.example.com',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Invalid data : name is already taken/
  end
end
