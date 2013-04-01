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

    {"uuid":"e8dbbf64-fc37-44ed-9e7e-419ca72b055e","name":"first conversation","timestamp":1364790366,"_links":{"self":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e"},"messages":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages"},"people":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"e8dbbf64-fc37-44ed-9e7e-419ca72b055e","name":"first conversation","timestamp":1364790366,"_links":{"self":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e"},"messages":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages"},"people":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"e8dbbf64-fc37-44ed-9e7e-419ca72b055e","name":"first conversation","timestamp":1364790366,"_links":{"self":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e"},"messages":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages"},"people":{"href":"http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages

This will return the message resource.

    {"uuid":"f6c027c9-dc18-48f2-81d3-9f068eefb777","content":"first message","timestamp":1364790366,"person_id":"033705d5-dddd-4038-9d54-3f246ce38950","_links":{"self":{"href":"http://localhost:3000/messages/f6c027c9-dc18-48f2-81d3-9f068eefb777"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"f6c027c9-dc18-48f2-81d3-9f068eefb777","content":"first message","timestamp":1364790366,"person_id":"6f5fae28-b0ac-4a0c-8ccc-5f50ab6058a7","_links":{"self":{"href":"http://localhost:3000/messages/f6c027c9-dc18-48f2-81d3-9f068eefb777"}}}]}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/f6c027c9-dc18-48f2-81d3-9f068eefb777?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"f6c027c9-dc18-48f2-81d3-9f068eefb777","content":"first message","timestamp":1364790366,"person_id":"d87241ae-59b6-4fb9-8b8c-5c7cb337dd45","_links":{"self":{"href":"http://localhost:3000/messages/f6c027c9-dc18-48f2-81d3-9f068eefb777"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"d64da006-2177-4397-bfea-986d274c4bae","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/178202a7-a1c4-4b69-a6c8-8b28051fd524"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people

    {"uuid":"fe39c2ad-c1ac-4ce9-808a-65ca16bf1d1a","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/7ab540fd-bdef-4004-aae6-27e4649da0b3"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e8dbbf64-fc37-44ed-9e7e-419ca72b055e/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"68fb0e6d-a326-470e-bf93-2235f4e9bc78","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/b2e053c9-80be-4951-8a54-57459c60eb41"}}},{"uuid":"5d98688e-ee64-45c6-9c5b-1b60ee7d7ced","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/491dd401-760b-4648-bdaa-67cc77283f91"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
