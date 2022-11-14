jQuery ->
  $(".calendar-day").on "click", ->
    date = $(this).data("date")
    location.href = "/absences#new_absence?absence[start_time]=#{date}"