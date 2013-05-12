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

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

This will return a session and list of available resource urls:

    {"_links":{"self":{"href":"http://localhost:3000/?session_id=948b9473-827e-4b9e-9e1f-893fa5d58a00"},"conversations":{"href":"http://localhost:3000/conversations?session_id=948b9473-827e-4b9e-9e1f-893fa5d58a00"}}}

To retrieve the list of your conversations, request the conversations resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?session_id=948b9473-827e-4b9e-9e1f-893fa5d58a00?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

Initially this will return an empty list of conversations (because you haven't created any):

    {"error":"unauthorized"}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations?session_id=948b9473-827e-4b9e-9e1f-893fa5d58a00

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"2ed48b5d-e783-436b-ba74-c5d42ba52c21","name":"first conversation","timestamp":1368352619,"_links":{"self":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21"},"messages":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages"},"people":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?session_id=948b9473-827e-4b9e-9e1f-893fa5d58a00?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"error":"unauthorized"}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"uuid":"2ed48b5d-e783-436b-ba74-c5d42ba52c21","name":"first conversation","timestamp":1368352619,"_links":{"self":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21"},"messages":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages"},"people":{"href":"http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages

This will return the message resource.

    {"uuid":"42aa090a-8b03-4134-8860-d1f661c47267","content":"first message","timestamp":1368352619,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/42aa090a-8b03-4134-8860-d1f661c47267"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"messages":[{"uuid":"42aa090a-8b03-4134-8860-d1f661c47267","content":"first message","timestamp":1368352619,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/42aa090a-8b03-4134-8860-d1f661c47267"}}},{"uuid":"3ad62f05-ad53-44e0-bd58-3756353d9015","content":"reply message","timestamp":1368352619,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/3ad62f05-ad53-44e0-bd58-3756353d9015"}}}]}

You can also reply to a message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"reply message","parent_id":"2ed48b5d-e783-436b-ba74-c5d42ba52c21","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/messages

This will return the message resource.

    {"uuid":"3ad62f05-ad53-44e0-bd58-3756353d9015","content":"reply message","timestamp":1368352619,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/3ad62f05-ad53-44e0-bd58-3756353d9015"}}}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/3ad62f05-ad53-44e0-bd58-3756353d9015?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"uuid":"3ad62f05-ad53-44e0-bd58-3756353d9015","content":"reply message","timestamp":1368352619,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/3ad62f05-ad53-44e0-bd58-3756353d9015"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/people?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"people":[{"uuid":"52317df8-e970-49f4-9c6c-33a777b773e1","email":"mark.ryall@gmail.com","timestamp":1368256192,"_links":{"self":{"href":"http://localhost:3000/people/52317df8-e970-49f4-9c6c-33a777b773e1"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/people

    {"uuid":"921a2fd8-40f5-409c-8a05-82ddc227239d","email":"test2@email.com","timestamp":1368256222,"_links":{"self":{"href":"http://localhost:3000/people/921a2fd8-40f5-409c-8a05-82ddc227239d"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/2ed48b5d-e783-436b-ba74-c5d42ba52c21/people?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"people":[{"uuid":"52317df8-e970-49f4-9c6c-33a777b773e1","email":"mark.ryall@gmail.com","timestamp":1368256192,"_links":{"self":{"href":"http://localhost:3000/people/52317df8-e970-49f4-9c6c-33a777b773e1"}}},{"uuid":"921a2fd8-40f5-409c-8a05-82ddc227239d","email":"test2@email.com","timestamp":1368256222,"_links":{"self":{"href":"http://localhost:3000/people/921a2fd8-40f5-409c-8a05-82ddc227239d"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
