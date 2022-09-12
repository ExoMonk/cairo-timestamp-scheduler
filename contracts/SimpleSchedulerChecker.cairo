// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from openzeppelin.access.ownable.library import Ownable

from openzeppelin.token.erc20.IERC20 import IERC20

//
// Storage
//

// ERC20 token address
@storage_var
func token_address() -> (address: felt) {
}

// Allowed Amount per mint
@storage_var
func allowed_amount() -> (withdraw_value: Uint256) {
}

// Timedelta between each mint
@storage_var
func waiter() -> (wait_time: felt) {
}

// Next unlock time per user
@storage_var
func user_unlock_time(address: felt) -> (unlock_time: felt) {
}

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, _token_address: felt, _allowed_amount: Uint256, _time: felt
) {
    Ownable.initializer(owner);
    token_address.write(_token_address);
    allowed_amount.write(_allowed_amount);
    waiter.write(_time);
    return ();
}

//
// Setters
//

@external
func faucet_mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    success: felt
) {
    alloc_locals;
    let (caller_address: felt) = get_caller_address();
    let (_allowed_amount: Uint256) = allowed_amount.read();
    let (_is_allowed: felt) = isAllowedForTransaction(caller_address);
    if (_is_allowed == TRUE) {
        let (timestamp: felt) = get_block_timestamp();
        let (_time_to_wait: felt) = waiter.read();
        user_unlock_time.write(caller_address, timestamp + _time_to_wait);
        let (token: felt) = token_address.read();
        let (success: felt) = IERC20.transfer(
            contract_address=token, recipient=caller_address, amount=_allowed_amount
        );
        with_attr error_message("transfer failed") {
            assert success = TRUE;
        }
        return (TRUE,);
    }
    return (FALSE,);
}

//
// Getters
//

@view
func get_token_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let (res: felt) = token_address.read();
    return (res,);
}

@view
func get_wait{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res: felt) = waiter.read();
    return (res,);
}

@view
func get_allowed_time{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (res: felt) {
    let (res: felt) = user_unlock_time.read(account);
    return (res,);
}

@view
func isAllowedForTransaction{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (success: felt) {
    alloc_locals;
    let (unlock_time: felt) = user_unlock_time.read(address);
    if (unlock_time == 0) {
        return (TRUE,);
    }
    let (timestamp: felt) = get_block_timestamp();
    let (unlock_time: felt) = user_unlock_time.read(address);
    let _is_valid: felt = is_le(unlock_time, timestamp);
    if (_is_valid == TRUE) {
        return (TRUE,);
    }
    return (FALSE,);
}
