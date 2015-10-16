myApp = angular.module 'daikonApp',[
  'ngRoute',
  'ngSanitize',
  'ui.bootstrap',
  'angular.filter',
  'tableSort',
  'jsonFormatter',
  'angularMoment',
  'angular-loading-bar',
]

baseURL = "/etcd2/v2/keys"
getNodes = (pfix,node,a)->
  a = [] unless a
  if node.dir
    node.nodes?.forEach (x)-> getNodes(pfix,x,a)
  else
    a.push
      name: node.key.substr(pfix.length)
      value: node.value
  return a

etcdGet = ($http,path) ->
  $http.get(baseURL+path, params: {recursive: true}).then (resp) ->
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
  .when '/instance/list',
    templateUrl: 'public/templates/instances.html'
    controller: 'InstanceListCtrl'
    controllerAs: 'instances'
  .when '/instance/:id',
    templateUrl: 'public/templates/instance-info.html'
    controller: 'InstanceInfoCtrl'
    controllerAs: 'instance'
  .when '/app/list',
    templateUrl: 'public/templates/apps.html'
    controller: 'AppListCtrl'
    controllerAs: 'apps'
  .when '/server/list',
    templateUrl: 'public/templates/servers.html'
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

myApp.controller 'HomeCtrl', ($scope,$http,$location,$rootScope,Page) ->
  Page.setTitle 'Home'
  $scope.$parent.reload = null

myApp.controller 'InstanceListCtrl', ($scope,$http,$rootScope,Page) ->
  Page.setTitle "Instance List"
  $scope.reload = ->
    etcdGet($http,"/docker/instances").then (data)->
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

myApp.controller 'AppListCtrl', ($scope,$http,$rootScope,Page) ->
  Page.setTitle "App List"
  $scope.reload = ->
    etcdGet($http,"/docker/apps").then (data)->
      $scope.apps = _.compact data.map (x)->
        [env,app,term,name] = x.name.split('/')
        return undefined if name is undefined
        [instance,node] = name.split('@')
        {env,app,term:parseInt(term),instance,node,id:x.value}
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'ServerListCtrl', ($scope,$http,$rootScope,Page) ->
  Page.setTitle "Server List"
  $scope.reload = ->
    etcdGet($http,"/docker/servers").then (data)->
      $scope.servers = data.map (x)->
        o = JSON.parse x.value
        o.Name = x.name
        return o
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'ServerInfoCtrl', ($scope,$http,$routeParams,$rootScope,Page) ->
  Page.setTitle "Server Info"
  $scope.reload = ->
    etcdGet($http,"/docker/servers/#{$routeParams.name}").then (data)->
      $scope.raw = JSON.parse data[0].value
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams,$rootScope,$sce,Page) ->
  Page.setTitle "Instance Info"
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
    etcdGet($http,"/docker/instances/#{$routeParams.id}/raw").then (data)->
      $scope.raw = JSON.parse data[0].value
      try
        grafanaReload x for x in ["stats-cpu","stats-mem","stats-net","stats-blk"]
      catch e
        console.error e

  $scope.reload()
  $scope.$parent.reload = $scope.reload

