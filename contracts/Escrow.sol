pragma solidity 0.4.24;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IPayment.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./StandardPayment.sol";

contract Escrow is Ownable{
    ERC20 public token;
    mapping(address => IPayment) public payments;
   
    constructor(ERC20 _token) public {
        token = _token;
    }

    function createEscrow(address _openLawId, address _payer, address _payee, uint256 _value, address _custodian) 
        public returns(address payment){
        payments[_openLawId] = new StandardPayment(token, _payer, _payee, _value, _custodian);
        return payments[_openLawId];
    }
}
