// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proxy_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProxyModel _$ProxyModelFromJson(Map<String, dynamic> json) {
  return _ProxyModel.fromJson(json);
}

/// @nodoc
mixin _$ProxyModel {
  String get id => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  ProxyType get type => throw _privateConstructorUsedError;
  ProxyStatus get status => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  DateTime? get lastChecked => throw _privateConstructorUsedError;
  DateTime? get lastUsed => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  int get responseTime => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this ProxyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyModelCopyWith<ProxyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyModelCopyWith<$Res> {
  factory $ProxyModelCopyWith(
          ProxyModel value, $Res Function(ProxyModel) then) =
      _$ProxyModelCopyWithImpl<$Res, ProxyModel>;
  @useResult
  $Res call(
      {String id,
      String address,
      int port,
      ProxyType type,
      ProxyStatus status,
      String? username,
      String? password,
      DateTime? lastChecked,
      DateTime? lastUsed,
      int successCount,
      int failureCount,
      int responseTime,
      String? country,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ProxyModelCopyWithImpl<$Res, $Val extends ProxyModel>
    implements $ProxyModelCopyWith<$Res> {
  _$ProxyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? address = null,
    Object? port = null,
    Object? type = null,
    Object? status = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? lastChecked = freezed,
    Object? lastUsed = freezed,
    Object? successCount = null,
    Object? failureCount = null,
    Object? responseTime = null,
    Object? country = freezed,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ProxyStatus,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      lastChecked: freezed == lastChecked
          ? _value.lastChecked
          : lastChecked // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      successCount: null == successCount
          ? _value.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _value.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as int,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyModelImplCopyWith<$Res>
    implements $ProxyModelCopyWith<$Res> {
  factory _$$ProxyModelImplCopyWith(
          _$ProxyModelImpl value, $Res Function(_$ProxyModelImpl) then) =
      __$$ProxyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String address,
      int port,
      ProxyType type,
      ProxyStatus status,
      String? username,
      String? password,
      DateTime? lastChecked,
      DateTime? lastUsed,
      int successCount,
      int failureCount,
      int responseTime,
      String? country,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ProxyModelImplCopyWithImpl<$Res>
    extends _$ProxyModelCopyWithImpl<$Res, _$ProxyModelImpl>
    implements _$$ProxyModelImplCopyWith<$Res> {
  __$$ProxyModelImplCopyWithImpl(
      _$ProxyModelImpl _value, $Res Function(_$ProxyModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? address = null,
    Object? port = null,
    Object? type = null,
    Object? status = null,
    Object? username = freezed,
    Object? password = freezed,
    Object? lastChecked = freezed,
    Object? lastUsed = freezed,
    Object? successCount = null,
    Object? failureCount = null,
    Object? responseTime = null,
    Object? country = freezed,
    Object? metadata = null,
  }) {
    return _then(_$ProxyModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProxyType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ProxyStatus,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      password: freezed == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      lastChecked: freezed == lastChecked
          ? _value.lastChecked
          : lastChecked // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      successCount: null == successCount
          ? _value.successCount
          : successCount // ignore: cast_nullable_to_non_nullable
              as int,
      failureCount: null == failureCount
          ? _value.failureCount
          : failureCount // ignore: cast_nullable_to_non_nullable
              as int,
      responseTime: null == responseTime
          ? _value.responseTime
          : responseTime // ignore: cast_nullable_to_non_nullable
              as int,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyModelImpl implements _ProxyModel {
  const _$ProxyModelImpl(
      {required this.id,
      required this.address,
      required this.port,
      required this.type,
      required this.status,
      this.username,
      this.password,
      this.lastChecked,
      this.lastUsed,
      this.successCount = 0,
      this.failureCount = 0,
      this.responseTime = 0,
      this.country,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$ProxyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String address;
  @override
  final int port;
  @override
  final ProxyType type;
  @override
  final ProxyStatus status;
  @override
  final String? username;
  @override
  final String? password;
  @override
  final DateTime? lastChecked;
  @override
  final DateTime? lastUsed;
  @override
  @JsonKey()
  final int successCount;
  @override
  @JsonKey()
  final int failureCount;
  @override
  @JsonKey()
  final int responseTime;
  @override
  final String? country;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'ProxyModel(id: $id, address: $address, port: $port, type: $type, status: $status, username: $username, password: $password, lastChecked: $lastChecked, lastUsed: $lastUsed, successCount: $successCount, failureCount: $failureCount, responseTime: $responseTime, country: $country, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.lastChecked, lastChecked) ||
                other.lastChecked == lastChecked) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            (identical(other.responseTime, responseTime) ||
                other.responseTime == responseTime) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      address,
      port,
      type,
      status,
      username,
      password,
      lastChecked,
      lastUsed,
      successCount,
      failureCount,
      responseTime,
      country,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ProxyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyModelImplCopyWith<_$ProxyModelImpl> get copyWith =>
      __$$ProxyModelImplCopyWithImpl<_$ProxyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyModelImplToJson(
      this,
    );
  }
}

abstract class _ProxyModel implements ProxyModel {
  const factory _ProxyModel(
      {required final String id,
      required final String address,
      required final int port,
      required final ProxyType type,
      required final ProxyStatus status,
      final String? username,
      final String? password,
      final DateTime? lastChecked,
      final DateTime? lastUsed,
      final int successCount,
      final int failureCount,
      final int responseTime,
      final String? country,
      final Map<String, dynamic> metadata}) = _$ProxyModelImpl;

  factory _ProxyModel.fromJson(Map<String, dynamic> json) =
      _$ProxyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get address;
  @override
  int get port;
  @override
  ProxyType get type;
  @override
  ProxyStatus get status;
  @override
  String? get username;
  @override
  String? get password;
  @override
  DateTime? get lastChecked;
  @override
  DateTime? get lastUsed;
  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  int get responseTime;
  @override
  String? get country;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of ProxyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyModelImplCopyWith<_$ProxyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
