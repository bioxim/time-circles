// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITicleToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

/**
 * @title ArenaRegistryV2
 * @dev Administra las partidas de la "Snake Arena" donde los jugadores
 * apuestan 1 TICLE cada uno. Se requieren 25 jugadores para comenzar.
 * El ganador recibe los 25 TICLE acumulados.
 * También controla la cantidad máxima de partidas diarias por Tier.
 */
contract ArenaRegistryV2 is Ownable {
    ITicleToken public ticleToken;

    uint256 public constant ENTRY_FEE = 1 * 1e18; // 1 TICLE por jugador
    uint256 public constant PLAYERS_PER_MATCH = 25;
    uint256 public constant PRIZE_POOL = 25 * 1e18; // siempre 25 TICLE
    uint256 public nextMatchId = 1;

    struct MatchInfo {
        uint256 id;
        address[] players;
        bool started;
        address winner;
        uint256 timestamp;
    }

    // tier 1 = 1 partida/día, tier 2 = 2, tier 3 = 3
    mapping(address => uint8) public playerTier;
    mapping(address => uint8) public playsToday;
    mapping(address => uint256) public lastPlayDay;

    mapping(uint256 => MatchInfo) public matches;
    uint256 public currentMatchPlayers;
    address[] public waitingPlayers;

    event PlayerJoined(address indexed player, uint8 tier);
    event MatchStarted(uint256 indexed matchId, address[] players);
    event MatchFinished(uint256 indexed matchId, address indexed winner, uint256 prize);

    constructor(address _ticleToken) Ownable(msg.sender) {
        require(_ticleToken != address(0), "invalid TICLE");
        ticleToken = ITicleToken(_ticleToken);
    }

    /// @notice Asignar el Tier de un jugador según su nivel o inversión (admin)
    function setPlayerTier(address player, uint8 tier) external onlyOwner {
        require(tier >= 1 && tier <= 3, "invalid tier");
        playerTier[player] = tier;
    }

    /// @notice Permite a un jugador unirse a la cola para jugar
    function joinArena() external {
        require(playerTier[msg.sender] > 0, "tier not set");
        _checkDailyLimit(msg.sender);

        // cobra 1 TICLE al jugador
        bool success = ticleToken.transferFrom(msg.sender, address(this), ENTRY_FEE);
        require(success, "TICLE transfer failed");

        waitingPlayers.push(msg.sender);
        currentMatchPlayers++;

        emit PlayerJoined(msg.sender, playerTier[msg.sender]);

        // Si hay 25 jugadores, se inicia una nueva partida
        if (currentMatchPlayers == PLAYERS_PER_MATCH) {
            _startMatch();
        }
    }

    /// @dev Interno: inicia la partida cuando hay 25 jugadores
    function _startMatch() internal {
        uint256 matchId = nextMatchId++;
        MatchInfo storage m = matches[matchId];
        m.id = matchId;
        m.players = waitingPlayers;
        m.started = true;
        m.timestamp = block.timestamp;

        emit MatchStarted(matchId, waitingPlayers);

        // limpiar cola
        delete waitingPlayers;
        currentMatchPlayers = 0;
    }

    /// @notice Registrar el ganador de una partida (puede ser por backend)
    function registerWinner(uint256 matchId, address winner) external onlyOwner {
        MatchInfo storage m = matches[matchId];
        require(m.started, "match not started");
        require(m.winner == address(0), "winner already set");
        require(winner != address(0), "invalid winner");

        m.winner = winner;

        // entrega el premio fijo de 25 TICLE
        bool success = ticleToken.transfer(winner, PRIZE_POOL);
        require(success, "reward transfer failed");

        emit MatchFinished(matchId, winner, PRIZE_POOL);
    }

    /// @dev Control de límite diario de partidas según el Tier
    function _checkDailyLimit(address player) internal {
        uint256 today = block.timestamp / 1 days;

        if (lastPlayDay[player] < today) {
            // resetea contador si es un nuevo día
            lastPlayDay[player] = today;
            playsToday[player] = 0;
        }

        uint8 limit = playerTier[player]; // 1, 2 o 3 partidas diarias
        require(playsToday[player] < limit, "daily limit reached");

        playsToday[player]++;
    }

    /// @notice Devuelve la lista de jugadores en espera
    function getWaitingPlayers() external view returns (address[] memory) {
        return waitingPlayers;
    }
}
