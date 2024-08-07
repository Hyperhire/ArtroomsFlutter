import 'dart:io';

import 'package:artrooms/beans/bean_file.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart' as path;

import '../utils/utils_media.dart';

class ModuleMedia {
  bool isLoadingImages = false;
  bool isLoadingMedia = false;
  List<FileItem> imageFiles = [];
  List<FileItem> mediaFiles = [];

  Future<List<FileItem>> loadFileImages({bool isShowSettings = false}) async {
    List<FileItem> imageFiles = [];

    List<FileItem> imageFiles1 =
        await loadFileImages1(isShowSettings: isShowSettings);

    imageFiles.addAll(imageFiles1);

    imageFiles.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    return imageFiles;
  }

  Future<List<FileItem>> loadFileImages1(
      {bool isShowSettings = false,
      int page = 1,
      int pageSize = 100,
      Null Function(FileItem fileItem)? onLoad,
      Null Function()? onLoadEnd}) async {
    // PhotoManager.clearFileCache();

    PermissionState result = await PhotoManager.requestPermissionExtend();

    if (result.isAuth || result.hasAccess) {
      final filterOption = FilterOptionGroup()
        ..addOrderOption(
          const OrderOption(type: OrderOptionType.createDate),
        );

      final int count = await PhotoManager.getAssetCount(
        type: RequestType.image,
        filterOption: filterOption,
      );
      print('Total Count: ${count}');

      final List<AssetEntity> images = await PhotoManager.getAssetListPaged(
        page: page - 1,
        pageCount: pageSize,
        filterOption: filterOption,
      );
      print('Total Images: ${images.length}');

      for (AssetEntity asset in images) {
        final directory = await getTemporaryDirectory();

        final String fileName =
            asset.title?.isNotEmpty == true ? asset.title! : asset.id;
        final String safeFileName =
            fileName.replaceAll(RegExp(r'[^\w\s-]'), '_');

        // final String filePath = path.join(directory.path, safeFileName);
        final String thumbnailPath =
            path.join(directory.path, "${safeFileName}_thumbnail");

        File? file = await asset.originFile;

        if (file != null) {
          final extension = path.extension(file.path);

          final tempData = await asset.originBytes;

          if (tempData != null) {
            // File tempFile = File("$filePath$extension")
            //   ..writeAsBytesSync(tempData);

            File? thumbFile;
            final thumbData = await asset.thumbnailDataWithSize(
              const ThumbnailSize(100, 100),
            );
            if (thumbData != null) {
              try {
                thumbFile = File("$thumbnailPath$extension")
                  ..writeAsBytesSync(thumbData);
              } catch (e) {
                print("Error writing thumbnail file: $e");
                thumbFile = null;
              }
            }

            FileItem fileItem = FileItem(
                file: file,
                thumbFile: thumbFile,
                name: file.path,
                path: file.path);

            if (onLoad != null) {
              onLoad(fileItem);
            }

            if (!imageFiles.contains(fileItem)) {
              imageFiles.add(fileItem);
            }
          }
        }
      }

      if (onLoadEnd != null) {
        onLoadEnd();
      }
    } else {
      if (isShowSettings) {
        PhotoManager.openSetting();
      }
    }

    return imageFiles;
  }

  Future<List<FileItem>> loadFilesMedia() async {
    List<FileItem> mediaFiles = [];
    print('1111');

    List<FileItem> mediaFiles1 = await loadFilesMedia1();
    print('2222');
    List<FileItem> mediaFiles2 = await loadFilesMedia2();
    print('3333');

    mediaFiles.addAll(mediaFiles1);
    print('4444');
    mediaFiles.addAll(mediaFiles2);
    print('5555');

    mediaFiles.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    return mediaFiles;
  }

  Future<List<FileItem>> loadFilesMedia1() async {
    print('loadFilesMedia1 started');
    List<FileItem> mediaFiles = [];

    List<AssetEntity> assetFiles = [];

    PermissionState result = await PhotoManager.requestPermissionExtend();

    if (result.isAuth || result.hasAccess) {
      List<AssetPathEntity> albums = [];

      List<AssetPathEntity> albums1 =
          await PhotoManager.getAssetPathList(type: RequestType.video);
      List<AssetPathEntity> albums2 =
          await PhotoManager.getAssetPathList(type: RequestType.audio);

      albums.addAll(albums1);
      albums.addAll(albums2);

      for (AssetPathEntity album in albums) {
        album.assetCountAsync.then((assetCount) async {
          print('asset count is ${assetCount}');
          List<AssetEntity> images =
              await album.getAssetListPaged(page: 0, size: assetCount);
          assetFiles.addAll(images);

          for (AssetEntity asset in images) {
            File? file = await asset.originFile;
            if (file != null) {
              final String fileExtension =
                  path.extension(asset.title ?? asset.id).toLowerCase();
              final bool isImage = isFileImage(fileExtension);

              final dateFormat = DateFormat('yyyy.MM.dd', 'ko_KR');
              final dateString = dateFormat.format(asset.createDateTime);

              if (!isImage) {
                FileItem fileItem = FileItem(
                  file: file,
                  name: asset.title ?? asset.id,
                  path: file.path,
                  date: dateString,
                );

                if (!mediaFiles.contains(fileItem)) {
                  mediaFiles.add(fileItem);
                }
              }
            }
          }
        });
      }

      assetFiles.sort((a, b) {
        return b.createDateTime.compareTo(a.createDateTime);
      });
    } else {
      PhotoManager.openSetting();
    }

    return mediaFiles;
  }

  Future<List<FileItem>> loadFilesMedia2() async {
    List<FileItem> mediaFiles = [];

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    List<Directory> directories = [];

    final Directory? dir = (await getDownloadsDirectory())?.parent;

    final Directory? dir1 = await getDownloadsDirectory();
    final Directory? dir2 = await getExternalStorageDirectory();
    final Directory dir3 = await getApplicationDocumentsDirectory();

    directories.add(dir!);
    directories.add(dir1!);
    directories.add(dir2!);
    directories.add(dir3);

    var directory;
    if (Platform.isIOS) {
      directory = await getDownloadsDirectory();
    } else {
      directory = "/storage/emulated/0/Download/";
      bool dirDownloadExists = await Directory(directory).exists();
      if (dirDownloadExists) {
        directory = Directory("/storage/emulated/0/Download/");
      } else {
        directory = Directory("/storage/emulated/0/Downloads/");
      }
    }
    directories.add(directory);

    var directoryRoot;
    if (Platform.isIOS) {
      directoryRoot = await getDownloadsDirectory();
    } else {
      directoryRoot = "/storage/emulated/0/";
      bool dirDownloadExists = await Directory(directoryRoot).exists();
      if (dirDownloadExists) {
        directoryRoot = Directory("/storage/emulated/0/");
      } else {
        directoryRoot = Directory("/storage/emulated/0/");
      }
    }
    directories.add(directoryRoot);

    for (var directory in directories) {
      try {
        if (kDebugMode) {
          print(directory.path);
        }

        if (await directory.exists()) {
          await for (var entity
              in directory.list(recursive: true, followLinks: false)) {
            if (entity is File) {
              final String fileExtension =
                  path.extension(entity.path).toLowerCase();
              final bool isImage = isFileImage(fileExtension);

              if (!isImage) {
                final dateFormat = DateFormat('yyyy.MM.dd', 'ko_KR');
                final dateString =
                    dateFormat.format(await entity.lastModified());

                final fileItem = FileItem(
                  file: entity,
                  name: path.basename(entity.path),
                  path: entity.path,
                  date: dateString,
                );

                if (!mediaFiles.contains(fileItem)) {
                  mediaFiles.add(fileItem);
                }
              }
            }
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }

    return mediaFiles;
  }
}
