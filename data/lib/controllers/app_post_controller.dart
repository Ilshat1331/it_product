import 'dart:io';

import 'package:data/utils/app_response.dart';
import 'package:data/models/post.dart';
import 'package:data/models/author.dart';

import 'package:conduit/conduit.dart';
import 'package:data/utils/app_utils.dart';

class AppPostController extends ResourceController {
  final ManagedContext managedContext;

  AppPostController(this.managedContext);

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetPosts = Query<Post>(managedContext)
        ..where((post) => post.author?.id).equalTo(id);
      final List<Post> posts = await qGetPosts.fetch();
      if (posts.isEmpty) return Response.notFound();
      return Response.ok(posts);
    } catch (error) {
      return AppResponse.serverError(error, message: "Posts getting error.");
    }
  }

  @Operation.post()
  Future<Response> createPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Post post) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<Author>(id);
      if (author == null) {
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      final qCreatePost = Query<Post>(managedContext)
        ..values.author?.id = id
        ..values.content = post.content;
      await qCreatePost.insert();
      return AppResponse.ok(message: "Successful create post");
    } catch (error) {
      return AppResponse.serverError(error, message: "Post getting error.");
    }
  }

  @Operation.get("id")
  Future<Response> getPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Post not found");
      }

      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Access is denied.");
      }

      post.backing.removeProperty("author");

      return AppResponse.ok(
        body: post.backing.contents,
        message: "Successful getting post.",
      );
    } catch (error) {
      return AppResponse.serverError(error, message: "Post getting error.");
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Post not found");
      }

      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Access is denied.");
      }

      final qDeletePost = Query<Post>(managedContext)
        ..where((post) => post.id).equalTo(id);
      await qDeletePost.delete();

      return AppResponse.ok(message: "Successful delete post.");
    } catch (error) {
      return AppResponse.serverError(error, message: "Post deletion error.");
    }
  }
}
