myApp = angular.module 'daikonApp',[
  'ngRoute',
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

myApp.config ($routeProvider,$locationProvider)->
  $locationProvider.html5Mode true
  $routeProvider
  .when '/instance/list',
    templateUrl: 'templates/instances.html'
    controller: 'InstanceListCtrl'
    controllerAs: 'instances'
  .when '/instance/:id',
    templateUrl: 'templates/jsonview.html'
    controller: 'InstanceInfoCtrl'
    controllerAs: 'instance'
  .when '/app/list',
    templateUrl: 'templates/apps.html'
    controller: 'AppListCtrl'
    controllerAs: 'apps'
  .when '/server/list',
    templateUrl: 'templates/servers.html'
    controller: 'ServerListCtrl'
    controllerAs: 'servers'
  .when '/server/:name',
    templateUrl: 'templates/jsonview.html'
    controller: 'ServerInfoCtrl'
    controllerAs: 'server'
  .when '/home',
    templateUrl: 'templates/home.html'
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
    console.info $scope.autoReload = !$scope.autoReload
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
        {env,app,term,instance,node,id:x.value}
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
      $scope.data = JSON.parse data[0].value
  $scope.reload()
  $scope.$parent.reload = $scope.reload

myApp.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams,$rootScope,Page) ->
  Page.setTitle "Instance Info"
  $scope.reload = ->
    etcdGet($http,"/docker/instances/#{$routeParams.id}/raw").then (data)->
      $scope.data = JSON.parse data[0].value
  $scope.reload()
  $scope.$parent.reload = $scope.reload

