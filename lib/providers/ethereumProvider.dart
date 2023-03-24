
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import "package:properly_made_nft_market/ABIs/nftMarketAbi.dart" as nftMarket;
import "package:properly_made_nft_market/ABIs/SUcoinAbi.dart" as suCoin;

import "dart:convert";

var httpClient = Client();
var apiUrl = "https://polygon-mumbai.infura.io/v3/c189a4f197f94261814cf2f0334463de";

var ethClient = Web3Client(apiUrl, httpClient);

DeployedContract suCoinContract = DeployedContract(ContractAbi.fromJson(JsonEncoder().convert(suCoin.abi["ABI"]), "SUCOIN"), EthereumAddress.fromHex(suCoin.abi["address"].toString()));
DeployedContract suNFTmarketContract = DeployedContract(ContractAbi.fromJson(JsonEncoder().convert(nftMarket.abi["ABI"]), "Market"), EthereumAddress.fromHex(nftMarket.abi["address"].toString()));

