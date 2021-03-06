pragma solidity 0.4.19;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {


	/* Constructor */
	function GoodAuction() public {
		highestBidder = address(0);
		highestBid = 0;
	}


	/* New data structure, keeps track of refunds owed */
	mapping(address => uint) refunds;


	/* 	Bid function, now shifted to pull paradigm
		Must return true on successful send and/or bid, bidder
		reassignment. Must return false on failure and 
		allow people to retrieve their funds  */
	function bid() payable external returns(bool) {
		// YOUR CODE HERE
		// If the bid is higher than previous highest, set new highest
		if (msg.value > highestBid) {
			refunds[highestBidder] += highestBid;
			highestBidder = msg.sender;
			highestBid = msg.value;
			return true;
		} else {
			// If bid fails, return funds
			msg.sender.transfer(msg.value);
			return false;
		}
	}


	/*  Implement withdraw function to complete new 
	    pull paradigm. Returns true on successful 
	    return of owed funds and false on failure
	    or no funds owed.  */
	function withdrawRefund() external returns(bool) {
		// YOUR CODE HERE
		address refunder = msg.sender;
		uint refundAmount = refunds[refunder];
		
		if (refundAmount > 0) {
			refunds[refunder] = 0;
			refunder.transfer(refundAmount);
			return true;
		} else {
			return false;
		}
	}


	/*  Allow users to check the amount they are owed
		before calling withdrawRefund(). Function returns
		amount owed.  */
	function getMyBalance() constant external returns(uint) {
		return refunds[msg.sender];
	}


	/* 	Consider implementing this modifier
		and applying it to the reduceBid function 
		you fill in below. */
	modifier canReduce() {
		require(msg.sender == getHighestBidder());
		_;
	}


	/*  Rewrite reduceBid from BadAuction to fix
		the security vulnerabilities. Should allow the
		current highest bidder only to reduce their bid amount */
	function reduceBid() external canReduce() {
		if (highestBid > 0) {
			require(highestBidder.send(1));
			highestBid -= 1;
		} else {
			revert();
		}
	}


	/* 	Remember this fallback function
		gets invoked if somebody calls a
		function that does not exist in this
		contract. But we're good people so we don't
		want to profit on people's mistakes.
		How do we send people their money back?  */

	function () payable {
		// YOUR CODE HERE
		revert();
	}

}
