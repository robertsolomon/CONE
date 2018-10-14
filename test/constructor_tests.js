
'use strict'
const Token = artifacts.require('./Escrow.sol');
const expectRevert = require('./exception_util');

contract('EscrowToken', ([erc20, custodian]) => {
    describe('Verify Token Construction - Addresses', () => {        
   
        it('0x0 address should fail construction in any address position', async () => {
            await expectRevert(Token.new)('0xb7720ee9db407f21fdf6277195cf1853513a7885', custodian);
        })
    })
});