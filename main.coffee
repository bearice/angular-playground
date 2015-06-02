myApp = angular.module 'myApp',[]

myApp.controller 'test', ($scope) ->
  $scope.data = [
    {
      name: "one"
      value: 1
    },
    {
      name: "two"
      value: 2
    },
  ]
  return null
