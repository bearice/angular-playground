module = angular.module 'daikon'

module.controller 'EnvListCtrl', ($scope,Page,Service) ->
  Page.setTitle "Env List"
  $scope.reload = ->
    data = Service.listEnv()
    data.$promise.then ->
      $scope.data = data

  $scope.reload()
  $scope.$parent.reload = $scope.reload

module.controller 'EnvInfoCtrl', ($scope,$routeParams,Page,Service) ->
  Page.setTitle "Env Info: #{$routeParams.env}"
  $scope.reload = ->
    data = Service.listApp({env:$routeParams.env})
    data.$promise.then ->
      $scope.data = data

  $scope.reload()
  $scope.$parent.reload = $scope.reload


