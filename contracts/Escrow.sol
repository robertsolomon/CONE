pragma solidity 0.4.24;
import "./custodial.sol";
import "./IEscrow.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/Safemath.sol";

contract Escrow is IEscro, Custodial {
    
    enum EscrowStatus {Active, InDispute, Approved, Settled}

    using SafeMath for uint256;
    ERC20 public currency;
    address public payer;
    address public payee;
    uint256 public value;
    uint256 disputeValue;
    EscrowStatus public status;

    modifier PayerOnly(address _contract) {
        require(payer == msg.sender, "Not payer in contract referenced");
        _;
    }

    modifier PayeeOnly(address _contract) {
        require(payee == msg.sender, "Not payee in contract referenced");
        _;
    }

    modifier OnlyActive(address _contract){
        require(contracts[_contract].state == AgreementState.active, "invalid state");
        _;
    }
    
    constructor(ERC20 _currency, address _payer, address _payee, uint256 _value, address _custodian) Custodial(_custodian) public {
        require(_payer != 0x0, "Invalid payer address");
        require(_payee != 0x0, "Invalid payee address");
        require(_value > 0, "escrow value must be greater than 0");

        //TODO: Is a assertion required for _currency that will cause collateral impacts
        currency = _currency;
        payer = _payer;
        payee = _payee;
        value = _value;
        fullReleaseApproved = false;
    }

    function deposit(uint256 _value) public PayerOnly()
    {
        require(_value > 0, "Invalid deposity");
        currency.transferFrom(msg.sender, address(this), _value);
    }
        
    function dispute(uint256 _value) public PayerOnly {
        require(value >= _value, "Disputed value exceeds the original escrow value");
        require(currency.balanceOf(address(this)) >= _value, "Disputed value exceeds the available escrow balance");
        
        disputeValue = _value;
        status = EscrowStatus.InDispute;
        //TODO: raise event
    }

    function approvalFullWithdrawal() public PayerOnly {
        require(state == EscrowStatus.Active, "Escrow in invalid state for full widthdrawal approval");
        status = EscrowStatus.Approved;
        //TODO: raise event;
    }

    function refund(uint256 _value) public onlyCustodian{
        require(state == EscrowStatus.InDisputej, "Contract is not in a disputed state for custodian to issue refund");
        require(disputeValue >= _value, "Refund exeeds disputed value");
        require(currency.balanceOf(address(this)) >= _value, "Refund value exceeds the available escrow balance");

        currency.transferFrom(address(this), _payer, _value);

        disputeValue == 0;
        status == EscrowStatus.Active;
        //rase event with refund and dispute values to idicate full or partial refund.
    }
    
    function fullWithdraw() public PayeeOnly {
        require(disputeValue == 0, "Cannot widthdraw until dispute is resolved");
        require(status == EscrowStatus.Approved, "Escrow is not in approved state for withdrawal");
        uint256 escrowBalance = current.balanceOf(address(this));
        currency.transFrom(addres(this), msg.sender, escrowBalance);
        status = EscrowStatus.Settled;
        //TODO: Raise event that escrow is settled
    }
}
