// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITicleToken {
    function mint(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
}

contract CircleContract is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stableToken;
    ITicleToken public ticleToken;
    address public devWallet;

    uint256 public constant CIRCLE_PARTICIPANTS = 5;
    uint256 public constant CYCLE_DAYS = 25;
    uint256 public secondsPerDay = 1 days;

    uint256 public tier1Min = 100 * 1e6;
    uint256 public tier2Min = 501 * 1e6;
    uint256 public tier3Min = 1001 * 1e6;

    uint256 public tier1DailyReward = 1 * 1e18;
    uint256 public tier2DailyReward = 2 * 1e18;
    uint256 public tier3DailyReward = 3 * 1e18;

    uint256 public maxTicleSupply = 100_000_000 * 1e18;
    uint256 public joinFeeBps = 100; // 1% = 100 basis points

    struct Circle {
        uint256 id;
        address[] participants;
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

    event CircleCreated(uint256 indexed circleId);
    event JoinedCircle(uint256 indexed circleId, address indexed user, uint256 amount, uint256 fee);
    event CircleStarted(uint256 indexed circleId, uint256 startTimestamp);
    event DailyDistributed(uint256 indexed circleId, uint8 dayIndex, uint256 mintedTotal);
    event PrincipalWithdrawn(uint256 indexed circleId, address indexed user, uint256 amount);
    event DevWalletUpdated(address indexed newWallet);

    constructor(address _stableToken, address _ticleToken, address _devWallet, uint256 _secondsPerDay) Ownable(msg.sender) {
        require(_stableToken != address(0), "invalid stable token");
        require(_ticleToken != address(0), "invalid ticle token");
        require(_devWallet != address(0), "invalid dev wallet");
        stableToken = IERC20(_stableToken);
        ticleToken = ITicleToken(_ticleToken);
        devWallet = _devWallet;
        if (_secondsPerDay > 0) secondsPerDay = _secondsPerDay;
    }

    function createCircle() external returns (uint256) {
        uint256 id = nextCircleId++;
        Circle storage c = circles[id];
        c.id = id;
        circleIds.push(id);
        emit CircleCreated(id);
        return id;
    }

    function joinCircle(uint256 circleId, uint256 amount) external nonReentrant {
        require(amount > 0, "zero amount");
        Circle storage c = circles[circleId];
        require(c.id == circleId, "circle not found");
        require(!c.active, "circle already started");
        require(c.participants.length < CIRCLE_PARTICIPANTS, "circle full");
        require(!c.participated[msg.sender], "already joined");

        uint256 fee = (amount * joinFeeBps) / 10_000;
        uint256 netAmount = amount - fee;

        // fee para devWallet y resto al contrato
        stableToken.safeTransferFrom(msg.sender, devWallet, fee);
        stableToken.safeTransferFrom(msg.sender, address(this), netAmount);

        c.participants.push(msg.sender);
        c.deposits[msg.sender] = netAmount;
        c.participated[msg.sender] = true;

        emit JoinedCircle(circleId, msg.sender, netAmount, fee);
    }

    // resto del contrato igual...
    // [omitido por espacio — la lógica de distribuciones y retiros no cambia]

    function setDevWallet(address _newDevWallet) external onlyOwner {
        require(_newDevWallet != address(0), "invalid");
        devWallet = _newDevWallet;
        emit DevWalletUpdated(_newDevWallet);
    }
}