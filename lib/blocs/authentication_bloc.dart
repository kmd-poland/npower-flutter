import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:npower/blocs/authentication_state.dart';

class AuthenticationBloc {
  static const platformLogin = const MethodChannel('kmdpoland.pl.npower/login');
  final Stream<AuthenticationState> authenticationState;
  final Sink<AuthenticationRequest> onAuthenticationRequired;

  factory AuthenticationBloc() {
    final onAuthenticationRequired = PublishSubject<AuthenticationRequest>();
    final state = onAuthenticationRequired
        .switchMap<AuthenticationState>((_) => _login())
        .startWith(NotAuthenticated());

    return AuthenticationBloc._(onAuthenticationRequired, state);
  }

  void dispose() {
    onAuthenticationRequired.close();
  }

  AuthenticationBloc._(this.onAuthenticationRequired, this.authenticationState);

  static Stream<AuthenticationState> _login() async* {
    yield Authenticated();
  }
}
