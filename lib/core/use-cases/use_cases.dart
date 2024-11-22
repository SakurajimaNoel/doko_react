import 'dart:async';

import 'package:equatable/equatable.dart';

/// base use_cases interface
/// inherited by all the use_cases
abstract class UseCases<Type, Params> {
  FutureOr<Type> call(Params params);
}

/// used when passing no parameter to use_cases
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
