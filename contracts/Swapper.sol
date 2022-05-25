//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "forwarder/contracts/BaseRelayRecipient.sol";

// A partial ERC20 interface.
interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

// A partial WETH interfaec.
interface IWETH is IERC20 {
    function deposit() external payable;
}

// Demo contract that swaps its ERC20 balance for another ERC20.
// NOT to be used in production.
contract Swapper is BaseRelayRecipient {

    event Swap(IERC20 sellToken, IERC20 web3Address, uint256 boughtAmount);

    // The WETH contract.
    IWETH public immutable WETH;
    // Creator of this contract.
    address public owner;
    // Swap target (0x)
    address immutable swapTarget;
    // Web3 Address
    IERC20 immutable web3Address;

    constructor(IWETH weth, address _swapTarget) {
        WETH = weth;
        owner = msg.sender;
        swapTarget = _swapTarget;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    // Payable fallback to allow this contract to receive protocol fee refunds.
    receive() external payable {}

    // Swaps ERC20->ERC20 tokens held by this contract using a 0x-API quote.
    function fillQuote(
        // The `sellTokenAddress` field from the API response.
        IERC20 sellToken,
        // The `data` field from the API response.
        bytes calldata swapCallData
    )
        external
        onlyOwner
        payable // Must attach ETH equal to the `value` field from the API response.
    {

        // Give `spender` an infinite allowance to spend this contract's `sellToken`.
        // Note that for some tokens (e.g., USDT, KNC), you must first reset any existing
        // allowance to 0 before being able to update it.
        require(sellToken.approve(spender, type(uint256).max), "APPROVE_TOKEN_FAILED");
        // Call the encoded swap function call on the contract at `swapTarget`,
        // passing along any ETH attached to this function call to cover protocol fees.
        (bool success,) = swapTarget.call{value: msg.value}(swapCallData);
        require(success, "SWAP_CALL_FAILED");
        // Refund any unspent protocol fees to the sender.
        payable(_msgSender()).transfer(address(this).balance);

        // Use our current buyToken balance to determine how much we've bought.
        uint256 boughtAmount = web3Address.balanceOf(address(this)) - boughtAmount;
        emit BoughtTokens(sellToken, web3Address, boughtAmount);
    }

    function setTrustedForwarder(address _forwarder) external onlyOwner {
        trustedForwarder = _forwarder;
    }

    /**
     * Runs all the necessary approval functions required for a given ERC20 token.
     * This function can be called when a new token is added to a SetToken during a
     * rebalance.
     *
     * @param _token    Address of the token which needs approval
     * @param _spender  Address of the spender which will be approved to spend token. (Must be a whitlisted issuance module)
     */
    function approveToken(IERC20 _token, address _spender) public  isValidModule(_spender) {
        _safeApprove(_token, _spender, type(uint256).max);
    }

    function _safeApprove(IERC20 _token, address _spender, uint256 _requiredAllowance) internal {
        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _requiredAllowance) {
            _token.safeIncreaseAllowance(_spender, type(uint256).max - allowance);
        }
    }
}
