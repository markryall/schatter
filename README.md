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

    {"uuid":"7581e0e5-9099-4705-a626-2495c26dcd6e","name":"first conversation","timestamp":1364776796,"_links":{"self":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/people?auth_token=AUTH_TOKEN"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"7581e0e5-9099-4705-a626-2495c26dcd6e","name":"first conversation","timestamp":1364776796,"_links":{"self":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/people?auth_token=AUTH_TOKEN"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"7581e0e5-9099-4705-a626-2495c26dcd6e","name":"first conversation","timestamp":1364776796,"_links":{"self":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/people?auth_token=AUTH_TOKEN"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message"}' http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return the message resource.

    {"uuid":"00715a7e-4cf6-4110-b936-6c4d299177a1","content":"first message","timestamp":1364776796,"person":{"uuid":"e9fdee73-d7f9-434f-bdd4-4842b0c7d971","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/4f40c1a8-8478-47a8-8019-b564477e4a31?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/00715a7e-4cf6-4110-b936-6c4d299177a1?auth_token=AUTH_TOKEN"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7581e0e5-9099-4705-a626-2495c26dcd6e/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"00715a7e-4cf6-4110-b936-6c4d299177a1","content":"first message","timestamp":1364776796,"person":{"uuid":"8853eb83-28cf-4042-841e-c98bd118caa0","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/ed2b1d40-6b0e-47b1-a206-64689b1db147?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/00715a7e-4cf6-4110-b936-6c4d299177a1?auth_token=AUTH_TOKEN"}}}]}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/00715a7e-4cf6-4110-b936-6c4d299177a1?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"00715a7e-4cf6-4110-b936-6c4d299177a1","content":"first message","timestamp":1364776796,"person":{"uuid":"5559eab0-8d15-4a20-a6ed-18ac5de963d5","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/7e9e870c-3bfe-406f-989e-14d5d62af74b?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/00715a7e-4cf6-4110-b936-6c4d299177a1?auth_token=AUTH_TOKEN"}}}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
