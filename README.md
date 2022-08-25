# cairo-timestamp-scheduler

Cairo StarkNet : Limit user's actions by time

Basic Smart Contract using timestamp and blocks to limit user's interaction with the Contract

`SimpleSchedulerChecker.cairo` contract allows any user to perform a specific transaction, only once given a period of time (timestamp)

This is pretty usefull for doing Faucets as an example


## Installation & Setup

```
python -m venv cairo-venv
source cairo-venv/bin/activate

sudo apt install -y libgmp3-dev
(or for M1 macbook)
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy
pip install --upgrade pip
pip install cairo-lang
pip install cairo-nile 
pip install openzeppelin-cairo-contracts
pip install immutablex-starknet

nile init
yarn install
```

## Compiling Contracts

- Compiling simple contract

```
nile compile contracts/SimpleSchedulerChecker.cairo
🔨 Compiling contracts/SimpleSchedulerChecker.cairo ✅ Done
```


## Deploying Contracts

```
python scripts/deploy.py
```
