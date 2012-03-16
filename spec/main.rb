require File.expand_path('../../spec/helper', __FILE__)


describe MainController do
  behaves_like :rack_test

  should 'show start page' do
    get('/').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Ramaze PowerDNS Interface/
  end

end
