// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proxy_assignment_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProxyAssignmentRequest _$ProxyAssignmentRequestFromJson(
    Map<String, dynamic> json) {
  return _ProxyAssignmentRequest.fromJson(json);
}

/// @nodoc
mixin _$ProxyAssignmentRequest {
  String get jobId => throw _privateConstructorUsedError;
  String get botId => throw _privateConstructorUsedError;
  bool get allowConcurrent => throw _privateConstructorUsedError;
  int get maxUses => throw _privateConstructorUsedError;
  bool get neverBan => throw _privateConstructorUsedError;
  List<ProxyType>? get preferredTypes => throw _privateConstructorUsedError;

  /// Serializes this ProxyAssignmentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyAssignmentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyAssignmentRequestCopyWith<ProxyAssignmentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyAssignmentRequestCopyWith<$Res> {
  factory $ProxyAssignmentRequestCopyWith(ProxyAssignmentRequest value,
          $Res Function(ProxyAssignmentRequest) then) =
      _$ProxyAssignmentRequestCopyWithImpl<$Res, ProxyAssignmentRequest>;
  @useResult
  $Res call(
      {String jobId,
      String botId,
      bool allowConcurrent,
      int maxUses,
      bool neverBan,
      List<ProxyType>? preferredTypes});
}

/// @nodoc
class _$ProxyAssignmentRequestCopyWithImpl<$Res,
        $Val extends ProxyAssignmentRequest>
    implements $ProxyAssignmentRequestCopyWith<$Res> {
  _$ProxyAssignmentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyAssignmentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? botId = null,
    Object? allowConcurrent = null,
    Object? maxUses = null,
    Object? neverBan = null,
    Object? preferredTypes = freezed,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      botId: null == botId
          ? _value.botId
          : botId // ignore: cast_nullable_to_non_nullable
              as String,
      allowConcurrent: null == allowConcurrent
          ? _value.allowConcurrent
          : allowConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      maxUses: null == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int,
      neverBan: null == neverBan
          ? _value.neverBan
          : neverBan // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredTypes: freezed == preferredTypes
          ? _value.preferredTypes
          : preferredTypes // ignore: cast_nullable_to_non_nullable
              as List<ProxyType>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyAssignmentRequestImplCopyWith<$Res>
    implements $ProxyAssignmentRequestCopyWith<$Res> {
  factory _$$ProxyAssignmentRequestImplCopyWith(
          _$ProxyAssignmentRequestImpl value,
          $Res Function(_$ProxyAssignmentRequestImpl) then) =
      __$$ProxyAssignmentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String jobId,
      String botId,
      bool allowConcurrent,
      int maxUses,
      bool neverBan,
      List<ProxyType>? preferredTypes});
}

/// @nodoc
class __$$ProxyAssignmentRequestImplCopyWithImpl<$Res>
    extends _$ProxyAssignmentRequestCopyWithImpl<$Res,
        _$ProxyAssignmentRequestImpl>
    implements _$$ProxyAssignmentRequestImplCopyWith<$Res> {
  __$$ProxyAssignmentRequestImplCopyWithImpl(
      _$ProxyAssignmentRequestImpl _value,
      $Res Function(_$ProxyAssignmentRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyAssignmentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? botId = null,
    Object? allowConcurrent = null,
    Object? maxUses = null,
    Object? neverBan = null,
    Object? preferredTypes = freezed,
  }) {
    return _then(_$ProxyAssignmentRequestImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      botId: null == botId
          ? _value.botId
          : botId // ignore: cast_nullable_to_non_nullable
              as String,
      allowConcurrent: null == allowConcurrent
          ? _value.allowConcurrent
          : allowConcurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      maxUses: null == maxUses
          ? _value.maxUses
          : maxUses // ignore: cast_nullable_to_non_nullable
              as int,
      neverBan: null == neverBan
          ? _value.neverBan
          : neverBan // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredTypes: freezed == preferredTypes
          ? _value._preferredTypes
          : preferredTypes // ignore: cast_nullable_to_non_nullable
              as List<ProxyType>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyAssignmentRequestImpl implements _ProxyAssignmentRequest {
  const _$ProxyAssignmentRequestImpl(
      {required this.jobId,
      required this.botId,
      required this.allowConcurrent,
      required this.maxUses,
      required this.neverBan,
      final List<ProxyType>? preferredTypes})
      : _preferredTypes = preferredTypes;

  factory _$ProxyAssignmentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyAssignmentRequestImplFromJson(json);

  @override
  final String jobId;
  @override
  final String botId;
  @override
  final bool allowConcurrent;
  @override
  final int maxUses;
  @override
  final bool neverBan;
  final List<ProxyType>? _preferredTypes;
  @override
  List<ProxyType>? get preferredTypes {
    final value = _preferredTypes;
    if (value == null) return null;
    if (_preferredTypes is EqualUnmodifiableListView) return _preferredTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ProxyAssignmentRequest(jobId: $jobId, botId: $botId, allowConcurrent: $allowConcurrent, maxUses: $maxUses, neverBan: $neverBan, preferredTypes: $preferredTypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyAssignmentRequestImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.botId, botId) || other.botId == botId) &&
            (identical(other.allowConcurrent, allowConcurrent) ||
                other.allowConcurrent == allowConcurrent) &&
            (identical(other.maxUses, maxUses) || other.maxUses == maxUses) &&
            (identical(other.neverBan, neverBan) ||
                other.neverBan == neverBan) &&
            const DeepCollectionEquality()
                .equals(other._preferredTypes, _preferredTypes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jobId, botId, allowConcurrent,
      maxUses, neverBan, const DeepCollectionEquality().hash(_preferredTypes));

  /// Create a copy of ProxyAssignmentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyAssignmentRequestImplCopyWith<_$ProxyAssignmentRequestImpl>
      get copyWith => __$$ProxyAssignmentRequestImplCopyWithImpl<
          _$ProxyAssignmentRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyAssignmentRequestImplToJson(
      this,
    );
  }
}

abstract class _ProxyAssignmentRequest implements ProxyAssignmentRequest {
  const factory _ProxyAssignmentRequest(
      {required final String jobId,
      required final String botId,
      required final bool allowConcurrent,
      required final int maxUses,
      required final bool neverBan,
      final List<ProxyType>? preferredTypes}) = _$ProxyAssignmentRequestImpl;

  factory _ProxyAssignmentRequest.fromJson(Map<String, dynamic> json) =
      _$ProxyAssignmentRequestImpl.fromJson;

  @override
  String get jobId;
  @override
  String get botId;
  @override
  bool get allowConcurrent;
  @override
  int get maxUses;
  @override
  bool get neverBan;
  @override
  List<ProxyType>? get preferredTypes;

  /// Create a copy of ProxyAssignmentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyAssignmentRequestImplCopyWith<_$ProxyAssignmentRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProxyAssignmentResponse _$ProxyAssignmentResponseFromJson(
    Map<String, dynamic> json) {
  return _ProxyAssignmentResponse.fromJson(json);
}

/// @nodoc
mixin _$ProxyAssignmentResponse {
  bool get success => throw _privateConstructorUsedError;
  EnhancedProxyModel? get proxy => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  ProxyAssignmentFailureReason? get failureReason =>
      throw _privateConstructorUsedError;

  /// Serializes this ProxyAssignmentResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyAssignmentResponseCopyWith<ProxyAssignmentResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyAssignmentResponseCopyWith<$Res> {
  factory $ProxyAssignmentResponseCopyWith(ProxyAssignmentResponse value,
          $Res Function(ProxyAssignmentResponse) then) =
      _$ProxyAssignmentResponseCopyWithImpl<$Res, ProxyAssignmentResponse>;
  @useResult
  $Res call(
      {bool success,
      EnhancedProxyModel? proxy,
      String? error,
      ProxyAssignmentFailureReason? failureReason});

  $EnhancedProxyModelCopyWith<$Res>? get proxy;
}

/// @nodoc
class _$ProxyAssignmentResponseCopyWithImpl<$Res,
        $Val extends ProxyAssignmentResponse>
    implements $ProxyAssignmentResponseCopyWith<$Res> {
  _$ProxyAssignmentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? proxy = freezed,
    Object? error = freezed,
    Object? failureReason = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as EnhancedProxyModel?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as ProxyAssignmentFailureReason?,
    ) as $Val);
  }

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EnhancedProxyModelCopyWith<$Res>? get proxy {
    if (_value.proxy == null) {
      return null;
    }

    return $EnhancedProxyModelCopyWith<$Res>(_value.proxy!, (value) {
      return _then(_value.copyWith(proxy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProxyAssignmentResponseImplCopyWith<$Res>
    implements $ProxyAssignmentResponseCopyWith<$Res> {
  factory _$$ProxyAssignmentResponseImplCopyWith(
          _$ProxyAssignmentResponseImpl value,
          $Res Function(_$ProxyAssignmentResponseImpl) then) =
      __$$ProxyAssignmentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success,
      EnhancedProxyModel? proxy,
      String? error,
      ProxyAssignmentFailureReason? failureReason});

  @override
  $EnhancedProxyModelCopyWith<$Res>? get proxy;
}

/// @nodoc
class __$$ProxyAssignmentResponseImplCopyWithImpl<$Res>
    extends _$ProxyAssignmentResponseCopyWithImpl<$Res,
        _$ProxyAssignmentResponseImpl>
    implements _$$ProxyAssignmentResponseImplCopyWith<$Res> {
  __$$ProxyAssignmentResponseImplCopyWithImpl(
      _$ProxyAssignmentResponseImpl _value,
      $Res Function(_$ProxyAssignmentResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? proxy = freezed,
    Object? error = freezed,
    Object? failureReason = freezed,
  }) {
    return _then(_$ProxyAssignmentResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as EnhancedProxyModel?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as ProxyAssignmentFailureReason?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyAssignmentResponseImpl implements _ProxyAssignmentResponse {
  const _$ProxyAssignmentResponseImpl(
      {required this.success, this.proxy, this.error, this.failureReason});

  factory _$ProxyAssignmentResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyAssignmentResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final EnhancedProxyModel? proxy;
  @override
  final String? error;
  @override
  final ProxyAssignmentFailureReason? failureReason;

  @override
  String toString() {
    return 'ProxyAssignmentResponse(success: $success, proxy: $proxy, error: $error, failureReason: $failureReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyAssignmentResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.proxy, proxy) || other.proxy == proxy) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, proxy, error, failureReason);

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyAssignmentResponseImplCopyWith<_$ProxyAssignmentResponseImpl>
      get copyWith => __$$ProxyAssignmentResponseImplCopyWithImpl<
          _$ProxyAssignmentResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyAssignmentResponseImplToJson(
      this,
    );
  }
}

abstract class _ProxyAssignmentResponse implements ProxyAssignmentResponse {
  const factory _ProxyAssignmentResponse(
          {required final bool success,
          final EnhancedProxyModel? proxy,
          final String? error,
          final ProxyAssignmentFailureReason? failureReason}) =
      _$ProxyAssignmentResponseImpl;

  factory _ProxyAssignmentResponse.fromJson(Map<String, dynamic> json) =
      _$ProxyAssignmentResponseImpl.fromJson;

  @override
  bool get success;
  @override
  EnhancedProxyModel? get proxy;
  @override
  String? get error;
  @override
  ProxyAssignmentFailureReason? get failureReason;

  /// Create a copy of ProxyAssignmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyAssignmentResponseImplCopyWith<_$ProxyAssignmentResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
