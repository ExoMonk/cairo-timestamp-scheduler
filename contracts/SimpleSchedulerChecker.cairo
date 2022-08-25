# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_block_number,
    get_block_timestamp,
    get_contract_address,
)
from openzeppelin.access.ownable.library import Ownable

#
# Storage
#

@storage_var
func balance(user : felt) -> (value : felt):
end

@storage_var
func user_unlock_time(user : felt) -> (unlock_time : felt):
end

@storage_var
func waiter() -> (wait_time : felt):
end

@storage_var
func allowed_amount() -> (withdraw_value : felt):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, _allowed_amount : felt, _time : felt
):
    Ownable.initializer(owner)
    allowed_amount.write(_allowed_amount)
    waiter.write(_time)
    return ()
end


#
# Setters
#

@external
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    success : felt
):
    alloc_locals
    let (caller_address : felt) = get_caller_address()
    let (_allowed_amount : felt) = allowed_amount.read()
    let (_is_allowed : felt) = isAllowedForTransaction(caller_address)
    if _is_allowed == TRUE:
        let (timestamp : felt) = get_block_timestamp()
        let (_time_to_wait : felt) = waiter.read()
        user_unlock_time.write(caller_address, timestamp + _time_to_wait)
        let (res) = balance.read(caller_address)
        balance.write(caller_address, res + _allowed_amount)
        return (TRUE)
    end
    return (FALSE)
end


#
# Getters
#

@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (caller_address : felt) = get_caller_address()
    let (res) = balance.read(caller_address)
    return (res)
end

@view
func get_wait{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res : felt) = waiter.read()
    return (res)
end

@view
func get_allowed_time{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (res : felt):
    let (res : felt) = user_unlock_time.read(account)
    return (res)
end

@view
func isAllowedForTransaction{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (success : felt):
    alloc_locals
    let (unlock_time : felt) = user_unlock_time.read(address)
    if unlock_time == 0:
        return (TRUE)
    end
    let (timestamp : felt) = get_block_timestamp()
    let (unlock_time : felt) = user_unlock_time.read(address)
    let (_is_valid : felt) = is_le(unlock_time, timestamp)
    if _is_valid == TRUE:
        return (TRUE)
    end
    return (FALSE)
end
