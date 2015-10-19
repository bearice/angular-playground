myApp = angular.module 'daikonApp',[
  'ngRoute',
  'ngResource',
  'ngSanitize',
  'ui.bootstrap',
  'angular.filter',
  'tableSort',
  'jsonFormatter',
  'angularMoment',
  'angular-loading-bar',
]

myApp.constant 'etcdBaseURL', "etcd2/v2/keys"

myApp.factory 'etcdGet', ($http,etcdBaseURL)->
  getNodes = (pfix,node,a)->
    a = [] unless a
    if node.dir
      node.nodes?.forEach (x)-> getNodes(pfix,x,a)
    else
      a.push
        name: node.key.substr(pfix.length)
        value: node.value
    return a

  return (path) ->
    $http.get(etcdBaseURL+path, params: {recursive: true}).then (resp) ->
      getNodes path+"/", resp.data.node

myApp.filter 'secondsAgo', ->
  (input)->
    d = new Date(input)
    d = (new Date()).valueOf() - d.valueOf()
    return "#{Math.ceil(d/1000)}S ago"

myApp.config ($routeProvider,$locationProvider,$sceProvider)->
  $sceProvider.enabled false
  $locationProvider.html5Mode true
  $routeProvider
  .when '/env/list',
    templateUrl: 'public/templates/env-list.html'
    controller: 'EnvListCtrl'
    controllerAs: 'envs'
  .when '/env/:env',
    templateUrl: 'public/templates/env-info.html'
    controller: 'EnvInfoCtrl'
    controllerAs: 'env'
  .when '/app/list',
    templateUrl: 'public/templates/app-list.html'
    controller: 'AppListCtrl'
    controllerAs: 'apps'
  .when '/app/:env/:app',
    templateUrl: 'public/templates/app-info.html'
    controller: 'AppInfoCtrl'
    controllerAs: 'app'
  .when '/instance/list',
    templateUrl: 'public/templates/instance-list.html'
    controller: 'InstanceListCtrl'
    controllerAs: 'instances'
  .when '/instance/:id',
    templateUrl: 'public/templates/instance-info.html'
    controller: 'InstanceInfoCtrl'
    controllerAs: 'instance'
  .when '/server/list',
    templateUrl: 'public/templates/server-list.html'
    controller: 'ServerListCtrl'
    controllerAs: 'servers'
  .when '/server/:name',
    templateUrl: 'public/templates/server-info.html'
    controller: 'ServerInfoCtrl'
    controllerAs: 'server'
  .when '/home',
    templateUrl: 'public/templates/home.html'
    controller: 'HomeCtrl'
    controllerAs: 'home'
  .otherwise redirectTo: '/home'

myApp.service 'Page',($rootScope)->
  return setTitle: (title)->$rootScope.title = title

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

myApp.factory 'Services', ($resource)->
  $resource 'api/service/:env/:app',null,{
    'listEnv':
      method: 'GET'
      isArray: true
      params: {}
    'listApp':
      method: 'GET'
      isArray: true
  }

myApp.controller 'HomeCtrl', ($scope,Page) ->
  Page.setTitle 'Home'
  $scope.$parent.reload = null

myApp.controller 'EnvListCtrl', ($scope,Page,Services) ->
  Page.setTitle "Env List"
  $scope.reload = ->
    data = Services.listEnv()
    data.$promise.then ->
      $scope.data = data
      console.info data

  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'EnvInfoCtrl', ($scope,$routeParams,Page,Services) ->
  Page.setTitle "Env Info: #{$routeParams.env}"
  $scope.reload = ->
    data = Services.listApp({env:$routeParams.env})
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

myApp.controller 'AppInfoCtrl', ($scope,$routeParams,Page,Services,etcdGet) ->
  $scope.env = $routeParams.env
  $scope.app = $routeParams.app
  Page.setTitle "App Info: #{$scope.env}/#{$scope.app}"
  $scope.reload = ->
    data = Services.get({env:$scope.env,app:$scope.app})
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

myApp.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams,$rootScope,$sce,Page,etcdGet) ->
  Page.setTitle "Instance Info: #{$routeParams.id}"
  grafanaReload = (name)->
    E=document.getElementById name
    W=E.contentWindow
    A=W.angular
    D=A.element W.document
    S=D.scope()
    S.$broadcast 'refresh'

  $scope.trustGrafanaUrl = (panelId)->
    $sce.trustAsUrl("grafana/dashboard-solo/db/instance-stats?panelId=#{panelId}&fullscreen&var-id=#{$scope.raw.Id}")

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

