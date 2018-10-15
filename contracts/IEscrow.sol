pragma solidity 0.4.24;

interface IEscrow {


    
    function deposit(uint256 _value) external;
    function dispute(uint256 _value) external;
    function approvalFullWithdrawal() external;
    function refund(uint256 _value) external;
    function fullWithdraw() external;
 
}