import 'package:firebase_dart/database.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mask.g.dart';

@JsonSerializable()
class Mask {
  Mask({
    String? name,
    String? svg,
  })  : name = name ?? '',
        svg = svg ?? '';

  @JsonKey(ignore: true)
  late final String id;
  final String name;
  final String svg;

  factory Mask.fromFirebase(DataSnapshot snapshot) =>
      _$MaskFromJson(snapshot.value)..id = snapshot.key!;
  Map<String, dynamic> toFirebase() => _$MaskToJson(this);
}

String generateMaskSVG(String path) {
  return path[0] == '<'
      ? path
      : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="$path" /></svg>';
}
