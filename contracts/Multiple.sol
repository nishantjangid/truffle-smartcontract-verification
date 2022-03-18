/**
 *Submitted for verification at BscScan.com on 2021-12-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-07
*/

/**
 *Submitted for verification at BscScan.com on 2021-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Main.sol";

contract Multiple is ERC721 {
	using SafeMath
	for uint256;
	IBEP20 dart;
	address payable public adminAddress;
	constructor() payable ERC721('Multiple', 'Multiple') {
		adminAddress = payable(msg.sender);
		sellingFess = 5;
	}
    uint256 public sellingFess;
    uint256 public creationFess = 0;
    uint256 public referenceFees = 1;

    function setreferralFees(uint256 _referralFees) public {
        require(msg.sender == adminAddress, "Only owner can set the referral fees");
        referenceFees = _referralFees;
    }

	function setAdminAddress(address payable _adminAdd) public {
		require(msg.sender == adminAddress, "Only owner can set the address");
		adminAddress = _adminAdd;
	}

	function setCreatonFees(uint256 _creationFess) public {
		require(msg.sender == adminAddress, "Only owner can set creation fees");
		creationFess = _creationFess;
	}
	function setSellingFees(uint256 _sellingFess) public {
		require(msg.sender == adminAddress, "Only owner can set creation fees");
		sellingFess = _sellingFess;
	}
	bool const = false;
	modifier onlyOwner {
		require(const == true);
		_;
	}

	function mintNFT(string memory _tokenURI, uint256 value, uint256 startId, uint256 endId, uint256 state, address _paymentCurrency) public payable {
		if(state == 0) {
			adminAddress.transfer(msg.value);
		} else {
			dart = IBEP20(_paymentCurrency);
			if(creationFess > 0) {
				require(dart.allowance(msg.sender, address(this)) > value, "Please allow fund first");
				uint256 amount = (value * creationFess) / 100;
				dart.transferFrom(msg.sender, adminAddress, amount);
			}
		}
		for(uint256 i = startId; i <= endId; i++) {
			_safeMint(msg.sender, i);
            _setTokenURI(i, _tokenURI);
		}
	}
	function buyWithBNB(uint256 _from, uint256 _to, uint256 _royalties, address payable artist) public payable {
		require(msg.value > 0, "Must Provide Amount");
	    claimAmount(_from, artist, _royalties);
        for(uint256 i = _from; i <= _to; i++) {
            address  _owner = ownerOf(i);
            _transfer(_owner, msg.sender, i);
        }
	}

	function buyWithTokens(uint256 _from, uint256 _to, uint256 _royalties, uint256 buyAmount, address paymentCurrency, address payable _artist) public {
			require(buyAmount > 0, "Amount should be grater then 0 ");
			calclulateAmount(_from, paymentCurrency, buyAmount, _royalties, _artist);
			for(uint256 i = _from; i <= _to; i++) {
				address _owner = (ownerOf(i));
				_transfer(_owner, msg.sender, i);
			}
	}
	function calclulateAmount(uint256 tokenId, address paymentCurrency, uint256 buyAmount, uint256 _royalties, address payable _artist) internal returns(bool){
		dart = IBEP20(paymentCurrency);
		address _owner = ownerOf(tokenId);
		uint256 owner_fees = 0;
		owner_fees = uint256(100) - sellingFess - _royalties;
		if(sellingFess > 0) {
			require(dart.allowance(msg.sender, address(this)) > buyAmount, "Please allow fund first");
			dart.transferFrom(msg.sender, adminAddress, (buyAmount * sellingFess) / 100);
		}
		if(_royalties > 0) {
			require(dart.allowance(msg.sender, address(this)) > buyAmount, "Please allow fund first");
			dart.transferFrom(msg.sender, _artist, (buyAmount * _royalties) / 100);
		}
		if(owner_fees > 0) {
			require(dart.allowance(msg.sender, address(this)) > buyAmount, "Please allow fund first");
			dart.transferFrom(msg.sender, _owner, (buyAmount * owner_fees) / 100);
		}
        return true;
	}
	function claimAmount(uint256 tokenId, address payable artist, uint256 _royalties) public payable returns(bool) {
		uint256 owner_fees = 0;
		owner_fees = uint256(100) - sellingFess - _royalties;
		address payable _owner = payable(ownerOf(tokenId));
		_owner.transfer((msg.value * owner_fees) / (100));
		adminAddress.transfer((msg.value * sellingFess) / (100));
		artist.transfer((msg.value * _royalties) / (100));
        return true;
	}
}