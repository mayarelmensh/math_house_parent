import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/api/api_manager.dart';

import '../../../../data/models/wallet_history.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletResponse response;
  WalletLoaded(this.response);
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}