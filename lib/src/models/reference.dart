import 'package:firedart/firedart.dart';
import 'package:firedart/src/generated/google/firestore/v1/document.pb.dart'
    as fs;
import 'package:firedart/src/repository/firestore_gateway.dart';
import 'package:firedart/src/util/firestore_encoding.dart';
import 'package:meta/meta.dart';

/// A base class for firestore references, that provides getters for path and id.
abstract class Reference {
  @protected
  final FirestoreGateway gateway;
  final String path;

  /// Returns the ID of the reference.
  String get id => path.substring(path.lastIndexOf('/') + 1);

  /// Returns the ID of the fullPath of the reference.
  String get fullPath => '${gateway.database}/$path';

  Reference(this.gateway, String path)
      : path = _trimSlashes(path.startsWith(gateway.database)
            ? path.substring(gateway.database.length + 1)
            : path);

  /// Factory method which creates a [DocumentReference] or [CollectionReference]
  /// depending on the path.
  factory Reference.create(FirestoreGateway gateway, String path) {
    return _trimSlashes(path).split('/').length % 2 == 0
        ? DocumentReference(gateway, path)
        : CollectionReference(gateway, path);
  }

  @override
  bool operator ==(other) {
    return runtimeType == other.runtimeType && fullPath == other.fullPath;
  }

  @override
  String toString() {
    return '$runtimeType: $path';
  }

  /// Protected method which helps encode map data.
  @protected
  fs.Document encodeMap(Map<String, dynamic> map) {
    var document = fs.Document();
    map.forEach((key, value) {
      document.fields[key] = FirestoreEncoding.encode(value);
    });
    return document;
  }

  /// Static method which trims slashes for provided path.
  static String _trimSlashes(String path) {
    path = path.startsWith('/') ? path.substring(1) : path;
    return path.endsWith('/') ? path.substring(0, path.length - 2) : path;
  }
}