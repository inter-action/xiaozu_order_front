/* jshint undef: true, unused: true, devel:true */
/* global angular: true , _: true
*/
var controllerModule = angular.module('myApp.controller', []);

controllerModule.controller('IndexController', ['MenuService', '$scope',
        function(MenuService, $scope) {
            $scope.focused_row = 0;

            //init page
            var loadPage = function() {
                MenuService.list().then(function(data) {
                    $scope.menus = data.data;
                    $scope.changeCate(0);
                });
            };

            var isCateA = function(menu){
                return menu.name.link.indexOf('/category/a') !== -1;
            };

            $scope.changeCate = function(idx){
                $scope.focusedIdx = idx;
                $scope.curMenu = $scope.menus[$scope.focusedIdx];
                $scope.isCateA = isCateA($scope.curMenu);

                //清空荤素配的用户选择
                $scope._comboCache = {};                
            };

            $scope.addSingle = function(food){
                var data = {
                    fid: food.fid,
                    bid: food.bid
                };

                MenuService.singleAdd(data).then(function(result){
                    result = result.data;

                    if (result.success){
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

                console.log('postdata for combo is: ' + JSON.stringify(postdata));

                MenuService.comboAdd(postdata).then(function(result){
                    result = result.data;

                    if (result.success){
                        alert('添加成功');
                    }else{
                        alert('添加失败');
                    }
                });
            };

            //init page
            loadPage();
        }
    ]
);