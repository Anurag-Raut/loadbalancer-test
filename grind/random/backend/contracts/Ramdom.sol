// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Random is VRFConsumerBase, Ownable {


    uint256 public fee;
    bytes32 public keyHash;

    address[] public players;
    uint256 public maxPlayers;
    bool public gameStarted;
    uint256 public entryFee;
    uint256 public gameId;

    // emitted when the game starts
    event GameStarted(uint256 gameId, uint256 maxPlayers, uint256 entryFee);
    // emitted when someone joins a game
    event PlayerJoined(uint256 gameId, address player);
    // emitted when the game ends
    event GameEnded(uint256 gameId, address winner,bytes32 requestId);


   constructor() 
        VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255,
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB
        ) public
    {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 100000000000000; // 0.0001 LINK
    }

    /**
    * startGame starts the game by setting appropriate values for all the variables
    */
    function startGame(uint256 _maxPlayers, uint256 _entryFee) public onlyOwner {
        // Check if there is a game already running
        require(!gameStarted, "Game is currently running");
        // Check if _maxPlayers is greater than 0
        require(_maxPlayers > 0, "You cannot create a game with max players limit equal 0");
        // empty the players array
        delete players;
        // set the max players for this game
        maxPlayers = _maxPlayers;
        // set the game started to true
        gameStarted = true;
        // setup the entryFee for the game
        entryFee = _entryFee;
        gameId += 1;
        emit GameStarted(gameId, maxPlayers, entryFee);
    }


    function joinGame() public payable {
        require(gameStarted==true, "Game has not been started yet");
        require(msg.value >= entryFee, "Value sent is not equal to entryFee");
        require(players.length < maxPlayers, "Game is full");
        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);
        if(players.length == maxPlayers) {
            getRandomWinner();
        }
    }
    function endGame() public {
        gameStarted=false;
        
    }

   
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override  {

        uint256 winnerIndex = randomness % players.length;
        
        address winner = players[winnerIndex];

        (bool sent,) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");

        emit GameEnded(gameId, winner,requestId);
      
        gameStarted = false;
    }

    /**
    * getRandomWinner is called to start the process of selecting a random winner
    */
    function getRandomWinner() public returns (bytes32 requestId) {

        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
      
        return requestRandomness(keyHash, fee);
    }


    receive() external payable {}

    fallback() external payable {}
}
