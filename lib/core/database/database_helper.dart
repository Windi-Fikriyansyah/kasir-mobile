import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:kasirsuper/features/transaction/models/transaction_item_model.dart';
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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
    
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        total_amount REAL,
        amount_given REAL,
        change REAL,
        payment_method TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        product_id INTEGER,
        product_name TEXT,
        price REAL,
        quantity INTEGER,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          total_amount REAL,
          amount_given REAL,
          change REAL,
          payment_method TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE transaction_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_id INTEGER,
          product_id INTEGER,
          product_name TEXT,
          price REAL,
          quantity INTEGER,
          FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
        )
      ''');
    }
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

  // Transactions
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    int transactionId = 0;
    
    await db.transaction((txn) async {
      transactionId = await txn.insert('transactions', transaction.toMap());
      
      if (transaction.items != null) {
        for (var item in transaction.items!) {
          final itemMap = item.toMap();
          itemMap['transaction_id'] = transactionId;
          await txn.insert('transaction_items', itemMap);
          
          // Deduct stock
          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [item.quantity, item.productId],
          );
        }
      }
    });
    
    return transactionId;
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    
    List<TransactionModel> transactions = [];
    for (var map in maps) {
      final id = map['id'];
      
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: [id],
      );
      
      final items = itemMaps.map((itemMap) => TransactionItemModel.fromMap(itemMap)).toList();
      transactions.add(TransactionModel.fromMap(map, items: items));
    }
    
    return transactions;
  }
}
