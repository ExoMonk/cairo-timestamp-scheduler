# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE
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
func balance() -> (res : felt):
end

@storage_var
func user_unlock_time(user : felt) -> (unlock_time : felt):
end

@storage_var
func waiter() -> (wait_time : felt):
end

@storage_var
func allowed_amount() -> (withdraw_value : Uint256):
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, _allowed_amount : Uint256, _time : felt
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
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount : felt):
    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end


#
# Getters
#

@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = balance.read()
    return (res)
end

@view
func get_wait{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res : felt) = wait_time.read()
    return (res)
end

@view
func get_allowed_time{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account : felt
) -> (res : felt):
    let (res : felt) = user_unlock_time.read(account)
    return (res)
end
