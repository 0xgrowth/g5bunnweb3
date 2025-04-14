// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SocialNFT is ERC721, Ownable {
    uint256 public tokenCounter;
    
    enum Level { Newbie, RisingStar, Influencer, SocialIcon }
    
    mapping(address => uint256) public engagementPoints;
    mapping(address => Level) public userLevels;
    
    constructor() ERC721("SocialNFT", "SNFT") {
        tokenCounter = 0;
    }

    function rewardEngagement(address user, uint256 points) public onlyOwner {
        engagementPoints[user] += points;
        _upgradeNFT(user);
    }

    function _upgradeNFT(address user) internal {
        Level newLevel = _determineLevel(user);
        if (userLevels[user] != newLevel) {
            _mintOrUpgradeNFT(user, newLevel);
        }
    }

    function _mintOrUpgradeNFT(address user, Level level) internal {
        // Burn old NFT and mint new one
        uint256 oldTokenId = uint256(userLevels[user]);
        if (_exists(oldTokenId)) {
            _burn(oldTokenId);
        }
        uint256 tokenId = uint256(level);
        _mint(user, tokenId);
        userLevels[user] = level;
    }

    function _determineLevel(address user) internal view returns (Level) {
        uint256 points = engagementPoints[user];
        if (points >= 100000) {
            return Level.SocialIcon;
        } else if (points >= 10000) {
            return Level.Influencer;
        } else if (points >= 500) {
            return Level.RisingStar;
        } else {
            return Level.Newbie;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        require(from == address(0) || to == address(0), "Soulbound: Token cannot be transferred");
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
