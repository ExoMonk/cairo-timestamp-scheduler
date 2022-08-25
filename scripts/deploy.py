import asyncio
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
from starknet_py.net.networks import TESTNET
from utils import str_to_felt

ERC20_FILE = ['contracts/SimpleERC20.cairo']
FAUCET_FILE = ['contracts/SimpleSchedulerChecker.cairo']

ERC20_NAME = str_to_felt("Token Name")
ERC20_SYMBOL = str_to_felt("EXOT")
DECIMALS = 18
INITIAL_SUPPLY = 1000000000000000000000000000

OWNER = 0x07445bd422E6B9c9cDF04E73A4cF36Ea7c011a737795D13c9342593e789a6a33
ALLOWED_AMOUNT = 10000000000000000
TIMEDELTA = 86400 #24h

async def deploy():
    client = GatewayClient(TESTNET)
    print("⏳ Deploying ERC20 Contract...")
    erc20_contract = await Contract.deploy(
        client=client,
        compilation_source=ERC20_FILE,
        constructor_args=[ERC20_NAME, ERC20_SYMBOL, DECIMALS, INITIAL_SUPPLY, OWNER]
    )
    print(f'✨ ERC20 Contract deployed at {hex(erc20_contract.deployed_contract.address)}')
    print("⏳ Deploying Faucet Contract...")
    scheduler_checker_contract = await Contract.deploy(
        client=client,
        compilation_source=FAUCET_FILE,
        constructor_args=[OWNER, erc20_contract.deployed_contract.address, ALLOWED_AMOUNT, TIMEDELTA]
    )
    print(f'✨ SchedulerChecker Contract deployed at {hex(scheduler_checker_contract.deployed_contract.address)}')
    await erc20_contract.wait_for_acceptance()
    await scheduler_checker_contract.wait_for_acceptance()
    return (scheduler_checker_contract, erc20_contract)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(deploy())
