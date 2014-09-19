###
Authors: Nick Giancola (@patbenatar), Brendan Loudermilk (@bloudermilk)
Homepage: https://github.com/patbenatar/jquery-nested_attributes
###
$ = jQuery

methods =
  init: (options) ->
    $el = $(@)
    throw "Can't initialize more than one item at a time" if $el.length > 1
    if $el.data("nestedAttributes")
      throw "Can't initialize on this element more than once"
    instance = new NestedAttributes($el, options)
    $el.data("nestedAttributes", instance)
    return $el
  add: ->
    $el = $(@)
    unless $el.data("nestedAttributes")?
      throw "You are trying to call instance methods without initializing first"
    $el.data("nestedAttributes").addItem()
    return $el

$.fn.nestedAttributes = (method) ->
  if methods[method]?
    return methods[method].apply @, Array.prototype.slice.call(arguments, 1)
  else if typeof method == 'object' || !method
    return methods.init.apply(@, arguments)
  else
    $.error("Method #{method} does not exist on jQuery.nestedAttributes")

class NestedAttributes

  RELEVANT_INPUTS_SELECTOR: ":input[name][name!=\"\"]"

  settings:
    collectionName: false       # If not provided, we will autodetect
    bindAddTo: false            # Required
    removeOnLoadIf: false
    collectIdAttributes: true
    beforeAdd: false
    afterAdd: false
    beforeMove: false
    afterMove: false
    beforeDestroy: false
    afterDestroy: false
    destroySelector: '.destroy'
    deepClone: true
    $clone: null

  ######################
  ##                  ##
  ##  Initialization  ##
  ##                  ##
  ######################

  constructor: ($el, options) ->

    # This plugin gets called on the container
    @$container = $el

    # Merge default options
    @options = $.extend({}, @settings, options)

    # If the user provided a jQuery object to bind the "Add"
    # bind it now or forever hold your peace.
    @options.bindAddTo.click(@addClick) if @options.bindAddTo

    # Cache all the items
    @$items = @$container.children()

    # If the user didn't provide a collectionName, autodetect it
    unless @options.collectionName
      @autodetectCollectionName()

    # Initialize existing items
    @$items.each (i, el) =>
      $item = $(el)

      # If the user wants us to attempt to collect Rail's ID attributes, do it now
      # Using the default rails helpers, ID attributes will wind up right after their
      # propper containers in the form.
      if @options.collectIdAttributes and $item.is('input')
        # Move the _id field into its proper container
        $item.appendTo($item.prev())
        # Remove it from the $items collection
        @$items = @$items.not($item)
      else
        # Try to find and bind the destroy link if the user wanted one
        @bindDestroy($item)

    # Now that we've collected ID attributes
    @hideIfAlreadyDestroyed $(item) for item in @$items

    # Remove any items on load if the client implements a check and the check passes
    if @options.removeOnLoadIf
      @$items.each (i, el) =>
        $el = $(el)
        if $el.call(true, @options.removeOnLoadIf, i)
          $el.remove()


  ########################
  ##                    ##
  ##  Instance Methods  ##
  ##                    ##
  ########################

  autodetectCollectionName: ->
    pattern = /\[(.[^\]]*)_attributes\]/
    try
      match = pattern.exec(@$items.first().find("#{@RELEVANT_INPUTS_SELECTOR}:first").attr('name'))[1]
      if match != null
        @options.collectionName = match
      else
        throw "Regex error"
    catch error
      console.log "Error detecting collection name", error

  addClick: (event) =>

    @addItem()

    # Don't let the link do anything
    event.preventDefault()

  addItem: ->
    # Piece together an item
    newIndex = @$items.length
    $newClone = @applyIndexToItem(@extractClone(), newIndex)

    # Give the user a chance to make their own changes before we insert
    if (@options.beforeAdd)

      # Stop the add process if the callback returns false
      return false if !@options.beforeAdd.call(undefined, $newClone, newIndex)

    # Insert the new item after the last item
    @$container.append($newClone)

    # Give the user a chance to make their own changes after insertion
    @options.afterAdd.call(undefined, $newClone, newIndex) if (@options.afterAdd)

    # Add this item to the items list
    @refreshItems()

  extractClone: ->

    # Are we restoring from an already created clone?
    if @$restorableClone

      $record = @$restorableClone

      @$restorableClone = null

    else
      $record = @options.$clone || @$items.first()

      # Make a deep clone (bound events and data)
      $record = $record.clone(@options.deepClone)

      @bindDestroy($record) if @options.$clone or !@options.deepClone

      # Empty out the values of text inputs and selects
      $record.find(':text, textarea, select').val('')

      # Reset checkboxes and radios
      $record.find(':checkbox, :radio').attr("checked", false)

      # Empty out any hidden [id] or [_destroy] fields
      $record.find('input[name$="\\[id\\]"]').remove()
      $record.find('input[name$="\\[_destroy\\]"]').remove()

    # Make sure it's not hidden as we return.
    # It would be hidden in the case where we're duplicating an
    # already removed item for its template.
    return $record.show()

  applyIndexToItem: ($item, index) ->
    collectionName = @options.collectionName

    $item.find(@RELEVANT_INPUTS_SELECTOR).each (i, el) =>

      $el = $(el)

      idRegExp = new RegExp("_#{collectionName}_attributes_\\d+_")
      idReplacement = "_#{collectionName}_attributes_#{index}_"
      nameRegExp = new RegExp("\\[#{collectionName}_attributes\\]\\[\\d+\\]")
      nameReplacement = "[#{collectionName}_attributes][#{index}]"

      newID = $el.attr('id').replace(idRegExp, idReplacement) if $el.attr('id')
      newName = $el.attr('name').replace(nameRegExp, nameReplacement)

      $el.attr
        id: newID
        name: newName

    $item.find('label[for]').each (i, el) =>
      $el = $(el)
      try
        forRegExp = new RegExp("_#{collectionName}_attributes_\\d+_")
        forReplacement = "_#{collectionName}_attributes_#{index}_"
        newFor = $el.attr('for').replace(forRegExp, forReplacement)
        $el.attr('for', newFor)
      catch error
        console.log "Error updating label", error

    return $item

  hideIfAlreadyDestroyed: ($item) ->
    $destroyField = $item.find("[name$='[_destroy]']")
    if $destroyField.length && $destroyField.val() == "true"
      @destroy $item

  # Hides a item from the user and marks it for deletion in the
  # DOM by setting _destroy to true if the record already exists. If it
  # is a new escalation, we simple delete the item
  destroyClick: (event) =>
    event.preventDefault()
    @destroy $(event.target).parentsUntil(@$container).last()

  destroy: ($item) ->
    # If you're about to delete the last one,
    # cache a clone of it first so we have something to show
    # the next time user hits add
    @$restorableClone = @extractClone() unless @$items.length-1

    index = @indexForItem($item)
    itemIsNew = $item.find('input[name$="\\[id\\]"]').length == 0

    if (@options.beforeDestroy)

      # Stop the destroy process if the callback returns false
      return false if !@options.beforeDestroy.call(undefined, $item, index, itemIsNew)

    # Add a blank item row if none are visible after this deletion
    @addItem() unless @$items.filter(':visible').length-1

    if itemIsNew

      $item.remove()

    else

      # Hide the item
      $item.hide()

      # Add the _destroy field
      otherFieldName = $item.find(':input[name]:first').attr('name')
      attributePosition = otherFieldName.lastIndexOf('[')
      destroyFieldName = "#{otherFieldName.substring(0, attributePosition)}[_destroy]"
      # First look for an existing _destroy field
      $destroyField = $item.find("input[name='#{destroyFieldName}']")
      # If it doesn't exist, create it
      if $destroyField.length == 0
        $destroyField = $("<input type=\"hidden\" name=\"#{destroyFieldName}\" />")
        $item.append($destroyField)
      $destroyField.val(true).change()

    @options.afterDestroy.call($item, index, itemIsNew) if (@options.afterDestroy)

    # Remove this item from the items list
    @refreshItems()

    # Rename the remaining items
    @resetIndexes()

  indexForItem: ($item) ->
    regExp = new RegExp("\\[#{@options.collectionName}_attributes\\]\\[\\d+\\]")
    name = $item.find("#{@RELEVANT_INPUTS_SELECTOR}:first").attr('name')
    return parseInt(name.match(regExp)[0].split('][')[1].slice(0, -1), 10)

  refreshItems: ->
    @$items = @$container.children()

  # Sets the proper association indices and labels to all items
  # Used when removing items
  resetIndexes: ->
    @$items.each (i, el) =>
      $el = $(el)

      # Make sure this is actually a new position
      oldIndex = @indexForItem($el)
      return true if (i == oldIndex)

      @options.beforeMove.call($el, i, oldIndex) if (@options.beforeMove)

      # Change the number to the new index
      @applyIndexToItem($el, i)

      @options.afterMove.call($el, i, oldIndex) if (@options.afterMove)

  bindDestroy: ($item) ->
    $item.find(@options.destroySelector).click(@destroyClick) if (@options.destroySelector)
