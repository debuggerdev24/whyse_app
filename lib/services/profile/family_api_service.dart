import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class FamilyApiService {
  FamilyApiService._();

  static final FamilyApiService _instance = FamilyApiService._();
  static FamilyApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getFamilyMembers({
    int page = 1,
    int limit = 20,
  }) async {
    return BaseApiHelper.instance.get(
      EndPoints.getFamilyMembers(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> addFamilyMember({
    required String memberUserId,
    required String role,
  }) async {
    return BaseApiHelper.instance.post(
      EndPoints.addFamilyMember,
      data: {
        'memberUserId': memberUserId,
        'role': role,
      },
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getFamilyMembersRoles({
    String? excludeFamilyMemberId,
  }) async {
    final path = excludeFamilyMemberId != null &&
            excludeFamilyMemberId.isNotEmpty
        ? EndPoints.getFamilyMembersRolesForEdit(
            excludeFamilyMemberId: excludeFamilyMemberId,
          )
        : EndPoints.getFamilyMembersRoles;
    return BaseApiHelper.instance.get(path);
  }

  Future<Either<ApiException, Map<String, dynamic>>> updateFamilyMemberRole({
    required String familyMemberId,
    required String role,
  }) async {
    return BaseApiHelper.instance.patch(
      EndPoints.updateFamilyMember(familyMemberId: familyMemberId),
      data: {'role': role},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> removeFamilyMember({
    required String familyMemberId,
  }) async {
    return BaseApiHelper.instance.delete(
      EndPoints.removeFamilyMember(familyMemberId: familyMemberId),
    );
  }
}
