
import '../../../../domain/entities/buy_package_entity.dart';

abstract class BuyPackageState {}

class BuyPackageInitial extends BuyPackageState {}

class BuyPackageLoading extends BuyPackageState {}

class BuyPackageSuccess extends BuyPackageState {
  final BuyPackageEntity response;

  BuyPackageSuccess(this.response);
}

class BuyPackageError extends BuyPackageState {
  final String message;

  BuyPackageError(this.message);
}
