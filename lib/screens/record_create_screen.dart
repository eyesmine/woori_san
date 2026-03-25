import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../models/hiking_record.dart';
import '../providers/mountain_provider.dart';

class RecordCreateScreen extends StatefulWidget {
  const RecordCreateScreen({super.key});

  @override
  State<RecordCreateScreen> createState() => _RecordCreateScreenState();
}

class _RecordCreateScreenState extends State<RecordCreateScreen> {
  Mountain? _selectedMountain;
  DateTime? _selectedDate;
  int _hours = 0;
  int _minutes = 0;
  final _distanceController = TextEditingController();
  final _mountainSearchController = TextEditingController();
  final _mountainSearchFocus = FocusNode();
  String _mountainQuery = '';
  final List<XFile> _photos = [];

  @override
  void dispose() {
    _distanceController.dispose();
    _mountainSearchController.dispose();
    _mountainSearchFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      final files = await picker.pickMultiImage(maxWidth: 1024, imageQuality: 85);
      if (files.isNotEmpty) {
        setState(() => _photos.addAll(files));
      }
    } catch (e) { AppLogger.warning('사진 선택 실패', tag: 'RecordCreate', error: e); }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_selectedMountain == null || _selectedDate == null) return;
    final distanceKm = double.tryParse(_distanceController.text) ?? 0;
    if (distanceKm <= 0) return;
    if (_hours == 0 && _minutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.durationRequired ?? 'Please enter duration')),
      );
      return;
    }

    final record = HikingRecord(
      mountain: _selectedMountain!.name,
      mountainId: _selectedMountain!.id,
      date: DateFormat('yyyy.MM.dd', 'ko_KR').format(_selectedDate!),
      duration: _hours > 0 ? '${_hours}h ${_minutes}m' : '${_minutes}m',
      distanceKm: distanceKm,
      emoji: _selectedMountain!.emoji,
      photoUrls: _photos.isNotEmpty ? _photos.map((f) => f.path).toList() : null,
    );

    context.read<MountainProvider>().addRecord(record);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mountains = context.read<MountainProvider>().mountains;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.addRecord),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.selectMountain, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
            const SizedBox(height: 12),
            if (_selectedMountain != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    Text(_selectedMountain!.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedMountain!.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedMountain = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              TextField(
                controller: _mountainSearchController,
                focusNode: _mountainSearchFocus,
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  filled: true,
                  fillColor: context.appSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _mountainQuery = v),
              ),
              if (_mountainQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final query = _mountainQuery.toLowerCase();
                  final filtered = mountains
                      .where((m) => m.name.toLowerCase().contains(query) || m.location.toLowerCase().contains(query))
                      .take(10)
                      .toList();
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l.noSearchResults, style: TextStyle(color: context.appTextSub)),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filtered.map((m) => ChoiceChip(
                      label: Text('${m.emoji} ${m.name}'),
                      selected: false,
                      onSelected: (_) => setState(() {
                        _selectedMountain = m;
                        _mountainSearchController.clear();
                        _mountainQuery = '';
                      }),
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(color: context.appText),
                    )).toList(),
                  );
                }),
              ],
            ],

            const SizedBox(height: 24),
            Text(l.selectDate, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? DateFormat('yyyy.M.d', 'ko_KR').format(_selectedDate!)
                        : l.selectDate,
                    style: TextStyle(color: _selectedDate != null ? context.appText : context.appTextSub),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 24),
            Text(l.duration, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _hours,
                        isExpanded: true,
                        items: List.generate(13, (i) => DropdownMenuItem(value: i, child: Text('$i ${l.hours}'))),
                        onChanged: (v) => setState(() => _hours = v ?? 0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _minutes,
                        isExpanded: true,
                        items: List.generate(12, (i) => DropdownMenuItem(value: i * 5, child: Text('${i * 5} ${l.minutes}'))),
                        onChanged: (v) => setState(() => _minutes = v ?? 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text('${l.distance} (km)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
            const SizedBox(height: 12),
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '예: 6.5',
                filled: true,
                fillColor: context.appSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                suffixText: 'km',
              ),
            ),

            const SizedBox(height: 24),
            Text(l.photo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._photos.asMap().entries.map((entry) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(entry.value.path, width: 80, height: 80, fit: BoxFit.cover)
                          : Image.file(File(entry.value.path), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(entry.key)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                )),
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary.withAlpha(77)),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.primary.withAlpha(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary),
                        const SizedBox(height: 4),
                        Text(l.addButton, style: const TextStyle(color: AppTheme.primary, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedMountain != null && _selectedDate != null && _distanceController.text.isNotEmpty)
                    ? _save
                    : null,
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
