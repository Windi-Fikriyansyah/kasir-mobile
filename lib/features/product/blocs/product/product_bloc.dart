import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/core/database/database_helper.dart';
import 'package:kasirsuper/features/product/blocs/product/product_event.dart';
import 'package:kasirsuper/features/product/blocs/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final DatabaseHelper databaseHelper;

  ProductBloc({required this.databaseHelper}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await databaseHelper.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError('Failed to load products: $e'));
    }
  }

  Future<void> _onAddProduct(AddProductEvent event, Emitter<ProductState> emit) async {
    try {
      await databaseHelper.insertProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to add product: $e'));
    }
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    try {
      await databaseHelper.updateProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to update product: $e'));
    }
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    try {
      await databaseHelper.deleteProduct(event.id);
      add(LoadProducts());
    } catch (e) {
      emit(ProductError('Failed to delete product: $e'));
    }
  }
}
