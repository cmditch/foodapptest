pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./Footest.sol";

contract FootestTest is DSTest {
    Footest footest;

    function setUp() public {
        footest = new Footest();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
