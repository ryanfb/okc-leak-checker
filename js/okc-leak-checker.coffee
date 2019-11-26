---
---

HASH_SALT = '1vMTI1_2gipUt1VMZWHvrGNARRLWjDmDshAOFTAoE'
OKC_HASHED_USERNAMES = []

update_results = (username, username_included) ->
  if username_included
    $('#results').append($('<div/>',{class: 'alert alert-danger', role: 'alert'}).text("The username \"#{username}\" was included in the data dump."))
  else
    $('#results').append($('<div/>',{class: 'alert alert-success', role: 'alert'}).text("The username \"#{username}\" was not included in the data dump."))

process_username = (username) ->
  $('#results').empty()
  hashed_username = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash("#{username}-#{HASH_SALT}".toLowerCase()))
  if OKC_HASHED_USERNAMES.length
    update_results(username, (hashed_username in OKC_HASHED_USERNAMES))
  else
    $.ajax 'okc.csv',
      type: 'GET'
      dataType: 'text'
      error: (jqXHR, textStatus, error_callback) ->
        console.log jqXHR
        console.log errorThrown
        console.log "AJAX Error: #{textStatus}"
        $('#results').append($('<div/>',{class: 'alert alert-danger', role: 'alert'}).text("Error loading username data."))
      success: (data) ->
        OKC_HASHED_USERNAMES = data.split("\n")
        update_results(username, (hashed_username in OKC_HASHED_USERNAMES))

find_matches = ->
  process_username($('#identifier_input').val())
  return false

$(document).ready ->
  console.log('ready')
  $('#loadingDiv').hide()
  $(document).ajaxStart -> $('#loadingDiv').show()
  $(document).ajaxStop -> $('#loadingDiv').hide()
  $('#identifier_form').submit(find_matches)
