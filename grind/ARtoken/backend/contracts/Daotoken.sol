// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOToken is ERC721Enumerable {
    constructor() ERC721("DAOToken", "DT") {}


    function mint() public payable  {
        require(msg.value==0.02 ether,"send 0.02 ether");
        _mint(msg.sender, totalSupply());
    }
}