require 'spec_helper'

describe ConversationsController do
  let(:conversation_hal) { {hal: 'conversation'} }
  let(:person) { stub 'person' }
  let(:conversation) { stub 'conversation', uuid: 'id', to_hal: conversation_hal }

  before do
    controller.stub(:current_person).and_return person
  end

  it 'should return empty conversation list if the current person has none' do
    person.stub(:conversations).and_return []
    get :index, format: :json
    response.body.should == {
      conversations: []
    }.to_json
  end

  it 'should list conversations for the current person' do
    person.stub(:conversations).and_return [conversation]
    get :index, format: :json
    response.body.should == {
      conversations: [conversation_hal]
    }.to_json
  end

  it 'should show conversation' do
    Conversation.stub(:find_by_uuid).with('id').and_return conversation
    conversation.stub!(:people).and_return [person]
    get :show, format: :json, id: 'id'
    response.body.should == conversation_hal.to_json
  end

  it 'should create conversation' do
    person.stub(:create_conversation).and_return conversation
    post :create, format: :json
    response.body.should == conversation_hal.to_json
  end
end
