import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../models/hiking_record.dart';
import '../widgets/share_record_card.dart';

class ShareService {
  static Future<void> shareRecord(HikingRecord record) async {
    final controller = ScreenshotController();
    final Uint8List image = await controller.captureFromLongWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: ShareRecordCard(record: record),
          ),
        ),
      ),
      pixelRatio: 3.0,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/woori_san_record.png');
    await file.writeAsBytes(image);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '우리산 등산 기록 - ${record.mountain} ${record.date}',
      ),
    );
  }
}
