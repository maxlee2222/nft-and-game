// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryGame is VRFConsumerBaseV2, Ownable {

    event GameStarted(uint256 gameId, uint256 minimumFeem, uint256 minimumAward);
    event GameEnded(uint256 gameId, bool isExecuted, address winner);

    VRFCoordinatorV2Interface COORDINATOR;
    uint256 public random;

    uint64 s_subscriptionId;
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 s_keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 250000;
    uint32 numWords = 1;

    uint256[] public requestIds;
    
    uint256 public fee = 0.001 ether;
    uint256 public minimumAward = 0.002 ether;
    bool public isGameStarted;
    uint256 public endedTime;
    uint256 public gameDuration = 120;

    address[] public participants;
    mapping(address => bool) public isParticipated;

    modifier gameStarted {
        require(isGameStarted, "game does not start yet");
        _;
    }

    modifier gameNotStarted {
        require(!isGameStarted, "game is already started");
        _;
    }

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
    }

    function startGame() public onlyOwner gameNotStarted {
        isGameStarted = true;
        endedTime = block.timestamp + gameDuration;
    }

    function enter() public payable gameStarted {
        require(msg.value == fee, "Ether does not match fee");
        require(!isParticipated[msg.sender], "You are in this game");
        require(block.timestamp < endedTime, "game is finished");
        participants.push(msg.sender);
        isParticipated[msg.sender] = true;
    }

    function endGame() public onlyOwner gameStarted {
        require(block.timestamp >= endedTime, "game is not ended yet");
        uint256 participatedNum = participants.length;

        if (participatedNum * fee < minimumAward) {
            for(uint256 i = 0; i < participatedNum; i++) {
                address receiver = participants[i];
                sendEther(receiver, fee);
            }
            resetGame();
        } else {
            getRandomNumber();
        }
    }

    function pickWinner() public onlyOwner gameStarted {
        require(random != 0, "random not initialize.");

        uint256 participatedNum = participants.length;
        uint256 winnerIdx = random % participatedNum;
        address wiinner = participants[winnerIdx];
        sendEther(wiinner, participatedNum * fee);
        resetGame();
    }

    function resetGame() internal {
        isGameStarted = false;

        for(uint256 i = 0; i < participants.length; i++) {
            delete isParticipated[participants[i]];
        }

        participants = new address[](0);
        random = 0;
    }

    function sendEther(address receiver, uint256 _value) internal {
        (bool sent, ) = receiver.call{value: _value}("");
        require(sent, "Failed to send Ether");
    }

    function setDuration(uint256 _gameDuration) public onlyOwner gameNotStarted {
        gameDuration = _gameDuration;
    }

    function getRandomNumber() public returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        requestIds.push(requestId);
        random = randomWords[0];
    }

    function withdraw () external onlyOwner {
        sendEther(msg.sender, address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}