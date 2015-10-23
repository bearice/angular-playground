module = angular.module 'daikon'

module.directive 'selectServer', ->
  restrict: 'E',
  require: 'ngModel',
  scope:
    list: '=data'
    model: '=ngModel'
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
    $scope.model = [] if $scope.model is undefined
    $scope.list.forEach (x)->
      x.selected = $scope.model.indexOf(x.Name)>=0

    $scope.selected = []
    $scope.sync = ->
      $scope.model = if $scope.selected.length is 0
        null
      else
        x.Name for x in $scope.selected

  link: (scope,elem,attr,ctrl)->
    scope.$watch 'model', (val)->ctrl.$setViewValue val

module.directive 'appEditor', ->
  restrict: 'E',
  require: 'ngModel',
  scope:
    apps: '='
    envs: '='
    templates: '='
    servers: '='
    data:'=ngModel'

  templateUrl: 'public/templates/app-editor.html'
  controller: ($scope)->

  link: ($scope, $element, $attrs, ngModel)->
    $scope.$watch 'overrideImage', ->
      if $scope.overrideImage
        $scope.data.image = $scope.customImage
      else
        delete $scope.data.image
        $scope.customImage = "docker.jimubox.com/#{$scope.data.env}/#{$scope.data.app}:latest"

    $scope.$watch 'customImage', ->
      if $scope.overrideImage
        $scope.data.image = $scope.customImage

    $scope.$watchGroup ['data.env','data.app'], ()->
      $scope.customImage = "docker.jimubox.com/#{$scope.data.env}/#{$scope.data.app}:latest" unless $scope.overrideImage

