// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IGaugeFactory {
    function createGauge(address, address, address, bool, address[] memory) external returns (address);
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

interface IBribe {
    function _deposit(uint amount, uint tokenId) external;
    function _withdraw(uint amount, uint tokenId) external;
    function getRewardForOwner(uint tokenId, address[] memory tokens) external;
    function notifyRewardAmount(address token, uint amount) external;
    function left(address token) external view returns (uint);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IGauge {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(address account, address[] memory tokens) external;
    function left(address token) external view returns (uint);
    function stake() external view returns (address);
}

interface IOptionToken {
    function mint(address _to, uint256 _amount) external;
    function exercise(
        uint256 _amount,
        uint256 _maxPaymentAmount,
        address _recipient
    ) external returns (uint256);
    function paymentToken() external returns (address);
    function underlyingToken() external returns (address);
    function getDiscountedPrice(uint256 _amount) external view returns (uint256);
}

interface IVoter {
    function _ve() external view returns (address);
    function governor() external view returns (address);
    function emergencyCouncil() external view returns (address);
    function attachTokenToGauge(uint _tokenId, address account) external;
    function detachTokenFromGauge(uint _tokenId, address account) external;
    function emitDeposit(uint _tokenId, address account, uint amount) external;
    function emitWithdraw(uint _tokenId, address account, uint amount) external;
    function isWhitelisted(address token) external view returns (bool);
    function notifyRewardAmount(uint amount) external;
    function distribute(address _gauge) external;
    function gauges(address) external view returns (address);
}

interface IVotingEscrow {

    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    function token() external view returns (address);
    function team() external returns (address);
    function epoch() external view returns (uint);
    function point_history(uint loc) external view returns (Point memory);
    function user_point_history(uint tokenId, uint loc) external view returns (Point memory);
    function user_point_epoch(uint tokenId) external view returns (uint);

    function ownerOf(uint) external view returns (address);
    function isApprovedOrOwner(address, uint) external view returns (bool);
    function transferFrom(address, address, uint) external;

    function voting(uint tokenId) external;
    function abstain(uint tokenId) external;
    function attach(uint tokenId) external;
    function detach(uint tokenId) external;

    function checkpoint() external;
    function deposit_for(uint tokenId, uint value) external;
    function create_lock_for(uint, uint, address) external returns (uint);

    function balanceOfNFT(uint) external view returns (uint);
    function totalSupply() external view returns (uint);
}

// Gauges are used to incentivize pools, they emit reward tokens over 7 days for staked LP tokens
contract Gauge is IGauge {

    address public immutable stake; // the LP token that needs to be staked for rewards
    address public immutable _ve; // the ve token used for gauges
    address public immutable external_bribe;
    address public immutable voter;
    address public immutable kus;
    address public immutable gaugeFactory;
    address public oKus;

    uint public derivedSupply;
    mapping(address => uint) public derivedBalances;

    bool public isForPair;

    uint internal constant DURATION = 7 days; // rewards are released over 7 days
    uint internal constant PRECISION = 10 ** 18;
    uint internal constant MAX_REWARD_TOKENS = 4;

    // default snx staking contract implementation
    mapping(address => uint) public rewardRate;
    mapping(address => uint) public periodFinish;
    mapping(address => uint) public lastUpdateTime;
    mapping(address => uint) public rewardPerTokenStored;

    mapping(address => mapping(address => uint)) public lastEarn;
    mapping(address => mapping(address => uint)) public userRewardPerTokenStored;

    mapping(address => uint) public tokenIds;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    address[] public rewards;
    mapping(address => bool) public isReward;

    /// @notice A checkpoint for marking balance
    struct Checkpoint {
        uint timestamp;
        uint balanceOf;
    }

    /// @notice A checkpoint for marking reward rate
    struct RewardPerTokenCheckpoint {
        uint timestamp;
        uint rewardPerToken;
    }

    /// @notice A checkpoint for marking supply
    struct SupplyCheckpoint {
        uint timestamp;
        uint supply;
    }

    /// @notice A record of balance checkpoints for each account, by index
    mapping (address => mapping (uint => Checkpoint)) public checkpoints;
    /// @notice The number of checkpoints for each account
    mapping (address => uint) public numCheckpoints;
    /// @notice A record of balance checkpoints for each token, by index
    mapping (uint => SupplyCheckpoint) public supplyCheckpoints;
    /// @notice The number of checkpoints
    uint public supplyNumCheckpoints;
    /// @notice A record of balance checkpoints for each token, by index
    mapping (address => mapping (uint => RewardPerTokenCheckpoint)) public rewardPerTokenCheckpoints;
    /// @notice The number of checkpoints for each token
    mapping (address => uint) public rewardPerTokenNumCheckpoints;

    uint public fees0;
    uint public fees1;

    event Deposit(address indexed from, uint tokenId, uint amount);
    event Withdraw(address indexed from, uint tokenId, uint amount);
    event NotifyReward(address indexed from, address indexed reward, uint amount);
    event ClaimRewards(address indexed from, address indexed reward, uint amount);
    event OKusSet(address indexed _oKus);

    constructor(address _stake, address _external_bribe, address  __ve, address _voter, address _oKus, address _gaugeFactory, bool _forPair, address[] memory _allowedRewardTokens) {
        stake = _stake;
        external_bribe = _external_bribe;
        _ve = __ve;
        voter = _voter;
        oKus = _oKus;
        gaugeFactory = _gaugeFactory;
        isForPair = _forPair;
        kus = IVotingEscrow(_ve).token();
        _safeApprove(kus, oKus, type(uint256).max);

        for (uint i; i < _allowedRewardTokens.length; i++) {
            if (_allowedRewardTokens[i] != address(0)) {
                isReward[_allowedRewardTokens[i]] = true;
                rewards.push(_allowedRewardTokens[i]);
            }
        }
    }

    // simple re-entrancy check
    uint internal _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    /**
    * @notice Determine the prior balance for an account as of a block number
    * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
    * @param account The address of the account to check
    * @param timestamp The timestamp to get the balance at
    * @return The balance the account had as of the given block
    */
    function getPriorBalanceIndex(address account, uint timestamp) public view returns (uint) {
        uint nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].timestamp <= timestamp) {
            return (nCheckpoints - 1);
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].timestamp > timestamp) {
            return 0;
        }

        uint lower = 0;
        uint upper = nCheckpoints - 1;
        while (upper > lower) {
            uint center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.timestamp == timestamp) {
                return center;
            } else if (cp.timestamp < timestamp) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return lower;
    }

    function getPriorSupplyIndex(uint timestamp) public view returns (uint) {
        uint nCheckpoints = supplyNumCheckpoints;
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (supplyCheckpoints[nCheckpoints - 1].timestamp <= timestamp) {
            return (nCheckpoints - 1);
        }

        // Next check implicit zero balance
        if (supplyCheckpoints[0].timestamp > timestamp) {
            return 0;
        }

        uint lower = 0;
        uint upper = nCheckpoints - 1;
        while (upper > lower) {
            uint center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            SupplyCheckpoint memory cp = supplyCheckpoints[center];
            if (cp.timestamp == timestamp) {
                return center;
            } else if (cp.timestamp < timestamp) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return lower;
    }

    function getPriorRewardPerToken(address token, uint timestamp) public view returns (uint, uint) {
        uint nCheckpoints = rewardPerTokenNumCheckpoints[token];
        if (nCheckpoints == 0) {
            return (0,0);
        }

        // First check most recent balance
        if (rewardPerTokenCheckpoints[token][nCheckpoints - 1].timestamp <= timestamp) {
            return (rewardPerTokenCheckpoints[token][nCheckpoints - 1].rewardPerToken, rewardPerTokenCheckpoints[token][nCheckpoints - 1].timestamp);
        }

        // Next check implicit zero balance
        if (rewardPerTokenCheckpoints[token][0].timestamp > timestamp) {
            return (0,0);
        }

        uint lower = 0;
        uint upper = nCheckpoints - 1;
        while (upper > lower) {
            uint center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            RewardPerTokenCheckpoint memory cp = rewardPerTokenCheckpoints[token][center];
            if (cp.timestamp == timestamp) {
                return (cp.rewardPerToken, cp.timestamp);
            } else if (cp.timestamp < timestamp) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return (rewardPerTokenCheckpoints[token][lower].rewardPerToken, rewardPerTokenCheckpoints[token][lower].timestamp);
    }

    function _writeCheckpoint(address account, uint balance) internal {
        uint _timestamp = block.timestamp;
        uint _nCheckPoints = numCheckpoints[account];

        if (_nCheckPoints > 0 && checkpoints[account][_nCheckPoints - 1].timestamp == _timestamp) {
            checkpoints[account][_nCheckPoints - 1].balanceOf = balance;
        } else {
            checkpoints[account][_nCheckPoints] = Checkpoint(_timestamp, balance);
            numCheckpoints[account] = _nCheckPoints + 1;
        }
    }

    function _writeRewardPerTokenCheckpoint(address token, uint reward, uint timestamp) internal {
        uint _nCheckPoints = rewardPerTokenNumCheckpoints[token];

        if (_nCheckPoints > 0 && rewardPerTokenCheckpoints[token][_nCheckPoints - 1].timestamp == timestamp) {
            rewardPerTokenCheckpoints[token][_nCheckPoints - 1].rewardPerToken = reward;
        } else {
            rewardPerTokenCheckpoints[token][_nCheckPoints] = RewardPerTokenCheckpoint(timestamp, reward);
            rewardPerTokenNumCheckpoints[token] = _nCheckPoints + 1;
        }
    }

    function _writeSupplyCheckpoint() internal {
        uint _nCheckPoints = supplyNumCheckpoints;
        uint _timestamp = block.timestamp;

        if (_nCheckPoints > 0 && supplyCheckpoints[_nCheckPoints - 1].timestamp == _timestamp) {
            supplyCheckpoints[_nCheckPoints - 1].supply = derivedSupply;
        } else {
            supplyCheckpoints[_nCheckPoints] = SupplyCheckpoint(_timestamp, derivedSupply);
            supplyNumCheckpoints = _nCheckPoints + 1;
        }
    }

    function rewardsListLength() external view returns (uint) {
        return rewards.length;
    }

    // returns the last time the reward was modified or periodFinish if the reward has ended
    function lastTimeRewardApplicable(address token) public view returns (uint) {
        return Math.min(block.timestamp, periodFinish[token]);
    }

    function getReward(address account, address[] memory tokens) external lock {
        require(msg.sender == account || msg.sender == voter);
        _unlocked = 1;
        IVoter(voter).distribute(address(this));
        _unlocked = 2;

        for (uint i = 0; i < tokens.length; i++) {
            (rewardPerTokenStored[tokens[i]], lastUpdateTime[tokens[i]]) = _updateRewardPerToken(tokens[i], type(uint).max, true);

            uint _reward = earned(tokens[i], account);
            lastEarn[tokens[i]][account] = block.timestamp;
            userRewardPerTokenStored[tokens[i]][account] = rewardPerTokenStored[tokens[i]];
            if (_reward > 0) {
                if (tokens[i] == kus) {
                    try IOptionToken(oKus).mint(account, _reward){} catch {
                        _safeTransfer(tokens[i], account, _reward);
                    }
                } else {
                    _safeTransfer(tokens[i], account, _reward);
                }
            }

            emit ClaimRewards(msg.sender, tokens[i], _reward);
        }

        uint _derivedBalance = derivedBalances[account];
        derivedSupply -= _derivedBalance;
        _derivedBalance = derivedBalance(account);
        derivedBalances[account] = _derivedBalance;
        derivedSupply += _derivedBalance;

        _writeCheckpoint(account, derivedBalances[account]);
        _writeSupplyCheckpoint();
    }

    function rewardPerToken(address token) public view returns (uint) {
        if (derivedSupply == 0) {
            return rewardPerTokenStored[token];
        }
        return rewardPerTokenStored[token] + ((lastTimeRewardApplicable(token) - Math.min(lastUpdateTime[token], periodFinish[token])) * rewardRate[token] * PRECISION / derivedSupply);
    }

    function derivedBalance(address account) public view returns (uint) {
        return balanceOf[account];
    }

    function batchRewardPerToken(address token, uint maxRuns) external {
        (rewardPerTokenStored[token], lastUpdateTime[token])  = _batchRewardPerToken(token, maxRuns);
    }

    function _batchRewardPerToken(address token, uint maxRuns) internal returns (uint, uint) {
        uint _startTimestamp = lastUpdateTime[token];
        uint reward = rewardPerTokenStored[token];

        if (supplyNumCheckpoints == 0) {
            return (reward, _startTimestamp);
        }

        if (rewardRate[token] == 0) {
            return (reward, block.timestamp);
        }

        uint _startIndex = getPriorSupplyIndex(_startTimestamp);
        uint _endIndex = Math.min(supplyNumCheckpoints-1, maxRuns);

        for (uint i = _startIndex; i < _endIndex; i++) {
            SupplyCheckpoint memory sp0 = supplyCheckpoints[i];
            if (sp0.supply > 0) {
                SupplyCheckpoint memory sp1 = supplyCheckpoints[i+1];
                (uint _reward, uint _endTime) = _calcRewardPerToken(token, sp1.timestamp, sp0.timestamp, sp0.supply, _startTimestamp);
                reward += _reward;
                _writeRewardPerTokenCheckpoint(token, reward, _endTime);
                _startTimestamp = _endTime;
            }
        }

        return (reward, _startTimestamp);
    }

    function _calcRewardPerToken(address token, uint timestamp1, uint timestamp0, uint supply, uint startTimestamp) internal view returns (uint, uint) {
        uint endTime = Math.max(timestamp1, startTimestamp);
        return (((Math.min(endTime, periodFinish[token]) - Math.min(Math.max(timestamp0, startTimestamp), periodFinish[token])) * rewardRate[token] * PRECISION / supply), endTime);
    }

    /// @dev Update stored rewardPerToken values without the last one snapshot
    ///      If the contract will get "out of gas" error on users actions this will be helpful
    function batchUpdateRewardPerToken(address token, uint maxRuns) external {
      (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, maxRuns, false);
    }

    function _updateRewardForAllTokens() internal {
      uint length = rewards.length;
      for (uint i; i < length; i++) {
        address token = rewards[i];
        (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, type(uint).max, true);
      }
    }

    function _updateRewardPerToken(address token, uint maxRuns, bool actualLast) internal returns (uint, uint) {
        uint _startTimestamp = lastUpdateTime[token];
        uint reward = rewardPerTokenStored[token];

        if (supplyNumCheckpoints == 0) {
            return (reward, _startTimestamp);
        }

        if (rewardRate[token] == 0) {
            return (reward, block.timestamp);
        }

        uint _startIndex = getPriorSupplyIndex(_startTimestamp);
        uint _endIndex = Math.min(supplyNumCheckpoints - 1, maxRuns);

        if (_endIndex > 0) {
            for (uint i = _startIndex; i <= _endIndex - 1; i++) {
                SupplyCheckpoint memory sp0 = supplyCheckpoints[i];
                if (sp0.supply > 0) {
                    SupplyCheckpoint memory sp1 = supplyCheckpoints[i+1];
                    (uint _reward, uint _endTime) = _calcRewardPerToken(token, sp1.timestamp, sp0.timestamp, sp0.supply, _startTimestamp);
                    reward += _reward;
                    _writeRewardPerTokenCheckpoint(token, reward, _endTime);
                    _startTimestamp = _endTime;
                }
            }
        }

        // need to override the last value with actual numbers only on deposit/withdraw/claim/notify actions
        if (actualLast) {
            SupplyCheckpoint memory sp = supplyCheckpoints[_endIndex];
            if (sp.supply > 0) {
                (uint _reward,) = _calcRewardPerToken(token, lastTimeRewardApplicable(token), Math.max(sp.timestamp, _startTimestamp), sp.supply, _startTimestamp);
                reward += _reward;
                _writeRewardPerTokenCheckpoint(token, reward, block.timestamp);
                _startTimestamp = block.timestamp;
            }
        }

        return (reward, _startTimestamp);
    }

    // earned is an estimation, it won't be exact till the supply > rewardPerToken calculations have run
    function earned(address token, address account) public view returns (uint) {
        uint _startTimestamp = Math.max(lastEarn[token][account], rewardPerTokenCheckpoints[token][0].timestamp);
        if (numCheckpoints[account] == 0) {
            return 0;
        }

        uint _startIndex = getPriorBalanceIndex(account, _startTimestamp);
        uint _endIndex = numCheckpoints[account]-1;

        uint reward = 0;

        if (_endIndex > 0) {
            for (uint i = _startIndex; i <= _endIndex-1; i++) {
                Checkpoint memory cp0 = checkpoints[account][i];
                Checkpoint memory cp1 = checkpoints[account][i+1];
                (uint _rewardPerTokenStored0,) = getPriorRewardPerToken(token, cp0.timestamp);
                (uint _rewardPerTokenStored1,) = getPriorRewardPerToken(token, cp1.timestamp);
                reward += cp0.balanceOf * (_rewardPerTokenStored1 - _rewardPerTokenStored0) / PRECISION;
            }
        }

        Checkpoint memory cp = checkpoints[account][_endIndex];
        (uint _rewardPerTokenStored,) = getPriorRewardPerToken(token, cp.timestamp);
        reward += cp.balanceOf * (rewardPerToken(token) - Math.max(_rewardPerTokenStored, userRewardPerTokenStored[token][account])) / PRECISION;

        return reward;
    }

    function depositAll(uint tokenId) external {
        deposit(IERC20(stake).balanceOf(msg.sender), tokenId);
    }

    function deposit(uint amount, uint tokenId) public lock {
        require(amount > 0);
        _updateRewardForAllTokens();

        _safeTransferFrom(stake, msg.sender, address(this), amount);
        totalSupply += amount;
        balanceOf[msg.sender] += amount;

        if (tokenId > 0) {
            require(IVotingEscrow(_ve).ownerOf(tokenId) == msg.sender);
            if (tokenIds[msg.sender] == 0) {
                tokenIds[msg.sender] = tokenId;
                IVoter(voter).attachTokenToGauge(tokenId, msg.sender);
            }
            require(tokenIds[msg.sender] == tokenId);
        } else {
            tokenId = tokenIds[msg.sender];
        }

        uint _derivedBalance = derivedBalances[msg.sender];
        derivedSupply -= _derivedBalance;
        _derivedBalance = derivedBalance(msg.sender);
        derivedBalances[msg.sender] = _derivedBalance;
        derivedSupply += _derivedBalance;

        _writeCheckpoint(msg.sender, _derivedBalance);
        _writeSupplyCheckpoint();

        IVoter(voter).emitDeposit(tokenId, msg.sender, amount);
        emit Deposit(msg.sender, tokenId, amount);
    }

    function withdrawAll() external {
        withdraw(balanceOf[msg.sender]);
    }

    function withdraw(uint amount) public {
        uint tokenId = 0;
        if (amount == balanceOf[msg.sender]) {
            tokenId = tokenIds[msg.sender];
        }
        withdrawToken(amount, tokenId);
    }

    function withdrawToken(uint amount, uint tokenId) public lock {
        _updateRewardForAllTokens();

        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        _safeTransfer(stake, msg.sender, amount);

        if (tokenId > 0) {
            require(tokenId == tokenIds[msg.sender]);
            tokenIds[msg.sender] = 0;
            IVoter(voter).detachTokenFromGauge(tokenId, msg.sender);
        } else {
            tokenId = tokenIds[msg.sender];
        }

        uint _derivedBalance = derivedBalances[msg.sender];
        derivedSupply -= _derivedBalance;
        _derivedBalance = derivedBalance(msg.sender);
        derivedBalances[msg.sender] = _derivedBalance;
        derivedSupply += _derivedBalance;

        _writeCheckpoint(msg.sender, derivedBalances[msg.sender]);
        _writeSupplyCheckpoint();

        IVoter(voter).emitWithdraw(tokenId, msg.sender, amount);
        emit Withdraw(msg.sender, tokenId, amount);
    }

    function left(address token) external view returns (uint) {
        if (block.timestamp >= periodFinish[token]) return 0;
        uint _remaining = periodFinish[token] - block.timestamp;
        return _remaining * rewardRate[token];
    }

    function notifyRewardAmount(address token, uint amount) external lock {
        require(token != stake);
        require(amount > 0);
        if (!isReward[token]) {
            require(IVoter(voter).isWhitelisted(token), "rewards tokens must be whitelisted");
            require(rewards.length < MAX_REWARD_TOKENS, "too many rewards tokens");
        }
        if (rewardRate[token] == 0) _writeRewardPerTokenCheckpoint(token, 0, block.timestamp);
        (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, type(uint).max, true);

        if (block.timestamp >= periodFinish[token]) {
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            _safeTransferFrom(token, msg.sender, address(this), amount);
            uint256 balanceAfter = IERC20(token).balanceOf(address(this));
            amount = balanceAfter - balanceBefore;
            rewardRate[token] = amount / DURATION;
        } else {
            uint _remaining = periodFinish[token] - block.timestamp;
            uint _left = _remaining * rewardRate[token];
            require(amount > _left);
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            _safeTransferFrom(token, msg.sender, address(this), amount);
            uint256 balanceAfter = IERC20(token).balanceOf(address(this));
            amount = balanceAfter - balanceBefore;
            rewardRate[token] = (amount + _left) / DURATION;
        }
        require(rewardRate[token] > 0);
        uint balance = IERC20(token).balanceOf(address(this));
        require(rewardRate[token] <= balance / DURATION, "Provided reward too high");
        periodFinish[token] = block.timestamp + DURATION;
        if (!isReward[token]) {
            isReward[token] = true;
            rewards.push(token);
        }

        emit NotifyReward(msg.sender, token, amount);
    }

    function swapOutRewardToken(uint i, address oldToken, address newToken) external {
        require(msg.sender == IVotingEscrow(_ve).team(), 'only team');
        require(rewards[i] == oldToken);
        isReward[oldToken] = false;
        isReward[newToken] = true;
        rewards[i] = newToken;
    }

    function setOKus(address _oKus) external {
        require(msg.sender == gaugeFactory, "not gauge factory");
        oKus = _oKus;
        _safeApprove(kus, _oKus, type(uint256).max);
        emit OKusSet(_oKus);
    }

    function _safeTransfer(address token, address to, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _safeApprove(address token, address spender, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.approve.selector, spender, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

contract GaugeFactory is IGaugeFactory, Ownable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER");

    address public last_gauge;
    address public oKus;

    event OKusSet(address indexed _oKus);
    event OKusUpdatedFor(address indexed _gauge);

    function createGauge(address _pool, address _external_bribe, address _ve, bool isPair, address[] memory allowedRewards) external returns (address) {
        last_gauge = address(new Gauge(_pool, _external_bribe, _ve, msg.sender, oKus, address(this), isPair, allowedRewards));
        if (oKus != address(0)) {
            IAccessControl(oKus).grantRole(MINTER_ROLE, last_gauge);
        }
        return last_gauge;
    }

    function setOKus(address _oKus) external onlyOwner {
        oKus = _oKus;
        emit OKusSet(_oKus);
    }

    function updateOKusFor(address _gauge) external onlyOwner {
        Gauge(_gauge).setOKus(oKus);
        emit OKusUpdatedFor(_gauge);
    }
}
