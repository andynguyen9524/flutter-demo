import 'package:flutter_application_demo/Login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginController extends Cubit<LoginState> {
  LoginController() : super(LoadingState());

  Future<void> fetchLogin() async {
    emit(LoadingState());
    await Future.delayed(const Duration(milliseconds: 200));
    emit(IsLoginState());
  }
}
