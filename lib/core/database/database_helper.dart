import 'package:kasirsuper/features/product/models/product_model.dart';
import 'package:kasirsuper/features/service/models/service_model.dart';
import 'package:kasirsuper/features/transaction/models/transaction_model.dart';
import 'package:kasirsuper/features/transaction/models/transaction_item_model.dart';
import 'package:kasirsuper/features/mechanic/models/mechanic_model.dart';
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
      version: 7,
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
        imagePath TEXT,
        sparepart_code TEXT
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
        item_type TEXT DEFAULT 'product',
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        sku TEXT,
        category TEXT,
        price REAL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        date TEXT,
        is_read INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE mechanics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        address TEXT,
        skills TEXT
      )
    ''');

    // Insert some initial data
    await db.execute('''
      INSERT INTO products (name, sku, category, price, cost, stock, minStock, sparepart_code)
      VALUES 
        ('Acoustic Pro X1', 'SKU: AUD-9920-B', 'Elektronik', 189000, 150000, 2, 5, 'SPR-000001'),
        ('Essential Cotton Tee', 'SKU: APP-1102-W', 'Pakaian', 25000, 15000, 142, 10, 'SPR-000002'),
        ('Artisan Ceramic Mug', 'SKU: HOM-0043-T', 'Peralatan Rumah', 18500, 10000, 58, 20, 'SPR-000003'),
        ('Rapid-Sync 1TB Drive', 'SKU: ACC-8831-S', 'Aksesoris', 115000, 90000, 5, 10, 'SPR-000004')
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

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE services(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          sku TEXT,
          category TEXT,
          price REAL,
          description TEXT
        )
      ''');
      await db.execute('ALTER TABLE transaction_items ADD COLUMN item_type TEXT DEFAULT "product"');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE notifications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          body TEXT,
          date TEXT,
          is_read INTEGER DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE mechanics(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          phone TEXT,
          address TEXT,
          skills TEXT
        )
      ''');
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE stock_movements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          type TEXT,
          quantity INTEGER,
          date TEXT,
          notes TEXT,
          FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 7) {
      await db.execute('ALTER TABLE products ADD COLUMN sparepart_code TEXT');
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

  // Stock Movements
  Future<int> insertStockMovement(int productId, String type, int quantity, String notes) async {
    final db = await database;
    int movementId = 0;

    await db.transaction((txn) async {
      // 1. Insert into stock_movements
      movementId = await txn.insert('stock_movements', {
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'date': DateTime.now().toIso8601String(),
        'notes': notes,
      });

      // 2. Update product stock
      if (type == 'in') {
        await txn.rawUpdate(
          'UPDATE products SET stock = stock + ? WHERE id = ?',
          [quantity, productId],
        );
      } else if (type == 'out') {
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [quantity, productId],
        );
      } else if (type == 'opname') {
        await txn.rawUpdate(
          'UPDATE products SET stock = ? WHERE id = ?',
          [quantity, productId],
        );
      }
    });

    return movementId;
  }

  Future<List<Map<String, dynamic>>> getStockMovements() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        sm.*, 
        p.name as product_name, 
        p.sku as product_sku
      FROM stock_movements sm
      LEFT JOIN products p ON sm.product_id = p.id
      ORDER BY sm.date DESC
    ''');
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
          
          // Deduct stock only for products
          if (item.itemType == 'product') {
            await txn.rawUpdate(
              'UPDATE products SET stock = stock - ? WHERE id = ?',
              [item.quantity, item.productId],
            );
          }
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

  // CRUD for Services
  Future<int> insertService(ServiceModel service) async {
    final db = await database;
    return await db.insert(
      'services',
      service.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ServiceModel>> getServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('services', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => ServiceModel.fromMap(maps[i]));
  }

  Future<int> updateService(ServiceModel service) async {
    final db = await database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD for Notifications
  Future<int> insertNotification(Map<String, dynamic> notificationData) async {
    final db = await database;
    return await db.insert(
      'notifications',
      notificationData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'id DESC');
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD for Mechanics
  Future<int> insertMechanic(MechanicModel mechanic) async {
    final db = await database;
    return await db.insert(
      'mechanics',
      mechanic.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MechanicModel>> getMechanics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mechanics', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => MechanicModel.fromMap(maps[i]));
  }

  Future<int> updateMechanic(MechanicModel mechanic) async {
    final db = await database;
    return await db.update(
      'mechanics',
      mechanic.toMap(),
      where: 'id = ?',
      whereArgs: [mechanic.id],
    );
  }

  Future<int> deleteMechanic(int id) async {
    final db = await database;
    return await db.delete(
      'mechanics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
