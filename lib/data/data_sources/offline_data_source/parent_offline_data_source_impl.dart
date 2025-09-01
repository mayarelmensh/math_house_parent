import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:math_house_parent/core/errors/failures.dart';
import '../../../core/cache/shared_preferences_utils.dart';
import '../../../domain/entities/login_response_entity.dart';
import '../../../domain/repository/data_sources/offline_data_source/profile_offline_data_source.dart';
import '../../models/login_response_dm.dart';

@Injectable(as: ProfileLocalDataSource)
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String cachedParentKey = 'CACHED_PARENT';

  @override
  Future<void> cacheParent(ParentLoginEntity parent) async {
    try {
      final parentDm = ParentLoginDm.fromEntity(parent);
      final jsonString = json.encode(parentDm.toJson());

      print("📥 Saving to cache: $jsonString");

      await SharedPreferenceUtils.saveData(
        key: cachedParentKey,
        value: jsonString,
      );
    } catch (e) {
      print("❌ Error while caching parent: $e");
      throw CacheFailure(errorMsg: e.toString());
    }
  }

  @override
  Future<ParentLoginEntity?> getCachedParent() async {
    try {
      final jsonString = SharedPreferenceUtils.getData(key: cachedParentKey) as String?;
      print("📤 Loaded raw from cache: $jsonString");

      if (jsonString != null) {
        final Map<String, dynamic> jsonMap =
        json.decode(jsonString) as Map<String, dynamic>;
        print("📤 Decoded JSON Map: $jsonMap");

        final parentDm = ParentLoginDm.fromJson(jsonMap);
        print("✅ Converted to ParentLoginDm: $parentDm");

        return parentDm;
      }
      return null;
    } catch (e) {
      print("❌ Error while getting cached parent: $e");
      throw CacheFailure(errorMsg: e.toString());
    }
  }

  @override
  Future<void> clearCachedParent () async {
    try {
      await SharedPreferenceUtils.removeData(key: cachedParentKey);
      print("🗑️ Cache cleared for key: $cachedParentKey");
    } catch (e) {
      print("❌ Error while clearing cache: $e");
      throw CacheFailure(errorMsg: e.toString());
    }
  }





// @Injectable(as: ProfileLocalDataSource)
// class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
//   static const String cachedParentKey = "CACHED_PARENT";
//
//   @override
//   Future<void> cacheParent(ParentLoginDm parentDm) async {
//     await SharedPreferenceUtils.saveData(
//       key: cachedParentKey,
//       value: jsonEncode(parentDm.toJson()),
//     );
//
//     // Debug
//     print("✅ Saved: ${jsonEncode(parentDm.toJson())}");
//   }
//
//   @override
//   Future<ParentLoginDm?> getCachedParent() async {
//     final jsonString =
//     SharedPreferenceUtils.getData(key: cachedParentKey) as String?;
//     print("📥 Loaded raw: $jsonString");
//
//       if (jsonString != null) {
//         final decoded = jsonDecode(jsonString);
//         final model = ParentLoginDm.fromJson(decoded);
//         print("🔥 Loaded parsed: ${model.toJson()}");
//         return model;
//       }
//       return null;
//     }
//
//   @override
//   Future<void> clearCachedParent() async {
//     await SharedPreferenceUtils.removeData(key: cachedParentKey);
//   }
}
