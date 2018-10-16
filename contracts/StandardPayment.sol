pragma solidity 0.4.24;
import "./custodial.sol";
import "./IPayment.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/Safemath.sol";

contract StandardPayment is IPayment, Custodial {
    
    enum PaymentStatus {Active, InDispute, Approved, Settled}

    using SafeMath for uint256;
    ERC20 public currency;
    address public payer;
    address public payee;
    uint256 public value;
    uint256 disputeValue;
    PaymentStatus public status;

    modifier PayerOnly() {
        require(payer == msg.sender, "Not payer in contract referenced");
        _;
    }

    modifier PayeeOnly() {
        require(payee == msg.sender, "Not payee in contract referenced");
        _;
    }
    
    constructor(ERC20 _currency, address _payer, address _payee, uint256 _value, address _custodian) Custodial(_custodian) public {
        require(_payer != 0x0, "Invalid payer address");
        require(_payee != 0x0, "Invalid payee address");
        require(_value > 0, "escrow value must be greater than 0");

        currency = _currency;
        payer = _payer;
        payee = _payee;
        value = _value;
        status = PaymentStatus.Active;
    }

    function deposit(uint256 _value) public PayerOnly()
    {
        require(_value > 0, "Invalid deposity");
        currency.transferFrom(msg.sender, address(this), _value);
    }
        
    function dispute(uint256 _value) public PayerOnly {
        require(disputeValue == 0, "prior dispute unresolved");
        require(status == PaymentStatus.Active, "Escrow is not in an active state to dispute");
        require(value >= _value, "Disputed value exceeds the original escrow value");
        require(currency.balanceOf(address(this)) >= _value, "Disputed value exceeds the available escrow balance");
        
        disputeValue = _value;
        status = PaymentStatus.InDispute;
        //TODO: raise event
    }

    function approvalFullWithdrawal() public PayerOnly {
        require(status == PaymentStatus.Active, "Escrow in invalid state for full widthdrawal approval");
        status = PaymentStatus.Approved;
        //TODO: raise event;
    }

    function refund(uint256 _payerRefund, uint256 _payeeRefund) public onlyCustodian{

        ///TODO: Add additinal value for split refund 
        uint256 totalRefund = _payerRefund.add(_payeeRefund);
        require(status == PaymentStatus.InDispute, "Contract is not in a disputed state for custodian to issue refund");
        require(disputeValue >= totalRefund, "Refund exeeds disputed value");
        require(currency.balanceOf(address(this)) >= totalRefund, "Refund value exceeds the available escrow balance");

        disputeValue == 0;
        status == PaymentStatus.Active;

        currency.transferFrom(address(this), payer, _payerRefund);
        currency.transferFrom(address(this), payee, _payeeRefund);

        //rase event with refund and dispute values to idicate full or partial refund.
    }
    
    function fullWithdraw() public PayeeOnly {
        require(disputeValue == 0, "Cannot widthdraw until dispute is resolved");
        require(status == PaymentStatus.Approved, "Escrow is not in approved state for withdrawal");
        uint256 escrowBalance = currency.balanceOf(address(this));
        currency.transferFrom(address(this), msg.sender, escrowBalance);
        status = PaymentStatus.Settled;
        //TODO: Raise event that escrow is settled
    }
}
