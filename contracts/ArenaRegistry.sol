// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ArenaRegistry is Ownable {
    IERC20 public ticleToken;
    address public devWallet;

    uint256 public constant ENTRY_FEE = 1 * 1e18;
    uint256 public constant MAX_PLAYERS = 25;

    struct Arena {
        uint256 id;
        address[] players;
        bool active;
        address winner;
    }

    uint256 public nextArenaId = 1;
    mapping(uint256 => Arena) public arenas;

    event ArenaCreated(uint256 id);
    event PlayerJoined(uint256 id, address player);
    event WinnerSelected(uint256 id, address winner, uint256 reward, uint256 fee);
    event DevWalletUpdated(address newWallet);

    constructor(address _ticleToken, address _devWallet) Ownable(msg.sender) {
        require(_ticleToken != address(0), "invalid ticle token");
        require(_devWallet != address(0), "invalid dev wallet");
        ticleToken = IERC20(_ticleToken);
        devWallet = _devWallet;
    }

    function createArena() external returns (uint256) {
        uint256 id = nextArenaId++;
        arenas[id].id = id;
        arenas[id].active = true;
        emit ArenaCreated(id);
        return id;
    }

    function joinArena(uint256 id) external {
        Arena storage a = arenas[id];
        require(a.active, "arena inactive");
        require(a.players.length < MAX_PLAYERS, "arena full");

        // cobrar 1 TICLE
        ticleToken.transferFrom(msg.sender, address(this), ENTRY_FEE);
        a.players.push(msg.sender);
        emit PlayerJoined(id, msg.sender);

        // cuando llega a 25 jugadores, cerrar arena
        if (a.players.length == MAX_PLAYERS) {
            a.active = false;
        }
    }

    function finalizeArena(uint256 id, address winner) external onlyOwner {
        Arena storage a = arenas[id];
        require(!a.active, "arena still active");
        require(a.winner == address(0), "already finalized");

        uint256 totalPot = ENTRY_FEE * MAX_PLAYERS;
        uint256 fee = ENTRY_FEE; // 1 TICLE para devWallet
        uint256 reward = totalPot - fee;

        a.winner = winner;

        ticleToken.transfer(winner, reward);
        ticleToken.transfer(devWallet, fee);

        emit WinnerSelected(id, winner, reward, fee);
    }

    function setDevWallet(address _newDevWallet) external onlyOwner {
        require(_newDevWallet != address(0), "invalid");
        devWallet = _newDevWallet;
        emit DevWalletUpdated(_newDevWallet);
    }
}