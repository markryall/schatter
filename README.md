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

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

This will return a session and list of available resource urls:

    {"_links":{"self":{"href":"http://localhost:3000/?session_id=96ea00cd-937b-45ff-8cfb-dee260b1b359"},"conversations":{"href":"http://localhost:3000/conversations?session_id=96ea00cd-937b-45ff-8cfb-dee260b1b359"}}}

To retrieve the list of your conversations, request the conversations resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

Initially this will return an empty list of conversations (because you haven't created any):

    {"conversations":[]}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation","auth_token":"b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5"}' http://localhost:3000/conversations

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c","name":"first conversation","timestamp":1402020218,"_links":{"self":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c"},"messages":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages"},"people":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"conversations":[{"uuid":"fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c","name":"first conversation","timestamp":1402020218,"_links":{"self":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c"},"messages":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages"},"people":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"uuid":"fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c","name":"first conversation","timestamp":1402020218,"_links":{"self":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c"},"messages":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages"},"people":{"href":"http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5"}' http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages

This will return the message resource.

    {"uuid":"f3176956-dcef-49b5-a626-a50db30cd17e","content":"first message","timestamp":1402020218,"person_id":"073c84c8-26e0-4a07-9927-605feff33468","_links":{"self":{"href":"http://localhost:3000/messages/f3176956-dcef-49b5-a626-a50db30cd17e"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"messages":[{"uuid":"f3176956-dcef-49b5-a626-a50db30cd17e","content":"first message","timestamp":1402020218,"person_id":"073c84c8-26e0-4a07-9927-605feff33468","_links":{"self":{"href":"http://localhost:3000/messages/f3176956-dcef-49b5-a626-a50db30cd17e"}}},{"uuid":"115b0649-1264-4acc-b082-c7faa5c22e91","content":"reply message","timestamp":1402020218,"person_id":"073c84c8-26e0-4a07-9927-605feff33468","_links":{"self":{"href":"http://localhost:3000/messages/115b0649-1264-4acc-b082-c7faa5c22e91"}}}]}

You can also reply to a message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"reply message","parent_id":"fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c","auth_token":"b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5"}' http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/messages

This will return the message resource.

    {"uuid":"115b0649-1264-4acc-b082-c7faa5c22e91","content":"reply message","timestamp":1402020218,"person_id":"073c84c8-26e0-4a07-9927-605feff33468","_links":{"self":{"href":"http://localhost:3000/messages/115b0649-1264-4acc-b082-c7faa5c22e91"}}}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/115b0649-1264-4acc-b082-c7faa5c22e91?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"uuid":"115b0649-1264-4acc-b082-c7faa5c22e91","content":"reply message","timestamp":1402020218,"person_id":"073c84c8-26e0-4a07-9927-605feff33468","_links":{"self":{"href":"http://localhost:3000/messages/115b0649-1264-4acc-b082-c7faa5c22e91"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"people":[{"uuid":"073c84c8-26e0-4a07-9927-605feff33468","email":"mark.ryall@gmail.com","timestamp":1402019035,"_links":{"self":{"href":"http://localhost:3000/people/073c84c8-26e0-4a07-9927-605feff33468"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5"}' http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people

    {"uuid":"084bba89-c574-4a11-8df7-3f124489caac","email":"test2@email.com","timestamp":1402019059,"_links":{"self":{"href":"http://localhost:3000/people/084bba89-c574-4a11-8df7-3f124489caac"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fdb451a4-a3f8-4de5-9a43-03c9c7d1eb2c/people?auth_token=b0c8c25a-f51a-4a6a-9c0b-4119f08d60d5

    {"people":[{"uuid":"073c84c8-26e0-4a07-9927-605feff33468","email":"mark.ryall@gmail.com","timestamp":1402019035,"_links":{"self":{"href":"http://localhost:3000/people/073c84c8-26e0-4a07-9927-605feff33468"}}},{"uuid":"084bba89-c574-4a11-8df7-3f124489caac","email":"test2@email.com","timestamp":1402019059,"_links":{"self":{"href":"http://localhost:3000/people/084bba89-c574-4a11-8df7-3f124489caac"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
