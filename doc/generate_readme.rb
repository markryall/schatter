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

    <%= urls_command %>

This will return a list of resource urls:

    <%= urls_output %>

Retrieve list of conversations by replacing the AUTH_TOKEN with the auth token generated when you sign in with a persona id.

    <%= conversations_command %>

Initially this will return an empty list of conversations (because you haven't created any):

    <%= conversations_output %>

You can create a new conversation with a POST to the conversation resource url:

    <%= new_conversation_command %>

This will return the conversation resource including urls for messages and people (conversation participants):

    <%= new_conversation_output %>

Getting a conversation:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X GET 'http://localhost:3000/conversations/8d4dc8d8-7f05-4c92-97f7-baf86e2d156e?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

Adding a message to a conversation:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X POST -d '{"content": "hello world"}' 'http://localhost:3000/conversations/c639211d-7a20-419e-8ff0-129e77ef1f49/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

This will return the message:

    {"uuid":"8626f75f-49bb-468a-8b9a-b856859778af","content":"hello world","timestamp":1364548482}

Getting conversation messages:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X GET 'http://localhost:3000/conversations/c639211d-7a20-419e-8ff0-129e77ef1f49/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

Destroying a message:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X DELETE 'http://localhost:3000/messages/d2fe2f02-9518-4d14-8723-b1ec5c057d30?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
EOF

require 'json'

def execute command
  out = `#{command}`
  raise "#{command.inspect} failed with exit status #{$?.exitstatus}" unless $?.success?
  out
end

class Curl
  def get url
    "curl -s -H 'Accept: application/json' -X GET #{url}"
  end

  def post url, data
    "curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '#{data.to_json}' #{url}"
  end
end

class Urls
  attr_reader :urls, :auth_token

  def initialize executed_urls, auth_token
    @urls = JSON.parse(executed_urls)['_links']
    @auth_token = auth_token
  end

  def [] key
    urls[key.to_s]['href'].gsub('AUTH_TOKEN', auth_token)
  end
end

require 'erb'

curl = Curl.new
base_url = 'http://localhost:3000'
urls_command = curl.get base_url
urls_output = execute urls_command
urls = Urls.new urls_output, ENV['SCHATTER_AUTH_TOKEN']
conversations_command = curl.get urls[:conversations]
conversations_output = execute conversations_command
new_conversation_command = curl.post urls[:conversations], name: 'first conversation'
new_conversation_output = execute new_conversation_command

template = ERB.new TEMPLATE, 0, "%<>"

puts template.result binding