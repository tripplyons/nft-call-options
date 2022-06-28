// SPDX-License-Identifier: Unlicense
pragma solidity =0.8.15;

import "forge-std/Test.sol";
import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import "src/NFTCallOptions.sol";
import "forge-std/console.sol";

// a freely mintable NFT for testing
contract ExampleNFT is ERC721 {
    constructor() ERC721("Example", "EXAMPLE") {}

    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }

    // needs to be implemented from the superclass
    function tokenURI(uint256)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return "";
    }
}

contract TestNFTCallOptions is Test {
    NFTCallOptions nftCallOptions;
    address buyer = address(100);
    address seller = address(200);
    ExampleNFT collection;
    uint256 strikePrice = 10 ether;
    uint256 expiration = block.timestamp + 100;
    uint256 premium = 1 ether;
    uint256 tokenId = 0;

    function setUp() public {
        nftCallOptions = new NFTCallOptions();
        collection = new ExampleNFT();

        startHoax(seller);

        // mint a token for the seller
        collection.mint(tokenId);

        vm.stopPrank();
    }

    function testCreateOfferChecks() public {
        startHoax(buyer);

        vm.expectRevert(bytes("NFTCallOptions: premium not payed"));
        nftCallOptions.createOffer{value: 0}(
            address(collection),
            strikePrice,
            expiration,
            premium
        );

        vm.expectRevert(bytes("NFTCallOptions: option already expired"));
        nftCallOptions.createOffer{value: premium}(
            address(collection),
            strikePrice,
            0,
            premium
        );

        vm.expectRevert(bytes("NFTCallOptions: collection address is 0"));
        nftCallOptions.createOffer{value: premium}(
            address(0),
            strikePrice,
            expiration,
            premium
        );

        vm.stopPrank();
    }

    function createOffer() public returns (uint256) {
        uint256 offerId = nftCallOptions.nextOfferId();

        startHoax(buyer);

        nftCallOptions.createOffer{value: premium}(
            address(collection),
            strikePrice,
            expiration,
            premium
        );

        vm.stopPrank();

        return offerId;
    }

    function testCreateOffer() public {
        uint256 offerId = createOffer();

        (
            address _buyer,
            address _collection,
            uint256 _strikePrice,
            uint256 _expiration,
            uint256 _premium,
            bool _isOpen,
            bool _isAccepted,
            address _seller,
            uint256 _tokenId
        ) = nftCallOptions.offers(offerId);

        assertEq(_buyer, buyer);
        assertEq(_collection, address(collection));
        assertEq(_strikePrice, strikePrice);
        assertEq(_expiration, expiration);
        assertEq(_premium, premium);
        assertTrue(_isOpen);
        assertTrue(!_isAccepted);
        assertEq(_seller, address(0));
        assertEq(_tokenId, 0);
    }

    function testCancelOfferChecks() public {
        uint256 offerId = createOffer();

        startHoax(seller);

        vm.expectRevert(bytes("NFTCallOptions: offer not owned by sender"));
        nftCallOptions.cancelOffer(offerId);

        vm.stopPrank();

        startHoax(buyer);

        nftCallOptions.cancelOffer(offerId);
        vm.expectRevert(bytes("NFTCallOptions: offer already cancelled"));
        nftCallOptions.cancelOffer(offerId);

        vm.stopPrank();
    }

    function testCancelOfferChecks2() public {
        uint256 offerId = acceptOffer();

        startHoax(buyer);

        vm.expectRevert(bytes("NFTCallOptions: offer already accepted"));
        nftCallOptions.cancelOffer(offerId);
        
        vm.stopPrank();
    }

    function testCancelOffer() public {
        uint256 offerId = createOffer();

        startHoax(buyer);

        uint256 balanceBefore = buyer.balance;

        nftCallOptions.cancelOffer(offerId);

        uint256 balanceAfter = buyer.balance;
        assertGt(balanceAfter, balanceBefore);

        (, , , , , bool _isOpen, , , ) = nftCallOptions.offers(offerId);
        assertTrue(!_isOpen);

        vm.stopPrank();
    }

    function testAcceptOfferChecks() public {
        ExampleNFT wrongCollection = new ExampleNFT();
        uint256 offerId = createOffer();

        startHoax(seller);

        wrongCollection.mint(tokenId);

        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        nftCallOptions.acceptOffer(offerId, tokenId);

        vm.stopPrank();

        startHoax(buyer);

        nftCallOptions.cancelOffer(offerId);

        vm.stopPrank();

        startHoax(seller);

        collection.approve(address(nftCallOptions), tokenId);
        vm.expectRevert(bytes("NFTCallOptions: offer was cancelled"));
        nftCallOptions.acceptOffer(offerId, tokenId);
        
        vm.stopPrank();
    }

    function testAcceptOfferChecks2() public {
        uint256 offerId = acceptOffer();

        startHoax(seller);

        collection.mint(tokenId + 1);
        collection.approve(address(nftCallOptions), tokenId + 1);
        vm.expectRevert(bytes("NFTCallOptions: offer already accepted"));
        nftCallOptions.acceptOffer(offerId, tokenId + 1);

        vm.stopPrank();
    }

    function acceptOffer() public returns (uint256) {
        uint256 offerId = createOffer();

        startHoax(seller);

        collection.approve(address(nftCallOptions), tokenId);
        nftCallOptions.acceptOffer(offerId, tokenId);

        vm.stopPrank();

        return offerId;
    }

    function testAcceptOffer() public {
        uint256 balanceBefore = seller.balance;

        uint256 offerId = acceptOffer();

        uint256 balanceAfter = seller.balance;
        assertGt(balanceAfter, balanceBefore);

        (
            ,
            ,
            ,
            ,
            ,
            ,
            bool _isAccepted,
            address _seller,
            uint256 _tokenId
        ) = nftCallOptions.offers(offerId);

        assertTrue(_isAccepted);
        assertEq(_seller, seller);
        assertEq(_tokenId, tokenId);
    }

    // an amount of time in the future where the options is expired
    function getTimeDelta() public view returns (uint256) {
        return expiration + 1 - block.timestamp;
    }

    function testExerciseChecks() public {
        uint256 offerId = acceptOffer();
        uint256 timeDelta = getTimeDelta();

        startHoax(buyer);

        vm.expectRevert("NFTCallOptions: strike price not met");
        nftCallOptions.exercise(offerId);

        skip(timeDelta);
        vm.expectRevert("NFTCallOptions: option already expired");
        nftCallOptions.exercise{value: strikePrice}(offerId);
        rewind(timeDelta);

        vm.stopPrank();

        startHoax(seller);

        vm.expectRevert("NFTCallOptions: option not owned by sender");
        nftCallOptions.exercise{value: strikePrice}(offerId);

        vm.stopPrank();
    }

    function testExercise() public {
        uint256 offerId = acceptOffer();

        startHoax(buyer);

        uint256 buyerNFTBalanceBefore = collection.balanceOf(buyer);
        uint256 sellerBalanceBefore = seller.balance;

        nftCallOptions.exercise{value: strikePrice}(offerId);

        uint256 buyerNFTBalanceAfter = collection.balanceOf(buyer);
        uint256 sellerBalanceAfter = seller.balance;

        assertGt(buyerNFTBalanceAfter, buyerNFTBalanceBefore);
        assertGt(sellerBalanceAfter, sellerBalanceBefore);

        vm.stopPrank();
    }

    function testClaimCollateralChecks() public {
        uint256 offerId = acceptOffer();
        uint256 timeDelta = getTimeDelta();

        startHoax(seller);

        vm.expectRevert("NFTCallOptions: option not expired");
        nftCallOptions.claimCollateral(offerId);

        vm.stopPrank();

        startHoax(buyer);

        skip(timeDelta);
        vm.expectRevert("NFTCallOptions: collateral not owned by sender");
        nftCallOptions.claimCollateral(offerId);
        rewind(timeDelta);

        nftCallOptions.exercise{value: strikePrice}(offerId);

        vm.stopPrank();

        startHoax(seller);

        skip(timeDelta);
        // should fail because the option was exercised
        vm.expectRevert("WRONG_FROM");
        nftCallOptions.claimCollateral(offerId);
        rewind(timeDelta);

        vm.stopPrank();
    }

    function testClaimCollateral() public {
        uint256 offerId = acceptOffer();
        uint256 timeDelta = getTimeDelta();

        startHoax(seller);

        uint256 balanceBefore = collection.balanceOf(seller);

        skip(timeDelta);
        nftCallOptions.claimCollateral(offerId);
        rewind(timeDelta);

        uint256 balanceAfter = collection.balanceOf(seller);
        assertGt(balanceAfter, balanceBefore);

        vm.stopPrank();
    }
}
