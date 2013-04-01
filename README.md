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

All requests require a auth_token parameter for authentication.  This is generated for you when you login.

Instead you hit the root url and follow hypermedia links to determine what can be done next.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return a session and list of available resource urls:

    {"_links":{"self":{"href":"http://localhost:3000/"},"conversations":{"href":"http://localhost:3000/conversations"}}}

To retrieve the list of your conversations, request the conversations resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

Initially this will return an empty list of conversations (because you haven't created any):

    {"conversations":[]}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"7e3297a0-a241-4a10-b4d1-a464b44b0744","name":"first conversation","timestamp":1364786379,"_links":{"self":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744"},"messages":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages"},"people":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"7e3297a0-a241-4a10-b4d1-a464b44b0744","name":"first conversation","timestamp":1364786379,"_links":{"self":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744"},"messages":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages"},"people":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"7e3297a0-a241-4a10-b4d1-a464b44b0744","name":"first conversation","timestamp":1364786379,"_links":{"self":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744"},"messages":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages"},"people":{"href":"http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages

This will return the message resource.

    {"uuid":"f4b63ecc-9dec-4175-a046-1edbc15ad046","content":"first message","timestamp":1364786380,"person":{"uuid":"4e44c007-3c85-4b9c-9499-bd51ef342d4d","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/2b51edc8-b67d-4061-a5c8-026dfba74307"}}},"_links":{"self":{"href":"http://localhost:3000/messages/f4b63ecc-9dec-4175-a046-1edbc15ad046"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"f4b63ecc-9dec-4175-a046-1edbc15ad046","content":"first message","timestamp":1364786380,"person":{"uuid":"f1db4bb4-f457-40f8-a197-f73febd09540","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/29b2d675-ae54-4114-bea9-81222ba1dcf0"}}},"_links":{"self":{"href":"http://localhost:3000/messages/f4b63ecc-9dec-4175-a046-1edbc15ad046"}}}]}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/f4b63ecc-9dec-4175-a046-1edbc15ad046?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"f4b63ecc-9dec-4175-a046-1edbc15ad046","content":"first message","timestamp":1364786380,"person":{"uuid":"403e56ee-0e80-45c8-9cc8-a335a1a31219","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/48fa8a61-7e8f-4978-ad66-16f8ceec6eea"}}},"_links":{"self":{"href":"http://localhost:3000/messages/f4b63ecc-9dec-4175-a046-1edbc15ad046"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"34ede3a5-aa29-44ea-97fd-433c2bd6a19c","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/b62cbe81-e4cd-4f94-bdf5-aa12a771ce51"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people

    {"uuid":"e4289139-c8b2-4fc8-812e-5729a0776439","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/6bcf266e-634b-4820-8974-6d0d108da231"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/7e3297a0-a241-4a10-b4d1-a464b44b0744/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"4bba3a6d-2916-414d-8f79-2f72dafac46f","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/c03996ba-aa24-4850-8bfb-2f326a591327"}}},{"uuid":"2077adea-3625-4425-b7a0-6591aa60900a","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/b0b2ecf2-ce13-4875-969f-16ee6a5c0100"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
