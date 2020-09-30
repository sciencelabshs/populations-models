Environment = require 'models/environment'
Trait       = require 'models/trait'
Rule        = require 'models/rule'
BasicAnimal = require 'models/agents/basic-animal'
FastPlant   = require 'models/agents/fast-plant'

env = new Environment
  columns:  45
  rows:     45
  imgPath: "images/environments/desert.jpg"
  barriers: []
  wrapEastWest: false
  wrapNorthSouth: false


env.addRule new Rule
  test: (agent)->
    return agent instanceof BasicAnimal && agent.get('prey').length is 0
  action: (agent) ->
    # Set the right prey based on size
    trait = new Trait({name: 'roots', possibleValues: [agent.get('size')]})
    agent.set 'prey', [{name: 'fast plants', traits: [trait]}]

# plants with roots 1
env.addRule new Rule
  test: (agent)->
    return agent instanceof FastPlant && agent.get('roots') is 1
  action: (agent)->
    water = agent.get('water')/10.0           # 0-1       1 is wettest
    distFrom90 = Math.max(0.9-water, 0.0)     # 0-0.9     0 is wettest
    dryness = Math.min(1.0, distFrom90/0.4)   # 0-1       0 is wettest, 1 happens at water 0.4

    # chance of survival is 1.0 at water > 0.9, 0.8 at water < 0.5, and decreases linearly between
    agent.set 'chance of survival', (1 - (dryness * 0.1))
    # growth rate is 0.04 at water > 0.9, 0 at water < 0.5, and decreases linearly between
    # agent.set 'growth rate', (0.04 - (dryness * .04) + pop_size_mod)

# plants with roots 2
env.addRule new Rule
  test: (agent)->
    return agent instanceof FastPlant && agent.get('roots') is 2
  action: (agent)->
    water = agent.get('water')/10
    distFrom70 = Math.max(0.7-water, 0.0)
    dryness = Math.min(1.0, distFrom70/0.4)

    # chance of survival is 1.0 at water > 0.7, 0.8 at water < 0.3, and decreases linearly between
    agent.set 'chance of survival', (1 - (dryness * 0.1))
    # growth rate is 0.04 at water > 0.7, 0 at water < 0.3, and decreases linearly between
    # agent.set 'growth rate', (0.04 - (dryness * .04) + pop_size_mod)

require.register "environments/desert", (exports, require, module) ->
  module.exports = env
