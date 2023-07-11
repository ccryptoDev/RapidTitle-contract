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
  event StatusUpdated(uint _titleId, uint holds_status_id, bool _state, uint256 updateAt);

  function getTitlesCount() external view returns(uint);
  function getTitle(uint _titleId) external view returns(uint, uint, uint, uint, uint, uint, address, uint256);
  function getHoldsStatus(uint _titleId, uint8 _holds_status_id) external view returns(bool, uint256);

  function mintTitle(
    address _to, 
    string memory _vehicleURI, 
    uint _dealerId, 
    uint _lenderId, 
    uint _sellerId,
    uint _dmvId,
    uint8 holds_number
  ) external;

  function updateTitleStatus(uint _titleId, uint8 holds_status_id, bool _state) external;
}