import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/process_checkout_usecase.dart';

/// EVENT
abstract class CheckoutEvent {}

class ProcessCheckoutEvent extends CheckoutEvent {}

/// STATE
class CheckoutState {
  final bool isLoading;
  final bool isSuccess;

  CheckoutState({
    this.isLoading = false,
    this.isSuccess = false,
  });

  CheckoutState copyWith({
    bool? isLoading,
    bool? isSuccess,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// BLOC
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final ProcessCheckoutUseCase processCheckoutUseCase;

  CheckoutBloc(this.processCheckoutUseCase)
      : super(CheckoutState()) {
    on<ProcessCheckoutEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final result = await processCheckoutUseCase.execute();

      if (result) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    });
  }
}