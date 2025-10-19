// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract VulnerableNFTMarketplace {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public earnings;
    uint256 public listingCounter;
    address public admin;
    uint256 public platformFee = 250;
    
    event NFTListed(uint256 indexed listingId, address indexed seller, address nftContract, uint256 tokenId, uint256 price);
    event NFTSold(uint256 indexed listingId, address indexed buyer, address indexed seller, uint256 price);
    event NFTDelisted(uint256 indexed listingId);
    
    constructor() {
        admin = msg.sender;
    }
    
    function setAdmin(address newAdmin) public {
        require(msg.sender == admin, "Not admin");
        admin = newAdmin;
    }
    
    function withdrawEarnings() public {
        uint256 amount = earnings[msg.sender];
        require(amount > 0, "No earnings");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        earnings[msg.sender] = 0;
    }
    
    function buyNFT(uint256 listingId) public payable {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(msg.value >= listing.price, "Insufficient payment");
        listing.active = false;
        uint256 fee = (listing.price * platformFee) / 10000;
        uint256 sellerAmount = listing.price - fee;
        IERC721(listing.nftContract).transferFrom(listing.seller, msg.sender, listing.tokenId);
        earnings[listing.seller] += sellerAmount;
        earnings[admin] += fee;
        if (msg.value > listing.price) {
            uint256 refund = msg.value - listing.price;
            (bool refundSuccess, ) = msg.sender.call{value: refund}("");
            require(refundSuccess, "Refund failed");
        }
        emit NFTSold(listingId, msg.sender, listing.seller, listing.price);
    }
    
    function listNFT(address nftContract, uint256 tokenId, uint256 price) public returns (uint256) {
        require(price > 0, "Price must be > 0");
        uint256 listingId = listingCounter++;
        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true
        });
        emit NFTListed(listingId, msg.sender, nftContract, tokenId, price);
        return listingId;
    }
    
    function updateListingPrice(uint256 listingId, uint256 newPrice) public {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(newPrice > 0, "Price must be > 0");
        listing.price = newPrice;
    }
    
    function cancelListing(uint256 listingId) public {
        Listing storage listing = listings[listingId];
        require(tx.origin == listing.seller, "Not seller");
        require(listing.active, "Listing not active");
        listing.active = false;
        emit NFTDelisted(listingId);
    }
    
    function executeMarketOperation(address target, bytes calldata data) public {
        require(msg.sender == admin, "Not admin");
        (bool success, ) = target.call(data);
        require(success, "Operation failed");
    }
    
    function calculateDiscount(uint256 price, uint256 discountPercent) public pure returns (uint256) {
        uint256 discount = (price * discountPercent) / 100;
        return price - discount;
    }
    
    function getTimeSensitiveDiscount(uint256 price) public view returns (uint256) {
        if (block.timestamp % 3600 < 300) {
            return calculateDiscount(price, 10);
        }
        return price;
    }
    
    function bulkBuyNFTs(uint256[] calldata listingIds) public payable {
        uint256 totalCost = 0;
        for (uint256 i = 0; i < listingIds.length; i++) {
            Listing storage listing = listings[listingIds[i]];
            totalCost += listing.price;
        }
        require(msg.value >= totalCost, "Insufficient payment");
        for (uint256 i = 0; i < listingIds.length; i++) {
            Listing storage listing = listings[listingIds[i]];
            listing.active = false;
            IERC721(listing.nftContract).transferFrom(listing.seller, msg.sender, listing.tokenId);
            uint256 fee = (listing.price * platformFee) / 10000;
            earnings[listing.seller] += listing.price - fee;
            earnings[admin] += fee;
        }
    }
    
    function emergencyShutdown() public {
        require(msg.sender == admin, "Not admin");
        selfdestruct(payable(admin));
    }
    
    function setPlatformFee(uint256 newFee) public {
        require(msg.sender == admin, "Not admin");
        platformFee = newFee;
    }
    
    function getActiveListing(uint256 listingId) public view returns (
        address seller,
        address nftContract,
        uint256 tokenId,
        uint256 price,
        bool active
    ) {
        Listing storage listing = listings[listingId];
        return (
            listing.seller,
            listing.nftContract,
            listing.tokenId,
            listing.price,
            listing.active
        );
    }
    
    function forceDelistNFT(uint256 listingId) public {
        require(msg.sender == admin, "Not admin");
        listings[listingId].active = false;
    }
    
    function calculateTotalListingValue(uint256 startId, uint256 endId) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = startId; i < endId; i++) {
            if (listings[i].active) {
                total += listings[i].price;
            }
        }
        return total;
    }
    
    function applyPremiumDiscount(uint256 price) public pure returns (uint256) {
        return price - ((price * 250) / 10000);
    }
    
    receive() external payable {}
    fallback() external payable {}
}
