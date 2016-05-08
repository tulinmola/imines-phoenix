class Navigator
  constructor: (@view) ->
    {@x, @y} = @view.lastSeen()
    @scale = 1

    [element] = @view.$el
    mc = new Hammer.Manager(element)

    mc.add(new Hammer.Pan(threshold: 4, pointers: 0))
    mc.add(new Hammer.Swipe()).recognizeWith(mc.get("pan"))
    mc.add(new Hammer.Rotate(threshold: 0)).recognizeWith(mc.get("pan"))
    mc.add(new Hammer.Pinch(threshold: 0)).recognizeWith([mc.get("pan"), mc.get("rotate")])

    mc.add(new Hammer.Tap(event: "doubletap", taps: 2))
    mc.add(new Hammer.Tap())
    mc.add(new Hammer.Press())

    mc.on("panstart panmove", @onPan)
    mc.on("rotatestart rotatemove", @onRotate)
    mc.on("pinchstart pinchmove", @onPinch)
    mc.on("swipe", @onSwipe)
    mc.on("tap", @onTap)
    mc.on("press", @onPress)
    mc.on("doubletap", @onDoubleTap)

  onPan: (event) =>
    if event.type == "panstart"
      @startX = @x
      @startY = @y
    else
      @x = @startX + event.deltaX / @scale
      @y = @startY + event.deltaY / @scale
      @view.update()

  onPinch: (event) =>
    if event.type == "pinchstart"
      @startScale = @scale
    else
      @scale = @startScale * event.scale
      @view.update()

  onRotate: (event) =>
    # console.log [event.type, event.rotation]

  onTap: (event) =>
    position = @getEventPosition(event)
    @view.tap(position)

  onPress: (event) =>
    position = @getEventPosition(event)
    @view.press(position)

  onDoubleTap: (event) =>
    position = @getEventPosition(event)
    @view.dtap(position)

  getEventPosition: (event) ->
    center = event.center
    offset = @view.offset
    sx = center.x - offset.left
    sy = center.y - offset.top
    x = -@x + (sx - @view.width * 0.5) / @scale
    y = -@y + (sy - @view.height * 0.5) / @scale
    {x, y}

module.exports = Navigator
