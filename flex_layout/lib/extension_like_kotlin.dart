///
/// for as
///
extension ToExt<T> on T {
  ///
  /// asのsafeなやつ
  ///
  R? to<R>() => this == null
      ? null
      : this! is R
          ? this! as R
          : null;
}

extension LetExt<T> on T {
  R let<R>(R Function(T it) block) => block(this);
}

extension AlsoExt<T> on T {
  T also(void Function(T it) func) {
    func(this);
    return this;
  }
}

extension ToMapExt<K> on Iterable<K> {
  Map<K, V> toMap<V>(V Function(K key) func) {
    final map = <K, V>{};
    for (var k in this) {
      map[k] = func(k);
    }

    return map;
  }
}

T? ifExt<T>(
  bool conditions, {
  T? Function()? then,
  T? Function()? elseThen,
}) {
  return conditions ? (then ?? () => null)() : (elseThen ?? () => null)();
}
