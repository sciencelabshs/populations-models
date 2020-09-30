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
rabbitSpecies = require 'species/varied-rabbits'
env           = require 'environments/desert'

window.model =
  run: ->
    rabbitSpecies.imageRules.forEach (imageRule) ->
      imageRule.rules.forEach (rule) ->
        rule.image.scale = 0.6

    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/grass/smallgrass-2.png"
          traits: [
            new Trait {name: "roots", default: 1 }
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/grass/medgrass-2.png"
          traits: [
            new Trait {name: "roots", default: 2 }
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/grass/tallgrass-2.png"
          traits: [
            new Trait {name: "roots", default:3 }
          ]
        }
      ]
      toolButtons: []

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    model.interactive.toolbar.organismButtons[0].getView().innerHTML = "A " + model.interactive.toolbar.organismButtons[0].getView().innerHTML
    model.interactive.toolbar.organismButtons[1].getView().innerHTML = "B " + model.interactive.toolbar.organismButtons[1].getView().innerHTML
    model.interactive.toolbar.organismButtons[2].getView().innerHTML = "C " + model.interactive.toolbar.organismButtons[2].getView().innerHTML

    @env = env
    env.depthPerception = true
    @plantSpecies = plantSpecies
    @rabbitSpecies = rabbitSpecies

    @_setEnvironmentProperty('water', 10, true)

    @_reset()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @_reset()

  _reset: ->
    @_addAgent(@rabbitSpecies, [["size", 1], ["is immortal", true], ["age", 50], ["max offspring", 0], ["vision distance", 800], ["eating distance", 30], ["metabolism", 20]])
    @_addAgent(@rabbitSpecies, [["size", 2], ["is immortal", true], ["age", 50], ["max offspring", 0], ["vision distance", 800], ["eating distance", 30], ["metabolism", 20]])
    @_addAgent(@rabbitSpecies, [["size", 3], ["is immortal", true], ["age", 50], ["max offspring", 0], ["vision distance", 800], ["eating distance", 30], ["metabolism", 20]])

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

    agent.chase = (agentDistance) ->
      directionToAgent =  this._direction(this.getLocation(), agentDistance.agent.getLocation());
      directionRelativeToMe = ExtMath.normalizeRads(directionToAgent - this.get('direction'));
      directionToMove = this.get('direction') + (directionRelativeToMe / 5);
      this.set('direction', directionToMove);
      speed = Math.min(this.get('speed'), Math.sqrt(agentDistance.distanceSq));
      this.move(speed);



  preload: [
    "images/environments/grass.jpg"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()


