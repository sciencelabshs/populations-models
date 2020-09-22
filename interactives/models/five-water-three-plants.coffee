helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
ToolButton  = require 'ui/tool-button'
Events      = require 'events'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/water-flowerboxes'

window.model =
  run: ->
    plantSpecies.defs.CAN_SEED = false

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_x.png"
          traits: [
            new Trait {name: "root size", default: 1}
            new Trait {name: "size", default: 5}
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_y.png"
          traits: [
            new Trait {name: "root size", default: 5}
            new Trait {name: "size", default: 5}
          ]
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_z.png"
          traits: [
            new Trait {name: "root size", default: 10}
            new Trait {name: "size", default: 5}
          ]
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
        {
          type: ToolButton.CARRY_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

  chartData: null
  chart: null
  setupChart: ->
    # setup chart data
    @chartData = new google.visualization.DataTable()
    @chartData.addColumn('string', 'Plant Type (Root Size)')
    @chartData.addColumn('number', 'Flowers')
    @chartData.addColumn({ type: 'string', role: 'style' })
    @chartData.addRows [
      ["1",  0, "color: #5942BF"]
      ["2",  0, "color: #5F42B8"]
      ["3",  0, "color: #65429F"]
      ["4",  0, "color: #73419E"]
      ["5",  0, "color: #874084"]
      ["6",  0, "color: #904078"]
      ["7",  0, "color: #9F416B"]
      ["8",  0, "color: #B5435A"]
      ["9",  0, "color: #C84349"]
      ["10", 0, "color: #D34441"]
    ]

    # Set chart options
    options =
      title: 'Number of Flowers'
      hAxis:
        title: 'Plant Type (Root Size)'
      vAxis:
        title: 'Flowers'
        minValue: 0
        maxValue: 10
        gridlines:
          count: 6
      legend:
        position: 'none'
      width: 450
      height: 360

    # Instantiate and draw our chart, passing in some options.
    @chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    @chart.draw(@chartData, options);

    Events.addEventListener Environment.EVENTS.STEP, =>
      counts = []; counts.push(0) for i in [0..10]
      for agent in @env.agents
        counts[agent.get('root size')] += 1 if agent.get('has flowers')

      for i in [0..9]
        @chartData.setValue(i, 1, counts[i+1])

      if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
        options.vAxis.gridlines.count = -1

      @chart.draw(@chartData, options)

  setupDialogs: ->
    messageShown = false
    showMessage = (message) =>
      if not messageShown
        helpers.showMessage message, @env.getView().view.parentElement
        messageShown = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      messageShown = false

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt)=>
      # age will not be 0 if it's an addition due to carrying
      messageShown = false if evt.detail.agent.get('age') is 0

    Events.addEventListener Environment.EVENTS.STEP, =>
      numWilted = 0
      numXFlowers = 0
      numYFlowers = 0
      numZFlowers = 0

      for agent in @env.agents
        if agent.get('age') <= agent.species.defs.MATURITY_AGE
          return # wait until all plants are mature before displaying dialogs

        if agent.get("health") < 0.99
          numWilted++

        if agent.get("has flowers")
          roots = agent.get("root size")
          if roots is 5
            numXFlowers++
          else if roots is 10
            numYFlowers++
          else
            numZFlowers++

      if numXFlowers >= 3 and numYFlowers >= 3 and numZFlowers >= 3
        if numWilted is 0
          showMessage("Good job! All your plants are in the right boxes.<br/>Take a picture of your model and continue on.")
        else
          if numWilted > 1
            showMessage("You've got lots of healthy plants, but still a few wilted ones! Can you work out where they should go?")
          else
            showMessage("You've got lots of healthy plants, but still one wilted one! Can you work out where it should go?")
      else if numWilted > 0
        if numWilted > 1
          showMessage("Uh oh, " + numWilted + " of your plants are wilted! Try to find the right environment for them using the Carry button.")
        else
          showMessage("Uh oh, one of your plants is wilted! Try to find the right environment for it using the Carry button.")

  preload: [
    "images/agents/varied-plants/buttons/seedpack_x.png",
    "images/agents/varied-plants/buttons/seedpack_y.png",
    "images/agents/varied-plants/buttons/seedpack_z.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupChart()
    model.setupDialogs()
