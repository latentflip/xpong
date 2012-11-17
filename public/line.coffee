define ['./vector'], (Vector) ->
  Graphics = createjs.Graphics
  Shape = createjs.Shape

  class Line
    hitSpacing: 10
    nextHit: 0
    onCollision: ->
      @nextHit = @hitSpacing
    updateNextHit: ->
      @nextHit--

    constructor: (from, to, color = [0,0,0]) ->
      @from = from
      @to = to
      @color = color

    slope: ->
      (@to[1] - @from[1]) / (@to[0] - @from[0])
    
    intercept: ->
      @from[1] - @slope()*@from[0]

    length: ->
      Vector.length(
        Vector.subtract(@from, @to)
      )

    perpendicularJoining: (point) ->
      slope = @slope()

      #horizontal
      if slope == 0
        new Line(point, [point[0], @from[1]], @color)
      else if slope == 1/0
        new Line(point, [@from[0], point[1]], @color)
      else
        newSlope = -1/slope
        intercept = @intercept()
        newIntercept = point[1] - newSlope * point[0]
        
        xIntersect = (newIntercept - intercept) / (slope - newSlope)
        yIntersect = newSlope*xIntersect + newIntercept

        new Line(point, [xIntersect, yIntersect], @color)

    render: (stage) ->
      @graphic ||= new LineGraphic(@)
      @graphic.render(stage)
      @updateNextHit()

  class LineGraphic
    constructor: (object) ->
      @object = object
      @g = new Graphics()
      @g.beginStroke(Graphics.getRGB(@object.color...))
      @g.moveTo @object.from...
      @g.lineTo @object.to...

      @shape = new Shape(@g)
      @shape.x = 0
      @shape.y = 0
    
    render: (stage) ->
      stage.addChild(@shape)

  return Line
