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

module.controller 'AppInfoCtrl', ($scope,$routeParams,$modal,$location,Page,Service,Etcd) ->
  $scope.env = $routeParams.env
  $scope.app = $routeParams.app
  Page.setTitle "App Info: #{$scope.env}/#{$scope.app}"
  $scope.reload = ->
    data = Service.get({env:$scope.env,app:$scope.app})
    data.$promise.then ->
      $scope.original_config = data
      $scope.resetConfig()

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

  $scope.resetConfig = -> $scope.config = angular.copy $scope.original_config
  $scope.deleteApp = ->
    m = $modal.open
      resolve:
        name: -> $scope.config.env+"/"+$scope.config.app
      templateUrl: 'public/templates/app-delete-confirm.html'
      controller: ($scope,$modalInstance,name)->
        $scope.name = name
        $scope.close = -> $modalInstance.close(name)

    m.result.then ->
      $scope.config.$remove().then ->
        Page.addAlert type:'info',msg:"Application deleted: #{$scope.config.env}/#{$scope.config.app}"
        $location.path("app/list")
      .catch (e)->
        console.info e
        Page.addAlert type:'danger',msg:e


module.controller 'AppCreateCtrl', ($scope,$location,Page,Service) ->
  Page.setTitle "Create Application"
  $scope.data = {
    app:'test'
    env:'test'
    template:'WebServer'
    options: {
      hosts: ['qa-101']
    }
  }

  $scope.save = ->
    s = new Service $scope.data
    s.$save().then ->
      console.info s
      $location.path("app/#{s.env}/#{s.app}")
    .catch (e)->
      console.info e
      Page.addAlert type:'danger',msg:e
