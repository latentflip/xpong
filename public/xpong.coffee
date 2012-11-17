define ['underscore', 'jquery', './socket'], (_, $, socket) ->

  Stage = createjs.Stage
  Graphics = createjs.Graphics
  Shape = createjs.Shape
  Ticker = createjs.Ticker

  config =
    width: $('canvas').width()
    height: $('canvas').height()

  canvas = $('#playingfield')
  canvas.width(config.width)
  canvas.height(config.height)
  stage = new createjs.Stage(canvas[0])
  player = null

  Vector =
    dotProduct: (v1, v2) ->
      v1[0]*v2[0] + v1[1]*v2[1]

    scale: (s, v) ->
      [
        v[0]*s,
        v[1]*s
      ]

    length: (v) ->
      Math.pow(
        v[0]*v[0] + v[1]*v[1]
      , 0.5)

    add: (v1, v2) ->
      [
        v1[0]+v2[0]
        v1[1]+v2[1]
      ]

    subtract: (v1,v2) ->
      [
        v1[0]-v2[0]
        v1[1]-v2[1]
      ]

    normalize: (v) ->
      l = @length(v)
      [
        v[0]/l,
        v[1]/l
      ]

    reflect: (v, n) ->
      @subtract(
        v,
        @scale(2*@dotProduct(v,n), n)
      )
 
  Physics = 
    circleCollisionNormal: (c1, c2) ->
      Vector.normalize(Vector.subtract(c2.position, c1.position))
      
    separation: (p1, p2) ->
      Math.pow(
        (Math.pow(p1[0]-p2[0],2) + Math.pow(p1[1]-p2[1],2))
      ,0.5)

    testCircleCircleCollision: (c1, c2) ->
      separation = @separation(c1.position, c2.position)
      radiusSum = c1.radius + c2.radius
      separation <= radiusSum

    collideBallWithPlayer: (ball, player) ->
      overlapVector = Vector.subtract(player.position, ball.position)
      radiusSum = ball.radius + player.radius

      overlapDistance = Vector.length(overlapVector) - radiusSum

      if overlapDistance <= 0
        normal = Vector.normalize(overlapVector)
        ball.velocity = Vector.reflect(ball.velocity, normal)

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


  class Ball
    radius: 5
    constructor: ->
      @position = [config.width/2, config.height/2]
      @graphic = new BallGraphic(@)
      @velocity = [0.05,0.05] #pixels per second

    updatePosition: (delta) ->
      @position[0] += @velocity[0]*delta
      @position[1] += @velocity[1]*delta

    render: (delta) ->
      @updatePosition(delta)
      @graphic.render(delta)


  class Player
    radius: 10
    constructor: (id) ->
      @position = [250,250]
      @graphic = new PlayerGraphic(@)
      @playerId = id

      socket.on "player:#{@playerId}:move", (pos) =>
        @updatePosition(pos)
  
    updatePosition: (p) ->
      @position = Vector.add(
        @position, 
        [
          config.width*p[0],
          config.height*p[1]
        ]
      )

    render: ->
      @graphic.render()

  class PlayerGraphic
    color: [255,0,0]
    constructor: (player) ->
      @player = player
      @g = new Graphics()
      @g.beginStroke(Graphics.getRGB(0,0,0))
      @g.drawCircle(0,0,@player.radius)

      @circle = new Shape(@g)
      @circle.x = @getX()
      @circle.y = @getY()
      
      stage.addChild(@circle)

    getX: -> @player.position[0]
    getY: -> @player.position[1]
    
    render: ->
      @circle.x = @getX()
      @circle.y = @getY()
      stage.addChild(@circle)

  class BallGraphic extends PlayerGraphic
    color: [255,0,0]


  class Game
    constructor: ->
      @players = []
      @addBall()

    addPlayer: (id) ->
      @players.push new Player(id)

    addBall: ->
      @ball = new Ball()

    tick: (delta) =>
      delta ||= 0
      @ball.render(delta)
      Physics.collideBallWithPlayer(@ball, p) for p in @players
      Physics.collideBallWithEdges(@ball)

      p.render(delta) for p in @players
      @ball.render()
      stage.update()

    start: =>
      @tick()
      Ticker.setFPS(30)
      Ticker.addListener(@tick)

      socket.on 'player:new', (id) =>
        console.log 'added player ', id
        @addPlayer(id)
    
  start = ->
    socket.emit('gamespace:register', '')
    socket.on 'gamespace:register:ack', ->
      game = new Game()
      game.start()

  {
    start: start
  }
