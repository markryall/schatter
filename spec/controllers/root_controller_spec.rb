require 'spec_helper'

describe RootController do
  it 'should respond with hypermedia links' do
    get :index, format: :json
    response.body.should == {
      _links: {
        self: { href: 'http://test.host/' },
        conversations: { href: 'http://test.host/conversations?auth_token=AUTH_TOKEN' }
      }
    }.to_json
  end
end