module = angular.module 'daikon'

module.directive 'selectServer', ->
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


