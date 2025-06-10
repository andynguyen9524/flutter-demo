import 'package:flutter_application_demo/Network/network.dart';
import 'package:flutter_application_demo/News/new_feed_state.dart';
import 'package:flutter_application_demo/models/new_api_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewFeedController extends Cubit<NewFeedState> {
  NewFeedController() : super(LoadingState());

  final List<Article> _articles = []; // Danh sách các bài viết để hiển thị

  int _currentPage = 1; // Trang hiện tại đang tải

  Future resetNews() async {
    _currentPage = 1;
    _articles.clear();
    await fetchNews();
  }

  Future<void> fetchNews() async {
    emit(LoadingState());

    final result = await Network().fetchNews(_currentPage);
    result.fold(
      (l) {
        emit(ErrorState(message: l));
      },
      (r) {
        if (r.isEmpty) {
          emit(NoDataState());
        } else {
          _articles.addAll(r);
          _currentPage++;
          emit(DataState(data: _articles));
        }
      },
    );
  }
}
