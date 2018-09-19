pragma solidity ^0.4.24;

import "ds-test/test.sol";

// pragma solidity ^0.4.24;

// import "../lib/ds-test/src/test.sol";


/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.
/// @author Stefan George - <stefan@gnosis.pm>

// Mix this into contracts you'd like to be "proxyable",
// masterCopy must be the first var in any proxied contract in order to work correctly.
contract Proxyable {
    address masterCopy;
}

contract Proxy is Proxyable {

    /// @dev Constructor function sets address of master copy contract.
    /// @param _masterCopy Master copy address.
    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    function ()
        external
        payable
    {
        assembly {
            let masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(sub(gas, 703), masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

// Proxy contract DSTest

contract Foo is Proxyable {

    function testFunc() public view returns(uint) {
        return 42;
    }

}

contract ProxyTest is DSTest {
    Foo fooMaster;
    Foo foo;

    function setUp() public {
        fooMaster = new Foo();
        Proxy fooProxy = new Proxy(address(fooMaster));
        foo = Foo(address(fooProxy));
    }

    function testFooMaster() public {
        assertEq(fooMaster.testFunc(), 42);
    }

    function testFooProxy() public {
        assertEq(foo.testFunc(), 42);
    }

}