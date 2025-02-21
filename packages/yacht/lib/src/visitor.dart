library;

import 'dart:async';

abstract class Node {}

abstract class Visitor<N> {
  // can return a [Future<Node>] or [Node] or null
  N visit(N node);
}

abstract class VisitorAsync<N> {
  // can return a [Future<Node>] or [Node] or null
  Future<N> visit(N node);
}
