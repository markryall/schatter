require 'spec_helper'

describe MessagesController do
  let(:message_hal) { {hal: 'message'} }
  let(:person) { stub 'person' }

  let(:message) do
    stub 'message', uuid: 'message_id', to_hal: message_hal
  end

  let(:conversation) do
    stub 'conversation',
      uuid: 'conversation_id',
      to_hal: {hal: 'conversation'},
      messages: [message],
      people: [person]
  end

  before do
    controller.stub(:current_person).and_return person
    Conversation.stub(:find_by_uuid).with('conversation_id').and_return conversation
  end

  it 'should show conversation messages' do
    get :index, format: :json, conversation_id: 'conversation_id'
    response.body.should == {messages: [message_hal]}.to_json
  end
end
