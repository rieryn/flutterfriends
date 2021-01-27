import 'package:aqueduct/aqueduct.dart';

class Image extends ManagedObject<_Image> implements _Image {}

class _Image {
  @primaryKey
  int id;

  String title;
  DateTime created;

  @Column(nullable: true)
  String desc;

  @Column(nullable: true)
  String thumbnail;
}
