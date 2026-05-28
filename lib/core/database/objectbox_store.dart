import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';

class ObjectBoxStore {
  late final Store store;

  ObjectBoxStore._create(this.store);

  static Future<ObjectBoxStore> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final storePath = p.join(docsDir.path, "simple-expensesbox");
    
    final store = await openStore(directory: storePath);
    return ObjectBoxStore._create(store);
  }
}