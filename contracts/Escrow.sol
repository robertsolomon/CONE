pragma solidity 0.4.24;
import "./custodial.sol";
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract Escrow is Custodial {
    address token;
    struct Agreement  {
        bool redeemable;
        address payer;
        address payee; 
        uint amount;
        uint expiry;
        bool settled;
    }
    mapping(address => Agreement) contracts;

    constructor(ERC20 _token, address _custodian) public Custodial(_custodian) {
        token = _token;
    }

    modifier PayerOnly(address _contract) {
        require(contracts[_contract].payer == msg.sender, "Not payer in contract referenced");
        _;
    }

    modifier PayeeOnly(address _contract) {
        require(contracts[_contract].payee == msg.sender, "Not payee in contract referenced");
        _;
    }

    function createAgreement(address _contract, address _payer, address _payee, uint _amount, uint _expiry) public {
        contracts[_contract].payer = _payer;
        contracts[_contract].payee = _payee;
        contracts[_contract].amount = _amount;
        contracts[_contract].expiry = _expiry;
        contracts[_contract].redeemable = false;
    }

    function makeRedeemable (address _contract) public PayerOnly(_contract)
    {
        contracts[_contract].redeemable = true;
    }

    function redeem (address _contract) public PayeeOnly(_contract)
    {
        require(contracts[_contract].redeemable == true, "Contract not available for redemption");
        contracts[_contract].settled = true;
        token.transfer(contracts[_contract].payer, contracts[_contract].payee, contracts[_contract].amount);
    }
}
