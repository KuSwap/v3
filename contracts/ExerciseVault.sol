// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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

interface IRouter {
    function pairFor(address tokenA, address tokenB, bool stable) external view returns (address pair);
    function swapExactTokensForTokensSimple(uint amountIn, uint amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint deadline) external returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, address tokenIn, address tokenOut, bool stable) external view returns (uint amount);
	function getReserves(address tokenA, address tokenB, bool stable) external view returns (uint, uint);
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint, uint, uint);
}

interface IPair {
    function metadata() external view returns (uint dec0, uint dec1, uint r0, uint r1, bool st, address t0, address t1);
    function tokens() external returns (address, address);
    function token0() external returns (address);
    function token1() external returns (address);
    function externalBribe() external returns (address);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function burn(address to) external returns (uint amount0, uint amount1);
    function mint(address to) external returns (uint liquidity);
    function getReserves() external view returns (uint _reserve0, uint _reserve1, uint _blockTimestampLast);
    function getAmountOut(uint, address) external view returns (uint);
    function setHasGauge(bool value) external;
    function setExternalBribe(address _externalBribe) external;
    function hasGauge() external view returns (bool);
    function stable() external view returns (bool);
    function prices(address tokenIn, uint amountIn, uint points) external view returns (uint[] memory);
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

contract ExerciseVault is Ownable {
     event OTokenAdded(address indexed _oToken);
     event OTokenRemoved(address indexed _oToken);
     event Donated(uint256 indexed _timestamp, address indexed _paymentToken,uint256 _amount);
     event Exercise(address indexed _oToken,address indexed _from,uint256 _amount,uint256 _profit);

     address public router;
     
     mapping(address => bool) public isOToken;
     
     uint256 public fee = 500; // 5%

     constructor(address _router) {
        router = _router;
     }

     function getAmountOfPaymentTokensAfterExercise(address _oToken,address _underlyingToken,address _paymentToken,uint256 _amount) public view returns (uint256) {
         uint256 price = IOptionToken(_oToken).getDiscountedPrice(_amount);
         uint256 amoutAfterSell = IRouter(router).getAmountOut(_amount, _underlyingToken, _paymentToken, false);
         uint256 profit = amoutAfterSell - price;
         uint256 fee = (profit * fee ) / 10000;
         return profit - fee;
     }

     function exercise(address _oToken,uint256 _amount,uint _minOut) external {
        require(isOToken[_oToken],"Not a valid oToken");
        require(_amount > 0,"_amount < 0");

        if (_minOut == 0) {
            _minOut = 1;
        }
        
        IERC20(_oToken).transferFrom(msg.sender, address(this), _amount);

        address paymentToken = IOptionToken(_oToken).paymentToken();
        address underlyingToken = IOptionToken(_oToken).underlyingToken();

        uint256 paymentTokenBalanceBefore = IERC20(paymentToken).balanceOf(address(this));
        uint256 underlyingTokenBalanceBefore = IERC20(underlyingToken).balanceOf(address(this));
        uint256 price = IOptionToken(_oToken).getDiscountedPrice(_amount);

        require(paymentTokenBalanceBefore > price,"Not enough payment tokens");

        IOptionToken(_oToken).exercise(_amount, price, address(this));

        uint256 underlyingTokenBalanceAfter = IERC20(underlyingToken).balanceOf(address(this));
        uint256 ammountToSell = underlyingTokenBalanceAfter - underlyingTokenBalanceBefore;

        IERC20(underlyingToken).approve(router, ammountToSell);
        IRouter(router).swapExactTokensForTokensSimple(ammountToSell, _minOut, underlyingToken, paymentToken, false, address(this), block.timestamp);

        uint256 paymentTokenBalanceAfter = IERC20(paymentToken).balanceOf(address(this));

        require(paymentTokenBalanceAfter > paymentTokenBalanceBefore,"Not profitable excercise");

        uint256 profit =  paymentTokenBalanceAfter - paymentTokenBalanceBefore;
        uint256 fee = (profit * fee ) / 10000;
        uint256 profitAfterFee = profit - fee;

        IERC20(paymentToken).transfer(msg.sender, profitAfterFee);

        emit Exercise(_oToken,msg.sender,_amount,profitAfterFee);
     }

     function donatePaymentToken(address _paymentToken,uint256 _amount) public {
        require(_amount > 0, 'need to add at least 1');
        IERC20(_paymentToken).transferFrom(msg.sender, address(this), _amount);
        emit Donated(block.timestamp,_paymentToken, _amount);
    }

     function inCaseTokensGetStuck(address _token, address _to) external onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, amount);
     }

    function addOToken(address _oToken) external onlyOwner{
        isOToken[_oToken] = true;
        address paymentToken = IOptionToken(_oToken).paymentToken();

        IERC20(paymentToken).approve(_oToken, type(uint256).max);

        emit OTokenAdded(_oToken);
    }

    function removeOToken(address _oToken) external onlyOwner{
        isOToken[_oToken] = false;

        address paymentToken = IOptionToken(_oToken).paymentToken();
        IERC20(paymentToken).approve(_oToken, 0);

        emit OTokenRemoved(_oToken);
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

}
