// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicleToken is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**18; // 100M TICLE
    address public circleContract;
    bool public initialMintDone = false; // evita doble mint inicial

    constructor() ERC20("TiCles Token", "TICLE") Ownable(msg.sender) {}

    modifier onlyCircle() {
        require(msg.sender == circleContract, "Not authorized");
        _;
    }

    /// @notice Set the Circle contract authorized to mint rewards
    function setCircleContract(address _circle) external onlyOwner {
        require(_circle != address(0), "invalid address");
        circleContract = _circle;
    }

    /// @notice Mint new TICLEs for daily rewards (only CircleContract)
    function mint(address to, uint256 amount) external onlyCircle {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply reached");
        _mint(to, amount);
    }

    /// @notice Mint initial supply once for liquidity or setup (only owner)
    function mintInitial(address to, uint256 amount) external onlyOwner {
        require(!initialMintDone, "Initial mint already done");
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply reached");
        require(to != address(0), "invalid address");

        initialMintDone = true;
        _mint(to, amount);
    }
}
