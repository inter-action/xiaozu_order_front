/* jshint undef: true, unused: true, devel:true */
/* global angular: true, window: true
*/
var myApp = angular.module('myApp', ['myApp.controller', 'myApp.service', 'ngRoute']);

myApp.config(['$routeProvider', function($routeProvider){
	$routeProvider.
		when('/', {
			templateUrl: '/partials/index.html'
		})
		.when('/login', {
			templateUrl: '/partials/login.html',
			controller: 'LoginController'
		})
		.when('/404', {
			templateUrl: '/404.html'
		})
		.otherwise({
			redirectTo: '/404'
		});
}]);


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
                    window.location = '/#/login';
                }
                return $q.reject(rejection);
            }
        };
    });
}]);
