import 'package:equatable/equatable.dart';

/// Generic paginated result entity for handling paginated API responses.
/// Reusable across different features that need pagination.
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  /// Whether there are more pages available after the current page.
  bool get hasNextPage => page < totalPages;

  /// Whether there is a previous page before the current page.
  bool get hasPreviousPage => page > 1;

  @override
  List<Object?> get props => [items, totalCount, page, pageSize, totalPages];
}
