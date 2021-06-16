pragma solidity ^0.8.0;

import "./NftmindToken.sol";

contract NFTMarket {
    struct SalesObject {
        uint256 price;
        NftmindToken nft;
        uint256 payAmount;
        uint256 copyrightAmount;
        address creator;
    }

    struct TransactionObject {
        address buyer;
        address seller;
        uint256 price;
        uint256 tokenId;
        uint256 time;
        uint256 copyrightAmount;
        uint256 serviceAmount;
    }

    event eveNewSales(uint256 tokenId);


    uint256 private  _serviceCharge = 0;
    address private _gathering = 0x582668B2272CeF9c6de655d08beB97bfFc197Bc1;


    event eveTransaction(
      uint256 tokenId,
      uint256 payAmount,
      uint256 copyrightAmount,
      uint256 copyright,
      address buyer,
      address seller,
      uint256 payTime,
      uint256 serviceAmount
    );

    TransactionObject[] _transactionObject;

    mapping(uint256 => SalesObject) public _salesObjects;


    function mint(
        uint256 price,
        uint256 copyrightAmount,
        address player,
        string memory tokenURI,
        address nft
    ) public returns (uint256) {
        uint256 tokenId = NftmindToken(nft).awardItem(player, tokenURI);
        SalesObject memory obj;
        obj.price = price;
        obj.creator = player;
        obj.copyrightAmount = copyrightAmount;
        obj.nft = NftmindToken(nft);
        _salesObjects[tokenId] = obj;
        emit eveNewSales(tokenId);
        return tokenId;
    }

    function buy(uint256 tokenId) external payable {
        SalesObject memory obj = _salesObjects[tokenId];
        address _seller = NftmindToken(obj.nft).ownerOf(tokenId);
        address buyer = msg.sender;
        NftmindToken(obj.nft).transferFrom(_seller, buyer, tokenId);
        address payable seller = _make_payable(_seller);
        address payable creator = _make_payable(obj.creator);
        address payable gathering = _make_payable(_gathering);
        uint256 buyAmount = obj.price;
        require(msg.value == obj.price, "msg.value invalid");
        uint256 copyrightAmount = (buyAmount * obj.copyrightAmount) / 100;
        uint256 serviceAmount = (buyAmount * _serviceCharge) / 100;
        uint256 sellerAmount = buyAmount - copyrightAmount-serviceAmount;

      
        seller.transfer(sellerAmount);
        if (copyrightAmount != 0) {
            creator.transfer(copyrightAmount);
        }
        if(serviceAmount != 0){
           gathering.transfer(serviceAmount);
        }
        TransactionObject memory transaction;
        transaction.buyer = buyer;
        transaction.seller = _seller;
        transaction.price = buyAmount;
        transaction.tokenId = tokenId;
        transaction.time = block.timestamp;
        transaction.copyrightAmount = copyrightAmount;
        transaction.serviceAmount = serviceAmount;

        emit eveTransaction(tokenId,buyAmount,copyrightAmount,obj.copyrightAmount,buyer,_seller, transaction.time,serviceAmount);

        
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(address(uint160(x)));
    }

    function updatePrice(uint256 tokenId, uint256 price) external {
        SalesObject storage obj = _salesObjects[tokenId];
        address owner = NftmindToken(obj.nft).ownerOf(tokenId);
        require(owner == msg.sender, "not owner address");
        obj.price = price;
    }

    function updateServiceCharge(uint256 serviceCharge) external{
       require(msg.sender == _gathering, "access denied");
        _serviceCharge = serviceCharge;
    }

    function updateGathering(address gathering) external{
       require(msg.sender == _gathering, "access denied");
        _gathering = gathering;
    }
}
