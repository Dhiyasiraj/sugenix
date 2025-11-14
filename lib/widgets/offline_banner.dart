import 'package:flutter/material.dart';
import 'package:sugenix/services/sync_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = SyncService();
    return StreamBuilder<Map<String, bool>>(
      stream: sync.networkStatusStream(),
      builder: (context, snapshot) {
        // Only show if we have data and there's actually an issue
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final isFromCache = snapshot.data?['isFromCache'] ?? false;
        final hasPending = snapshot.data?['hasPendingWrites'] ?? false;
        
        // Don't show if we're online and have no pending writes
        if (!isFromCache && !hasPending) return const SizedBox.shrink();
        
        // Don't show if snapshot has errors (collection doesn't exist)
        if (snapshot.hasError) return const SizedBox.shrink();

        String text = '';
        Color bg = Colors.orange;
        if (isFromCache && hasPending) {
          text = 'Offline • Syncing pending changes when online';
          bg = Colors.orange;
        } else if (isFromCache) {
          text = 'Offline • Showing cached data';
          bg = Colors.redAccent;
        } else if (hasPending) {
          text = 'Syncing your changes…';
          bg = Colors.orange;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: bg,
          child: Row(
            children: [
              const Icon(Icons.cloud_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await sync.goOnline();
                },
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}


