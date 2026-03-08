import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/search_customers_usecase.dart';
import '../../domain/usecases/get_customer_detail_usecase.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

/// BLoC for managing customer-related business logic.
///
/// Handles all customer events and emits corresponding states.
/// Each event handler follows the pattern:
/// 1. Emit loading state
/// 2. Call the appropriate use case
/// 3. Emit success or error state based on result
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final SearchCustomersUseCase searchCustomersUseCase;
  final GetCustomerDetailUseCase getCustomerDetailUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.searchCustomersUseCase,
    required this.getCustomerDetailUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
  }) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<LoadCustomerDetail>(_onLoadCustomerDetail);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  /// Handles loading paginated customer list.
  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await getCustomersUseCase(
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (paginatedResult) => emit(CustomerLoaded(result: paginatedResult)),
    );
  }

  /// Handles searching customers with filters.
  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await searchCustomersUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      address: event.address,
      uniqueId: event.uniqueId,
      page: event.page,
      pageSize: event.pageSize,
    );

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (paginatedResult) => emit(CustomerLoaded(
        result: paginatedResult,
        searchQuery: event.name,
      )),
    );
  }

  /// Handles loading a single customer's detail.
  Future<void> _onLoadCustomerDetail(
    LoadCustomerDetail event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await getCustomerDetailUseCase.callById(event.customerId);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(CustomerDetailLoaded(customer)),
    );
  }

  /// Handles creating a new customer.
  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await createCustomerUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      address: event.address,
      uniqueId: event.uniqueId,
    );

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) =>
          emit(const CustomerActionSuccess('Müşteri başarıyla oluşturuldu')),
    );
  }

  /// Handles updating an existing customer.
  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await updateCustomerUseCase(
      id: event.id,
      name: event.name,
      email: event.email,
      phone: event.phone,
      address: event.address,
      uniqueId: event.uniqueId,
    );

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) =>
          emit(const CustomerActionSuccess('Müşteri başarıyla güncellendi')),
    );
  }

  /// Handles deleting a customer.
  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final result = await deleteCustomerUseCase(event.customerId);

    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (_) => emit(const CustomerActionSuccess('Müşteri başarıyla silindi')),
    );
  }
}
