define ['underscore', 'jquery', './socket', './line', './vector', './physics'], (_, $, socket, Line, Vector, Physics) ->

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

  window.stage = stage

  class Ball
    friction: 0
    radius: 5
    constructor: ->
      @position = [config.width/2, config.height/2]
      @graphic = new BallGraphic(@)
      @velocity = [0.1,0.1] #pixels per second

    updatePosition: (delta) ->
      if delta
        @position[0] += @velocity[0]*delta
        @position[1] += @velocity[1]*delta

    updateVelocity: (delta) ->
      @velocity = Vector.scale(1-@friction, @velocity)
      
    render: (delta) ->
      @updateVelocity(delta)
      @updatePosition(delta)
      @graphic.render(delta)


  class Player
    radius: 10
    constructor: (id) ->
      @position = [250,250]
      @velocity = [0,0]
      @graphic = new PlayerGraphic(@)
      @playerId = id

      socket.on "player:#{@playerId}:move", (pos) =>
        @updatePosition(pos)
  
    hitSpacing: 10
    nextHit: 0
    updatePosition: (p) ->
      @position = Vector.add(
        @position, 
        [
          config.width*p[0],
          config.height*p[1]
        ]
      )
    
    updateVelocity: (delta) ->
      if !@lastPosition
        @lastPosition = @position
        @velocity = [0,0]
      else
        pdelta = Vector.subtract(@position, @lastPosition)
        @velocity = Vector.scale(1/delta, pdelta)
        @lastPosition = @position

    onCollision: ->
      @nextHit = @hitSpacing

    updateNextHit: ->
      @nextHit--

    render: (delta) ->
      @updateVelocity(delta)
      @graphic.render()
      @updateNextHit()

  class PlayerGraphic
    color: [255,0,0]
    constructor: (player) ->
      @player = player
      @g = new Graphics()
      @g.beginStroke(Graphics.getRGB(@color...))
      @g.drawCircle((-1*@player.radius/2),(-1*@player.radius/2),@player.radius)

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
      @addLines()

    addPlayer: (id) ->
      @players.push new Player(id)

    addBall: ->
      @ball = new Ball()

    addLines: ->
      points = [
        [0,200]
        [400,100]
        [500,200]
        [400,400]
        [100,400]
        [0,200]
      ]
      colors = [
        [0,250,0],
        [250,0,0],
        [250,250,0],
        [0,0,250],
        [0,250,250],
        [0,0,0]
      ]
      @lines ||= []
      
      for i in [0...points.length-1]
        do (i) =>
          @lines.push(new Line(points[i], points[i+1], colors[i]))
      
    tick: (delta) =>
      if !delta
        line.render(stage) for line in @lines

      delta ||= 0
      @ball.render(delta)
      Physics.collideBallWithPlayer(@ball, p) for p in @players
      Physics.collideBallWithEdges(@ball)
      Physics.collideBallWithLine(@ball, l) for l in @lines

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
      console.log 'Start game'
      game = new Game()
      game.start()

  {
    start: start
  }
