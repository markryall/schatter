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

My lame understand of REST suggests that building urls from known templates is bad.  Instead you hit a resource url and the hypermedia links to determine what can be done next should be returned.

    <%= curl_get base_url %>

This will give you the resource urls for retrieving collections of conversations:

    <%= execute curl_get base_url %>

Creating a conversation:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X POST -d '{"name": "first conversation"}' 'http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

This will return the resource urls for messages and people (conversation participants):

    {"uuid":"da14e2ae-8cbf-46b6-84c0-437c4a393389","name":"first conversation","timestamp":1364625518,"_links":{"self":{"href":"http://localhost:3000/conversations/da14e2ae-8cbf-46b6-84c0-437c4a393389"},"messages":{"href":"http://localhost:3000/conversations/da14e2ae-8cbf-46b6-84c0-437c4a393389/messages"},"people":{"href":"http://localhost:3000/conversations/da14e2ae-8cbf-46b6-84c0-437c4a393389/people"}}}

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

def base_url
  'http://localhost:3000'
end

def curl_get url
  "curl -H 'Accept: application/json' #{url}"
end

def execute command
  out = `#{command}`
  raise "#{command.inspect} failed with exit status #{$?.exitstatus}" unless $?.success?
  out
end

require 'erb'

template = ERB.new TEMPLATE, 0, "%<>"

puts template.result binding