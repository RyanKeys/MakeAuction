pragma solidity ^0.7.0;

contract Auction {

    uint256 public endTime;
    address payable public owner;
    bool public auctionOver;
    address public highestBidder;
    uint256 public highestBid;

    //handles easy access to bidder and their highest bid.
    mapping(address => uint256) public bidderMapping;

    event AnnounceWinner(address winner, uint256 winningBid);
    event NewBid(address bidder, uint amount);
    event Withdraw(address bidder, uint256 amount);

    //Init fn.
    constructor(uint256 _auctionDuration, address payable _owner) public {
        owner = _owner;
        //Accounts for deployment time of auction.
        endTime = block.timestamp + _auctionDuration;
    }

    //must return true to continue on function path with modifiers.
    modifier isEnded {
        require(block.timestamp >= endTime, "The Auction is over.");
        _;
    }
    modifier isNotEnded {
        require(block.timestamp < endTime, "This auction isn't over.");
        _;
    }

    modifier isNotOwner {
        require(msg.sender != owner, "This is your auction!");
        _;
    }

    //Handles accepting of bids, assigns new highest bidder, and emit a new bid event.
    function placeBid() payable isNotOwner isNotEnded public {
        require(msg.value > 0, "Your bid is too low.");
        require(msg.value > highestBid, "Your bid is too low.");
        if (bidderMapping[msg.sender] == 0) {
            bidderMapping[msg.sender] = msg.value;
        } else {
            bidderMapping[msg.sender] += msg.value;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit NewBid(msg.sender, msg.value);
    }
    
    //Allows highest bidder to take funds into ETH wallet.
    function withdraw() isNotOwner isEnded public {
        uint256 withdrawAmount = bidderMapping[msg.sender];
        require(withdrawAmount > 0, "Nothing to withdraw.");
        if (msg.sender == highestBidder) {
            withdrawAmount -= highestBid;
            bidderMapping[msg.sender] = highestBid;
        } else {
            bidderMapping[msg.sender] = 0;
        }
        msg.sender.transfer(withdrawAmount);
        emit Withdraw(msg.sender, withdrawAmount);
    }

    //Ends auction, tranfers ownership and emits ending event.
    function auctionEnd() isEnded public {
        require(!auctionOver, "This action has already ended.");
        auctionOver = true;
        owner.transfer(highestBid);
        emit AnnounceWinner(highestBidder, highestBid);
    }
}