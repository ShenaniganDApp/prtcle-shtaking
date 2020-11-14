// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "../libraries/AppStorage.sol";
import "../libraries/LibDiamond.sol";
import "../libraries/LibERC20.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC1155TokenReceiver.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract StakingFacet {
    AppStorage internal s;
    bytes4 internal constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // Return value from `onERC1155BatchReceived` call if a contract accepts receipt (i.e `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    function shweatPrtcles(address _account) public view returns (uint256 shweatParticles_) {
        Account memory account = s.accounts[_account];
        // this cannot underflow or overflow
        uint256 timePeriod = block.timestamp - account.lastUpdate;
        shweatParticles_ = account.shweatPrtcles;
        // 86400 the number of seconds in 1 day
        // 100 shweatPrtcles are generated for each LP token over 24 hours
        shweatParticles_ += ((uint256(account.uniV2PoolTokens) * 100) * timePeriod) / 86400;
        // 1 sweatPrtcle is generated for each PRTCLE over 24 hours
        shweatParticles_ += (account.prtcle * timePeriod) / 86400;
    }

    function updateShweatPrtcles() internal {
        Account storage account = s.accounts[msg.sender];
        account.shweatPrtcles = uint104(shweatPrtcles(msg.sender));
        account.lastUpdate = uint40(block.timestamp);
    }

    function stakePrtcle(uint256 _prtcleValue) external {
        updateShweatPrtcles();
        s.accounts[msg.sender].prtcle += uint96(_prtcleValue);
        LibERC20.transferFrom(s.prtcleContract, msg.sender, address(this), _prtcleValue);
    }

    function stakeUniV2PoolTokens(uint256 _uniV2PoolTokens) external {
        updateShweatPrtcles();
        s.accounts[msg.sender].uniV2PoolTokens += uint96(_uniV2PoolTokens);
        LibERC20.transferFrom(s.uniV2PoolContract, msg.sender, address(this), _uniV2PoolTokens);
    }

    function staked(address _account) external view returns (uint256 prtcle_, uint256 uniV2PoolTokens_) {
        prtcle_ = s.accounts[_account].prtcle;
        uniV2PoolTokens_ = s.accounts[_account].uniV2PoolTokens;
    }

    function withdrawPrtcleStake(uint256 _prtcleValue) external {
        updateShweatPrtcles();
        uint256 bal = s.accounts[msg.sender].prtcle;
        require(bal >= _prtcleValue, "Staking: Can't withdraw more than staked");
        s.accounts[msg.sender].prtcle = uint96(bal - _prtcleValue);
        LibERC20.transfer(s.prtcleContract, msg.sender, _prtcleValue);
    }

    function withdrawUniV2PoolStake(uint256 _uniV2PoolTokens) external {
        updateShweatPrtcles();
        uint256 bal = s.accounts[msg.sender].uniV2PoolTokens;
        require(bal >= _uniV2PoolTokens, "Staking: Can't withdraw more than staked");
        s.accounts[msg.sender].uniV2PoolTokens = uint96(bal - _uniV2PoolTokens);
        LibERC20.transfer(s.uniV2PoolContract, msg.sender, _uniV2PoolTokens);
    }

    function withdrawPrtcleStake() external {
        updateShweatPrtcles();
        uint256 bal = s.accounts[msg.sender].prtcle;
        s.accounts[msg.sender].prtcle = uint96(0);
        LibERC20.transfer(s.prtcleContract, msg.sender, bal);
    }

    function withdrawUniV2PoolStake() external {
        updateShweatPrtcles();
        uint256 bal = s.accounts[msg.sender].uniV2PoolTokens;
        s.accounts[msg.sender].uniV2PoolTokens = uint96(0);
        LibERC20.transfer(s.uniV2PoolContract, msg.sender, bal);
    }

    function claimStrings(uint256[] calldata _ids, uint256[] calldata _values) external {
        require(_ids.length == _values.length, "Staking: _ids not the same length as _values");
        updateShweatPrtcles();
        uint256 shweatPrtclesBal = s.accounts[msg.sender].shweatPrtcles;
        for (uint256 i; i < _ids.length; i++) {
            uint256 id = _ids[i];
            require(s.strings[id].totalSupply < s.strings[id].maxSupply, "Staking: Max supply has been execeed");
            uint256 value = _values[i];
            require(id < 1, "Staking: String not found");
            uint256 cost = stringCost(id) * value;
            require(shweatPrtclesBal >= cost, "Staking: Not enough Shweat Prtcles");
            shweatPrtclesBal -= cost;
            s.strings[id].accountBalances[msg.sender] += value;
            s.strings[id].totalSupply += uint96(value);
        }
        s.accounts[msg.sender].shweatPrtcles = uint104(shweatPrtclesBal);
        emit TransferBatch(msg.sender, address(0), msg.sender, _ids, _values);
        uint256 size;
        address to = msg.sender;
        assembly {
            size := extcodesize(to)
        }
        if (size > 0) {
            require(
                ERC1155_BATCH_ACCEPTED ==
                    IERC1155TokenReceiver(msg.sender).onERC1155BatchReceived(msg.sender, address(0), _ids, _values, new bytes(0)),
                "Staking: Ticket transfer rejected/failed"
            );
        }
    }

    function stringCost(uint256 _id) public pure returns (uint256 _shweatPrtclesCost) {
        if (_id == 0) {
            _shweatPrtclesCost = 1_000_000e18;
        } else {
            revert("Staking: _id does not exist");
        }
    }
}
