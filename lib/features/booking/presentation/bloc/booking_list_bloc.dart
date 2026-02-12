import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/network/api_response.dart';
import '../../data/models/booking_model.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';

// Events
abstract class BookingListEvent extends Equatable {
  const BookingListEvent();
  @override
  List<Object?> get props => [];
}

class BookingListFetchRequested extends BookingListEvent {
  final int page;
  const BookingListFetchRequested({this.page = 1});
  @override
  List<Object?> get props => [page];
}

class BookingListRefreshRequested extends BookingListEvent {
  const BookingListRefreshRequested();
}

class BookingListFilterChanged extends BookingListEvent {
  final BookingStatus? statusFilter;
  const BookingListFilterChanged(this.statusFilter);
  @override
  List<Object?> get props => [statusFilter];
}

// State
enum BlocStatus { initial, loading, loaded, error }

class BookingListState extends Equatable {
  final List<BookingModel> bookings;
  final BookingStatus? statusFilter;
  final PaginationMeta? pagination;
  final BlocStatus status;
  final String? errorMessage;
  final bool hasReachedMax;

  const BookingListState({
    this.bookings = const [],
    this.statusFilter,
    this.pagination,
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  BookingListState copyWith({
    List<BookingModel>? bookings,
    BookingStatus? statusFilter,
    bool clearFilter = false,
    PaginationMeta? pagination,
    BlocStatus? status,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      statusFilter: clearFilter ? null : (statusFilter ?? this.statusFilter),
      pagination: pagination ?? this.pagination,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  List<BookingModel> get filteredBookings {
    if (statusFilter == null) return bookings;
    return bookings
        .where((b) => b.bookingStatus == statusFilter)
        .toList();
  }

  @override
  List<Object?> get props =>
      [bookings, statusFilter, pagination, status, errorMessage, hasReachedMax];
}

// Bloc
class BookingListBloc extends Bloc<BookingListEvent, BookingListState> {
  final BookingRepository _repository;

  BookingListBloc(this._repository) : super(const BookingListState()) {
    on<BookingListFetchRequested>(_onFetchRequested);
    on<BookingListRefreshRequested>(_onRefreshRequested);
    on<BookingListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onFetchRequested(
    BookingListFetchRequested event,
    Emitter<BookingListState> emit,
  ) async {
    if (state.status == BlocStatus.loading) return;
    if (state.hasReachedMax && event.page > 1) return;

    emit(state.copyWith(status: BlocStatus.loading));
    try {
      final result = await _repository.listBookings(page: event.page);
      final allItems = event.page == 1
          ? result.items
          : [...state.bookings, ...result.items];
      emit(state.copyWith(
        status: BlocStatus.loaded,
        bookings: allItems,
        pagination: result.pagination,
        hasReachedMax: !result.pagination.hasNextPage,
      ));
    } on ApiError catch (e) {
      emit(state.copyWith(
          status: BlocStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: BlocStatus.error, errorMessage: 'Failed to load bookings'));
    }
  }

  Future<void> _onRefreshRequested(
    BookingListRefreshRequested event,
    Emitter<BookingListState> emit,
  ) async {
    emit(state.copyWith(hasReachedMax: false));
    add(const BookingListFetchRequested(page: 1));
  }

  void _onFilterChanged(
    BookingListFilterChanged event,
    Emitter<BookingListState> emit,
  ) {
    if (event.statusFilter == state.statusFilter) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(statusFilter: event.statusFilter));
    }
  }
}
