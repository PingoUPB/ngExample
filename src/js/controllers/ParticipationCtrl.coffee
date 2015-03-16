# pingoVote = angular.module "pingoVote"

pingoVote.controller "ParticipationController", ($scope, $http) ->
	
	$http.get("choice.json").success (data) ->
		$scope.event = data
	
	$scope.sendVote = (option) ->
		if option 
			window.alert option.name
		else 
			window.alert "Bitte eine Antwort wählen! "
		
