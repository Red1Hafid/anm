jQuery ->
   grounds = $('#user_ground_id').html()
   $("#user_stop_action_id").change ->
    stop_action = $('#user_stop_action_id :selected').text()
    options = $(grounds).filter("optgroup[label='#{stop_action}']").html()
    if options 
        $('#user_ground_id').html(options)
        $('#user_ground_id').parent().show()
    else
        $('#user_ground_id').empty()
        $('#user_ground_id').parent().hide()
    
    