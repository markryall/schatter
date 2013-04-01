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

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return a list of resource urls:

    {"_links":{"self":{"href":"http://localhost:3000/"},"conversations":{"href":"http://localhost:3000/conversations"}}}

Retrieve list of conversations by replacing the AUTH_TOKEN with the auth token generated when you sign in with a persona id.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

Initially this will return an empty list of conversations (because you haven't created any):

    {"conversations":[]}

You can create a new conversation with a POST to the conversation resource url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"name":"first conversation","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations

This will return the conversation resource including urls for messages and people (conversation participants):

    {"uuid":"24ae2534-e9d1-4ddc-a741-2d93322e7d6f","name":"first conversation","timestamp":1364786176,"_links":{"self":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f"},"messages":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages"},"people":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"24ae2534-e9d1-4ddc-a741-2d93322e7d6f","name":"first conversation","timestamp":1364786176,"_links":{"self":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f"},"messages":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages"},"people":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"24ae2534-e9d1-4ddc-a741-2d93322e7d6f","name":"first conversation","timestamp":1364786176,"_links":{"self":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f"},"messages":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages"},"people":{"href":"http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages

This will return the message resource.

    {"uuid":"1eb93b90-21a2-424f-9d32-f32866e0f127","content":"first message","timestamp":1364786176,"person":{"uuid":"7175ea9c-c5e8-49a3-80e6-05b37b0680a7","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/06f66f33-8cde-4000-9730-10f28cbe2012"}}},"_links":{"self":{"href":"http://localhost:3000/messages/1eb93b90-21a2-424f-9d32-f32866e0f127"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"1eb93b90-21a2-424f-9d32-f32866e0f127","content":"first message","timestamp":1364786176,"person":{"uuid":"0a548c67-7dee-474c-beb7-eedc07974abc","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/17ae9c9e-ff9b-4c0e-abb7-a1bfa157cd27"}}},"_links":{"self":{"href":"http://localhost:3000/messages/1eb93b90-21a2-424f-9d32-f32866e0f127"}}}]}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/1eb93b90-21a2-424f-9d32-f32866e0f127?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"1eb93b90-21a2-424f-9d32-f32866e0f127","content":"first message","timestamp":1364786176,"person":{"uuid":"6bcd7ab0-89b6-439c-aee1-f35f97dc35cb","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/3b0bff55-c614-4b4d-8e73-0e0f1b760b25"}}},"_links":{"self":{"href":"http://localhost:3000/messages/1eb93b90-21a2-424f-9d32-f32866e0f127"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"dcf2173b-0da5-4b8c-9654-5f6fe7712fea","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/330817f1-93bf-4ac9-9306-d5bdfdfa2021"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com","auth_token":"96b97445-9694-4506-aa14-82ec76c50629"}' http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people

    {"uuid":"909bb742-bb12-4e34-8d94-783b91f59054","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/b867baf4-359b-4f95-a6f6-d7a77e9aac90"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/24ae2534-e9d1-4ddc-a741-2d93322e7d6f/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"565edfee-a87a-4b5e-be01-d883db3e32fb","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/7c998790-9784-44d7-a873-00ceeb378ba5"}}},{"uuid":"0949daf7-ca5a-4e8d-b6d6-289a0097d0cd","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/e3f2fb4c-e9b6-4846-a3f1-007d83541979"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
