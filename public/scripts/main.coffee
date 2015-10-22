myApp = angular.module 'DaikonMain',[
  'ngRoute',
  'ngResource',
  'ngSanitize',
  'ngAnimate',
  'ui.bootstrap',
  'angular.filter',
  'tableSort',
  'jsonFormatter',
  'angularMoment',
  'angular-loading-bar',
  'isteven-multi-select'
]

myApp.constant 'config',
  etcd: "etcd2/v2/keys"
  grafana: "grafana/"

myApp.factory 'etcdGet', ($http,config)->
  getNodes = (pfix,node,a)->
    a = [] unless a
    if node.dir
      node.nodes?.forEach (x)-> getNodes(pfix,x,a)
    else
      a.push
        name: node.key.substr(pfix.length)
        value: node.value
    return a

myApp.directive 'selectServer', ->
  restrict: 'E',
  require: 'ngModel',
  scope:
    list: '=data'
  template: '''
    <div  isteven-multi-select
          input-model="list"
          output-model="selected"
          tick-property="selected"
          button-label="Name"
          item-label="Name"
          search-property="Name"
          output-properties="Name"
          on-close="sync()" />
    '''

  controller: ($scope)->
    $scope.selected = []
    $scope.sync = ->
      $scope.val = if $scope.selected.length is 0
        null
      else
        x.Name for x in $scope.selected

  link: (scope,elem,attr,ctrl)->
    scope.$watch 'val', (val)->ctrl.$setViewValue val
    ctrl.$name = attr.name


myApp.filter 'secondsAgo', ->
  (input)->
    d = new Date(input)
    d = (new Date()).valueOf() - d.valueOf()
    return "#{Math.ceil(d/1000)}S ago"

myApp.service 'Page',($rootScope)->
  return setTitle: (title)->$rootScope.title = title

myApp.config ($routeProvider,$locationProvider,$sceProvider)->
  $sceProvider.enabled false
  $locationProvider.html5Mode true
  $routeProvider
  .when '/env/list',
    templateUrl: 'public/templates/env-list.html'
    controller: 'EnvListCtrl'
  .when '/env/:env',
    templateUrl: 'public/templates/env-info.html'
    controller: 'EnvInfoCtrl'
  .when '/app/list',
    templateUrl: 'public/templates/app-list.html'
    controller: 'AppListCtrl'
  .when '/app/:env/:app',
    templateUrl: 'public/templates/app-info.html'
    controller: 'AppInfoCtrl'
  .when '/app/create',
    templateUrl: 'public/templates/app-create.html'
    controller: 'AppCreateCtrl'
  .when '/instance/list',
    templateUrl: 'public/templates/instance-list.html'
    controller: 'InstanceListCtrl'
  .when '/instance/:id',
    templateUrl: 'public/templates/instance-info.html'
    controller: 'InstanceInfoCtrl'
  .when '/server/list',
    templateUrl: 'public/templates/server-list.html'
    controller: 'ServerListCtrl'
  .when '/server/:name',
    templateUrl: 'public/templates/server-info.html'
    controller: 'ServerInfoCtrl'
  .when '/home',
    templateUrl: 'public/templates/home.html'
    controller: 'HomeCtrl'
  .otherwise redirectTo: '/home'

