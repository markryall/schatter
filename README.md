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

    {"_links":{"self":{"href":"http://localhost:3000/?session_id=0bb94498-4f2d-41df-b8ea-acea6dc817e6"},"conversations":{"href":"http://localhost:3000/conversations?session_id=0bb94498-4f2d-41df-b8ea-acea6dc817e6"}}}

To retrieve the list of your conversations, request the conversations resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?session_id=0bb94498-4f2d-41df-b8ea-acea6dc817e6?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

Initially this will return an empty list of conversations (because you haven't created any):

    {"error":"unauthorized"}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations?session_id=0bb94498-4f2d-41df-b8ea-acea6dc817e6

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"e7543727-8082-4873-845f-97092a7e041f","name":"first conversation","timestamp":1368256221,"_links":{"self":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f"},"messages":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages"},"people":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?session_id=0bb94498-4f2d-41df-b8ea-acea6dc817e6?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"error":"unauthorized"}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"uuid":"e7543727-8082-4873-845f-97092a7e041f","name":"first conversation","timestamp":1368256221,"_links":{"self":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f"},"messages":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages"},"people":{"href":"http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages

This will return the message resource.

    {"uuid":"f8b3d443-e20c-4b99-a480-518c5473db06","content":"first message","timestamp":1368256222,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/f8b3d443-e20c-4b99-a480-518c5473db06"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"messages":[{"uuid":"f8b3d443-e20c-4b99-a480-518c5473db06","content":"first message","timestamp":1368256222,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/f8b3d443-e20c-4b99-a480-518c5473db06"}}},{"uuid":"5c99e987-def9-42fc-82ee-4174f1f06745","content":"reply message","timestamp":1368256222,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/5c99e987-def9-42fc-82ee-4174f1f06745"}}}]}

You can also reply to a message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"reply message","parent_id":"e7543727-8082-4873-845f-97092a7e041f","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/messages

This will return the message resource.

    {"uuid":"5c99e987-def9-42fc-82ee-4174f1f06745","content":"reply message","timestamp":1368256222,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/5c99e987-def9-42fc-82ee-4174f1f06745"}}}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/5c99e987-def9-42fc-82ee-4174f1f06745?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"uuid":"5c99e987-def9-42fc-82ee-4174f1f06745","content":"reply message","timestamp":1368256222,"person_id":"52317df8-e970-49f4-9c6c-33a777b773e1","_links":{"self":{"href":"http://localhost:3000/messages/5c99e987-def9-42fc-82ee-4174f1f06745"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/people?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"people":[{"uuid":"52317df8-e970-49f4-9c6c-33a777b773e1","email":"mark.ryall@gmail.com","timestamp":1368256192,"_links":{"self":{"href":"http://localhost:3000/people/52317df8-e970-49f4-9c6c-33a777b773e1"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6"}' http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/people

    {"uuid":"921a2fd8-40f5-409c-8a05-82ddc227239d","email":"test2@email.com","timestamp":1368256222,"_links":{"self":{"href":"http://localhost:3000/people/921a2fd8-40f5-409c-8a05-82ddc227239d"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/e7543727-8082-4873-845f-97092a7e041f/people?auth_token=cb7f39ff-a9d9-4ac8-8962-1bb9dac0eef6

    {"people":[{"uuid":"52317df8-e970-49f4-9c6c-33a777b773e1","email":"mark.ryall@gmail.com","timestamp":1368256192,"_links":{"self":{"href":"http://localhost:3000/people/52317df8-e970-49f4-9c6c-33a777b773e1"}}},{"uuid":"921a2fd8-40f5-409c-8a05-82ddc227239d","email":"test2@email.com","timestamp":1368256222,"_links":{"self":{"href":"http://localhost:3000/people/921a2fd8-40f5-409c-8a05-82ddc227239d"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
