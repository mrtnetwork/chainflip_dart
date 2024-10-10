import 'package:on_chain/on_chain.dart';

class CfApiConst {
  static final AbiFunctionFragment erc20BalaceFragment =
      AbiFunctionFragment.fromJson({
    "inputs": [
      {"internalType": "address", "name": "account", "type": "address"}
    ],
    "name": "balanceOf",
    "outputs": [
      {"internalType": "uint256", "name": "", "type": "uint256"}
    ],
    "stateMutability": "view",
    "type": "function"
  });
  static final AbiFunctionFragment tokenName = AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {"internalType": "string", "name": "", "type": "string"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment tokenSymbol = AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {"internalType": "string", "name": "", "type": "string"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment tokenDecimals = AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "decimals",
      "outputs": [
        {"internalType": "uint8", "name": "", "type": "uint8"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment eip712Domain = AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "eip712Domain",
      "outputs": [
        {"internalType": "bytes1", "name": "fields", "type": "bytes1"},
        {"internalType": "string", "name": "name", "type": "string"},
        {"internalType": "string", "name": "version", "type": "string"},
        {"internalType": "uint256", "name": "chainId", "type": "uint256"},
        {
          "internalType": "address",
          "name": "verifyingContract",
          "type": "address"
        },
        {"internalType": "bytes32", "name": "salt", "type": "bytes32"},
        {"internalType": "uint256[]", "name": "extensions", "type": "uint256[]"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );

  static final AbiFunctionFragment transferFragment =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "address", "name": "to", "type": "address"},
        {"internalType": "uint256", "name": "amount", "type": "uint256"}
      ],
      "name": "transfer",
      "outputs": [
        {"internalType": "bool", "name": "", "type": "bool"}
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment increaseAllowance =
      AbiFunctionFragment.fromJson({
    "inputs": [
      {"internalType": "address", "name": "spender", "type": "address"},
      {"internalType": "uint256", "name": "addedValue", "type": "uint256"}
    ],
    "name": "increaseAllowance",
    "outputs": [
      {"internalType": "bool", "name": "", "type": "bool"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  });
  static final AbiFunctionFragment approve = AbiFunctionFragment.fromJson({
    "inputs": [
      {"internalType": "address", "name": "spender", "type": "address"},
      {"internalType": "uint256", "name": "value", "type": "uint256"}
    ],
    "name": "approve",
    "outputs": [
      {"internalType": "bool", "name": "", "type": "bool"}
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  });

  static final AbiFunctionFragment decreaseAllowance =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "address", "name": "spender", "type": "address"},
        {
          "internalType": "uint256",
          "name": "subtractedValue",
          "type": "uint256"
        }
      ],
      "name": "decreaseAllowance",
      "outputs": [
        {"internalType": "bool", "name": "", "type": "bool"}
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );

  static final AbiFunctionFragment getAllowance = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "address", "name": "owner", "type": "address"},
        {"internalType": "address", "name": "spender", "type": "address"}
      ],
      "name": "allowance",
      "outputs": [
        {"internalType": "uint256", "name": "", "type": "uint256"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );

  static final AbiFunctionFragment fundStateChainAccount =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "bytes32", "name": "nodeID", "type": "bytes32"},
        {"internalType": "uint256", "name": "amount", "type": "uint256"}
      ],
      "name": "fundStateChainAccount",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment executeRedemption =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "bytes32", "name": "nodeID", "type": "bytes32"}
      ],
      "name": "executeRedemption",
      "outputs": [
        {"internalType": "address", "name": "", "type": "address"},
        {"internalType": "uint256", "name": "", "type": "uint256"}
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment getMinimumFunding =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "getMinimumFunding",
      "outputs": [
        {"internalType": "uint256", "name": "", "type": "uint256"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment getPendingRedemption =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "bytes32", "name": "nodeID", "type": "bytes32"}
      ],
      "name": "getPendingRedemption",
      "outputs": [
        {
          "components": [
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
            {
              "internalType": "address",
              "name": "redeemAddress",
              "type": "address"
            },
            {"internalType": "uint48", "name": "startTime", "type": "uint48"},
            {"internalType": "uint48", "name": "expiryTime", "type": "uint48"},
            {"internalType": "address", "name": "executor", "type": "address"}
          ],
          "internalType": "struct IStateChainGateway.Redemption",
          "name": "",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment getRedemptionDelay =
      AbiFunctionFragment.fromJson(
    {
      "inputs": [],
      "name": "REDEMPTION_DELAY",
      "outputs": [
        {"internalType": "uint48", "name": "", "type": "uint48"}
      ],
      "stateMutability": "view",
      "type": "function"
    },
  );
  static final AbiFunctionFragment xSwapToken = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "uint32", "name": "dstChain", "type": "uint32"},
        {"internalType": "bytes", "name": "dstAddress", "type": "bytes"},
        {"internalType": "uint32", "name": "dstToken", "type": "uint32"},
        {
          "internalType": "contract IERC20",
          "name": "srcToken",
          "type": "address"
        },
        {"internalType": "uint256", "name": "amount", "type": "uint256"},
        {"internalType": "bytes", "name": "cfParameters", "type": "bytes"}
      ],
      "name": "xSwapToken",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment xSwapNative = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "uint32", "name": "dstChain", "type": "uint32"},
        {"internalType": "bytes", "name": "dstAddress", "type": "bytes"},
        {"internalType": "uint32", "name": "dstToken", "type": "uint32"},
        {"internalType": "bytes", "name": "cfParameters", "type": "bytes"}
      ],
      "name": "xSwapNative",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment xCallNative = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "uint32", "name": "dstChain", "type": "uint32"},
        {"internalType": "bytes", "name": "dstAddress", "type": "bytes"},
        {"internalType": "uint32", "name": "dstToken", "type": "uint32"},
        {"internalType": "bytes", "name": "message", "type": "bytes"},
        {"internalType": "uint256", "name": "gasAmount", "type": "uint256"},
        {"internalType": "bytes", "name": "cfParameters", "type": "bytes"}
      ],
      "name": "xCallNative",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
  );
  static final AbiFunctionFragment xCallToken = AbiFunctionFragment.fromJson(
    {
      "inputs": [
        {"internalType": "uint32", "name": "dstChain", "type": "uint32"},
        {"internalType": "bytes", "name": "dstAddress", "type": "bytes"},
        {"internalType": "uint32", "name": "dstToken", "type": "uint32"},
        {"internalType": "bytes", "name": "message", "type": "bytes"},
        {"internalType": "uint256", "name": "gasAmount", "type": "uint256"},
        {
          "internalType": "contract IERC20",
          "name": "srcToken",
          "type": "address"
        },
        {"internalType": "uint256", "name": "amount", "type": "uint256"},
        {"internalType": "bytes", "name": "cfParameters", "type": "bytes"}
      ],
      "name": "xCallToken",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
  );
}
