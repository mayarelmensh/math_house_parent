// wallet_recharge_states.dart

import '../../../../data/models/recharge_wallet.dart';

abstract class WalletRechargeStates {}

class WalletRechargeInitialState extends WalletRechargeStates {}

class WalletRechargeLoadingState extends WalletRechargeStates {}

class WalletRechargeSuccessState extends WalletRechargeStates {
  final WalletRechargeResponseEntity response;

  WalletRechargeSuccessState(this.response);
}

class WalletRechargeErrorState extends WalletRechargeStates {
  final String error;

  WalletRechargeErrorState(this.error);
}