// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proxy_pool_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProxyPoolStats _$ProxyPoolStatsFromJson(Map<String, dynamic> json) {
  return _ProxyPoolStats.fromJson(json);
}

/// @nodoc
mixin _$ProxyPoolStats {
  int get total => throw _privateConstructorUsedError;
  int get available => throw _privateConstructorUsedError;
  int get busy => throw _privateConstructorUsedError;
  int get banned => throw _privateConstructorUsedError;
  int get bad => throw _privateConstructorUsedError;
  int get untested => throw _privateConstructorUsedError;
  int get alive => throw _privateConstructorUsedError; // available + busy
  Map<ProxyType, int>? get byType => throw _privateConstructorUsedError;
  Map<String, int>? get byCountry => throw _privateConstructorUsedError;

  /// Serializes this ProxyPoolStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyPoolStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyPoolStatsCopyWith<ProxyPoolStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyPoolStatsCopyWith<$Res> {
  factory $ProxyPoolStatsCopyWith(
          ProxyPoolStats value, $Res Function(ProxyPoolStats) then) =
      _$ProxyPoolStatsCopyWithImpl<$Res, ProxyPoolStats>;
  @useResult
  $Res call(
      {int total,
      int available,
      int busy,
      int banned,
      int bad,
      int untested,
      int alive,
      Map<ProxyType, int>? byType,
      Map<String, int>? byCountry});
}

/// @nodoc
class _$ProxyPoolStatsCopyWithImpl<$Res, $Val extends ProxyPoolStats>
    implements $ProxyPoolStatsCopyWith<$Res> {
  _$ProxyPoolStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyPoolStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? available = null,
    Object? busy = null,
    Object? banned = null,
    Object? bad = null,
    Object? untested = null,
    Object? alive = null,
    Object? byType = freezed,
    Object? byCountry = freezed,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      busy: null == busy
          ? _value.busy
          : busy // ignore: cast_nullable_to_non_nullable
              as int,
      banned: null == banned
          ? _value.banned
          : banned // ignore: cast_nullable_to_non_nullable
              as int,
      bad: null == bad
          ? _value.bad
          : bad // ignore: cast_nullable_to_non_nullable
              as int,
      untested: null == untested
          ? _value.untested
          : untested // ignore: cast_nullable_to_non_nullable
              as int,
      alive: null == alive
          ? _value.alive
          : alive // ignore: cast_nullable_to_non_nullable
              as int,
      byType: freezed == byType
          ? _value.byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<ProxyType, int>?,
      byCountry: freezed == byCountry
          ? _value.byCountry
          : byCountry // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyPoolStatsImplCopyWith<$Res>
    implements $ProxyPoolStatsCopyWith<$Res> {
  factory _$$ProxyPoolStatsImplCopyWith(_$ProxyPoolStatsImpl value,
          $Res Function(_$ProxyPoolStatsImpl) then) =
      __$$ProxyPoolStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      int available,
      int busy,
      int banned,
      int bad,
      int untested,
      int alive,
      Map<ProxyType, int>? byType,
      Map<String, int>? byCountry});
}

/// @nodoc
class __$$ProxyPoolStatsImplCopyWithImpl<$Res>
    extends _$ProxyPoolStatsCopyWithImpl<$Res, _$ProxyPoolStatsImpl>
    implements _$$ProxyPoolStatsImplCopyWith<$Res> {
  __$$ProxyPoolStatsImplCopyWithImpl(
      _$ProxyPoolStatsImpl _value, $Res Function(_$ProxyPoolStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyPoolStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? available = null,
    Object? busy = null,
    Object? banned = null,
    Object? bad = null,
    Object? untested = null,
    Object? alive = null,
    Object? byType = freezed,
    Object? byCountry = freezed,
  }) {
    return _then(_$ProxyPoolStatsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      busy: null == busy
          ? _value.busy
          : busy // ignore: cast_nullable_to_non_nullable
              as int,
      banned: null == banned
          ? _value.banned
          : banned // ignore: cast_nullable_to_non_nullable
              as int,
      bad: null == bad
          ? _value.bad
          : bad // ignore: cast_nullable_to_non_nullable
              as int,
      untested: null == untested
          ? _value.untested
          : untested // ignore: cast_nullable_to_non_nullable
              as int,
      alive: null == alive
          ? _value.alive
          : alive // ignore: cast_nullable_to_non_nullable
              as int,
      byType: freezed == byType
          ? _value._byType
          : byType // ignore: cast_nullable_to_non_nullable
              as Map<ProxyType, int>?,
      byCountry: freezed == byCountry
          ? _value._byCountry
          : byCountry // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyPoolStatsImpl implements _ProxyPoolStats {
  const _$ProxyPoolStatsImpl(
      {this.total = 0,
      this.available = 0,
      this.busy = 0,
      this.banned = 0,
      this.bad = 0,
      this.untested = 0,
      this.alive = 0,
      final Map<ProxyType, int>? byType,
      final Map<String, int>? byCountry})
      : _byType = byType,
        _byCountry = byCountry;

  factory _$ProxyPoolStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyPoolStatsImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int available;
  @override
  @JsonKey()
  final int busy;
  @override
  @JsonKey()
  final int banned;
  @override
  @JsonKey()
  final int bad;
  @override
  @JsonKey()
  final int untested;
  @override
  @JsonKey()
  final int alive;
// available + busy
  final Map<ProxyType, int>? _byType;
// available + busy
  @override
  Map<ProxyType, int>? get byType {
    final value = _byType;
    if (value == null) return null;
    if (_byType is EqualUnmodifiableMapView) return _byType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, int>? _byCountry;
  @override
  Map<String, int>? get byCountry {
    final value = _byCountry;
    if (value == null) return null;
    if (_byCountry is EqualUnmodifiableMapView) return _byCountry;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ProxyPoolStats(total: $total, available: $available, busy: $busy, banned: $banned, bad: $bad, untested: $untested, alive: $alive, byType: $byType, byCountry: $byCountry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyPoolStatsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.banned, banned) || other.banned == banned) &&
            (identical(other.bad, bad) || other.bad == bad) &&
            (identical(other.untested, untested) ||
                other.untested == untested) &&
            (identical(other.alive, alive) || other.alive == alive) &&
            const DeepCollectionEquality().equals(other._byType, _byType) &&
            const DeepCollectionEquality()
                .equals(other._byCountry, _byCountry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total,
      available,
      busy,
      banned,
      bad,
      untested,
      alive,
      const DeepCollectionEquality().hash(_byType),
      const DeepCollectionEquality().hash(_byCountry));

  /// Create a copy of ProxyPoolStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyPoolStatsImplCopyWith<_$ProxyPoolStatsImpl> get copyWith =>
      __$$ProxyPoolStatsImplCopyWithImpl<_$ProxyPoolStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyPoolStatsImplToJson(
      this,
    );
  }
}

abstract class _ProxyPoolStats implements ProxyPoolStats {
  const factory _ProxyPoolStats(
      {final int total,
      final int available,
      final int busy,
      final int banned,
      final int bad,
      final int untested,
      final int alive,
      final Map<ProxyType, int>? byType,
      final Map<String, int>? byCountry}) = _$ProxyPoolStatsImpl;

  factory _ProxyPoolStats.fromJson(Map<String, dynamic> json) =
      _$ProxyPoolStatsImpl.fromJson;

  @override
  int get total;
  @override
  int get available;
  @override
  int get busy;
  @override
  int get banned;
  @override
  int get bad;
  @override
  int get untested;
  @override
  int get alive; // available + busy
  @override
  Map<ProxyType, int>? get byType;
  @override
  Map<String, int>? get byCountry;

  /// Create a copy of ProxyPoolStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyPoolStatsImplCopyWith<_$ProxyPoolStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
