require 'spec_helper'

describe MessagesController do
  let(:person) { stub 'person' }

  let(:message) do
    stub 'message', uuid: 'message_id', to_hal: {uuid: 'message_id', content: 'message content'}
  end

  let(:conversation) do
    stub 'conversation',
      uuid: 'conversation_id',
      to_hal: {uuid: 'conversation_id'},
      messages: [message],
      people: [person]
  end

  before do
    controller.stub(:current_person).and_return person
    Conversation.stub(:find_by_uuid).with('conversation_id').and_return conversation
  end

  it 'should show conversation messages' do
    get :index, format: :json, conversation_id: 'conversation_id'
    response.body.should == {
      messages: [
        {
          uuid: 'message_id',
          content: 'message content',
          _links: {
            self: { href: 'http://test.host/messages/message_id' },
          }
        }
      ]
    }.to_json
  end
end
