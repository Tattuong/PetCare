import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class PetPhotoService {
  PetPhotoService._();

  static final ImagePicker _picker = ImagePicker();
  static const _uuid = Uuid();

  static Future<String?> pickAndSave(BuildContext context, {String? petId}) async {
    final source = await _showSourceSheet(context);
    if (source == null || !context.mounted) return null;

    final picked = await _picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return null;

    return _persistFile(picked.path, petId: petId);
  }

  static Future<String> _persistFile(String tempPath, {String? petId}) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/pet_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName = '${petId ?? _uuid.v4()}.jpg';
    final dest = File('${photosDir.path}/$fileName');
    await File(tempPath).copy(dest.path);
    return dest.path;
  }

  static Future<ImageSource?> _showSourceSheet(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.pastelLavender.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryDark),
                ),
                title: Text(AppStrings.t(context, 'chooseGallery'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.pastelOrange.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.photo_camera_rounded, color: AppColors.primaryDark),
                ),
                title: Text(AppStrings.t(context, 'takePhoto'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
