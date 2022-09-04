// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tshirt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tshirt _$TshirtFromJson(Map<String, dynamic> json) => Tshirt(
      name: json['name'] as String?,
      print: Tshirt.imageFromJson(json['print'] as String?),
    );

Map<String, dynamic> _$TshirtToJson(Tshirt instance) => <String, dynamic>{
      'name': instance.name,
      'print': Tshirt.imageToJson(instance.print),
    };
