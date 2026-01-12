library;

import 'dart:async';

/// Base node class.
abstract class Node {}

/// Visitor interface.
abstract class Visitor<N> {
  /// Visit a node.
  N visit(N node);
}

/// Async visitor interface.
abstract class VisitorAsync<N> {
  /// Visit a node asynchronously.
  Future<N> visit(N node);
}
