var serviceModule = angular.module('myApp.service', []);


serviceModule.factory('MenuService', ['$http',
    function($http) {
        var api = {};

        api.list = function(){
            return $http.get('/menus');
        };
        
        //单点
        api.singleAdd = function(data){
            return $http.post('/order/single', {data: data});
        };

        //添加荤素配
        api.comboAdd = function(data){
            return $http.post('/order/combo', {data: data});
        };

        return api;
    }
]);


serviceModule.factory('UserService', ['$http',
    function($http) {
        var api = {};

        //登录
        api.login = function(username){
            return $http.post('/login', {username: username});
        };
        
        api.logout = function(){
            return $http.post('/logout');
        };

        api.list = function(){
            return $http.get('/users');
        };


        
        return api;
    }
]);
