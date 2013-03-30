#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Schatter::Application.load_tasks

task clear: :environment do
  Conversation.delete_all
  Message.delete_all
end

task readme: :clear do
  `ruby doc/generate_readme.rb > README.md`
end