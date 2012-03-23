
describe "The Records controller" do
  behaves_like :rack_test

  should 'show records page for a domain' do
    get('/domains/records/15').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /<h1>adm<\/h1>/
  end

  should 'add record for a domain' do
    false.should.equal true
  end

end

