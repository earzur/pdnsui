
describe "The Domains controller" do
  behaves_like :rack_test

  should 'add domain' do
    post('/domains/create', :name => 'example.com', :type => 'SLAVE', :master => '1.2.3.4').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /domain example.com added/i
  end

  should 'not add the same domain twice' do
    post('/domains/create', :name => 'another.example.com', :type => 'SLAVE', :master => '1.2.3.4').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /domain example.com added/i
    post('/domains/create', :name => 'another.example.com', :type => 'SLAVE', :master => '1.2.3.4').status.should == 200 
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /domain example.com already exists/i
  end
end
