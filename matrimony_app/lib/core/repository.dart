// ignore_for_file: depend_on_referenced_packages

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../features/authentication/phone_auth/phone_auth_mixin.dart';
import '../features/groups_and_permissions/models/group_model.dart';
import '../features/groups_and_permissions/models/permission_model.dart';
import '../features/notification/models/notification_history_model.dart';
import '../features/notification/models/notification_model.dart';
import '../features/profile_screen/profile_details_model.dart';
import '../features/users/models/user_model.dart';
import '../services/shared_preferences_services.dart';
import 'api_constants.dart';
import 'app_config.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'pagination_response.dart';

final diologger = PrettyDioLogger(
  requestHeader: true,
  responseHeader: true,
  requestBody: true,
  enabled: kDebugMode,
);

class DataRepository {
  DataRepository._private();
  late final Dio _client;

  bool initialized = false;
  Future<void> initialize() async {
    if (initialized) return;
    final domainUrl = await SharedPreferencesService.i.domainUrl;
    _client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        baseUrl: domainUrl == ""
            ? appConfig.baseUrl
            : domainUrl + appConfig.slugUrl,
        contentType: "application/json",
      ),
    );
    var cookieJar = CookieJar(ignoreExpires: false);
    _client.interceptors.add(CookieManager(cookieJar));
    _client.interceptors.add(TokenAuthInterceptor());
    _client.interceptors.add(diologger);
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            await Future.delayed(const Duration(seconds: 1));
          }
          handler.next(options);
        },
      ),
    );
    initialized = true;
  }

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();

  void setBaseUrl(String text) {
    _client.options.baseUrl = text + appConfig.slugUrl;
  }

  Future<String> login({
    required String username,
    required String password,
    String? totp,
    bool donotAsk = false,
  }) async {
    Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "totp_token": totp,
    };

    if (donotAsk == true) {
      data.addAll({"do_not_ask": donotAsk});
    }
    var response = await _client.post(
      APIConstants.login,
      data: FormData.fromMap(data),
    );
    // response = await _client.post(
    //   APIConstants.login,
    //   data: FormData.fromMap(data),
    // );
    // final allowedCompanies = (response.data["companies"] as List)
    //     .map((e) => NameId.fromMap(e)!)
    //     .toList();
    // final defaultComapnyId = (response.data["company"] as List).first as int;
    // final defaultCompany = allowedCompanies.firstWhereOrNull(
    //   (element) => element.id == defaultComapnyId,
    // );
    // SharedPreferencesService.i.setValue(
    //   key: defaultCompanyKey,
    //   value: defaultCompany?.toJson() ?? "",
    // );
    return response.data["token"];
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String gender,
  }) async {
    final response = await _client.post(
      APIConstants.register,
      data: {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "phone_number": phoneNumber,
        "gender": gender,
      },
    );
    return {
      "token": response.data["token"],
      "user": ProfileDetailsModel.fromMap(response.data["user"]),
    };
  }

  Future<Response> updateDevice(BaseDeviceInfo deviceInfo) async {
    final response = await _client.put(
      APIConstants.updateDevice,
      data: deviceInfo.data,
    );
    return response;
  }

  Future<Response> updateProfileDetails(
    ProfileDetailsModel profileDetails,
  ) async {
    final formData = await profileDetails.toFormData;
    final response = await _client.put(
      APIConstants.updateprofile,
      data: formData,
    );
    return response;
  }

  Future<ProfileDetailsModel> fetchProfileDetails() async {
    final response = await _client.get(APIConstants.profileDetails);
    return ProfileDetailsModel.fromMap(response.data);
  }

  Future<PaginationResponse<ProfileDetailsModel>> fetchUserProfiles({
    required int page,
    int? pageSize,
    Map<String, dynamic>? filters,
  }) async {
    final Map<String, dynamic> queryParameters = {
      "page": page,
      "page_size": ?pageSize,
      if (filters != null) ...filters,
    };
    final response = await _client.get(
      APIConstants.profiles,
      queryParameters: queryParameters,
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => ProfileDetailsModel.fromMap(json),
    );
  }

  Future<PaginationResponse<ProfileDetailsModel>> fetchMyInterests({
    required int page,
    int? pageSize,
  }) async {
    final response = await _client.get(
      APIConstants.myInterests,
      queryParameters: {
        "page": page,
        "page_size": ?pageSize,
      },
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => ProfileDetailsModel.fromMap(json),
    );
  }

  Future<Map<String, dynamic>> toggleInterest(int profileId) async {
    final response = await _client.post(
      APIConstants.toggleInterest,
      data: {"profile_id": profileId},
    );
    return response.data;
  }

  // Future<Response> updateToken({required String token}) async {
  //   final response = await _client.post(
  //     APIConstants.fcmtoken,
  //     data: {"device_token": token},
  //   );
  //   return response;
  // }

  Future<DateTime> serverTime() async => DateTime.now();

  Future<PaginationResponse<NotificationModel>> fetchNotifications({
    required int pageNo,
  }) async {
    final response = await _client.get(APIConstants.notifications);
    return PaginationResponse.fromJson(
      response.data,
      (json) => NotificationModel.fromMap(json),
    );
  }

  Future<Response> logout() async {
    final response = await _client.post(APIConstants.logout);
    return response;
  }

  Future<dynamic> fetchTranslations() async {}

  Future<PaginationResponse<NotificationHistoryModel>>
  fetchNotificationHistory({int page = 1, int pageSize = 20}) async {
    final response = await _client.get(
      APIConstants.notificationHistory,
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => NotificationHistoryModel.fromMap(json),
    );
  }

  // Groups and Permissions
  Future<PaginationResponse<GroupModel>> fetchGroups({
    required int page,
    int? pageSize,
    String? search,
    String? ordering,
  }) async {
    final Map<String, dynamic> queryParameters = {
      "page": page,
      "page_size": ?pageSize,
      if (search != null && search.isNotEmpty) "search": search,
      if (ordering != null && ordering.isNotEmpty) "ordering": ordering,
    };
    final response = await _client.get(
      APIConstants.groups,
      queryParameters: queryParameters,
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => GroupModel.fromMap(json),
    );
  }

  Future<Response> createGroup(GroupModel group) async {
    final response = await _client.post(
      APIConstants.groups,
      data: group.toRequestMap(),
    );
    return response;
  }

  Future<Response> updateGroup(int id, GroupModel group) async {
    final response = await _client.put(
      "${APIConstants.groups}$id/",
      data: group.toRequestMap(),
    );
    return response;
  }

  Future<Response> deleteGroup(int id) async {
    final response = await _client.delete("${APIConstants.groups}$id/");
    return response;
  }

  Future<PaginationResponse<PermissionModel>> fetchPermissions({
    required int page,
    int? pageSize,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {
      "page": page,
      "page_size": ?pageSize,
      if (search != null && search.isNotEmpty) "search": search,
    };
    final response = await _client.get(
      APIConstants.permissions,
      queryParameters: queryParameters,
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => PermissionModel.fromMap(json),
    );
  }

  Future<List<PermissionModel>> fetchAllPermissions() async {
    // Helper to fetch all permissions (assuming not too many, handling pagination if needed but here just fetching page 1 large size or loop)
    // For now assuming we can fetch a large page or backend supports no pagination (usually not with CustomPagination).
    // Let's implement fetching with large page size
    return (await fetchPermissions(page: 1, pageSize: 1000)).results;
  }

  // Users
  Future<PaginationResponse<UserModel>> fetchUsers({
    required int page,
    int? pageSize,
    String? search,
    String? ordering,
  }) async {
    final Map<String, dynamic> queryParameters = {
      "page": page,
      "page_size": ?pageSize,
      if (search != null && search.isNotEmpty) "search": search,
      if (ordering != null && ordering.isNotEmpty) "ordering": ordering,
    };
    final response = await _client.get(
      APIConstants.users,
      queryParameters: queryParameters,
    );
    return PaginationResponse.fromJson(
      response.data,
      (json) => UserModel.fromMap(json),
    );
  }

  Future<Response> createUser(UserModel user) async {
    final response = await _client.post(
      APIConstants.users,
      data: user.toRequestMap(),
    );
    return response;
  }

  Future<Response> updateUser(int id, UserModel user) async {
    final response = await _client.put(
      "${APIConstants.users}$id/",
      data: user.toRequestMap(),
    );
    return response;
  }

  Future<Response> deleteUser(int id) async {
    final response = await _client.delete("${APIConstants.users}$id/");
    return response;
  }
}
