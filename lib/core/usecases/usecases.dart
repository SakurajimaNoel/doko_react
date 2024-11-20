import 'dart:async';

import 'package:doko_react/core/result/result.dart';
import 'package:equatable/equatable.dart';

/// base use_cases interface
/// inherited by all the use_cases
abstract class UseCases<Params> {
  FutureOr<Result> call(Params params);
}

/// used when passing no parameter to use_cases
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
