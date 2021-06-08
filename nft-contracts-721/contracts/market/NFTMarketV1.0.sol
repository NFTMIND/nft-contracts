pragma solidity ^0.8.0;

import "./NftmindToken.sol";

contract NFTMarket {
    struct SalesObject {
        uint256 price;
        NftmindToken nft;
    }

    mapping(uint256 => SalesObject) public _salesObjects;

    function mint(
        uint256 price,
        address player,
        string memory tokenURI,
        address nft
    ) public returns (uint256) {
        uint256 tokenId = NftmindToken(nft).awardItem(player, tokenURI);
        SalesObject memory obj;
        obj.price = price;
        obj.nft = NftmindToken(nft);
        _salesObjects[tokenId] = obj;
        return tokenId;
    }

    function buy(uint256 tokenId) external payable {
        SalesObject memory obj = _salesObjects[tokenId];
        address _seller = NftmindToken(obj.nft).ownerOf(tokenId);
        address buyer = msg.sender;
        NftmindToken(obj.nft).transferFrom(_seller, buyer, tokenId);
        address payable seller = _make_payable(_seller);
        uint256 buyAmount = obj.price;
        seller.transfer(buyAmount);
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }
}
