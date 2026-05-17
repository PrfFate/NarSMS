import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/custom_refresh_button.dart';
import '../../../../core/widgets/device_image_widget.dart';
import '../../domain/entities/service_request_entity.dart';
import '../bloc/technical_service_bloc.dart';
import '../bloc/technical_service_event.dart';
import '../bloc/technical_service_state.dart';

/// Son Kontroller listesi.
/// GET /api/ServiceRequest/paged?status=LastControl
class ServiceFinalChecksPage extends StatefulWidget {
  const ServiceFinalChecksPage({super.key});

  @override
  State<ServiceFinalChecksPage> createState() => _ServiceFinalChecksPageState();
}

class _ServiceFinalChecksPageState extends State<ServiceFinalChecksPage> {
  int _currentPage = 1;
  static const int _pageSize = 15;
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollListener);
    _loadRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollListener() {
    _onScroll();
    _updateFabVisibility();
  }

  void _updateFabVisibility() {
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToTop) {
      if (mounted) setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    final state = context.read<TechnicalServiceBloc>().state;
    if (state is! TechnicalServiceLoaded) return;
    if (!state.hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    context.read<TechnicalServiceBloc>().add(
          LoadMoreServiceRequests(
            nextPage: _currentPage,
            existingRequests: state.requests,
            pageSize: _pageSize,
            status: 'LastControl',
          ),
        );
  }

  void _loadRequests() {
    if (!mounted) return;
    setState(() {
      _currentPage = 1;
      _isLoadingMore = false;
    });
    context.read<TechnicalServiceBloc>().add(
          const LoadServiceRequests(
            page: 1,
            pageSize: _pageSize,
            status: 'LastControl',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  );
                }
              },
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              tooltip: 'Başa Dön',
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomRefreshButton(onPressed: _loadRequests),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<TechnicalServiceBloc, TechnicalServiceState>(
                listener: (context, state) {
                  if (state is TechnicalServiceLoaded && !state.isLoadingMore) {
                    setState(() => _isLoadingMore = false);
                  }
                  if (state is TechnicalServiceError) {
                    setState(() => _isLoadingMore = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TechnicalServiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TechnicalServiceLoaded) {
                    if (state.requests.isEmpty) return _buildEmptyState();
                    return _buildRequestList(
                        state.requests, state.hasMore, state.isLoadingMore);
                  }
                  if (state is TechnicalServiceError) {
                    return _buildErrorState(state.message);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fact_check_outlined, size: 64, color: Color(0xFFF57C00)),
            SizedBox(height: 16),
            Text(
              'Son kontrolde olan kayıt bulunmuyor',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(
      List<ServiceRequestEntity> requests, bool hasMore, bool isLoadingMore) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: requests.length + 1,
        separatorBuilder: (context, index) => index < requests.length - 1
            ? const Divider(height: 1)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index == requests.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (!hasMore && requests.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Tüm ${requests.length} kayıt listelendi',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final request = requests[index];

          return InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.serviceFinalCheckDetail,
                arguments: request,
              );
              if (result == true) _loadRequests();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  DeviceImageWidget(
                    deviceTypeName: request.deviceTypeName,
                    size: 48,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.deviceTypeName ?? 'Bilinmeyen Cihaz',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              request.deviceSerialNumber ?? 'Seri No Yok',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            if (request.supplierName != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.business,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  request.supplierName!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.faultDescription ?? 'Arıza açıklaması yok',
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (request.requestDate != null)
                        Text(
                          DateFormat('dd.MM.yyyy')
                              .format(request.requestDate!.toLocal()),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF57C00).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SON KONTROL',
                          style: TextStyle(
                            color: Color(0xFFF57C00),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
