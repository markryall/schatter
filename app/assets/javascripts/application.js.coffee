//= require jquery
//= require jquery_ujs
//= require_tree .

$('#authenticate').click ->
  navigator.id.get (assertion) ->
    if assertion
      $.post '/persona/verify', { assertion: assertion }, (data) ->
        window.location = '/'