pragma solidity ^0.8.0;

import "./NftmindToken.sol";

contract NFTInvite {
    
    struct SalesObject {
        NftmindToken nft;
        string code;
    }

    
    mapping(uint256 => SalesObject) public _salesObjects;
    
    
      function mint(
        uint256 tokenId,
        string memory code,
        address nft
    ) external {
        SalesObject memory obj;
        obj.code = code;
        obj.nft = NftmindToken(nft);
        _salesObjects[tokenId] = obj;
    }
    
    
    function receive(string memory code,uint256 tokenId) external{
        
         SalesObject memory obj = _salesObjects[tokenId];
         require(utilCompareInternal(obj.code,code), "Invalid invitation code");
         
           address _seller = NftmindToken(obj.nft).ownerOf(tokenId);
           address buyer = msg.sender;
         
           NftmindToken(obj.nft).transferFrom(_seller, buyer, tokenId);
        
    }
    
    
    function utilCompareInternal(string memory a, string memory b) internal returns (bool) {
    if (bytes(a).length != bytes(b).length) {
        return false;
    }
    for (uint i = 0; i < bytes(a).length; i ++) {
        if(bytes(a)[i] != bytes(b)[i]) {
            return false;
        }
    }
    return true;
}
    
    
    
}
