class LruCache
  class Item
    constructor: (@id, @value) ->
      @next = @previous = null

  constructor: (options = {}) ->
    # Items id index
    @items = {}
    # Lru ordered double linked list
    @first = @last = null
    # Element counter
    @count = 0
    # Item value factory, events and cache limits
    {@factory, @onRemove} = options
    @loWater = options.loWater || 40
    @hiWater = options.hiWater || 50

  add: (id, value) ->
    # Create item and add to index
    item = new Item(id, value)
    @items[id] = item
    # Then put new item in the list first position
    item.next = @first
    @first?.previous = item
    @first = item
    # If cache is empty this is the last element too
    @last = item unless @last
    # Incrementing counter
    @count++
    # Taking care of cache limits
    @clean() if @count > @hiWater

  clean: ->
    @remove(@last.id) while @count > @loWater

  clear: ->
    @remove(@first.id) while @first

  remove: (id, callListener = true) ->
    # Get item and remove from indices
    item = @items[id]
    delete @items[id]
    @onRemove?(item.value) if callListener
    # Remove from list
    item.previous?.next = item.next
    item.next?.previous = item.previous
    # Taking care of being first element
    @first = item.next if @first == item
    # or the last one
    @last = item.previous if @last == item
    # Decrementing counter
    @count--

  at: (index) ->
    item = @first
    while item && index > 0
      item = item.next
      index--
    item.value

  get: (id, doCreate = true) ->
    item = @items[id]
    if item
      # TODO: Maybe optimize this?
      {value} = item
      @remove(id, false)
      @add(id, value)
      value
    else if doCreate
      value = @factory.create(id)
      @add(id, value)
      value
    else
      null

  getIds: ->
    item = @first
    ids = []
    while item
      ids.push(item.id)
      item = item.next
    ids

module.exports = LruCache
