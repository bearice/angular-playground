myApp = angular.module 'daikonApp',[
  'ngRoute',
  'ui.bootstrap',
  'angular.filter',
  'tableSort',
  'jsonFormatter',
  'angularMoment',
  'angular-loading-bar',
]

baseURL = "https://node-34.etcd.zhaowei.jimubox.com:2379/v2/keys"
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
  .otherwise redirectTo: '/app/list'

  $locationProvider.html5Mode true

myApp.controller 'RootCtrl', ($scope, $route, $routeParams, $location) ->
  $scope.$on '$routeChangeSuccess', (e)->
    current = $route.current
    console.log "ROUTE CHANGE: [ %s ] .. [ Path: %s ]",current.originalPath,$location.path()

myApp.controller 'NavCtrl', ($scope,$http,$location) ->

myApp.controller 'InstanceListCtrl', ($scope,$http) ->
  etcdGet($http,"/docker/instances").then (data)->
    $scope.instances = []
    map = {}
    for x in data
      [id,name] = x.name.split('/')
      x.value = JSON.parse x.value if name is 'raw'
      map[id] = {id} unless map[id]
      map[id][name] = x.value
    $scope.instances.push v for k,v of map

myApp.controller 'AppListCtrl', ($scope,$http) ->
  etcdGet($http,"/docker/apps").then (data)->
    $scope.apps = _.compact data.map (x)->
      [env,app,term,name] = x.name.split('/')
      return undefined if name is undefined
      [instance,node] = name.split('@')
      {env,app,term,instance,node,id:x.value}

myApp.controller 'ServerListCtrl', ($scope,$http) ->
  etcdGet($http,"/docker/servers").then (data)->
    $scope.servers = data.map (x)->
      o = JSON.parse x.value
      o.Name = x.name
      return o

myApp.controller 'ServerInfoCtrl', ($scope,$http,$routeParams) ->
  etcdGet($http,"/docker/servers/#{$routeParams.name}").then (data)->
    $scope.data = JSON.parse data[0].value

myApp.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams) ->
  etcdGet($http,"/docker/instances/#{$routeParams.id}/raw").then (data)->
    $scope.data = JSON.parse data[0].value

