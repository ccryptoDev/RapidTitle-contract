// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IRT_ERC721 is IERC721 {
  /// @notice status enum for title
  enum Status {
    Created,
    Pending,
    Completed
  }
  event BaseURIChanged(string newURI);
  event TitleCreated(address to, uint _tokenId); 
  event StatusUpdated(uint _titleId, uint _state);

  function getTitlesCount() external view returns(uint);
  function getTitle(uint _titleId) external view returns(uint, uint, uint, uint, uint , Status);

  function mintTitle(
    address _to, 
    string memory _vehicleURI, 
    uint _dealerId, 
    uint _lenderId, 
    uint _sellerId
  ) external;

  function updateTitleStatus(uint _titleId, uint _state) external;
}