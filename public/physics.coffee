define ['./vector'], (Vector) ->
  config = 
    width: 500
    height: 500

  Physics = 
    collideBallWithLine: (ball, line) ->

      collisionLine = line.perpendicularJoining(ball.position)
      
      normal = Vector.scale(-1, Vector.normalize(Vector.subtract(collisionLine.to, collisionLine.from)))
      
      if ball.radius >= collisionLine.length()
        line.onCollision()
        ball.velocity = Vector.reflect(ball.velocity, normal)
  

    collideBallWithPlayer: (ball, player) ->
      return if player.nextHit > 0
      overlapVector = Vector.subtract(player.position, ball.position)
      radiusSum = ball.radius + player.radius

      overlapDistance = Vector.length(overlapVector) - radiusSum

      if overlapDistance <= 0
        normal = Vector.normalize(overlapVector)
        player.onCollision()

        ball.velocity = Vector.reflect(ball.velocity, normal)
        ball.velocity = Vector.subtract(ball.velocity, player.velocity)

        ball.position = Vector.add(
          ball.position,
          Vector.scale(overlapDistance, normal)
        )
        

    collideBallWithEdges: (ball) ->
      x = ball.position[0]
      y = ball.position[1]
      r = ball.radius

      if x <= r
        ball.velocity = Vector.reflect(ball.velocity, [1,0])
      else if x >= config.width - ball.radius
        ball.velocity = Vector.reflect(ball.velocity, [-1,0])
      else if y <= r
        ball.velocity = Vector.reflect(ball.velocity, [0,1])
      else if y >= config.height - ball.radius
        ball.velocity = Vector.reflect(ball.velocity, [0,-1])
