class Meeting
  constructor: ({@timeLeft}) ->
  toData: -> {@timeLeft}
  finished: false

  update: (delta, players = []) ->
    return false if @finished
    @timeLeft -= delta

    if @timeLeft <= 0
      @finished = true
      for player in players
        player.meeting()
      true
    false

exports.Meeting = Meeting


