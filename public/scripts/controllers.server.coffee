module = angular.module 'daikon'

module.controller 'ServerListCtrl', ($scope,$http,$rootScope,Page,Etcd)->
  Page.setTitle "Server List"
  $scope.reload = ->
    Etcd.get("/docker/servers").then (data)->
      $scope.servers = data.map (x)->
        o = JSON.parse x.value
        o.Name = x.name
        return o
  $scope.reload()
  $scope.$parent.reload = $scope.reload

module.controller 'ServerInfoCtrl', ($scope,$http,$routeParams,$rootScope,Page,Etcd) ->
  Page.setTitle "Server Info: #{$routeParams.name}"
  $scope.reload = ->
    Etcd.get("/docker/servers/#{$routeParams.name}").then (data)->
      $scope.raw = JSON.parse data[0].value
  $scope.reload()
  $scope.$parent.reload = $scope.reload

