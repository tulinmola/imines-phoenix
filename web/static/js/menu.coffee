$ ->
  $("#toggle-nav").click (event) ->
    $("nav").toggleClass("hidden")
    event.preventDefault()
