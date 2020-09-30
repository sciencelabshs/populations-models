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
env          = require 'environments/water-field'

window.model =
  run: ->
    plantSpecies.defs.CHANCE_OF_MUTATION = 0.3
    plantSpecies.setMutatable 'size', false

    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_z.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 1}
          ]
          limit: 20
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

    startingMoney = 20
    moneyLeft = 20
    updateMoney = (val)->
      moneyLeft = val
      document.getElementById('money-value').innerHTML = "$"+val

    Events.addEventListener Environment.EVENTS.RESET, ->
      updateMoney(startingMoney)

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt)->
      updateMoney(moneyLeft-1) unless evt.detail.agent.bred

  chartData: null
  chart: null
  setupChart: ->
    # setup chart data
    @chartData = new google.visualization.DataTable()
    @chartData.addColumn('string', 'Plant Type (Root Size)')
    @chartData.addColumn('number', 'Flowers')
    @chartData.addColumn({ type: 'string', role: 'style' })
    @chartData.addRows [
      ["1",  0, "color: #888"]
      ["2",  0, "color: #888"]
      ["3",  0, "color: #888"]
      ["4",  0, "color: #888"]
      ["5",  0, "color: #888"]
      ["6",  0, "color: #888"]
      ["7",  0, "color: #888"]
      ["8",  0, "color: #888"]
      ["9",  0, "color: #888"]
      ["10", 0, "color: #888"]
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
      width: 500
      height: 400

    # Instantiate and draw our chart, passing in some options.
    @chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    @chart.draw(@chartData, options);

    Events.addEventListener Environment.EVENTS.STEP, =>
      unless @env.get(0, 0, "season") is "summer" then return
      counts = []; counts.push(0) for i in [0..10]
      for agent in @env.agents
        counts[agent.get('root size')] += 1 if agent.get('has flowers')

      for i in [0..9]
        @chartData.setValue(i, 1, counts[i+1])

      if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
        options.vAxis.gridlines.count = -1

      @chart.draw(@chartData, options)

  preload: [
    "images/agents/varied-plants/buttons/seedpack_z.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupChart()
