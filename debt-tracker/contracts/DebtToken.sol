// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// tokenul de datorii, basic ERC20
contract DebtToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Debt Token", "DEBT") {}

    // mintam tokeni doar daca esti owner, gen deployer sau cine are drepturi
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}