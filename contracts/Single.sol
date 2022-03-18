/**
 *Submitted for verification at BscScan.com on 2021-12-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Main.sol";

contract Single is ERC721,BlackLkisted {
	using SafeMath for uint256;
	IBEP20 dart;
	constructor() payable ERC721('Single', 'Single') {
		sellingFess = 5;
	}
    uint256 public sellingFess;
    uint256 public creationFess = 0;
    uint256 public referenceFees = 1;
    bool public hasSaleStarted = false;
    struct nft{
        uint256 price;
        uint256 royalty;
        address owner_address;
        address creator_address;
        IBEP20  paymentCurrency;
        bool isToken;
        bool sell;
    }
    mapping(uint256=>nft) public nftINFO;
    IBEP20 [] currencies;

      // Start Sale, we can start minting!
    function startSale() public onlyOwner {
        hasSaleStarted = true;
    }

    // Pause Sale
    function pauseSale() public onlyOwner {
        hasSaleStarted = false;
    }
    function checkExitscurrency(IBEP20 currency) private view returns (bool){
       bool found=false;
        for (uint i=0; i<currencies.length; i++) {
            if(currencies[i]==currency){
                found=true;
                break;
            }
        }
        return found;
    }
    function addCurrenicies(IBEP20 currency) public onlyOwner{
        require(checkExitscurrency(currency)==false,"Currency Alreday Added");
        currencies.push(currency);
    }
     function setTokenPrice(uint256 price, uint256 tokenId,bool sell,IBEP20 paymentCurrency,bool isToken) public {
          require(msg.sender==nftINFO[tokenId].owner_address,"Only token Owner can set price");
          require(checkExitscurrency(paymentCurrency),"Invalid Payment Currency");
          nftINFO[tokenId].price=price;
          nftINFO[tokenId].sell=sell;
          nftINFO[tokenId].isToken=isToken;
          nftINFO[tokenId].paymentCurrency=paymentCurrency;
    }
     function resellOff(uint256 tokenId) public {
          require(msg.sender==nftINFO[tokenId].owner_address,"Only token Owner can Off Sell ");
          nftINFO[tokenId].sell=false;
    }
    
	function setContractFees(uint256 _creationFess,uint256 _sellingFess,uint256 _referralFees) public onlyOwner {
	    creationFess = _creationFess;
        referenceFees = _referralFees;
        sellingFess = _sellingFess;
	}
	
	function mintNFT(string memory _tokenURI,uint256 amount, uint256 tokenId, bool isToken,uint256 price,IBEP20 paymentCurrency,uint256 royalties) public payable {
		require(!isBlacklisted[msg.sender], "caller is backlisted");  
        require(checkExitscurrency(paymentCurrency),"Invalid Payment Currency");
        require(hasSaleStarted == true, "Sale hasn't started");
        if(creationFess > 0) {
                if(isToken) {
                    require(amount>=(price.mul(creationFess)).div(100),"Low Creation Fees");
                    dart = IBEP20(paymentCurrency);
                    require(dart.allowance(msg.sender, address(this)) > amount, "Please allow fund first");
                    uint256 value = (amount * creationFess) / 100;
                    dart.transferFrom(msg.sender, owner(), value);
                    }
                else {
                    require(msg.value>=(price.mul(creationFess)).div(100),"Low Creation Fees");
                    payable(owner()).transfer(msg.value);
                 }      
		}
		_safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        nftINFO[tokenId].price=price;
        nftINFO[tokenId].owner_address=msg.sender;
        nftINFO[tokenId].creator_address=msg.sender;
        nftINFO[tokenId].isToken=isToken;
        nftINFO[tokenId].paymentCurrency=paymentCurrency;
        nftINFO[tokenId].sell=true;
        nftINFO[tokenId].royalty=royalties;
	}
	
    function transferNFT(uint256 tokenId,address payable _reference,uint256 amount) public payable{
            if(nftINFO[tokenId].isToken ==true){
                buyWithTokens(tokenId,_reference,amount);
            }else{
                buyWithBNB(tokenId,_reference);
            }
	}
    function buyWithTokens(uint256 tokenId,address payable _reference,uint256 amount) internal {
        require(!isBlacklisted[msg.sender], "caller is backlisted");  
        require(hasSaleStarted == true, "Sale hasn't started");
        require(nftINFO[tokenId].sell== true, "Currently NFT is NOT For Sell");
        require(nftINFO[tokenId].isToken== true, "This NFT Can not Sell With Tokens");
        dart = IBEP20( nftINFO[tokenId].paymentCurrency);
        require(amount >=nftINFO[tokenId].price, "The Token submitted with this transaction is too low.");
		require(dart.allowance(msg.sender, address(this)) > nftINFO[tokenId].price, "Please allow fund first");
		address _owner = ownerOf(tokenId);
		uint256 owner_fees = 0;
		if(_reference==address(0)){
		    owner_fees = uint256(100) - sellingFess - nftINFO[tokenId].royalty;
		}else{
		    owner_fees = uint256(100) - sellingFess - nftINFO[tokenId].royalty - referenceFees;
			dart.transferFrom(msg.sender, _reference, (nftINFO[tokenId].price * referenceFees) / 100);
		}
        
		if(sellingFess > 0) {
		dart.transferFrom(msg.sender, owner(), (nftINFO[tokenId].price * sellingFess) / 100);
		}
		if(nftINFO[tokenId].royalty > 0) {
		dart.transferFrom(msg.sender, nftINFO[tokenId].creator_address, (nftINFO[tokenId].price * nftINFO[tokenId].royalty) / 100);
		}
		if(owner_fees > 0) {
		dart.transferFrom(msg.sender, _owner, (nftINFO[tokenId].price * owner_fees) / 100);
		}
        _transfer(_owner,msg.sender,tokenId);
        nftINFO[tokenId].sell=false;
        nftINFO[tokenId].owner_address=msg.sender;
	}
    
	function buyWithBNB(uint256 tokenId,address payable _reference) public payable {
        require(!isBlacklisted[msg.sender], "caller is backlisted");  
        require(hasSaleStarted == true, "Sale hasn't started");
        require(nftINFO[tokenId].sell== true, "Currently NFT is NOT For Sell");
        require(nftINFO[tokenId].isToken== false, "This NFT Can not Sell With BNB");
        require(msg.value >=nftINFO[tokenId].price, "The value submitted with this transaction is too low.");
		uint256 owner_fees = 0;
		if(_reference == address(0)){
		    owner_fees = uint256(100) - sellingFess - nftINFO[tokenId].royalty;
		}else{
		    owner_fees = uint256(100) - sellingFess - nftINFO[tokenId].royalty- referenceFees;
		    _reference.transfer((msg.value * referenceFees) / (100));
		}
		address payable _owner = payable(ownerOf(tokenId));
		_owner.transfer((msg.value * owner_fees) / (100));
		payable(owner()).transfer((msg.value * sellingFess) / (100));
		payable(nftINFO[tokenId].creator_address).transfer((msg.value * nftINFO[tokenId].royalty) / (100));
        _transfer(_owner,msg.sender,tokenId);
        nftINFO[tokenId].sell=false;
        nftINFO[tokenId].owner_address=msg.sender;
	}

}