---
---

FUSION_TABLES_URI = 'https://www.googleapis.com/fusiontables/v2'

GOOGLE_API_KEY = 'AIzaSyBoQNYbbHb-MEGa4_oq83_JCLt9cKfd4vg'
# Fusion Tables ID of the username index
OKC_TABLE_ID = '1vMTI1_2gipUt1VMZWHvrGNARRLWjDmDshAOFTAoE'

html_id = (input) ->
  input.replace(/[\/:$.,'-]/g,'_')

# wrap values in single quotes and backslash-escape single-quotes
fusion_tables_escape = (value) ->
  "'#{value.replace(/'/g,"\\\'")}'"

fusion_tables_query = (query, callback, error_callback) ->
  console.log "Query: #{query}"
  switch query.split(' ')[0]
    when 'SELECT'
      $.ajax "#{FUSION_TABLES_URI}/query?sql=#{query}&key=#{GOOGLE_API_KEY}",
        type: 'GET'
        dataType: 'json'
        crossDomain: true
        error: (jqXHR, textStatus, errorThrown) ->
          # $('#results').append($('<div/>',{class: 'alert alert-danger', role: 'alert'}).text("Error in Fusion Tables AJAX call."))
          console.log jqXHR
          console.log errorThrown
          console.log "AJAX Error: #{textStatus}"
          error_callback() if error_callback?
          console.log "Retrying Fusion Tables query: #{query}"
          fusion_tables_query(query, callback, error_callback)
        success: (data) ->
          console.log data
          if callback?
            callback(data)

process_username = (username) ->
  $('#results').empty()
  hashed_username = sjcl.codec.hex.fromBits(sjcl.hash.sha256.hash("#{username}-#{OKC_TABLE_ID}"))
  fusion_tables_query "SELECT username FROM #{OKC_TABLE_ID} WHERE username = #{fusion_tables_escape(hashed_username)}",
    (data) ->
      if data.rows?
        $('#results').append($('<div/>',{class: 'alert alert-danger', role: 'alert'}).text("The username \"#{username}\" was included in the data dump."))
      else
        $('#results').append($('<div/>',{class: 'alert alert-success', role: 'alert'}).text("The username \"#{username}\" was not included in the data dump."))

find_matches = ->
  process_username($('#identifier_input').val())
  return false

$(document).ready ->
  console.log('ready')
  $('#loadingDiv').hide()
  $(document).ajaxStart -> $('#loadingDiv').show()
  $(document).ajaxStop -> $('#loadingDiv').hide()
  $('#identifier_form').submit(find_matches)
