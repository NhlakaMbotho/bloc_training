/* {
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005
    }
  ]
}
*/
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  const Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  final int id;
  final String name;
  final double latitude;
  final double longitude;
}
