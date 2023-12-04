-include .env

AaveGetUserData:
	forge script script/Interactions.s.sol:AaveGetUserData  --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveSupplyLink:
	forge script script/Interactions.s.sol:AaveSupply --sig "run(uint256)" 10000000000 --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveBorrow:
	forge script script/Interactions.s.sol:AaveBorrow --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast