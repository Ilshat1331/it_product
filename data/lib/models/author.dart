import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/post.dart';

class Author extends ManagedObject<_Author> implements _Author {}

class _Author {
  @primaryKey
  int? id;
  ManagedSet<Post>? postList;
}
