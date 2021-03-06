module.exports =
class DOMElementPool
  constructor: ->
    @freeElementsByTagName = {}
    @freedElements = new Set

  clear: ->
    @freedElements.clear()
    for tagName, freeElements of @freeElementsByTagName
      freeElements.length = 0
    return

  build: (tagName, className, textContent = "") ->
    element = @freeElementsByTagName[tagName]?.pop()
    element ?= document.createElement(tagName)
    delete element.dataset[dataId] for dataId of element.dataset
    element.removeAttribute("class")
    element.removeAttribute("style")
    element.className = className if className?
    element.textContent = textContent

    @freedElements.delete(element)

    element

  freeElementAndDescendants: (element) ->
    @free(element)
    for index in [element.children.length - 1..0] by -1
      child = element.children[index]
      @freeElementAndDescendants(child)
    return

  free: (element) ->
    throw new Error("The element cannot be null or undefined.") unless element?
    throw new Error("The element has already been freed!") if @freedElements.has(element)

    tagName = element.tagName.toLowerCase()
    @freeElementsByTagName[tagName] ?= []
    @freeElementsByTagName[tagName].push(element)
    @freedElements.add(element)

    element.remove()
