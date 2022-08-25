import asyncio
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
from starknet_py.net.networks import TESTNET
from utils import decimal_to_hex

CONTRACT_FILE = ['contracts/SimpleSchedulerChecker.cairo']
OWNER = 0x07445bd422E6B9c9cDF04E73A4cF36Ea7c011a737795D13c9342593e789a6a33
ALLOWED_AMOUNT = 100
TIMEDELTA = 100000000

async def deploy():
    client = GatewayClient(TESTNET)
    scheduler_checker_contract = await Contract.deploy(
        client=client,
        compilation_source=CONTRACT_FILE,
        constructor_args=[OWNER, ALLOWED_AMOUNT, TIMEDELTA]
    )
    print(f'Contract deployed at {decimal_to_hex(scheduler_checker_contract.deployed_contract.address)}')
    await scheduler_checker_contract.wait_for_acceptance()
    return (scheduler_checker_contract)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(deploy())
