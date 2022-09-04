import 'package:firebase_dart/database.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../resources/images.dart';

part 'tshirt.g.dart';

@JsonSerializable()
class Tshirt {
  Tshirt({
    String? name,
    required this.print,
  }) : name = name ?? '';

  @JsonKey(ignore: true)
  late final String id;

  final String name;

  @JsonKey(fromJson: imageFromJson, toJson: imageToJson)
  final ImageProvider print;

  static ImageProvider imageFromJson(String? url) {
    return url != null
        ? NetworkImage(url)
        : Images.tshirtFront as ImageProvider;
  }

  static String imageToJson(ImageProvider image) {
    return image is NetworkImage ? image.url : '';
  }

  factory Tshirt.fromFirebase(DataSnapshot snapshot) =>
      _$TshirtFromJson(snapshot.value)..id = snapshot.key!;
  Map<String, dynamic> toFirebase() => _$TshirtToJson(this);
}

enum TshirtSize {
  S,
  M,
  L,
}

enum TshirtSide {
  Front,
  Back,
}
