include .env

build :; forge build 

deploy-dex :; forge script script/DeployDex.s.sol --broadcast --rpc-url $(SEPOLIA_RPC_URL) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --account myaccount -vvvv
deploy-token :; forge script script/DeployToken.s.sol --broadcast --rpc-url $(SEPOLIA_RPC_URL) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --account myaccount -vvvv
