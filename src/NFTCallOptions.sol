// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.15;

import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";

// NFT Call Options
// A smart contract for trading equity-settled call options on NFTs
// https://github.com/tripplyons/nft-call-options
contract NFTCallOptions is ERC721TokenReceiver {
    // represents a transaction of a call option
    struct Offer {
        // set when an offer is created
        address payable buyer; // the buyer of the call option
        address collection; // an ERC721 contract
        uint256 strikePrice; // wei
        uint256 expiration; // unix timestamp
        uint256 premium; // wei
        bool isOpen; // starts as true until cancelled or accepted
        // set after an offer is accepted
        bool isAccepted;
        address payable seller; // the seller of the call option
        uint256 tokenId; // tokenId in collection of the seller's collateral
    }

    event OfferCreated(
        uint256 indexed offerId,
        address indexed buyer,
        address indexed collection
    );

    event OfferCancelled(uint256 indexed offerId);

    event OfferAccepted(uint256 indexed offerId, address indexed seller);

    event OptionExercised(uint256 indexed offerId);

    // offers by offerId
    mapping(uint256 => Offer) public offers;
    uint256 public nextOfferId;

    constructor() {}

    function createOffer(
        address collection,
        uint256 strikePrice,
        uint256 expiration,
        uint256 premium
    ) public payable {
        require(msg.value == premium, "NFTCallOptions: premium not payed");
        require(
            expiration > block.timestamp,
            "NFTCallOptions: option already expired"
        );
        require(
            collection != address(0),
            "NFTCallOptions: collection address is 0"
        );

        offers[nextOfferId].buyer = payable(msg.sender);
        offers[nextOfferId].collection = collection;
        offers[nextOfferId].strikePrice = strikePrice;
        offers[nextOfferId].expiration = expiration;
        offers[nextOfferId].premium = premium;
        offers[nextOfferId].isOpen = true;

        emit OfferCreated(nextOfferId, msg.sender, collection);

        nextOfferId++;
    }

    function cancelOffer(uint256 offerId) public {
        require(
            offers[offerId].buyer == msg.sender,
            "NFTCallOptions: offer not owned by sender"
        );
        require(
            offers[offerId].isOpen == true,
            "NFTCallOptions: offer already cancelled"
        );
        require(
            offers[offerId].isAccepted == false,
            "NFTCallOptions: offer already accepted"
        );
        // does not need to check if offer is expired
        // because if it was never accepted, it should be able to be refunded

        offers[offerId].isOpen = false;

        offers[offerId].buyer.transfer(offers[offerId].premium);

        emit OfferCancelled(offerId);
    }

    function acceptOffer(uint256 offerId, uint256 tokenId) public {
        require(
            offers[offerId].isOpen == true,
            "NFTCallOptions: offer was cancelled"
        );
        require(
            offers[offerId].isAccepted == false,
            "NFTCallOptions: offer already accepted"
        );
        require(
            offers[offerId].expiration > block.timestamp,
            "NFTCallOptions: option already expired"
        );

        offers[offerId].isAccepted = true;
        offers[offerId].seller = payable(msg.sender);
        offers[offerId].tokenId = tokenId;

        ERC721 tokenContract = ERC721(offers[offerId].collection);

        tokenContract.safeTransferFrom(msg.sender, address(this), tokenId);

        offers[offerId].seller.transfer(offers[offerId].premium);

        emit OfferAccepted(offerId, msg.sender);
    }

    // the buyer can exercise their option before expiration
    function exercise(uint256 offerId) public payable {
        require(
            offers[offerId].isAccepted == true,
            "NFTCallOptions: offer not accepted"
        );
        require(
            offers[offerId].expiration > block.timestamp,
            "NFTCallOptions: option already expired"
        );
        require(
            offers[offerId].buyer == msg.sender,
            "NFTCallOptions: option not owned by sender"
        );
        require(
            offers[offerId].strikePrice == msg.value,
            "NFTCallOptions: strike price not met"
        );

        ERC721 tokenContract = ERC721(offers[offerId].collection);

        tokenContract.safeTransferFrom(
            address(this),
            offers[offerId].buyer,
            offers[offerId].tokenId
        );

        offers[offerId].seller.transfer(offers[offerId].strikePrice);

        emit OptionExercised(offerId);
    }

    // the seller can claim their NFT after expiration if it is not exercised
    function claimCollateral(uint256 offerId) public {
        // must be expired for the seller to claim collateral
        require(
            offers[offerId].expiration < block.timestamp,
            "NFTCallOptions: option not expired"
        );
        require(
            offers[offerId].seller == msg.sender,
            "NFTCallOptions: collateral not owned by sender"
        );

        ERC721 tokenContract = ERC721(offers[offerId].collection);

        tokenContract.safeTransferFrom(
            address(this),
            offers[offerId].seller,
            offers[offerId].tokenId
        );

        // doesn't need to emit an event because it isn't relevant to trading
    }
}
