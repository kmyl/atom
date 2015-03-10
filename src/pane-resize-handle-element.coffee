class PaneResizeHandleElement extends HTMLElement
  createdCallback: ->
    @resizePane = @resizePane.bind(this)
    @resizeStopped = @resizeStopped.bind(this)
    @subscribeToDOMEvents()

  subscribeToDOMEvents: ->
    @addEventListener 'dblclick', @resizeToFitContent.bind(this)
    @addEventListener 'mousedown', @resizeStarted.bind(this)

  attachedCallback: ->
    @isHorizontal = @parentElement.classList.contains("horizontal")

  resizeToFitContent: ->
    # clear flex-grow css style of both pane
    @previousSibling.style.flexGrow = ''
    @nextSibling.style.flexGrow = ''

  resizeStarted: (e)->
    e.stopPropagation()
    document.addEventListener 'mousemove', @resizePane
    document.addEventListener 'mouseup', @resizeStopped

  resizeStopped: ->
    document.removeEventListener 'mousemove', @resizePane
    document.removeEventListener 'mouseup', @resizeStopped

  calcRatio: (ratio1, ratio2, total) ->
    allRatio = ratio1 + ratio2
    [total * ratio1 / allRatio, total * ratio2 / allRatio]

  getFlexGrow: (element) ->
    parseFloat window.getComputedStyle(element).flexGrow

  setFlexGrow: (prevSize, nextSize) ->
    flexGrow = @getFlexGrow(@previousSibling) + @getFlexGrow(@nextSibling)
    flexGrows = @calcRatio(prevSize, nextSize, flexGrow)
    @previousSibling.style.flexGrow = flexGrows[0]
    @nextSibling.style.flexGrow = flexGrows[1]

  fixInRange: (val, minValue, maxValue) ->
    Math.min(Math.max(val, minValue), maxValue)

  resizePane: ({clientX, clientY, which}) ->
    return @resizeStopped() unless which is 1

    if @isHorizontal
      totalWidth = @previousSibling.clientWidth + @nextSibling.clientWidth
      #get the left and right width after move the resize view
      leftWidth = clientX - @previousSibling.getBoundingClientRect().left
      leftWidth = @fixInRange(leftWidth, 0, totalWidth)
      rightWidth = totalWidth - leftWidth
      # set the flex grow by the ratio of left width and right width
      # to change pane width
      @setFlexGrow(leftWidth, rightWidth)
    else
      totalHeight = @previousSibling.clientHeight + @nextSibling.clientHeight
      topHeight = clientY - @previousSibling.getBoundingClientRect().top
      topHeight = @fixInRange(topHeight, 0, totalHeight)
      bottomHeight = totalHeight - topHeight
      @setFlexGrow(topHeight, bottomHeight)

module.exports = PaneResizeHandleElement =
document.registerElement 'atom-pane-resize-handle', prototype: PaneResizeHandleElement.prototype