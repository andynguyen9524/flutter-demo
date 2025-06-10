import 'package:equatable/equatable.dart';
import 'package:flutter_application_demo/models/new_api_model.dart';

abstract class NewFeedState extends Equatable {
  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [];
}

class LoadingState extends NewFeedState {}

class NoDataState extends NewFeedState {}

class DataState extends NewFeedState {
  final List<Article> data;

  DataState({required this.data});
}

class ErrorState extends NewFeedState {
  final String message;

  ErrorState({required this.message});
}
