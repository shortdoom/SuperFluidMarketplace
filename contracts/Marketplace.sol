// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
User needs to have ability to start a contract of given definition between him and receiver.
From the perspective of both parties, interface needs to abstract technical difficulties.
User should be able to 
    a) choose a type of contract (rental / mortage / etc.)
    b) start streaming betwee him and receiver in context of chosen contract
    c) close / stop / dispute contract
 */

contract Marketplace is ERC721 {

    event AgreementCreated(string indexed typeOf, uint256 amount, uint256 duration);
    mapping(address => mapping(uint256 => Agreement)) agreementType;

    uint256

    struct Agreement {
        string typeOf;
        uint256 amount;
        uint256 duration;
        bool signed;
    }
    constructor(string _name, string _symbol) ERC721(_name, _symbol) {}

    function openContract(string memory _typeOf, uint256 _amount, uint256 _duration) public {
        _agreementId.increment();
        uint256 agreementId = _agreementId.current();
        agreementType[msg.sender][agreementId] = Agreement({ typeOf: _typeOf, amount: _amount, duration: _duration, signed: false });
        _mint(msg.sender, agreementId);
        emit AgreementCreated(_typeOf, _amount, _duration);
    }

    function signContract(address contractOwner, uint256 _agreementId) public {

    }

}
