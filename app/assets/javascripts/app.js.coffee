# Define App and dependencies
HangmanApp = angular.module("HangmanApp", ["ngRoute", "templates", "ui.bootstrap", "modals.newGame", "modals.message"])

# Setup the angular router
HangmanApp.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
	$routeProvider
	 .when '/',
      templateUrl: "index.html",
      controller: "MainCtrl"
	.otherwise
			redirectTo: "/"

	$locationProvider.html5Mode(true)

]

#Controllers
HangmanApp.controller "MainCtrl", ["$scope", "$modal", ($scope, $modal) ->

  window.scope = $scope

  $scope.letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
  $scope.points = 0

  openMessageModal = (header, message, onSuccess) ->
    onSuccess = onSuccess or ->

    modalInstance = $modal.open(
      templateUrl: "modals/message.html"
      controller: "MessageCtrl"
      resolve:
        message: ->
          message

        header: ->
          header
    )
    modalInstance.result.then onSuccess

  openNewGameModal = ->

    modalInstance = $modal.open(
      templateUrl: "modals/new-game.html"
      controller: "NewGameCtrl"
    )
    modalInstance.result.then (word) ->
      $scope.startNewGame word

  openNewGameModal()
  $scope.startNewGame = (providedWord) ->
    $scope.word = []
    providedWord.split("").forEach (letter) ->
      $scope.word.push
        name: letter
        guessed: false

    $scope.points = 0
    $scope.gameLetters = $scope.letters.slice()

  $scope.check = (guess) ->
    $scope.gameLetters.splice $scope.gameLetters.indexOf(guess), 1
    correct = false
    $scope.word.forEach (letter) ->
      if letter.name is guess
        letter.guessed = true
        correct = true

    unless correct
      $scope.points++
      if $scope.points is 6
        openMessageModal "Sorry", "You lose", ->
          openNewGameModal()

    if _.every($scope.word, (letter) ->
      letter.guessed
    )
      openMessageModal "Congratulations!", "You won!", ->
        openNewGameModal()

    $scope.guess = ""

]

angular.module('modals.newGame', [])

.controller 'NewGameCtrl', ["$scope", "$modalInstance", ($scope, $modalInstance) ->
  $scope.submit = (word) ->
    $modalInstance.close(word);
]

angular.module('modals.message', [])

.controller 'MessageCtrl', ["$scope", "$modalInstance", ($scope, $modalInstance, message, header) ->
  console.log message
  console.log header
  $scope.message = "Game Over!";
  $scope.header = header;
  $scope.close = ->
    $modalInstance.close();
]

# Define Config for CSRF token
HangmanApp.config ["$httpProvider", ($httpProvider)->
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]

HangmanApp.filter 'letters', ->
  (word) ->
    word.split('')
