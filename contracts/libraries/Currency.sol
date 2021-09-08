// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "./Random.sol";

library Currency {
    uint256 internal constant MOD_FOUR = 2;
    uint256 internal constant MOD_TWO = 3;
    uint256 internal constant ADD_TWO = 4;
    uint256 internal constant ADD_FOUR = 5;
    uint256 internal constant REMOVE = 6;
    uint256 internal constant AUGMENT_TWO = 7;
    uint256 internal constant AUGUMENT_FOUR = 8;
    uint256 internal constant MEM_COPY = 9;
    uint256 internal constant START_INDEX = 10;

    error ModifyError();

    /// @return Count of attribute Ids > 0
    function amountOf(uint256[4] memory params)
        internal
        pure
        returns (uint256)
    {
        uint256 len = params.length;
        uint256 count;
        for (uint256 i; i < len; i++) {
            uint256 value = params[i];
            if (value > 0) count++;
        }
        return count;
    }

    function slot(string memory prefix, uint256 seed)
        internal
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(prefix, seed))) % 1000000;
    }

    /// @notice Modifies an array of values which are the tokenIds for the attributes
    /// @param currencyId Type of currency being used
    /// @param params Values to manipulate; directly converted to attributes
    /// @param seed Pseudorandom value hopefully generated through a commit-reveal scheme
    function modify(
        uint256 currencyId,
        uint256[4] memory params,
        uint256 seed
    ) internal returns (uint256[4] memory) {
        seed = seed % 10000;
        uint256 len = params.length;
        uint256 count = amountOf(params); // count how many properties are > 0

        // adds a property to a one property item
        if (currencyId == AUGMENT_TWO) {
            if (count != 1) revert ModifyError();
            // for each attribute, find the currently set one and modify the one above it
            for (uint256 i; i < len; i++) {
                uint256 value = params[i];
                // if its the last one, set the first slot
                if (i == len - 1) params[0] = slot("SLOT0", seed);
                if (value > 0) params[i + 1] = slot("SLOT1", seed);
            }
        }

        // adds a property to a three property item
        if (currencyId == AUGUMENT_FOUR) {
            if (count != 3) revert ModifyError();
            // for each attribute, find the one that is not set, and modify it
            for (uint256 i; i < len; i++) {
                uint256 value = params[i];
                // if its the last one, set the first slot
                if (value == 0) params[i] = slot("SLOT1", seed);
            }
        }

        // deletes all properties
        if (currencyId == REMOVE) {
            // for each attribute, find the one that is set, and set it to 0
            for (uint256 i; i < len; i++) {
                uint256 value = params[i];
                // if its not 0, set it to 0
                if (value > 0) params[i] = 0;
            }
        }

        // adds up to two properties to a zero property item
        if (currencyId == ADD_TWO) {
            if (count > 0) revert ModifyError();
            if (seed > 5000) params[1] = slot("SLOT1", seed);
            else params[len - 1] = slot("SLOT2", seed);
        }

        // adds up to four properties to a zero property item
        if (currencyId == ADD_FOUR) {
            if (count > 0) revert ModifyError();
            for (uint256 i; i < len; i++) {
                // if its the last one, set the first slot
                if (seed > 9000) params[i] = 0;
                else params[i] = slot("SLOT1", seed);
            }
        }

        // modifies up to four properties on a max four property item
        if (currencyId == MOD_FOUR) {
            if (seed > 9000) params = update(seed, 1);
            else if (seed < 500) params = update(seed, 2);
            else if (seed < 9000 && seed > 7000) params = update(seed, 3);
            else params = update(seed, 4);
        }

        // modifies up to two properties on a max two property item
        if (currencyId == MOD_TWO) {
            if (count > 2) revert ModifyError();
            if (seed > 5000) params = update(seed, 1);
            else params = update(seed, 2);
        }

        return params;
    }

    /// @notice Updates an array of values up to `max` using `seed`
    function update(uint256 seed, uint256 max)
        internal
        returns (uint256[4] memory)
    {
        uint256[4] memory params;
        uint256 updated = 1;
        params[0] = slot("SLOT0", seed);
        if (updated >= max) return params;
        updated++;
        params[1] = slot("SLOT1", seed);
        if (updated >= max) return params;
        updated++;
        params[2] = slot("SLOT2", seed);
        if (updated >= max) return params;
        params[3] = slot("SLOT3", seed);
        return params;
    }
}
