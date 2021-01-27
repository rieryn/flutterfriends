import 'package:aqueduct/aqueduct.dart';

import '../models/image.dart';

class ImageController extends ResourceController {
  ImageController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getImages() async {
    final query = Query<Image>(context)
      ..sortBy(
        (g) => g.id,
        QuerySortOrder.ascending,
      );
    return Response.ok(await query.fetch());
  }

  @Operation.get('id')
  Future<Response> getImage(@Bind.path('id') int id) async {
    final query = Query<Image>(context)..where((g) => g.id).equalTo(id);
    return Response.ok(await query.fetchOne());
  }

  @Operation.post()
  Future<Response> createImage(@Bind.body() Image payload) async {
    final query = Query<Image>(context)..values = payload;
    return Response.ok(await query.insert());
  }

  @Operation.put('id')
  Future<Response> updateImage(
    @Bind.path('id') int id,
    @Bind.body(ignore: ['id']) Image payload,
  ) async {
    final query = Query<Image>(context)
      ..where((g) => g.id).equalTo(id)
      ..values = payload;
    return Response.ok(await query.updateOne());
  }

  @Operation.delete('id')
  Future<Response> deleteImage(@Bind.path('id') int id) async {
    final query = Query<Image>(context)..where((g) => g.id).equalTo(id);
    return Response.ok(await query.delete());
  }
}
