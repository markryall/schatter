TEMPLATE = <<EOF
# schatter

A simple persisted chat service.  See the schatter gem for wrapping calls to this service.

## Getting started

Deploy the application somewhere (heroku for instance).

Log in with a persona account.

Use the generated auth_token for everything else.

## Deployment

You can try this out on heroku (after installing the heroku toolbelt):

    heroku apps:create
    heroku addons:add heroku-postgresql
    heroku config:add RAILS_SECRET=`rake secret`
    git push heroku master
    heroku run rake db:migrate

## API

My inadequate understanding of REST suggests that guessing urls from known templates is bad.

Instead you hit a resource url and follow hypermedia links to determine what can be done next.

    <%= urls.command %>

This will return a list of resource urls:

    <%= urls.result %>

Retrieve list of conversations by replacing the AUTH_TOKEN with the auth token generated when you sign in with a persona id.

    <%= empty_conversations.command %>

Initially this will return an empty list of conversations (because you haven't created any):

    <%= empty_conversations.result %>

You can create a new conversation with a POST to the conversation resource url:

    <%= first_conversation.command %>

This will return the conversation resource including urls for messages and people (conversation participants):

    <%= first_conversation.result %>

This new conversation will now be included in the response to the conversation request.

    <%= conversations.command %>

    <%= conversations.result %>

You can retrieve the conversation using the resource url:

    <%= retrieved_conversation.command %>

    <%= retrieved_conversation.result %>

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    <%= empty_messages.command %>

    <%= empty_messages.result %>

To create a new message in a conversation:

    <%= first_message.command %>

This will return the message resource.

    <%= first_message.result %>

Now retrieving conversation messages will include the new message:

    <%= messages.command %>

    <%= messages.result %>

Messages can be deleted (only by the initial creator of the message)

    <%= deleted_message.command %>

    <%= deleted_message.result %>

Initially the members of a conversation will only include the person who created it:

    <%= initial_people.command %>

    <%= initial_people.result %>

New members can be created by posting to the conversation people url:

    <%= new_person.command %>

    <%= new_person.result %>

This new person will now be included in the conversation list:

    <%= people.command %>

    <%= people.result %>

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
EOF

require 'json'
require 'cgi'

class Curl
  def non_post verb, url, params
    params[:auth_token] = ENV['SCHATTER_AUTH_TOKEN']
    "curl -s -H 'Accept: application/json' -X #{verb} #{url}?#{params.map{ |k,v| "#{k}=#{CGI.escape v.to_s}" }.join('&')}"
  end

  def get url, params={}
    non_post 'GET', url, params
  end

  def delete url, params={}
    non_post 'DELETE', url, params
  end

  def post url, data
    data[:auth_token] = ENV['SCHATTER_AUTH_TOKEN']
    "curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '#{data.to_json}' #{url}"
  end
end

class Request
  attr_reader :command, :result

  def initialize command
    @command = command.tap {|c| $stderr.puts c }
    @result = `#{command}`.tap {|c| $stderr.puts c }
    raise "#{command.inspect} failed with exit status #{$?.exitstatus}" unless $?.success?
    @parsed_result = JSON.parse @result
  end

  def link key
    @parsed_result['_links'][key.to_s]['href']
  end
end

require 'erb'

curl = Curl.new
base_url = 'http://localhost:3000'

urls = Request.new curl.get base_url

empty_conversations = Request.new curl.get urls.link(:conversations)
first_conversation = Request.new curl.post urls.link(:conversations), name: 'first conversation'
conversations = Request.new curl.get urls.link(:conversations)
retrieved_conversation = Request.new curl.get first_conversation.link(:self)

empty_messages = Request.new curl.get first_conversation.link(:messages)
first_message = Request.new curl.post first_conversation.link(:messages), content: 'first message'
messages = Request.new curl.get first_conversation.link(:messages)
deleted_message = Request.new curl.delete first_message.link(:self)

initial_people = Request.new curl.get first_conversation.link(:people)
new_person = Request.new curl.post first_conversation.link(:people), email: 'test2@email.com'
people = Request.new curl.get first_conversation.link(:people)

template = ERB.new TEMPLATE, 0, "%<>"

puts template.result binding