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

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000

This will return a list of resource urls:

    {"_links":{"self":{"href":"http://localhost:3000/"},"conversations":{"href":"http://localhost:3000/conversations?auth_token=AUTH_TOKEN"}}}

Retrieve list of conversations by replacing the AUTH_TOKEN with the auth token generated when you sign in with a persona id.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

Initially this will return an empty list of conversations (because you haven't created any):

    {"conversations":[]}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation"}' http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"548ab90b-d141-4603-9e2c-7e1705423861","name":"first conversation","timestamp":1364776203,"_links":{"self":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/people?auth_token=AUTH_TOKEN"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"548ab90b-d141-4603-9e2c-7e1705423861","name":"first conversation","timestamp":1364776203,"_links":{"self":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/people?auth_token=AUTH_TOKEN"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"548ab90b-d141-4603-9e2c-7e1705423861","name":"first conversation","timestamp":1364776203,"_links":{"self":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/people?auth_token=AUTH_TOKEN"}}}

Now that you have a conversation, you can add messages and people.

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message"}' http://localhost:3000/conversations/548ab90b-d141-4603-9e2c-7e1705423861/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return the message resource.

    {"uuid":"b2f0e7c9-653e-4da5-90a6-853c5f595762","content":"first message","timestamp":1364776203,"person":{"uuid":"3408705e-4a19-4187-82e0-1551a38cbceb","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/6c20b750-56ee-4192-b158-56f3a5c356e9?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/b2f0e7c9-653e-4da5-90a6-853c5f595762?auth_token=AUTH_TOKEN"}}}

Getting conversation messages:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X GET 'http://localhost:3000/conversations/c639211d-7a20-419e-8ff0-129e77ef1f49/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

Destroying a message:

    curl -H 'Content-Type: application/json' -H "Accept: application/json" -X DELETE 'http://localhost:3000/messages/d2fe2f02-9518-4d14-8723-b1ec5c057d30?auth_token=96b97445-9694-4506-aa14-82ec76c50629'

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
