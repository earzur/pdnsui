require_relative '../helper'

describe "The Utils controller" do
  behaves_like :rack_test

  should 'notify slaves' do
    get('/utils/notify_slaves').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response =~ /not implemented/
  end
end
