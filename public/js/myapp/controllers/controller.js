/* jshint undef: true, unused: true, devel:true */
/* global angular: true , _: true, sessionStorage: true, angular:true, document: true
*/
var controllerModule = angular.module('myApp.controller', []);


controllerModule.controller('TopBannerController', ['$scope', '$location', 'UserService', function($scope, $location, UserService){
    
    //退出
    $scope.logout = function(){
        UserService.logout().then(function(result){
            result = result.data;

            if (result.code === 0x00){
                sessionStorage.removeItem('user');
                angular.element(document.getElementById('TopBannerController')).scope()._init();
                $location.path('/login');
                $scope.user = null;
            }else{
                alert(result.msg);
            }
        });
    };


    $scope._init = function(){
        var userJson = sessionStorage.user;
        if (userJson){
            $scope.user = JSON.parse(userJson);
        }else{
            $scope.user = null;
        }
    };
    //init
    $scope._init();
}]);

controllerModule.controller('IndexController', ['MenuService', '$scope',
        function(MenuService, $scope) {
            $scope.focused_row = 0;
            var user = JSON.parse(sessionStorage.user);

            var isCateA = function(menu){
                return menu.name.link.indexOf('/category/a') !== -1;
            };

            $scope.changeCate = function(idx){
                $scope.focusedIdx = idx;
                $scope.curMenu = $scope.menus[$scope.focusedIdx];
                $scope.isCateA = isCateA($scope.curMenu);
                $scope.focusedMIdx = 0;
                //清空荤素配的用户选择
                $scope._comboCache = {};                
            };

            $scope.changeMerchantIdx = function(idx){
                $scope.focusedMIdx = idx;
            };

            $scope.addSingle = function(food){
                var data = {
                    fid: food.fid,
                    bid: food.bid,
                    audit:{
                        foods: food.name,
                        username: user.username
                    }
                };

                MenuService.singleAdd(data).then(function(result){
                    result = result.data;

                    if (result.code === 0x00){
                        alert('添加成功');
                    }else{
                        alert('添加失败');
                    }
                });
            };


            $scope.chkCombo = function($event, bid, type, food){
                var fid = food.form_value;

                if (typeof $scope._comboCache[bid] === 'undefined' || $scope._comboCache[bid] === null){
                    $scope._comboCache[bid] = {};
                }
                var _ref = $scope._comboCache[bid];
                if (typeof _ref[type] === 'undefined' || _ref[type] === null){
                    _ref[type] = [];
                }

                if (type === 3){//主食
                    _ref[type] = [];
                    _ref[type].push(food);
                }else{
                    var idx = -1;
                    for (var _i = 0; _i<_ref[type].length; _i++){
                        var _e = _ref[type][_i];
                        if (_e.form_value === fid){
                            idx = _i;
                        }

                    }

                    if (idx === -1){
                        _ref[type].push(food);
                    }else{
                        _ref[type].splice(idx, 1);
                    }
                }
            };

            $scope.comboAdd = function(bid){
                var _ref =  $scope._comboCache[bid];
                if (!_ref){
                    return;
                }

                _ref[1] = _ref[1] || [];
                _ref[2] = _ref[2] || [];
                _ref[3] = _ref[3] || [];

                var concated = [].concat(_ref[1], _ref[2]);

                if (concated.length < 2){
                    alert('请选择至少2个菜');
                    return;
                }

                if (concated.length > 3){
                    alert('最多选3个菜');
                    return;
                }

                if (_ref[3].length === 0){
                    alert('请选择主食');
                    return;
                }

                var postdata = {
                    bid: bid,
                    zhushi: _ref[3][0].form_value
                };

                postdata.foodIds = _.map(concated, function(_e){
                    return _e.form_value;
                });

                postdata.audit = {
                    foods: _.map(concated, function(_e){ return _e.name; }).concat(_ref[3][0].name).join(','),
                    username: user.username
                };

                console.log('postdata for combo is: ' + JSON.stringify(postdata));

                MenuService.comboAdd(postdata).then(function(result){
                    result = result.data;

                    if (result.code === 0x00){
                        alert('添加成功');
                    }else{
                        alert('添加失败: ' + result.msg);
                    }
                });
            };

            //init page
            MenuService.list().then(function(data) {
                $scope.menus = data.data;
                $scope.changeCate(0);
            });
        }
    ]
);

controllerModule.controller('LoginController', ['$scope', 'UserService', '$location', function($scope, UserService, $location){

    $scope.submit = function(){
        UserService.login($scope.username).then(function(result){
            result = result.data;

            if (result.code === 0x00){
                //sessionStorage does not support object, only string it seems
                sessionStorage.user = JSON.stringify(result.data);
                $location.path('/');
                angular.element(document.getElementById('TopBannerController')).scope()._init();
            }else{
                alert(result.msg);
            }
        });
    };


    $scope.isInvalid = function(){
        if (!$scope.username){
            return true;
        }

        return false;
    };

    //load users
    UserService.list().then(function(result){
        result = result.data;

        $scope.users = result;
    });

}]);


controllerModule.controller('OrderTodayController', ['$scope', 'CommonService', function($scope, CommonService){
    CommonService.auditlogs().then(function(result){
        result = result.data;

        if (result.code === 0x00 && result.data.length !== 0){
            $scope.datas = _.map(result.data, function(_e){
                var body = JSON.parse(_e.body);
                body.createdTime = new Date(_e.createdTime);
                return body;
            });
        }
    });
}]);

controllerModule.controller('UserListController', ['$scope', 'UserService', function($scope, UserService){
    UserService.list().then(function(result){
        $scope.users = result.data;
    });
}]);

controllerModule.controller('DBUpdatorController', ['$scope', 'CommonService', function($scope, CommonService){
    CommonService.updatedb().then(function(result){
        result = result.data;
        $scope.result = result.data;
    });
}]);