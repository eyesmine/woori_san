import '../models/stamp.dart';
import '../datasources/local/stamp_local.dart';

class StampRepository {
  final StampLocalDataSource _local;

  StampRepository(this._local);

  List<Stamp> getAll() => _local.getAll();

  Future<void> saveAll(List<Stamp> stamps) => _local.saveAll(stamps);
}
