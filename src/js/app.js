'use strict';

angular.module('App', ['ui.bootstrap']).controller('AppCtrl', function($scope, $http) {
  $scope.countries = {};
  $scope.country = false;
  $scope.country_names = [];
  $http.get('./latest.json').success(function(json) {
    $scope.countries = json.country_zones;
    $scope.country_names = json.country_names;
    $scope.country = false;
  });
  $scope.countrySelected = function(){
    if($scope.selected_country in $scope.countries){
      $scope.country = $scope.countries[$scope.selected_country];
    }else{
      $scope.country = false;
    }
  }
});
