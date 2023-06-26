// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
contract RandomWinnerGame  is VRFConsumerBase, Ownable {
    uint public fee;
    uint public  gameId = 0;
    uint public maxPlayers;
    bool public gameStarted;
    uint256 public entryFee;
    address [] public players;
    bytes32 public keyHash;


    constructor(address vrfCoordinator, address linkToken,
    bytes32 vrfKeyHash, uint256 vrfFee)
    VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }
    event GameStarted(uint gameId,uint maxPlayers,uint entryFeefee);
    event PlayerJoined(uint256 gameId, address player);
     event GameEnded(uint256 gameId, address winner,bytes32 requestId);


     function startGame(uint _maxPlayers,uint _entryFee) public onlyOwner(){
        require(gameStarted==false,'game already running');
         require(_maxPlayers > 0, "You cannot create a game with max players limit equal 0");
         delete players;
         maxPlayers=_maxPlayers;
         _entryFee=entryFee;
         gameId+=1;
         gameStarted=true;
        emit GameStarted(gameId, maxPlayers, entryFee);



     }
     function joinGamme() public payable{
        require(gameStarted, "Game has not been started yet");
        require(msg.value == entryFee, "Value sent is not equal to entryFee");
        require(players.length < maxPlayers, "Game is full");
        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);
        if(players.length == maxPlayers) {
            getRandomWinner();
        }

     }

     function getRandomWinner() private returns (bytes32 requestId)  {
          require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
          return requestRandomness(keyHash, fee);
     }

     function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual  override {
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
         (bool sent,) = winner.call{value: address(this).balance}("");
         require(sent,"transaction failed");
         emit GameEnded(gameId, winner,requestId);
        gameStarted=false;
     }


    
    receive() external payable {}

    fallback() external payable {}

    
}
