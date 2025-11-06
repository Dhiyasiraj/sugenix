import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugenix/services/glucose_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class GlucoseHistoryScreen extends StatefulWidget {
  const GlucoseHistoryScreen({super.key});

  @override
  State<GlucoseHistoryScreen> createState() => _GlucoseHistoryScreenState();
}

class _GlucoseHistoryScreenState extends State<GlucoseHistoryScreen> {
  final GlucoseService _glucoseService = GlucoseService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _loading = false;
  List<Map<String, dynamic>> _readings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      await _load();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _glucoseService.getGlucoseReadingsByDateRange(
        startDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
        endDate: DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
      );
      setState(() => _readings = list);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportCSV() async {
    if (_readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('timestamp,value,type,notes');
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final r in _readings) {
      final ts = (r['timestamp'] as Timestamp?)?.toDate();
      final line = [
        ts != null ? df.format(ts) : '',
        (r['value'] ?? '').toString(),
        (r['type'] ?? '').toString(),
        (r['notes'] ?? '').toString().replaceAll(',', ' '),
      ].join(',');
      buffer.writeln(line);
    }

    final bytes = utf8.encode(buffer.toString());
    final fileName =
        'glucose_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      (html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click());
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported to $path')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: ${e.toString()}')),
        );
      }
    }
  }

  // PDF export is optional; enable later when PDF dependencies are added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose History'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0C4556),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: _exportCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.date_range),
                    label: Text('From: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEndDate,
                    icon: const Icon(Icons.event),
                    label: Text('To: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _readings.isEmpty
                    ? const Center(
                        child: Text('No readings in selected range',
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _readings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = _readings[index];
                          final ts = (r['timestamp'] as Timestamp?)?.toDate();
                          final value = (r['value'] as double?) ?? 0.0;
                          final type = (r['type'] as String?) ?? '';
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.bloodtype, color: Color(0xFF0C4556)),
                              title: Text('${value.toStringAsFixed(0)} mg/dL',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, color: Color(0xFF0C4556))),
                              subtitle: Text(
                                '${type.toUpperCase()} • ${ts != null ? DateFormat('yyyy-MM-dd HH:mm').format(ts) : '—'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6F8),
    );
  }
}


