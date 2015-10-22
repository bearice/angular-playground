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

myApp.factory 'Etcd', (config,$http)->
  flatNodes = (pfix,node,acc=[])->
    if node.dir
      flatNodes(pfix,x,acc) for x in node.nodes || []
    else
      acc.push
        name: node.key.substr(pfix.length)
        value: node.value
    return acc

  return {
    get: (path) ->
      $http.get(config.etcd+path, params: {recursive: true}).then (resp) ->
        flatNodes path+"/", resp.data.node

    loadServers: ->
      @get("/docker/servers").then (data)->
        data.map (x)->
          o = JSON.parse x.value
          o.Name = x.name
          return o
  }

