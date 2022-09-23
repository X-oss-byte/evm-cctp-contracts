/* SPDX-License-Identifier: UNLICENSED
 *
 * Copyright (c) 2022, Circle Internet Financial Trading Company Limited.
 * All rights reserved.
 *
 * Circle Internet Financial Trading Company Limited CONFIDENTIAL
 *
 * This file includes unpublished proprietary source code of Circle Internet
 * Financial Trading Company Limited, Inc. The copyright notice above does not
 * evidence any actual or intended publication of such source code. Disclosure
 * of this source code or any related proprietary information is strictly
 * prohibited without the express written permission of Circle Internet Financial
 * Trading Company Limited.
 */
pragma solidity ^0.7.6;

import "@memview-sol/contracts/TypedMemView.sol";
import "forge-std/Test.sol";
import "../../src/messages/BurnMessage.sol";

contract BurnMessageTest is Test {
    using TypedMemView for bytes;
    using TypedMemView for bytes29;
    using BurnMessage for bytes29;

    uint32 version = 1;

    function testFormatMessage_succeeds(
        bytes32 _burnToken,
        bytes32 _mintRecipient,
        uint256 _amount
    ) public {
        bytes memory _expectedMessageBody = abi.encodePacked(
            version,
            _burnToken,
            _mintRecipient,
            _amount
        );

        bytes memory _messageBody = BurnMessage.formatMessage(
            version,
            _burnToken,
            _mintRecipient,
            _amount
        );

        bytes29 _m = _messageBody.ref(0);
        assertEq(_m.getMintRecipient(), _mintRecipient);
        assertEq(_m.getBurnToken(), _burnToken);
        assertEq(_m.getAmount(), _amount);
        assertEq(uint256(_m.getVersion()), uint256(version));
        assertTrue(_m.isValidBurnMessage(version));

        assertEq(_expectedMessageBody.ref(0).keccak(), _m.keccak());
    }

    function testIsValidBurnMessage_returnsFalseForWrongVersion(
        bytes32 _burnToken,
        bytes32 _mintRecipient,
        uint256 _amount
    ) public {
        bytes memory _messageBody = BurnMessage.formatMessage(
            version,
            _burnToken,
            _mintRecipient,
            _amount
        );

        bytes29 _m = _messageBody.ref(0);
        assertEq(_m.getMintRecipient(), _mintRecipient);
        assertEq(_m.getBurnToken(), _burnToken);
        assertEq(_m.getAmount(), _amount);
        assertFalse(_m.isValidBurnMessage(2));
    }

    function testIsValidBurnMessage_returnsFalseForWrongLength(
        bytes32 _burnToken,
        bytes32 _mintRecipient,
        uint256 _amount
    ) public {
        bytes memory _tooLongMessageBody = abi.encodePacked(
            version,
            _burnToken,
            _mintRecipient,
            _amount,
            _amount // encode _amount twice (invalid)
        );

        bytes29 _m = _tooLongMessageBody.ref(0);
        assertEq(_m.getMintRecipient(), _mintRecipient);
        assertEq(_m.getBurnToken(), _burnToken);
        assertEq(_m.getAmount(), _amount);
        assertFalse(_m.isValidBurnMessage(2));
    }
}
