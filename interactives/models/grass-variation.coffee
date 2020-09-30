helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'

plantSpecies  = require 'species/fast-plants-roots'
env           = require 'environments/desert'

addClass = (el, className) ->
  if el.classList
    el.classList.add(className);
  else
    current = el.className
    found = false;
    all = current.split(' ')
    i = 0
    while i < all.length && !found
      found = all[i] == className
      i++
    if !found
      if current == ''
        el.className = className
      else
        el.className += ' ' + className

removeClass = (el, className) ->
  if el.classList
    el.classList.remove(className);
  else
    el.className = el.className.replace(new RegExp('(^|\\b)' + className.split(' ').join('|') + '(\\b|$)', 'gi'), ' ');

window.model =
  startTime: 0
  previousTime: 0

  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/grass/medgrass.png"
          traits: [
            new Trait {name: "roots", possibleValues: [1,2,3] }
          ]
          limit: 60
          scatter: 60
        }
      ]
      toolButtons: []

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    env.depthPerception = true
    @plantSpecies = plantSpecies

    @_reset()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @_reset()

  _reset: ->
    @startTime = 0
    @previousTime = 0
    model.interactive.toolbar.organismButtons[0].disable()
    popup = document.getElementById("modal-popup")
    removeClass(popup, "hidden")
    @_setTime(0)

  setRain: ->
    waterLevels =
      Most: 10
      Medium: 8.5
      Least: 6.7
    waterLevelName = document.getElementById("water-level-select").value
    waterLevel = waterLevels[waterLevelName]

    @_setEnvironmentProperty('water', waterLevel, true)

    waterLevelIndicator = document.getElementById('water-level-indicator')
    indicatorMin = 6
    indicatorLevel = (waterLevel - indicatorMin) * (10 / 4)
    waterLevelIndicator.style.height = ""+(indicatorLevel * 10)+"%"

    popup = document.getElementById("modal-popup")
    addClass(popup, "hidden")
    model.interactive.toolbar.organismButtons[0].reset()

  _setTime: (time) ->
    document.getElementById("time").innerHTML = time


  chartData: null
  chart: null
  setupCharts: ->
    @chartData = new google.visualization.DataTable()
    @chartData.addColumn('string', 'Plant types')
    @chartData.addColumn('number', 'Number of plants')
    @chartData.addColumn({ type: 'string', role: 'style' })
    @chartData.addRows [
      ["Small",  0, "color: #00FF00"]
      ["Medium", 0, "color: #00CC00"]
      ["Big",    0, "color: #008800"]
    ]

    options =
      title: 'Grass'
      hAxis:
        title: 'Grass types'
      vAxis:
        title: 'Number of plants'
        minValue: 0
        maxValue: 50
        gridlines:
          count: 6
      legend:
        position: 'none'
      width: 300
      height: 250
    # Instantiate and draw our chart, passing in some options.
    @chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    @chart.draw(@chartData, options)

    updateCharts = () =>
      counts = [0,0,0,0]

      for agent in @env.agents
        counts[agent.get('roots')] += 1

      for i in [0..2]
        @chartData.setValue(i, 1, counts[i+1])

      @chart.draw(@chartData, options)



    Events.addEventListener Environment.EVENTS.STEP, updateCharts
    $(".button:nth-child(3)").on('click', updateCharts)

  _agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  setupTimer: ->
    that = @
    Events.addEventListener Environment.EVENTS.STEP, () ->
      if that.startTime
        timePassed = (window.performance.now() - that.startTime) / 1000 + that.previousTime
        that._setTime(Math.floor(timePassed))
      else
        if that.env.agents.length && that.env._isRunning
          that.startTime = window.performance.now()

    Events.addEventListener Environment.EVENTS.STOP, () ->
      that.previousTime += timePassed = (window.performance.now() - that.startTime) / 1000
      that.startTime = 0

  _setAgentProperty: (agents, prop, val)->
    for a in agents
      a.set prop, val

  _setAgentProperty: (agents, prop, val)->
    for a in agents
      a.set prop, val

  _setEnvironmentProperty: (prop, val, all=false)->
    for row in [0..(@env.rows)]
      if all or row > @env.rows/2
        for col in [0..(@env.columns)]
          @env.set col, row, prop, val

  _addAgent: (species, properties=[])->
    agent = species.createAgent()
    agent.setLocation @env.randomLocation()
    for prop in properties
      agent.set prop[0], prop[1]
    @env.addAgent agent

  setupPopulationMonitoring: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      # Check population levels and adjust accordingly
      @_setPlantGrowthRate()

  _setPlantGrowthRate: ->
    allPlants = @_agentsOfSpecies @plantSpecies

    varieties = [[], [], [], [], [], []]
    for plant in allPlants
      rootSize = plant.get("roots")
      varieties[rootSize].push(plant)

    for variety in varieties
      @_setGrowthRateForVariety(variety)


  _setGrowthRateForVariety: (plants)->
    if plants.length > 0
      growthRate = 0.004

      health = plants[0].get("chance of survival")
      if health > 0.999
        if plants.length > 220
          growthRate = 0
        else if plants.length > 180
          growthRate = 0.001
        else if plants.length > 160
          growthRate = 0.002
        else if plants.length > 110
          growthRate = 0.0025
      else
        if plants.length > 49
          growthRate = 0

      for plant in plants
        plant.set "growth rate", growthRate


  preload: [
    "images/environments/grass.jpg"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupTimer()
    model.setupCharts()
    model.setupPopulationMonitoring()


