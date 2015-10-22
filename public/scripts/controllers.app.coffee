module = angular.module 'daikon'

module.controller 'AppListCtrl', ($scope,$http,$rootScope,Page,Etcd) ->
  Page.setTitle "App List"
  $scope.reload = ->
    Etcd.get("/docker/apps").then (data)->
      $scope.apps = _.compact data.map (x)->
        [env,app,term,name] = x.name.split('/')
        return undefined if name is undefined
        [instance,node] = name.split('@')
        {env,app,term:parseInt(term),instance,node,id:x.value}
  $scope.reload()
  $scope.$parent.reload = $scope.reload

module.controller 'AppInfoCtrl', ($scope,$routeParams,Page,Service,Etcd) ->
  $scope.env = $routeParams.env
  $scope.app = $routeParams.app
  Page.setTitle "App Info: #{$scope.env}/#{$scope.app}"
  $scope.reload = ->
    data = Service.get({env:$scope.env,app:$scope.app})
    data.$promise.then ->
      $scope.config = data

    Etcd.get("/docker/apps/#{$scope.env}/#{$scope.app}").then (data)->
      $scope.instances = _.compact data.map (x)->
        if x.name is "current_term"
          $scope.currentTerm = parseInt x.value
          undefined
        else
          [term,name] = x.name.split('/')
          [instance,node] = name.split('@')
          {term:parseInt(term),instance,node,id:x.value}

  $scope.reload()
  $scope.$parent.reload = $scope.reload

module.controller 'AppCreateCtrl', ($scope,Page,Service,Template,Etcd) ->
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


