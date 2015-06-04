myApp = angular.module 'myApp',[]

myApp.controller 'test', ($scope,$http) ->
  $scope.data = []
  $http.get("https://node-34.etcd.zhaowei.jimubox.com:2379/v2/keys/docker?recursive=true")
    .success (data)->
      getNodes = (node,a)->
        a = [] unless a
        if node.dir
          console.info node
          node.nodes?.forEach (x)-> getNodes(x,a)
        else
          a.push
            name: node.key
            value: node.value
        return a
      $scope.data = _.sortBy(getNodes(data.node),"name")

