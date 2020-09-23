helpers     = require 'helpers'
Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/sunlight-mountain'

window.model =
  emptyBarriers: [
    [  0,   0,  42, 520],
    [558,   0,  42, 520]
  ]
  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          limit: 40
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

    Events.addEventListener Environment.EVENTS.STEP, =>
      numPlants = @env.agents.length
      if numPlants > 500
        for plant in @env.agents
          plant.set "min offspring", 0
          plant.set "max offspring", 1
      else if numPlants > 400
        for plant in @env.agents
          plant.set "min offspring", 0
          plant.set "max offspring", 2
      else if numPlants > 250
        for plant in @env.agents
          plant.set "min offspring", 0
          plant.set "max offspring", 3
      else
        for plant in @env.agents
          plant.set "min offspring", 1
          plant.set "max offspring", 3

  preload: [
    "images/agents/varied-plants/buttons/seedpack_10.png",
    "images/environments/mountains1.jpg"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
