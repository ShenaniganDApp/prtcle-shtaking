// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

/******************************************************************************\
* Author: Nick Mudge
* Aavegotchi GHST Staking Diamond
* 18 October 2020
* 
* 
* Uses the diamond-2, version 1.3.4, diamond implementation:
* https://github.com/mudgen/diamond-2
/******************************************************************************/

import "./libraries/LibDiamond.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./interfaces/IDiamondCut.sol";
import "./interfaces/IERC173.sol";
import "./interfaces/IERC165.sol";
import "./libraries/AppStorage.sol";
import "./interfaces/IERC1155Metadata_URI.sol";

contract PRTCLEShtakingDiamond {
    AppStorage s;

    struct Input {
        address prtcleContract;
        address uniV2PoolContract;
        string[] stringHashes;
        uint96[] maxSupplies;
    }
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    constructor(
        IDiamondCut.FacetCut[] memory diamondCut,
        address owner,
        Input memory input
    ) {
        require(owner != address(0), "PRTCLEShtakingDiamond: _owner can't be address(0)");
        require(input.prtcleContract != address(0), "PRTCLEShtakingDiamond: _prtcleContract can't be address(0)");
        require(input.uniV2PoolContract != address(0), "PRTCLEShtakingDiamond: _uniV2PoolContract can't be address(0)");
        require(input.maxSupplies.length == input.stringHashes.length, "PRTCLEShtakingDiamond: Hashes and maxSupplies not of equal length");

        LibDiamond.diamondCut(diamondCut, address(0), new bytes(0));
        LibDiamond.setContractOwner(owner);
        s.prtcleContract = input.prtcleContract;
        s.uniV2PoolContract = input.uniV2PoolContract;
        s.stringHashes = input.stringHashes;
        for(uint256 i = 0; i < input.stringHashes.length; i++){
            s.strings[i].maxSupply = input.maxSupplies[i];
        }

         LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // ERC1155
        // ERC165 identifier for the main token standard.
        ds.supportedInterfaces[0xd9b67a26] = true;

        // ERC1155
        // ERC1155Metadata_URI
        ds.supportedInterfaces[IERC1155Metadata_URI.uri.selector] = true;

        // create wearable strings:
        emit TransferSingle(msg.sender, address(0), address(0), 0, 0);
     }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "GHSTSTaking: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
             returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {
        revert("PRTCLEShtaking: Does not accept ether");
    }
}
