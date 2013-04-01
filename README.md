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

    {"uuid":"fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39","name":"first conversation","timestamp":1364777365,"_links":{"self":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=AUTH_TOKEN"}}}

This new conversation will now be included in the response to the conversation request.

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"conversations":[{"uuid":"fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39","name":"first conversation","timestamp":1364777365,"_links":{"self":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=AUTH_TOKEN"}}}]}

You can retrieve the conversation using the resource url:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39","name":"first conversation","timestamp":1364777365,"_links":{"self":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39?auth_token=AUTH_TOKEN"},"messages":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=AUTH_TOKEN"},"people":{"href":"http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=AUTH_TOKEN"}}}

Now that you have a conversation, you can retrieve messages and add messages and people.

Retrieve the list of messages (which will initially be empty)

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[]}

To create a new message in a conversation:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"content":"first message"}' http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

This will return the message resource.

    {"uuid":"fc53428f-186f-4254-9a19-adde71e7d0fa","content":"first message","timestamp":1364777365,"person":{"uuid":"0b19b1fe-9a6f-471b-9857-4a114682ffbb","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/23004933-fe28-4680-9f40-a0a894909231?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/fc53428f-186f-4254-9a19-adde71e7d0fa?auth_token=AUTH_TOKEN"}}}

Now retrieving conversation messages will include the new message:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/messages?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"messages":[{"uuid":"fc53428f-186f-4254-9a19-adde71e7d0fa","content":"first message","timestamp":1364777365,"person":{"uuid":"73e1124f-c827-4065-b3aa-a90782bd5a7a","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/3f98f761-0860-4663-b227-b1027c073710?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/fc53428f-186f-4254-9a19-adde71e7d0fa?auth_token=AUTH_TOKEN"}}}]}

Messages can be deleted (only by the initial creator of the message)

    curl -s -H 'Accept: application/json' -X DELETE http://localhost:3000/messages/fc53428f-186f-4254-9a19-adde71e7d0fa?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"fc53428f-186f-4254-9a19-adde71e7d0fa","content":"first message","timestamp":1364777365,"person":{"uuid":"67315bc5-8ec6-469f-852e-55a70edcae7e","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/86a89e2b-9be3-433d-bd14-9ba87412f6b0?auth_token=AUTH_TOKEN"}}},"_links":{"self":{"href":"http://localhost:3000/messages/fc53428f-186f-4254-9a19-adde71e7d0fa?auth_token=AUTH_TOKEN"}}}

Initially the members of a conversation will only include the person who created it:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"f63a10a6-bb82-46a2-b9c9-a0b9b7a40dc0","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/7b40880e-5ced-4981-9de0-70b891f9ff17?auth_token=AUTH_TOKEN"}}}]}

New members can be created by posting to the conversation people url:

    curl -s -H 'Accept: application/json' -H 'Content-Type: application/json' -X POST -d '{"email":"test2@email.com"}' http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"uuid":"df0813aa-c0a9-49a9-9991-113608aa9523","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/58ce4415-670e-4f30-85e3-5bde3109a7b3?auth_token=AUTH_TOKEN"}}}

This new person will now be included in the conversation list:

    curl -s -H 'Accept: application/json' -X GET http://localhost:3000/conversations/fcf6ad58-ad38-4f40-af3a-4ecdc25b3a39/people?auth_token=96b97445-9694-4506-aa14-82ec76c50629

    {"people":[{"uuid":"cf8602e6-530b-4193-90ed-e9c9c2a59921","email":"test@email.com","timestamp":1364526089,"_links":{"self":{"href":"http://localhost:3000/people/c0ed1d9d-9038-4d45-a3ad-8706d9b0d1d9?auth_token=AUTH_TOKEN"}}},{"uuid":"f26096e1-a409-4880-943d-0af3f8f8ac20","email":"test2@email.com","timestamp":1364777237,"_links":{"self":{"href":"http://localhost:3000/people/769bf3a7-8af2-416d-a998-3e209ee9957e?auth_token=AUTH_TOKEN"}}}]}

## Future plans

* actually being able to communicate via the web interface
* switching between sequential and threaded conversation views
