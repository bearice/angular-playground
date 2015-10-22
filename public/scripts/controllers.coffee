module = angular.module 'daikon'

module.controller 'RootCtrl', ($scope,Page) ->
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

