// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Badge
 * @author TheV
 * @notice This contract represent a Crowdfundr ERC721 token awarded to contributors
 */
contract Badge is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /**
     * @author TheV
     * @notice Constructor of the badge NFT
     * @dev Full implementation provided by OpenZeppelin
     */
    constructor() ERC721("Crowdfundr", "FDR") {}

    /**
     * @notice Award contributor badge to an address
     * @param _contributor The address of the contributor to award the badge to
     * @return The tokenId of the badge
     */
    function awardContributorBadge(address _contributor) public returns (uint256) {
        _tokenIds.increment();
        _mint(_contributor, _tokenIds.current());
        return _tokenIds.current();
    }
}
