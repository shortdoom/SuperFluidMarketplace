// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

/**
User needs to have ability to start a contract of given definition between him and receiver.
From the perspective of both parties, interface needs to abstract technical difficulties.
User should be able to 
    a) choose a type of contract (rental / mortage / etc.)
    b) start streaming betwee him and receiver in context of chosen contract
    c) close / stop / dispute contract
 */

contract Marketplace is ERC721, SuperAppBase {
    ISuperfluid internal host;
    IConstantFlowAgreementV1 internal cfa;
    ISuperToken internal acceptedToken;
    Counters.Counter private _agreementId;

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

    constructor(
        string _name,
        string _symbol,
        address _host,
        address _cfa,
        address _acceptedToken
    ) ERC721(_name, _symbol) {
        require(address(_host) != address(0), "Host is zero address");
        require(address(_cfa) != address(0), "CFA is zero address");
        require(address(_acceptedToken) != address(0), "acceptedToken is zero address");

        host = _host;
        cfa = _cfa;
        acceptedToken = _acceptedToken;

        uint256 configWord =
            SuperAppDefinitions.APP_LEVEL_FINAL |
                SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
                SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        host.registerApp(configWord);
        // NOTE: Call URI method to set external data point. Otherwise there is no point to actually use ERC721 and we can simplify.
    }

    function openContract(
        string memory _typeOf,
        uint256 _amount,
        uint256 _duration
    ) public {
        _agreementId.increment();
        uint256 agreementId = _agreementId.current();
        agreementType[msg.sender][agreementId] = Agreement({
            typeOf: _typeOf,
            amount: _amount,
            duration: _duration,
            signed: false,
            payer: address(0)
        });
        _mint(msg.sender, agreementId);
        // NOTE: Generate underlying contract tied to NFT, e.g rental, lending, employment
        emit AgreementCreated(_typeOf, _amount, _duration);
    }

    function signContract(address contractOwner, uint256 agreementId) public {
        agreementType[contractOwner][agreementId].signed = true;
        agreementType[contractOwner][agreementId].payer = msg.sender;
        // NOTE: Lock ERC721 transfer for now
        // NOTE: Create constant flow agreement https://docs.superfluid.finance/superfluid/docs/constant-flow-agreement
        emit AgreementSigned(msg.sender, contractOwner, agreementId);
    }
}
