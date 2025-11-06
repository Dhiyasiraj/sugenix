import 'package:cloud_firestore/cloud_firestore.dart';

class SyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Emits network/cache and pending-writes status by listening to a tiny collection
  Stream<Map<String, bool>> networkStatusStream() {
    return _db
        .collection('_sync_probe')
        .limit(1)
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
      return {
        'isFromCache': snap.metadata.isFromCache,
        'hasPendingWrites': snap.metadata.hasPendingWrites,
      };
    });
  }

  Future<void> goOffline() => _db.disableNetwork();
  Future<void> goOnline() => _db.enableNetwork();
}


