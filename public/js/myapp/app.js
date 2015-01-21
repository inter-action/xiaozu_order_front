/* jshint undef: true, unused: true, devel:true */

var myApp = angular.module('myApp', ['myApp.controller', 'myApp.service', 'ngRoute']);

myApp.config(['$routeProvider', function($routeProvider){
	$routeProvider.
		when('/', {
			templateUrl: '/partials/index.html',
			controller: 'IndexController'
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
