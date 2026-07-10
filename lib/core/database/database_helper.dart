import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kasirsuper.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        sku TEXT,
        category TEXT,
        price INTEGER,
        cost INTEGER,
        stock INTEGER,
        minStock INTEGER,
        imagePath TEXT
      )
    ''');
    
    // Insert some initial data
    await db.execute('''
      INSERT INTO products (name, sku, category, price, cost, stock, minStock)
      VALUES 
        ('Acoustic Pro X1', 'SKU: AUD-9920-B', 'Elektronik', 189000, 150000, 2, 5),
        ('Essential Cotton Tee', 'SKU: APP-1102-W', 'Pakaian', 25000, 15000, 142, 10),
        ('Artisan Ceramic Mug', 'SKU: HOM-0043-T', 'Peralatan Rumah', 18500, 10000, 58, 20),
        ('Rapid-Sync 1TB Drive', 'SKU: ACC-8831-S', 'Aksesoris', 115000, 90000, 5, 10)
    ''');
  }

  // CRUD for Products
  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
