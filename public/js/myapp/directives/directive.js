var directiveModule = angular.module('myapp.directive', []);

//create a hello world demo directive
directiveModule.directive('helloworld', function(){
    /*
    restrict:
        'E': only match tag name
        'A': only match tag attribute
    template: template string
    templateUrl: url of this directive template
    replace:
        If true, replace the current element. If false or unspecified, append this directive to the current element.
    */
    return {
        restrict: 'E',
        template: '<div>Hello world</div>',
        replace: true
    };
});
//copy from: http://stackoverflow.com/questions/17144180/angularjs-loading-screen-on-ajax-request
directiveModule.directive('loading', ['$http', function($http) {
    return {
        restrict: 'A',
        link: function(scope, elm, attrs) {
            scope.isLoading = function() {
                return $http.pendingRequests.length > 0;
            };

            scope.$watch(scope.isLoading, function(v) {
                if (v) {
                    elm.show();
                } else {
                    elm.hide();
                }
            });
        }
    };

}]);
