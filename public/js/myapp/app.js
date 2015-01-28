/* jshint undef: true, unused: true, devel:true */
/* global angular: true, window: true, sessionStorage: true
*/

/*
程序的依赖:
    html5 localStorage, sessionStorage,
 */

var myApp = angular.module('myApp', ['myApp.controller', 'myApp.service', 'myapp.directive', 'ngRoute']);

myApp.config(['$routeProvider', function($routeProvider){
    $routeProvider
        .when('/', {
            templateUrl: '/partials/index.html',
            controller: 'IndexController'
        })
        .when('/login', {
            templateUrl: '/partials/login.html',
            controller: 'LoginController'
        })
        .when('/users', {
            templateUrl: '/partials/users.html',
            controller: 'UserListController'
        })
        .when('/ordertoday', {
            templateUrl: '/partials/ordertoday.html',
            controller: 'OrderTodayController'
        })
        .when('/404', {
            templateUrl: '/404.html'
        })
        .otherwise({
            redirectTo: '/404'
        });
}]);

// $http 拦截器
myApp.config(['$httpProvider', function ($httpProvider) {
    $httpProvider.interceptors.push(function ($q) {
        return {
            'response': function (response) {
                //Will only be called for HTTP up to 300
                return response;
            },
            'responseError': function (rejection) {
                //for status code greater than 3xx, this func will be called
                if(rejection.status === 401) {
                    // todo: could not inject `$location` here
                    // $location.path('login');
                    window.location = '/#/login';
                }
                return $q.reject(rejection);
            }
        };
    });
}]);

//页面拦截器
// http://stackoverflow.com/questions/11541695/redirecting-to-a-certain-route-based-on-condition
// $rootScope 存值的问题, 由于是单页面应用所以如果用户只是在页面中点击连接是没有问题的
// 但是如果用户在地址栏中点击回车, 整个js的生命周期就结束了, 这意味着在所有js中存值都是无法回避的问题
// 所以 html5 的localStorage, sessionStorage 能解决这个问题
myApp.run(function($rootScope, $location) {
    // register listener to watch route changes
    $rootScope.$on("$routeChangeStart", function(event, next, current) {
        if (!sessionStorage.user) {
            // next.templateUrl 指向的是模板的地址
            // no logged user, we should be going to #login
            if (next.templateUrl == "/partials/login.html ") {
                // already going to #login, no redirect needed
            } else {
                // not going to #login, we should redirect now
                // will go to /#/login
                $location.path("/login");
            }
        }
    });
});
