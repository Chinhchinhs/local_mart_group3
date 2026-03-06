import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequestedEvent extends AuthEvent {
  final String username;
  final String password;
  LoginRequestedEvent(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class RegisterRequestedEvent extends AuthEvent {
  final UserEntity user;
  RegisterRequestedEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class LogoutEvent extends AuthEvent {}

// STATES
enum AuthStatus { initial, authenticated, admin, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  @override
  List<Object?> get props => [status, user, errorMessage];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository repository;

  AuthBloc(this.loginUseCase, this.repository) : super(const AuthState()) {
    
    on<LoginRequestedEvent>((event, emit) async {
      // Logic Admin cố định
      if (event.username == "admin" && event.password == "admin123") {
        emit(const AuthState(status: AuthStatus.admin));
        return;
      }

      final user = await loginUseCase.execute(event.username, event.password);
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.error, errorMessage: "Sai tài khoản hoặc mật khẩu"));
      }
    });

    on<RegisterRequestedEvent>((event, emit) async {
      try {
        await repository.register(event.user);
        emit(const AuthState(status: AuthStatus.unauthenticated)); // Đăng ký xong quay về login
      } catch (e) {
        emit(const AuthState(status: AuthStatus.error, errorMessage: "Tên đăng nhập đã tồn tại"));
      }
    });

    on<LogoutEvent>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
