module = angular.module 'daikon'

module.controller 'HomeCtrl', ($scope,Page) ->
  Page.setTitle 'Home'
  $scope.$parent.reload = null
