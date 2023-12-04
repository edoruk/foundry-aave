-include .env

AaveGetUserData:
	forge script script/Interactions.s.sol:AaveGetUserData  --sig "write()"  --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveSupplyLink:
	forge script script/Interactions.s.sol:AaveSupplyLink --sig "run(uint256)" 10000000000 --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveBorrowLink:
	forge script script/Interactions.s.sol:AaveBorrowLink --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveRepayLink:
	forge script script/Interactions.s.sol:AaveRepayLink --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveWithdrawLink:
	forge script script/Interactions.s.sol:AaveWithdrawLink --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast

AaveWETHGateway:
	forge script script/Interactions.s.sol:AaveWETHGateway --rpc-url ${RPC_URL_SEP} --private-key ${PRIVATE_KEY_SEP} --broadcast