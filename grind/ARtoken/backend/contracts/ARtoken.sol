// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ARtoken is ERC721Enumerable {


     constructor() ERC721("CryptoDevs", "AR") {}

    function mint() public {
        
        
        _safeMint(msg.sender, totalSupply());
        
    }
  
   
    


}