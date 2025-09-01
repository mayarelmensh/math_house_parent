import '../../../../domain/entities/login_response_entity.dart';

abstract class ProfileStates{}

class ProfileInitial extends ProfileStates {}

class ProfileLoading extends ProfileStates {}

class ProfileLoaded extends ProfileStates {
  final ParentLoginEntity parent;

   ProfileLoaded({required this.parent});

}

class ProfileError extends ProfileStates {
  final String message;

   ProfileError({required this.message});

}
