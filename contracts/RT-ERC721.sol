// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IRT-ERC721.sol";

/// @title  Extended ERC721Enumerable contract for the Rapid Title system
/// @notice Uses AccessControl for the minting mechanisms
/// @author Mario Sergio Ayerve Estrella.
contract RT_ERC721 is ERC165, IRT_ERC721, ERC721Enumerable, AccessControlEnumerable {
  using Strings for uint;
    
  //Roles
	bytes32 public constant DEALER = keccak256("DEALER");
	bytes32 public constant SELLER = keccak256("SELLER");
	bytes32 public constant LENDER = keccak256("LENDER");
	bytes32 public constant DMV = keccak256("DMV");
  
  struct Holds_Status {
    bool status;
    uint256 updateAt;
  }

  struct Titles {
    uint title_id;
    uint vehicle_id;
    uint dealer_id;
    uint seller_id;
    uint lender_id;
    uint dmv_id;
    address ownerWallet;
    uint256 createAt;
	}

  mapping(uint256 => Holds_Status[]) internal titleStatus;

  //URIs
	string internal baseURI;
	mapping(uint => string) internal vehicleURI;

  uint256 lastTokenId;
  
  Titles[] private _titles;

  /**
  * @notice Initializer
  */
  constructor(
    string memory _contractName
  ) ERC721(_contractName, "RT") {
    _setRoleAdmin(SELLER, DEALER);
		_setRoleAdmin(LENDER, DEALER);
		_setupRole(DEALER, msg.sender);
		_setupRole(SELLER, msg.sender);
		_setupRole(LENDER, msg.sender);
		_setupRole(DMV, msg.sender);
  }

  /// @notice	Sets the Base URI for ALL tokens
	/// @dev	Can be overriden by the specific token URI
	/// @param	newURI	URI to be used
  function setBaseURI(string calldata newURI) public {
		baseURI = newURI;
		emit BaseURIChanged(newURI);
	}

	/// @notice	Overridden function from the ERC721 contract that returns our
	///	variable base URI instead of the hardcoded URI
	function _baseURI() internal view override(ERC721) returns (string memory) {
		return baseURI;
	}

  /// @notice Get vehicle inform by vehicleId
  /// @param _vehicleId The ID of vehicle
  function getVehicleURI(uint _vehicleId) public view returns (string memory) {
    require(
      _exists(_vehicleId),
      "ERC721URIStorage: URI query for nonexistent vehicle"
    );

    string memory __baseURI;
    __baseURI = _baseURI();

    return
      bytes(__baseURI).length > 0
        ? string(abi.encodePacked(__baseURI, vehicleURI[_vehicleId]))
        : "";
  }

  /// @notice	Returns the number of titles on the contract
	/// @dev	Use with get product to list all of the titles
	function getTitlesCount() external view returns(uint) {
		return _titles.length;
	}

  /// @notice Returns the title information
  /// @param _titleId The ID of the title
  function getTitle(uint _titleId) 
    external 
    view 
    returns(uint, uint, uint, uint, uint, uint, address, uint256) 
  {
    Titles storage titleInform = _titles[_titleId];
    return (
      titleInform.title_id,
      titleInform.vehicle_id,
      titleInform.dealer_id,
      titleInform.lender_id,
      titleInform.seller_id,
      titleInform.dmv_id,
      titleInform.ownerWallet,
      titleInform.createAt
    );
  }

  /// @notice Return holds status of the title
  /// @param _titleId The ID of title
  /// @param _holds_status_id The ID of holds status
  function getHoldsStatus(uint _titleId, uint8 _holds_status_id) 
    external 
    view 
    returns (bool, uint256) 
  {
    require( _holds_status_id < titleStatus[_titleId].length, "Invalid holds status index" );

    Holds_Status memory holds_status_info = titleStatus[_titleId][_holds_status_id];
    return (
      holds_status_info.status,
      holds_status_info.updateAt
    );
  }
  
  /**
  * @notice tokenURI overrride function.
  */
  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721)
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721URIStorage: URI query for nonexistent token"
    );
    string memory __baseURI;
    __baseURI = _baseURI();
    // Concatenate the unrevealBaseURI and tokenId (via abi.encodePacked).
    return
      bytes(__baseURI).length > 0
        ? string(abi.encodePacked(__baseURI, tokenId))
        : "";
  }

  /**
  * @notice _burn internal overrride function.
  */
  function _burn(uint256 tokenId)
    internal
    override(ERC721)
  {
    super._burn(tokenId);
  }

  /// @notice Hook being called before every transfer
	/// @param	_from		Token's original owner
	/// @param	_to			Token's new owner
	/// @param	_tokenId	Token's ID
	function _beforeTokenTransfer(address _from, address _to, uint256 _tokenId, uint256 _batchSize) 
    internal 
    virtual 
    override(ERC721Enumerable) 
  {
    require(_from == address(0) || _to == address(0), "RT ERC721: _from and _to should be available addresses");
		
		super._beforeTokenTransfer(_from, _to, _tokenId, _batchSize);
	}

  /**
  * @notice supportsInterface overrride function.
  */
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC165, AccessControlEnumerable, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  /**
  * @notice Mint new title.
  * @param _to The address of minter.
  * @param _vehicleURI The metadata URI of vehicle.
  * @param _dealerId The id of dealer.
  * @param _lenderId The id of lender.
  * @param _sellerId The id of seller.
  * @param _dmvId The id of DMV.
  * @param holds_number The number of holds status.
  */
  function mintTitle(
    address _to, 
    string memory _vehicleURI, 
    uint _dealerId, 
    uint _lenderId, 
    uint _sellerId,
    uint _dmvId,
    uint8 holds_number
  ) 
    public
  {
    require(_to != address(0), "The minter is wrong address");
    require(bytes(_vehicleURI).length > 0, "The vehicle URI is required");
    require(holds_number > 0, "The holds status number is required");

    uint256 _id = nextTokenId();
    _safeMint(_to, _id, "");
    incrementTokenId();

    vehicleURI[_id] = _vehicleURI;

    Titles storage newTitle = _titles.push();

    newTitle.title_id = _id;
    newTitle.vehicle_id = _id;
    newTitle.dealer_id = _dealerId;
    newTitle.lender_id = _lenderId;
    newTitle.seller_id = _sellerId;
    newTitle.dmv_id = _dmvId;
    newTitle.ownerWallet = _to;
    newTitle.createAt = block.timestamp;
    // newTitle.status = Status.Created;

    for(uint8 i = 0; i < holds_number; i++) {
      Holds_Status memory newStatus = Holds_Status(false, 0);
      titleStatus[_id].push(newStatus);
    } 

    emit TitleCreated(_to, _id);
  }

  /// @notice Updates the status of the title
  /// @param _titleId The ID of the title to update
  /// @param _state The status to be updated
  function updateTitleStatus(uint _titleId, uint8 holds_status_id, bool _state) external {
    require(holds_status_id < titleStatus[_titleId].length, "Invalid holds status index");

    Holds_Status storage _currentTitleStatus = titleStatus[_titleId][holds_status_id];

    _currentTitleStatus.status = _state;
    _currentTitleStatus.updateAt = block.timestamp;
    
    emit StatusUpdated(_titleId, holds_status_id, _state, _currentTitleStatus.updateAt);
  }

  /**
  * @return The list of all titles.
  */
  function getAllTitlesList() public view returns (uint256[] memory) {
    uint256[] memory _titlesList = new uint256[](
      ERC721Enumerable.totalSupply()
    );
    uint256 i;

    for (i = 0; i < ERC721Enumerable.totalSupply(); i++) {
      _titlesList[i] = ERC721Enumerable.tokenByIndex(i);
    }
    return (_titlesList);
  }

  /**
  * @notice A method to get the list of all tokens owned by any user.
  * @param _owner the owner address.
  * @return The list of tokens owned by any user.
  */
  function getTokensListOwnedByUser(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256[] memory _tokensOfOwner = new uint256[](
      ERC721.balanceOf(_owner)
    );
    uint256 i;

    for (i = 0; i < ERC721.balanceOf(_owner); i++) {
      _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(
        _owner,
        i
      );
    }
    return (_tokensOfOwner);
  }

  function nextTokenId() public view returns (uint256) {
    return lastTokenId + 1;
  }

  function incrementTokenId() internal {
    lastTokenId++;
  }

  /**
  * @notice get the Last token id.
  */
  function getLastTokenId() public view returns (uint256) {
    return lastTokenId;
  }

  /// @notice Queries if an operator can act on behalf of an owner on all of their tokens
	/// @dev Overrides the OpenZeppelin standard by allowing anyone with the DEALER role to transfer tokens
	/// @param owner 		Owner of the tokens.
	/// @param operator 	Operator of the tokens.
	function isApprovedForAll(address owner, address operator) public view virtual override(ERC721, IERC721) returns (bool) {
    return (hasRole(DEALER, operator) || super.isApprovedForAll(owner, operator));
  }
}
