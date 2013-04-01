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

    {"uuid":"3d7f6b19-751e-40b4-af96-76cf6785c955","name":"first conversation","timestamp":1364807342,"_links":{"self":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955"},"messages":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages"},"people":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"3d7f6b19-751e-40b4-af96-76cf6785c955","name":"first conversation","timestamp":1364807342,"_links":{"self":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955"},"messages":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages"},"people":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"3d7f6b19-751e-40b4-af96-76cf6785c955","name":"first conversation","timestamp":1364807342,"_links":{"self":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955"},"messages":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages"},"people":{"href":"http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages

This will return the message resource.

    {"uuid":"0ebe7a75-b81a-4e96-bb00-fbdd2183e2f1","content":"first message","timestamp":1364807342,"person_id":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","_links":{"self":{"href":"http://localhost:3000/messages/0ebe7a75-b81a-4e96-bb00-fbdd2183e2f1"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"0ebe7a75-b81a-4e96-bb00-fbdd2183e2f1","content":"first message","timestamp":1364807342,"person_id":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","_links":{"self":{"href":"http://localhost:3000/messages/0ebe7a75-b81a-4e96-bb00-fbdd2183e2f1"}}},{"uuid":"1fc089cb-9b45-45a2-9c04-1da680e8ce67","content":"reply message","timestamp":1364807343,"person_id":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","_links":{"self":{"href":"http://localhost:3000/messages/1fc089cb-9b45-45a2-9c04-1da680e8ce67"}}}]}

You can also reply to a message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"reply message","parent_id":"3d7f6b19-751e-40b4-af96-76cf6785c955","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/messages

This will return the message resource.

    {"uuid":"1fc089cb-9b45-45a2-9c04-1da680e8ce67","content":"reply message","timestamp":1364807343,"person_id":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","_links":{"self":{"href":"http://localhost:3000/messages/1fc089cb-9b45-45a2-9c04-1da680e8ce67"}}}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/1fc089cb-9b45-45a2-9c04-1da680e8ce67?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"1fc089cb-9b45-45a2-9c04-1da680e8ce67","content":"reply message","timestamp":1364807343,"person_id":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","_links":{"self":{"href":"http://localhost:3000/messages/1fc089cb-9b45-45a2-9c04-1da680e8ce67"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/704db3f8-8ebe-4dd7-b037-abb6a99d9fd3"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people

    {"uuid":"901b7da4-c36e-46d8-850b-06d3e95801b6","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/901b7da4-c36e-46d8-850b-06d3e95801b6"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/3d7f6b19-751e-40b4-af96-76cf6785c955/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"704db3f8-8ebe-4dd7-b037-abb6a99d9fd3","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/704db3f8-8ebe-4dd7-b037-abb6a99d9fd3"}}},{"uuid":"901b7da4-c36e-46d8-850b-06d3e95801b6","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/901b7da4-c36e-46d8-850b-06d3e95801b6"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
