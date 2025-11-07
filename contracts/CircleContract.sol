// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaz mínima para el token TICLE
interface ITicleToken {
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
}

contract CircleContract is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // ======= Configurable =======
    IERC20 public stableToken;      // Token estable usado para depositar (USDC o USDT)
    ITicleToken public ticleToken;  // Contrato TICLE (permite mint)
    uint256 public constant CIRCLE_PARTICIPANTS = 5;
    uint256 public constant CYCLE_DAYS = 25;
    uint256 public secondsPerDay = 1 days; // parámetro ajustable (útil para testnet)

    // Umbrales de tiers y recompensas diarias (en TICLE)
    uint256 public tier1Min = 100 * 1e6;  // USDC tiene 6 decimales
    uint256 public tier2Min = 501 * 1e6;
    uint256 public tier3Min = 1001 * 1e6;

    uint256 public tier1DailyReward = 1 * 1e18; // TICLE tiene 18 decimales
    uint256 public tier2DailyReward = 2 * 1e18;
    uint256 public tier3DailyReward = 3 * 1e18;

    // Límite máximo (solo informativo, la verificación real está en el token)
    uint256 public maxTicleSupply = 100_000_000 * 1e18;

    // ======= Circle Data =======
    struct Circle {
        uint256 id;
        address[] participants; // hasta 5
        mapping(address => uint256) deposits; 
        mapping(address => bool) participated;
        uint256 startTimestamp;
        uint256 lastDistribTimestamp;
        uint8 dayIndex;
        bool active;
    }

    uint256 public nextCircleId = 1;
    mapping(uint256 => Circle) private circles;
    uint256[] public circleIds;

    // ======= Events =======
    event CircleCreated(uint256 indexed circleId);
    event JoinedCircle(uint256 indexed circleId, address indexed user, uint256 amount);
    event CircleStarted(uint256 indexed circleId, uint256 startTimestamp);
    event DailyDistributed(uint256 indexed circleId, uint8 dayIndex, uint256 mintedTotal);
    event PrincipalWithdrawn(uint256 indexed circleId, address indexed user, uint256 amount);

    // ======= Constructor =======
    constructor(address _stableToken, address _ticleToken, uint256 _secondsPerDay) Ownable(msg.sender) {
        require(_stableToken != address(0), "invalid stable token");
        require(_ticleToken != address(0), "invalid ticle token");
        stableToken = IERC20(_stableToken);
        ticleToken = ITicleToken(_ticleToken);
        if (_secondsPerDay > 0) secondsPerDay = _secondsPerDay;
    }

    // ======= Core Functions =======

    /// @notice Crear un nuevo círculo (reserva ID)
    function createCircle() external returns (uint256) {
        uint256 id = nextCircleId++;
        Circle storage c = circles[id];
        c.id = id;
        c.active = false;
        c.dayIndex = 0;
        circleIds.push(id);
        emit CircleCreated(id);
        return id;
    }

    /// @notice Unirse al círculo depositando el token estable
    function joinCircle(uint256 circleId, uint256 amount) external nonReentrant {
        require(amount > 0, "zero amount");
        Circle storage c = circles[circleId];
        require(c.id == circleId, "circle not found");
        require(!c.active, "circle already started");
        require(c.participants.length < CIRCLE_PARTICIPANTS, "circle full");
        require(!c.participated[msg.sender], "already joined");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);
        c.participants.push(msg.sender);
        c.deposits[msg.sender] = amount;
        c.participated[msg.sender] = true;

        emit JoinedCircle(circleId, msg.sender, amount);
    }

    /// @notice Iniciar ciclo cuando haya 5 participantes
    function startCircle(uint256 circleId) external {
        Circle storage c = circles[circleId];
        require(c.id == circleId, "circle not found");
        require(!c.active, "already active");
        require(c.participants.length == CIRCLE_PARTICIPANTS, "need 5 participants");

        c.active = true;
        c.startTimestamp = block.timestamp;
        c.lastDistribTimestamp = block.timestamp;
        c.dayIndex = 0;

        emit CircleStarted(circleId, c.startTimestamp);
    }

    /// @notice Distribuye recompensas diarias en TICLE según el tier
    function distributeDaily(uint256 circleId) external nonReentrant {
        Circle storage c = circles[circleId];
        require(c.id == circleId, "circle not found");
        require(c.active, "circle not active");
        require(c.dayIndex < CYCLE_DAYS, "cycle finished");

        uint256 elapsed = block.timestamp - c.lastDistribTimestamp;
        require(elapsed >= secondsPerDay, "too soon to distribute");

        uint256 mintedTotal = 0;

        for (uint256 i = 0; i < c.participants.length; i++) {
            address participant = c.participants[i];
            uint256 deposit = c.deposits[participant];
            uint256 reward = _tierRewardForDeposit(deposit);

            if (reward > 0) {
                uint256 supply = ticleToken.totalSupply();
                if (supply + reward <= maxTicleSupply) {
                    ticleToken.mint(participant, reward);
                    mintedTotal += reward;
                }
            }
        }

        c.dayIndex += 1;
        c.lastDistribTimestamp = block.timestamp;
        emit DailyDistributed(circleId, c.dayIndex, mintedTotal);
    }

    /// @notice Permite retirar el capital original al finalizar el ciclo
    function withdrawPrincipal(uint256 circleId) external nonReentrant {
        Circle storage c = circles[circleId];
        require(c.id == circleId, "circle not found");
        require(c.dayIndex >= CYCLE_DAYS, "cycle not finished");
        require(c.participated[msg.sender], "not participant");

        uint256 amount = c.deposits[msg.sender];
        require(amount > 0, "no deposit");

        c.deposits[msg.sender] = 0;
        c.participated[msg.sender] = false;

        stableToken.safeTransfer(msg.sender, amount);
        emit PrincipalWithdrawn(circleId, msg.sender, amount);
    }

    // ======= Views & Helpers =======

    function getParticipants(uint256 circleId) external view returns (address[] memory) {
        Circle storage c = circles[circleId];
        return c.participants;
    }

    function _tierRewardForDeposit(uint256 deposit) internal view returns (uint256) {
        if (deposit >= tier3Min) return tier3DailyReward;
        else if (deposit >= tier2Min) return tier2DailyReward;
        else if (deposit >= tier1Min) return tier1DailyReward;
        return 0;
    }

    // ======= Admin =======

    function setSecondsPerDay(uint256 s) external onlyOwner {
        require(s > 0, "invalid");
        secondsPerDay = s;
    }

    function setTierThresholds(uint256 t1, uint256 t2, uint256 t3) external onlyOwner {
        tier1Min = t1;
        tier2Min = t2;
        tier3Min = t3;
    }

    function setTierRewards(uint256 r1, uint256 r2, uint256 r3) external onlyOwner {
        tier1DailyReward = r1;
        tier2DailyReward = r2;
        tier3DailyReward = r3;
    }

    function setMaxTicleSupply(uint256 s) external onlyOwner {
        maxTicleSupply = s;
    }

    function rescueStable(address to, uint256 amount) external onlyOwner {
        stableToken.safeTransfer(to, amount);
    }
}
