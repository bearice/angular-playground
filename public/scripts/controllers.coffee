myApp = angular.module 'DaikonMain'


myApp.controller 'RootCtrl', ($scope,Page) ->
  timer = null
  countdown = ->
    timer = setTimeout countdown,1000
    if $scope.countdown is 0
      $scope.$emit('reload')
      $scope.countdown = 5
    else
      $scope.countdown--
    $scope.$apply()
  $scope.autoReload = false
  $scope.toggleAutoReload = ->
    $scope.autoReload = !$scope.autoReload
    clearTimeout timer if timer
    if $scope.autoReload
      $scope.countdown = 5
      timer = setTimeout countdown,1000
  $scope.$on 'reload', -> $scope.reload?()

myApp.controller 'HomeCtrl', ($scope,Page) ->
  Page.setTitle 'Home'
  $scope.$parent.reload = null

myApp.controller 'EnvListCtrl', ($scope,Page,Service) ->
  Page.setTitle "Env List"
  $scope.reload = ->
    data = Service.listEnv()
    data.$promise.then ->
      $scope.data = data
      console.info data

  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'EnvInfoCtrl', ($scope,$routeParams,Page,Service) ->
  Page.setTitle "Env Info: #{$routeParams.env}"
  $scope.reload = ->
    data = Service.listApp({env:$routeParams.env})
    data.$promise.then ->
      $scope.data = data
      console.info data

  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'AppListCtrl', ($scope,$http,$rootScope,Page,etcdGet) ->
  Page.setTitle "App List"
  $scope.reload = ->
    etcdGet("/docker/apps").then (data)->
      $scope.apps = _.compact data.map (x)->
        [env,app,term,name] = x.name.split('/')
        return undefined if name is undefined
        [instance,node] = name.split('@')
        {env,app,term:parseInt(term),instance,node,id:x.value}
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'AppInfoCtrl', ($scope,$routeParams,Page,Service,etcdGet) ->
  $scope.env = $routeParams.env
  $scope.app = $routeParams.app
  Page.setTitle "App Info: #{$scope.env}/#{$scope.app}"
  $scope.reload = ->
    data = Service.get({env:$scope.env,app:$scope.app})
    data.$promise.then ->
      $scope.config = data

    etcdGet("/docker/apps/#{$scope.env}/#{$scope.app}").then (data)->
      console.info $scope.instances = _.compact data.map (x)->
        if x.name is "current_term"
          $scope.currentTerm = parseInt x.value
          undefined
        else
          [term,name] = x.name.split('/')
          [instance,node] = name.split('@')
          {term:parseInt(term),instance,node,id:x.value}

  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'AppCreateCtrl', ($scope,Page,Service,Template,Etcd) ->
  Page.setTitle "Create Application"
  $scope.envs = []
  $scope.apps = []
  $scope.templates = {}
  $scope.servers = []
  $scope.selected_servers = []
  $scope.data = options: {}
  $scope.syncServer = ->
    if $scope.selected_servers.length is 0
      $scope.$valid=false
    else
      $scope.data.options.hosts = (x.Name for x in $scope.selected_servers)

  Service.listEnv().$promise.then (data)->
    envs = {}
    apps = {}
    for x in data
      envs[x._id] = true
      apps[a] = true for a in x.apps
    $scope.envs = _.keys(envs).sort()
    $scope.apps = _.keys(apps).sort()

  Template.query().$promise.then (data)->
    $scope.templates[a.name] = a for a in data

  Etcd.loadServers().then (data)->
    $scope.servers = _.sortBy data, 'Name'

myApp.controller 'InstanceListCtrl', ($scope,$http,$rootScope,Page,etcdGet) ->
  Page.setTitle "Instance List"
  $scope.reload = ->
    etcdGet("/docker/instances").then (data)->
      $scope.instances = []
      map = {}
      for x in data
        [id,name] = x.name.split('/')
        x.value = JSON.parse x.value if name is 'raw'
        map[id] = {id} unless map[id]
        map[id][name] = x.value
      $scope.instances.push v for k,v of map
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams,$rootScope,$sce,Page,etcdGet,config) ->
  Page.setTitle "Instance Info: #{$routeParams.id}"
  grafanaReload = (name)->
    E=document.getElementById name
    W=E.contentWindow
    A=W.angular
    D=A.element W.document
    S=D.scope()
    S.$broadcast 'refresh'

  $scope.trustGrafanaUrl = (panelId)->
    $sce.trustAsUrl(config.grafana + "?panelId=#{panelId}&fullscreen&var-id=#{$scope.raw.Id}")

  $scope.reload = ->
    etcdGet("/docker/instances/#{$routeParams.id}/raw").then (data)->
      $scope.raw = JSON.parse data[0].value
      Page.setTitle "Instance Info: #{$scope.raw.Name}"
      try
        grafanaReload x for x in ["stats-cpu","stats-mem","stats-net","stats-blk"]
      catch e
        console.error e

  $scope.reload()
  $scope.$parent.reload = $scope.reload


myApp.controller 'ServerListCtrl', ($scope,$http,$rootScope,Page,etcdGet) ->
  Page.setTitle "Server List"
  $scope.reload = ->
    etcdGet("/docker/servers").then (data)->
      $scope.servers = data.map (x)->
        o = JSON.parse x.value
        o.Name = x.name
        return o
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'ServerInfoCtrl', ($scope,$http,$routeParams,$rootScope,Page,etcdGet) ->
  Page.setTitle "Server Info: #{$routeParams.name}"
  $scope.reload = ->
    etcdGet("/docker/servers/#{$routeParams.name}").then (data)->
      $scope.raw = JSON.parse data[0].value
  $scope.reload()
  $scope.$parent.reload = $scope.reload

