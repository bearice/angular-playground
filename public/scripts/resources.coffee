myApp = angular.module 'DaikonMain'

myApp.factory 'Service', ($resource)->
  $resource 'api/service/:env/:app',null,{
    'listEnv':
      method: 'GET'
      isArray: true
      params: {}
    'listApp':
      method: 'GET'
      isArray: true
  }

myApp.factory 'Template', ($resource)->
  $resource 'api/template/:name',null,{}
