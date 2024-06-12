// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./critterCoin.sol"; //ABI

contract ignisFox is ERC721URIStorage {

    uint256 private s_tokenCounter;
    address[] public s_claimers;
    uint256 private s_levelOfCreature;

    address payable gameManager;
    critterCoin private _critterCoin;  // Instance of the ERC20 token contract

    string public constant TOKEN_URI = "https://arweave.net/NX8bgt_tAInNCZBghiieHtorhmxTWvPXt4uaIfZsl8s";
 
    mapping(uint256 =>uint256)  tokenToCreatureLevel;
    mapping(address => uint256[] ) ownerToTokenIDs; 

    constructor() ERC721("Ignis Fox","IGNIS"){ 
            claimNFT();
            gameManager=payable(msg.sender);
            _critterCoin = critterCoin(0x25d6890b41f365a1f7EdF959Dc48c116EDEfa453); //Address of Deployed Contract
    }

    //claim NFT

    function claimNFT() public returns(uint256){
        require(alreadyClaimerCheck(msg.sender)==false);
        _safeMint(msg.sender, s_tokenCounter);
        s_claimers.push(msg.sender);
        tokenToCreatureLevel[s_tokenCounter]=1; //inital level 1
        _setTokenURI(s_tokenCounter,TOKEN_URI);
        ownerToTokenIDs[msg.sender].push(s_tokenCounter);
        s_tokenCounter+=1;
        return s_tokenCounter;
    }

    //to check they have already claimed

    function alreadyClaimerCheck(address _sender) public view returns(bool){
        address[] memory claimers = s_claimers;
        for(uint256 i =0;i<claimers.length;i++){
            if(claimers[i]==_sender){
                return true;
            }
        }
        return false;
    }

    //purchase NFT

    function purchaseNFT() public {
        // require(msg.value == 0.001 ether, "Incorrect Value Sent");
        uint256 coinsReq = 100*1e18;  // 10 CritterCoins -> 0.00001 ethers * 100 => 0.001 
        require(_critterCoin.approveContract(msg.sender,address(this),coinsReq), "Approval failed");
        require(_critterCoin.transferFrom(msg.sender, gameManager, coinsReq), "Transfer failed");
        _purchaseNFT();
    }
    
    function _purchaseNFT() private returns(uint256){
        // first NFT token ID = 0
        _safeMint(msg.sender, s_tokenCounter);
        tokenToCreatureLevel[s_tokenCounter]=1;
        _setTokenURI(s_tokenCounter, TOKEN_URI);
        ownerToTokenIDs[msg.sender].push(s_tokenCounter);
        s_tokenCounter+=1;
        return s_tokenCounter;
    }

    //get TokenID //will return array of token-ids of tokens he owns
    function getTokenIDsOwnedByAddress(address _owner) public view returns (uint256[] memory) {
    return ownerToTokenIDs[_owner];
    }

    function upgradeLevelbyPurchase(uint256 _tokenID) public payable {
        require(tokenToCreatureLevel[_tokenID]<=25,"Ignis Fox reached max level, no futher upgradation"); //max level of stage 1 will be 25
        uint256 coinsReq = 20*1e18;  // 10 CritterCoins -> 0.00001 ethers * 20  => 0.0002
        require(_critterCoin.approveContract(msg.sender,address(this),coinsReq), "Approval failed");
        require(_critterCoin.transferFrom(msg.sender, gameManager, coinsReq), "Transfer failed");
        tokenToCreatureLevel[_tokenID]++;
        
    }
    
    function upgradeLevelByExp(uint256 _tokenID,uint256 _exp) public {
        //100 exp =1 level upgrade
        //yahan bhi memory type banale
        require(tokenToCreatureLevel[_tokenID]<=25,"Ignis Fox reached max level, no futher upgradation"); //Max Level 25
        require(_exp==100);
        tokenToCreatureLevel[_tokenID]++;
    }

    function getLevel(uint256 _tokenID) public view returns(uint256){
        return tokenToCreatureLevel[_tokenID];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721,IERC721){
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
 
        if(alreadyClaimerCheck(from)){
            s_claimers.push(to);
            uint256[] storage tokensOwned = ownerToTokenIDs[from]; //Reference to Storage of Array
            uint256  indexOfTokenIdTransfer;

            for(uint i =0;i<tokensOwned.length;i++){
                if(tokensOwned[i]==tokenId){
                    indexOfTokenIdTransfer=i;
                    break;
                }
            }
            for(uint256 i=indexOfTokenIdTransfer;i<tokensOwned.length;i++){
                tokensOwned[i]=tokensOwned[i+1];
            }

             tokensOwned.pop();

        } else {

            uint256[] storage tokensOwned = ownerToTokenIDs[from]; //Reference to Storage of Array
            uint256  indexOfTokenIdTransfer;

            for(uint i =0;i<tokensOwned.length;i++){
                if(tokensOwned[i]==tokenId){
                    indexOfTokenIdTransfer=i;
                    break;
                }
            }
            for(uint256 i=indexOfTokenIdTransfer;i<tokensOwned.length;i++){
                tokensOwned[i]=tokensOwned[i+1];
            }

             tokensOwned.pop();
        }
    }
 
}
