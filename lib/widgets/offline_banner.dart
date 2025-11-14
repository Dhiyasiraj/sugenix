import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sugenix/services/sync_service.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  Timer? _debounceTimer;
  bool _shouldShow = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sync = SyncService();
    return StreamBuilder<Map<String, bool>>(
      stream: sync.networkStatusStream(),
      builder: (context, snapshot) {
        // Only show if we have data and there's actually an issue
        if (!snapshot.hasData || snapshot.hasError) {
          _shouldShow = false;
          return const SizedBox.shrink();
        }
        
        final isFromCache = snapshot.data?['isFromCache'] ?? false;
        final hasPendingWrites = snapshot.data?['hasPendingWrites'] ?? false;
        final isOnline = snapshot.data?['isOnline'] ?? true;
        
        // Only show if we're actually offline OR have pending writes
        // Don't show during normal navigation when Firebase is just using cache
        final shouldShow = (!isOnline) || (hasPendingWrites && !isOnline);
        
        // Debounce to prevent flickering during navigation
        if (shouldShow != _shouldShow) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _shouldShow = shouldShow;
              });
            }
          });
        }
        
        // Don't show if we're online and no pending writes
        if (isOnline && !hasPendingWrites) {
          return const SizedBox.shrink();
        }
        
        // Don't show if only reading from cache but we're online (normal Firebase behavior)
        if (isFromCache && isOnline && !hasPendingWrites) {
          return const SizedBox.shrink();
        }

        // Only render if we should show (after debounce)
        if (!_shouldShow && !hasPendingWrites) {
          return const SizedBox.shrink();
        }

        String text = '';
        Color bg = Colors.orange;
        if (!isOnline && hasPendingWrites) {
          text = 'Offline • Syncing pending changes when online';
          bg = Colors.orange;
        } else if (!isOnline) {
          text = 'Offline • Showing cached data';
          bg = Colors.redAccent;
        } else if (hasPendingWrites) {
          text = 'Syncing your changes…';
          bg = Colors.orange;
        } else {
          return const SizedBox.shrink();
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


