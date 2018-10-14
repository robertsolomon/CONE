pragma solidity 0.4.24;
import "./custodial.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Escrow is Refundable {
    modifier PayerOnly(address _contract) {
        require(contracts[_contract].payer == msg.sender, "Not payer in contract referenced");
        _;
    }

    modifier PayeeOnly(address _contract) {
        require(contracts[_contract].payee == msg.sender, "Not payee in contract referenced");
        _;
    }

    modifier OnlyActive(address _contract){
        require(contracts[_contract].state == AgreementState.active, "invalid state");
        _;
    }

    ERC20 token;

    enum PaymentStatus {Pending, Active, InDispute, Refunded, Completed }

    event PaymentCreated (address indexed _contract, address indexed _payer, address indexed _payee, uint256 _amount);
    event EscrowDisputed(address indexed _contract, address indexed _payer, address indexed _payee, uint256 _amount);
    event PaymentCompleted(address indexed _contract, address indexed _payer, address indexed _payee, uint256 _amount);
    
    struct Payment  {
        address payer;
        address payee; 
        uint256 value;
        uint256 expiry;
        PaymentStatus status;
        bool claimable;
    }

    mapping(address => Payment) public payments;

    constructor(ERC20 _currency, address _custodian) public Custodial(_custodian) {
        require(_custodian != 0x0, "can not assigned 0x0 as custodian");
        token = _currency;
    }

 
    function createPayment(address _contract, address _payer, address _payee, uint256 _value, uint256 _expiry) public {
        payments[_contract] = Payment(_payer, _payee, _value, _expiry, PaymetStatus.Active, false);
    }

    function deposit(){

    }
    
    function makeRedeemable (address _contract) public PayerOnly(_contract) OnlyActive(_contract)
    {
        contracts[_contract].redeemable = true;
    }

    function redeem (address _contract) public PayeeOnly(_contract)
    {
        require(contracts[_contract].redeemable == true, "Contract not available for redemption");
        contracts[_contract].settled = true;
        token.transferFrom(contracts[_contract].payer, contracts[_contract].payee, contracts[_contract].amount);
    }
}
