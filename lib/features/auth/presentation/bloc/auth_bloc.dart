import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart'; // THÊM THƯ VIỆN NÀY
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

class CheckAuthStatusEvent extends AuthEvent {} // EVENT KIỂM TRA KHI MỞ APP

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
    
    // KIỂM TRA PHIÊN ĐĂNG NHẬP CŨ
    on<CheckAuthStatusEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final bool? isAdmin = prefs.getBool('isAdmin');
      final bool? isLogged = prefs.getBool('isLoggedIn');

      if (isAdmin == true) {
        emit(const AuthState(status: AuthStatus.admin));
      } else if (isLogged == true) {
        emit(const AuthState(status: AuthStatus.authenticated));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });

    on<LoginRequestedEvent>((event, emit) async {
      emit(const AuthState(status: AuthStatus.initial));
      final prefs = await SharedPreferences.getInstance();
      
      if (event.username == "admin" && event.password == "admin123") {
        await prefs.setBool('isAdmin', true); // LƯU PHIÊN ADMIN
        emit(const AuthState(status: AuthStatus.admin));
        return;
      }

      final user = await loginUseCase.execute(event.username, event.password);
      if (user != null) {
        await prefs.setBool('isLoggedIn', true); // LƯU PHIÊN USER
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.error, errorMessage: "Sai tài khoản hoặc mật khẩu"));
      }
    });

    on<LogoutEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // XÓA SẠCH PHIÊN KHI LOGOUT
      emit(const AuthState(status: AuthStatus.initial));
    });
  }
}
