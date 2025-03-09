import 'package:doko_react/core/global/entity/page-info/nodes.dart';

/// nodes wrapper for archive entity
class ArchiveEntity extends Nodes {
  /// latest messages at start
  ArchiveEntity({
    required super.pageInfo,
    required super.items,
  });

  ArchiveEntity.empty() : super.empty();
}
