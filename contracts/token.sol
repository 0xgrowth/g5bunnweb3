// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SocialNFT is ERC721, Ownable {
    uint256 public tokenCounter;
    
    enum Level { Newbie, RisingStar, Influencer, SocialIcon }
    
    mapping(address => uint256) public engagementPoints;
    mapping(address => Level) public userLevels;
    mapping(uint256 => Level) public tokenIdToLevel;
    mapping(address => uint256) public addressToTokenId; 
    
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
        uint256 tokenId = addressToTokenId[user];
    
        // If user already has an NFT, burn it
        if (_exists(tokenId)) {
            _burn(tokenId);
        }
    
        // Mint new NFT with a unique tokenId
        tokenCounter++;
        uint256 newTokenId = tokenCounter;
        _mint(user, newTokenId);
    
        // Update mappings
        tokenIdToLevel[newTokenId] = level;
        addressToTokenId[user] = newTokenId;
        userLevels[user] = level;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
    
        Level level = tokenIdToLevel[tokenId];
        string memory levelName;
    
        if (level == Level.Newbie) levelName = "Newbie";
        else if (level == Level.RisingStar) levelName = "Rising Star";
        else if (level == Level.Influencer) levelName = "Influencer";
        else levelName = "Social Icon";
    
    return string(abi.encodePacked(
        "data:application/json;utf8,{",
        "\"name\":\"SocialNFT #", Strings.toString(tokenId), "\",",
        "\"description\":\"A Social Engagement NFT\",",
        "\"attributes\":[{\"trait_type\":\"Level\",\"value\":\"", levelName, "\"}],",
        "\"image\":\"", _getLevelImage(level), "\"",
        "}"
    ));
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

    
    function _getLevelImage(Level level) internal pure returns (string memory) {
        // Could return IPFS/Arweave URLs or on-chain SVG
        if (level == Level.Newbie) return "ipfs://Qm...Newbie";
        else if (level == Level.RisingStar) return "ipfs://Qm...RisingStar";
        else if (level == Level.Influencer) return "ipfs://Qm...Influencer";
        else return "ipfs://Qm...SocialIcon";
    }
    function likePost(address creator) public {
        engagementPoints[creator] += 1;
        _upgradeNFT(creator);
}
}
