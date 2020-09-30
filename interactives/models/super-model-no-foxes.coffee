helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'
BasicAnimal = require 'models/agents/basic-animal'

plantSpecies  = require 'species/fast-plants-roots'
rabbitSpecies = require 'species/white-brown-rabbits'
hawkSpecies   = require 'species/hawks'
env           = require 'environments/open'

window.model =
  run: ->
    rabbitSpecies.defs.MATURITY_AGE = 35
    rabbitSpecies.defs.MAX_AGE = 4000

    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/grass/tallgrass.png"
          traits: [
            new Trait {name: 'resource consumption rate', default: 2}
          ]
          limit: 4000
          scatter: 400
          showRemoveButton: true
        }
        {
          species: rabbitSpecies
          imagePath: "images/agents/rabbits/rabbit2.png"
          traits: [
            new Trait {name: "maturity age", default: 2000}
            new Trait {name: "mating desire bonus", default: -12}
            new Trait {name: "fear bonus", default: -200}
            new Trait {name: "hunger bonus", default: -15}
            new Trait {name: "age", min: 1, max: 25}
            new Trait {name: "resource consumption rate", default: 10}
            new Trait {name: "min offspring", default: 1}
            new Trait {name: "max offspring", default: 3}
            new Trait {name: "metabolism", default: 0.6}
            new Trait {name: "chance of being seen", default: 0.3}
            new Trait {name: "mating distance", default: 900}
            new Trait {name: "vision distance", default: 1000}
            new Trait {name: "color", default: "white"}
          ]
          limit: 150
          scatter: 50
          showRemoveButton: true
        }
        {
          species: hawkSpecies
          imagePath: "images/agents/hawks/hawk.png"
          traits: [
            new Trait {name: "age", min: 1, max: 10}
            new Trait {name: "mating desire bonus", default: -25}
            new Trait {name: "min offspring", default: 0}
            new Trait {name: "max offspring", default: 1}
            new Trait {name: "mating distance", default: 340}
            new Trait {name: "eating distance", default:  150}
            new Trait {name: "vision distance", default: 1000}
            new Trait {name: "metabolism", default: 1}
          ]
          limit: 15
          scatter: 5
          showRemoveButton: true
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies  = plantSpecies
    @hawkSpecies   = hawkSpecies
    @rabbitSpecies = rabbitSpecies

  setupGraph: ->
    outputOptions =
      title:  "Number of organisms"
      xlabel: "Time (s)"
      ylabel: "Number of organisms"
      xmax:   30
      xmin:   0
      ymax:   50
      ymin:   0
      xTickCount: 10
      yTickCount: 10
      xFormatter: "2d"
      yFormatter: "2d"
      realTime: false
      fontScaleRelativeToParent: true
      sampleInterval: (Environment.DEFAULT_RUN_LOOP_DELAY/1000)
      dataType: 'samples'
      dataColors: [
        [  0, 170,   0]
        [153, 153, 187]
        [163,  31,   5]
        [222, 183,   9]
      ]

    @outputGraph = LabGrapher '#graph', outputOptions

    Events.addEventListener Environment.EVENTS.RESET, =>
      @outputGraph.reset()

    Events.addEventListener Environment.EVENTS.STEP, =>
      @outputGraph.addSamples @_countOrganisms()

  _countOrganisms: ->
    plants = 0
    rabbits = 0
    hawks = 0
    for a in @env.agents
      switch a.species
        when @plantSpecies
          plants++
        when @rabbitSpecies
          rabbits++
        when @hawkSpecies
          hawks++
    return [plants, rabbits, hawks]

  _showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  _agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  _addedHawks: false
  _hawksAreDead: false
  _hawksRemoved: false
  _addedRabbits: false
  _rabbitsAreDead: false
  _rabbitsRemoved: false
  _endMessageShown: false
  _timeOfExtinction: 0
  setupPopulationControls: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      allGrass = @_agentsOfSpecies @plantSpecies
      allRabbits = @_agentsOfSpecies @rabbitSpecies
      allHawks = @_agentsOfSpecies @hawkSpecies
      @_checkExtinction allRabbits, allHawks

      @_checkGrass allGrass
      @_checkPredators allHawks
      @_checkRabbits allRabbits

      if (@env.date + 1) % 400 is 0
        @_showEndMessage()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @_showEndMessage() unless @_endMessageShown
      @_hawksRemoved = @_rabbitsRemoved = @_hawksAreDead = @_rabbitsAreDead = @_endMessageShown = @_addedRabbits = @_addedHawks = false
      @_timeOfExtinction = 0
    Events.addEventListener Environment.EVENTS.USER_REMOVED_AGENTS, (evt)=>
      species = evt.detail.species
      if species is @hawkSpecies
        @_hawksRemoved = true
      else if species is @rabbitSpecies
        @_rabbitsRemoved = true

  _showEndMessage: ->
    popupText = "If you've been able to discover what happens in the model, you can continue on.\n\n"+
                     "If not, you can keep running the model, or reset it if you want to run a new model."

    @_showMessage popupText
    @env.stop()
    @_endMessageShown = true

  _checkExtinction: (allRabbits, allHawks)->
    if allRabbits.length > 0
      @_addedRabbits = true
      @_rabbitsRemoved = false
      @_rabbitsAreDead = false

    if allHawks.length > 0
      @_addedHawks = true
      @_hawksRemoved = false
      @_hawksAreDead = false

    if @_hawksAreDead or @_rabbitsAreDead
      if @env.date is (@_timeOfExtinction + 50)
        if (@_hawksAreDead and !@_hawksRemoved) or (@_rabbitsAreDead and !@_rabbitsRemoved)
          @_showEndMessage()
    else if @_addedRabbits
      if allRabbits.length is 0
        @_rabbitsAreDead = true
        @_timeOfExtinction = @env.date

  _setProperty: (agents, property, value)->
    for agent in agents
      agent.set property, value

  _checkPredators: (allHawks)->
    if allHawks.length > 17
      @_setProperty allHawks, "min offspring", 0
      @_setProperty allHawks, "max offspring", 0
      @_setProperty allHawks, "metabolism", 3
    else if allHawks.length > 14
      @_setProperty allHawks, "min offspring", 0
      @_setProperty allHawks, "max offspring", 1
      @_setProperty allHawks, "metabolism", 0.2
    else if allHawks.length < 8
      @_setProperty allHawks, "min offspring", 0
      @_setProperty allHawks, "max offspring", 2
      @_setProperty allHawks, "metabolism", 0.1
    else
      @_setProperty allHawks, "min offspring", 0
      @_setProperty allHawks, "max offspring", 2
      @_setProperty allHawks, "metabolism", 0.2


  _checkRabbits: (allRabbits)->
    if allRabbits.length > 60
      @_setProperty allRabbits, "min offspring", 0
      @_setProperty allRabbits, "max offspring", 1
      @_setProperty allRabbits, "metabolism", 2
      @_setProperty allRabbits, "chance of being seen", 0.3
      @_setProperty allRabbits, "mating desire bonus", -15
    else if allRabbits.length < 40
      @_setProperty allRabbits, "min offspring", 3
      @_setProperty allRabbits, "max offspring", 6
      @_setProperty allRabbits, "metabolism", 2
      @_setProperty allRabbits, "chance of being seen", 0.001
      @_setProperty allRabbits, "mating desire bonus", 15
    else if allRabbits.length < 30
      @_setProperty allRabbits, "min offspring", 4
      @_setProperty allRabbits, "max offspring", 7
      @_setProperty allRabbits, "metabolism", 1
      @_setProperty allRabbits, "chance of being seen", 0.0005
      @_setProperty allRabbits, "mating desire bonus", 50
    else
      @_setProperty allRabbits, "min offspring", 1
      @_setProperty allRabbits, "max offspring", 4
      @_setProperty allRabbits, "metabolism", 2
      @_setProperty allRabbits, "chance of being seen", 0.01
      @_setProperty allRabbits, "mating desire bonus", -12

  _checkGrass: (allGrass)->
    if allGrass.length > 720
      @_setProperty allGrass, "max offspring", 1
      @_setProperty allGrass, "growth rate", 0.0002
    else if allGrass.length > 620
      @_setProperty allGrass, "max offspring", 1
      @_setProperty allGrass, "growth rate", 0.0005
    else if allGrass.length > 400
      @_setProperty allGrass, "max offspring", 2
      @_setProperty allGrass, "growth rate", 0.001
    else if allGrass.length < 100
      @_setProperty allGrass, "max offspring", 3
      @_setProperty allGrass, "growth rate", 0.003
    else
      @_setProperty allGrass, "max offspring", 3
      @_setProperty allGrass, "growth rate", 0.003

    if allGrass.length < 60
      for i in [1..(Math.ceil(Math.random() * 2))]
        plant = plantSpecies.createAgent()
        plant.setLocation @env.randomLocation()
        @env.addAgent plant

  preload: [
    "images/agents/grass/tallgrass.png",
    "images/agents/rabbits/rabbit2.png",
    "images/agents/hawks/hawk.png",
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies, rabbitSpecies, hawkSpecies], ->
    model.run()
    model.setupGraph()
    model.setupPopulationControls()
