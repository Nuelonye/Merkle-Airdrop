#!/usr/bin/env bash

set -e  # stop on error

echo "Starting Merkle Airdrop Flow..."

RPC_URL="http://localhost:8545"

# Anvil default accounts
DEPLOYER_PK="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
USER_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

USER_ADDRESS=$(cast wallet address --private-key $USER_PK)

echo "User Address: $USER_ADDRESS"

echo "Step 1: Generate Input JSON..."
forge script script/GenerateInput.s.sol:GenerateInput

echo "Step 2: Generate Merkle Tree..."
forge script script/MakeMerkle.s.sol:MakeMerkle

echo "Step 3: Deploy Contracts..."
DEPLOY_OUTPUT=$(forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop \
    --rpc-url $RPC_URL \
    --private-key $DEPLOYER_PK \
    --broadcast)

echo "$DEPLOY_OUTPUT"

# Extract contract addresses from output
TOKEN_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP 'BagelToken \K0x[a-fA-F0-9]{40}')
AIRDROP_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP 'MerkleAirdrop \K0x[a-fA-F0-9]{40}')

echo "Token Address: $TOKEN_ADDRESS"
echo "Airdrop Address: $AIRDROP_ADDRESS"

echo "Step 4: Generate Message Hash..."

AMOUNT="25000000000000000000"

DIGEST=$(cast call $AIRDROP_ADDRESS \
    "getMessageHash(address,uint256)" \
    $USER_ADDRESS \
    $AMOUNT \
    --rpc-url $RPC_URL)

echo "Message Hash: $DIGEST"

echo "Step 5: Sign Message..."

SIGNATURE=$(cast wallet sign --no-hash $DIGEST --private-key $USER_PK)

echo "Signature: $SIGNATURE"

echo ""
echo "ACTION REQUIRED:"
echo "---------------------------------------------"
echo "Copy signature WITHOUT 0x and paste into:"
echo "script/Interact.s.sol -> SIGNATURE = hex\"...\""
echo "---------------------------------------------"
echo ""

read -p "Press ENTER after updating the script..."

echo "Step 6: Execute Claim..."

forge script script/Interact.s.sol:ClaimAirdrop \
    --rpc-url $RPC_URL \
    --private-key $DEPLOYER_PK \
    --broadcast

echo "Step 7: Checking Final Balance..."

BALANCE_HEX=$(cast call $TOKEN_ADDRESS \
    "balanceOf(address)" \
    $USER_ADDRESS \
    --rpc-url $RPC_URL)

BALANCE_DEC=$(cast --to-dec $BALANCE_HEX)

echo "Final Balance (wei): $BALANCE_DEC"

echo "DONE!"