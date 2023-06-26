// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";
import './Daotoken.sol';
interface INFTmarketPlace{
    function purchase (uint256 _tokenId)  external payable;
    function getPrice() external view returns (uint256);
    function available (uint256 _tokenId) external view returns(bool);
}
interface IARtoken {
    /// @dev balanceOf returns the number of NFTs owned by the given address
    /// @param owner - address to fetch number of NFTs for
    /// @return Returns the number of NFTs owned
    function balanceOf(address owner) external view returns (uint256);

    /// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
    /// @param owner - address to fetch the NFT TokenID for
    /// @param index - index of NFT in owned tokens array to fetch
    /// @return Returns the TokenID of the NFT
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}

contract DAO is Ownable{
    
    struct Proposal{
  
        uint256 nftTokenId;   
        uint256 deadline;        
        uint256 PosVotes;    
        uint256 NegVotes;        
        bool executed;    
        mapping(uint256 => bool) voters;

    }
  
    INFTmarketPlace marketplace;
    IARtoken artoken;
    DAOToken daotoken;
     mapping (uint256=>Proposal) public proposals;
     uint256 public totalProposals=0;
    constructor (address _nftMarketplace, address _artoken,address _daotoken){
        marketplace=INFTmarketPlace(_nftMarketplace);
        artoken=IARtoken(_artoken);
        daotoken=DAOToken(_daotoken);

    }

    modifier NFTholderonly(){
        require(daotoken.balanceOf(msg.sender)>0,"you dont hold the nft");
        _;
    }
   
    function CreateProposal(uint _tokenId,uint _deadline )public NFTholderonly {


        Proposal storage newproposal =proposals[totalProposals];
        newproposal.deadline=_deadline;
        newproposal.nftTokenId=_tokenId;
        totalProposals++;
    }
    function vote(uint256 _proposalId,bool _vote) public NFTholderonly {
  
        require(_proposalId<totalProposals,"proposal doesn't exits");
        require(proposals[_proposalId].executed==false,'Proposal already executed');
         require(
        proposals[_proposalId].deadline > block.timestamp,
        "DEADLINE_EXCEEDED"
    );
        uint256 numvotes=0;
        Proposal storage proposal = proposals[_proposalId];
        for(uint i=0;i<daotoken.balanceOf(msg.sender);i++){
              uint256 tokenId = daotoken.tokenOfOwnerByIndex(msg.sender, 0);
              if (proposal.voters[tokenId] == false) {
                    numvotes++;
                    proposal.voters[tokenId] = true;
                }

        }
       
            // uint256 tokenId = artoken.tokenOfOwnerByIndex(msg.sender, 0);
     
         
          require(numvotes > 0, "ALREADY_VOTED");
        if(_vote==true){
            proposals[_proposalId].PosVotes+=numvotes;
        }
        else{
             proposals[_proposalId].NegVotes+=numvotes;
        }

        


       

    }

    function executeProposal(uint256 proposalIndex)external
    NFTholderonly{
    Proposal storage proposal = proposals[proposalIndex];
     require(
        proposals[proposalIndex].deadline <= block.timestamp,
        "DEADLINE_EXCEEDED"
    );

    // If the proposal has more YAY votes than NAY votes
    // purchase the NFT from the FakeNFTMarketplace
    if (proposal.PosVotes > proposal.NegVotes) {
        uint256 nftPrice = marketplace.getPrice();
        require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
        marketplace.purchase{value: nftPrice}(proposal.nftTokenId);
    }
    proposal.executed = true;
}

function withdrawEther() external onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "Nothing to withdraw, contract balance empty");
    (bool sent, ) = payable(owner()).call{value: amount}("");
    require(sent, "FAILED_TO_WITHDRAW_ETHER");
}


receive() external payable {}
}