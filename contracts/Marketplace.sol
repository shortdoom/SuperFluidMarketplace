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
    event AgreementSigned(address indexed by, address indexed owner, uint256 agreementId);

    mapping(address => mapping(uint256 => Agreement)) agreementType;

    // NOTE: Change _typeOf to selection
    uint256 rentalType;
    uint256 mortageType;

    struct Agreement {
        string typeOf;
        uint256 amount;
        uint256 duration;
        bool signed;
        address payer;
    }
    constructor(string _name, string _symbol) ERC721(_name, _symbol) {
        // NOTE: Call URI method to set external data point. Otherwise there is no point to actually use ERC721 and we can simplify.
    }

    function openContract(string memory _typeOf, uint256 _amount, uint256 _duration) public {
        _agreementId.increment();
        uint256 agreementId = _agreementId.current();
        agreementType[msg.sender][agreementId] = Agreement({ typeOf: _typeOf, amount: _amount, duration: _duration, signed: false, payer: address(0) });
        _mint(msg.sender, agreementId);
        // NOTE: Generate underlying contract tied to NFT, e.g rental, lending, employment
        emit AgreementCreated(_typeOf, _amount, _duration);
    }

    function signContract(address contractOwner, uint256 _agreementId) public {
        agreementType[contractOwner][_agreementId].signed = true;
        agreementType[contractOwner][_agreementId].payer = msg.sender;
        // NOTE: Lock ERC721 transfer for now
        // NOTE: Deposit DAI into token stream
        emit AgreementSigned(msg.sender, contractOwner, _agreementId);
    }

}
