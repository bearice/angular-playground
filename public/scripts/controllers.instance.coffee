module = angular.module 'daikon'

module.controller 'InstanceListCtrl', ($scope,$http,$rootScope,Page,Etcd) ->
  Page.setTitle "Instance List"
  $scope.reload = ->
    Etcd.get("/docker/instances").then (data)->
      $scope.instances = []
      map = {}
      for x in data
        [id,name] = x.name.split('/')
        x.value = JSON.parse x.value if name is 'raw'
        map[id] = {id} unless map[id]
        map[id][name] = x.value
      $scope.instances.push v for k,v of map
  $scope.reload()
  $scope.$parent.reload = $scope.reload

module.controller 'InstanceInfoCtrl', ($scope,$http,$routeParams,$rootScope,$sce,Page,Etcd,config) ->
  Page.setTitle "Instance Info: #{$routeParams.id}"
  grafanaReload = (name)->
    E=document.getElementById name
    W=E.contentWindow
    A=W.angular
    D=A.element W.document
    S=D.scope()
    S.$broadcast 'refresh'

  $scope.trustGrafanaUrl = (panelId)->
    $sce.trustAsUrl(config.grafana + "?panelId=#{panelId}&fullscreen&var-id=#{$scope.raw.Id}")

  $scope.reload = ->
    Etcd.get("/docker/instances/#{$routeParams.id}/raw").then (data)->
      $scope.raw = JSON.parse data[0].value
      Page.setTitle "Instance Info: #{$scope.raw.Name}"
      try
        grafanaReload x for x in ["stats-cpu","stats-mem","stats-net","stats-blk"]
      catch e
        console.error e

  $scope.reload()
  $scope.$parent.reload = $scope.reload


