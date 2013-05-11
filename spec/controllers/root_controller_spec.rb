require 'spec_helper'

describe RootController do
  it 'should respond with hypermedia links' do
    controller.stub(:new_uuid).and_return 'uuid'
    get :index, format: :json
    response.body.should == {
      _links: {
        self: { href: 'http://test.host/?session_id=uuid' },
        conversations: { href: 'http://test.host/conversations?session_id=uuid' }
      }
    }.to_json
  end
end