# Merkle Airdrop Project

A complete implementation of a Merkle Tree-based token airdrop using Foundry.

This project allows you to:

1. Generate a Merkle tree from a list of recipients
2. Deploy an ERC20 token and airdrop contract
3. Sign claim messages
4. Claim tokens using Merkle proofs + signatures
5. Automate the entire flow with a single .sh script


## Project Structure

├── script/
│   ├── GenerateInput.s.sol      # Creates input.json
│   ├── MakeMerkle.s.sol         # Builds Merkle tree + proofs
│   ├── DeployMerkleAirdrop.s.sol
│   ├── Interact.s.sol           # Claim script

├── src/
│   ├── BagelToken.sol
│   ├── MerkleAirdrop.sol

├── script/target/
│   ├── input.json
│   ├── output.jsons

├── run_airdrop.sh               #  FULL AUTOMATION SCRIPT


## QUICK START (ONE COMMAND)

### Quickstart

```
git clone https://github.com/Nuelonye/merkle-airdrop
cd merkle-airdrop
foundryup
anvil
```


## Deployment and Interaction on Anvil

### What this Script Does (Step-by-Step)
```
chmod +x run_airdrop_anvil.sh
./run_airdrop_anvil.sh
```

### The .sh script automates everything:

1. Generate Input Data
```forge script script/GenerateInput.s.sol:GenerateInput```

    Creates: script/target/input.json

    Contains: recipient addresses, token amounts

2. Build Merkle Tree
```forge script script/MakeMerkle.s.sol:MakeMerkle```

    Creates:script/target/output.json

    Contains: leaf nodes, proofs, root

3. Deploy Contracts
```forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url http://localhost:8545 --private-key <DEPLOYER_PK> --broadcast```

    Deploys: ERC20 token, MerkleAirdrop contract

4. Generate Message Hash
```cast call <AIRDROP_ADDRESS> "getMessageHash(address,uint256)" <USER_ADDRESS> <AMOUNT>```

5. Sign Message
```cast wallet sign --no-hash <DIGEST> --private-key <USER_PK>```

6. Paste Signature (Manual Step)

Edit:

> script/Interact.s.sol
> bytes private SIGNATURE = hex"...";
> 👉 Paste signature WITHOUT 0x

7. Claim Airdrop
```forge script script/Interact.s.sol:ClaimAirdrop --rpc-url http://localhost:8545 --private-key <DEPLOYER_PK> --broadcast```

8. Verify Balance
```
cast call <TOKEN_ADDRESS> "balanceOf(address)" <USER_ADDRESS>
cast --to-dec <HEX_BALANCE>
```
✅ User successfully claimed 25 tokens


## Important Notes

### Signature Format

✅ Correct:
        hex"76e78a..."

❌ Wrong:
        hex"0x76e78a..."


# Thank you!

## Project design and assumptions

1. Efficient airdrops using Merkle trees
2. Secure claims using signatures
3. Full automation via Foundry scripts
4. Real-world production pattern