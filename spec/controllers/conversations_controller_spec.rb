require 'spec_helper'

describe ConversationsController do
  let(:person) { stub 'person', conversations: [] }
  let(:conversation) { stub 'conversation', uuid: 'id', to_hal: {uuid: 'id'} }

  before do
    controller.stub(:current_person).and_return person
    Conversation.stub(:find_by_uuid).with('id').and_return conversation
    person.stub(:create_conversation).and_return conversation
  end

  it 'should return empty conversation list if the current person has none' do
    get :index, format: :json
    response.body.should == {
      conversations: []
    }.to_json
  end

  it 'should list conversations for the current person' do
    person.stub(:conversations).and_return [conversation]
    get :index, format: :json
    response.body.should == {
      conversations: [{
        uuid: 'id',
        _links: {
          self: { href: 'http://test.host/conversations/id' },
          messages: { href: 'http://test.host/conversations/id/messages' }
        }
      }]
    }.to_json
  end

  it 'should show conversation' do
    get :show, format: :json, id: 'id'
    response.body.should == {
      uuid: 'id',
      _links: {
        self: { href: 'http://test.host/conversations/id' },
        messages: { href: 'http://test.host/conversations/id/messages' }
      }
    }.to_json
  end

  it 'should create conversation' do
    post :create, format: :json
    response.body.should == {
      uuid: 'id',
      _links: {
        self: { href: 'http://test.host/conversations/id' },
        messages: { href: 'http://test.host/conversations/id/messages' }
      }
    }.to_json
  end
end
