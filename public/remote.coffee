define ['./socket', 'jquery'], (socket, $) ->
  return {
    start: ->
      socket.emit('player:register', '')

      height = $('body').height()
      width = $('body').height()

      lastTouch = null
      getTouchPosition = (e) ->
        touch = e.originalEvent.touches[0]
        if !lastTouch
          lastTouch = touch
          return false
        else
          move = [
            (touch.clientX - lastTouch.clientX) / width,
            (touch.clientY - lastTouch.clientY) / height
          ]
          lastTouch = touch
          return move

      onTouchMove = (e) ->
        move = getTouchPosition(e)
        socket.emit('move', move) if move

      onTouchEnd = ->
        lastTouch = null

      $('body div').on('touchmove', onTouchMove)
      $('body div').on('touchend', onTouchEnd)
  }
