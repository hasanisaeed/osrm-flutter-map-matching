import 'dart:convert';

MapMatching mapMatchingFromJson(String str) =>
    MapMatching.fromJson(json.decode(str));

String mapMatchingToJson(MapMatching data) => json.encode(data.toJson());

class MapMatching {
  String code;
  List<Matching> matchings;
  List<Tracepoint> tracepoints;

  MapMatching({
    required this.code,
    required this.matchings,
    required this.tracepoints,
  });

  factory MapMatching.fromJson(Map<String, dynamic> json) => MapMatching(
        code: json["code"],
        matchings: List<Matching>.from(
            json["matchings"].map((x) => Matching.fromJson(x))),
        tracepoints: json["tracepoints"] != null
            ? List<Tracepoint>.from(json["tracepoints"]
                    .map((x) => x == null ? null : Tracepoint.fromJson(x)))
                .whereType<Tracepoint>()
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "matchings": List<dynamic>.from(matchings.map((x) => x.toJson())),
        "tracepoints": List<dynamic>.from(tracepoints.map((x) => x.toJson())),
      };
}

class Matching {
  double confidence;
  Geometry geometry;
  List<Leg> legs;
  double distance;
  double duration;
  String weightName;
  double weight;

  Matching({
    required this.confidence,
    required this.geometry,
    required this.legs,
    required this.distance,
    required this.duration,
    required this.weightName,
    required this.weight,
  });

  factory Matching.fromJson(Map<String, dynamic> json) => Matching(
        confidence: json["confidence"]?.toDouble(),
        geometry: Geometry.fromJson(json["geometry"]),
        legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
        distance: json["distance"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        weightName: json["weight_name"],
        weight: json["weight"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "confidence": confidence,
        "geometry": geometry.toJson(),
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "distance": distance,
        "duration": duration,
        "weight_name": weightName,
        "weight": weight,
      };
}

class Geometry {
  List<List<double>> coordinates;
  String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": List<dynamic>.from(
            coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "type": type,
      };
}

class Leg {
  List<dynamic> steps;
  double distance;
  double duration;
  String summary;
  double weight;

  Leg({
    required this.steps,
    required this.distance,
    required this.duration,
    required this.summary,
    required this.weight,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        steps: List<dynamic>.from(json["steps"].map((x) => x)),
        distance: json["distance"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        summary: json["summary"],
        weight: json["weight"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "steps": List<dynamic>.from(steps.map((x) => x)),
        "distance": distance,
        "duration": duration,
        "summary": summary,
        "weight": weight,
      };
}

class Tracepoint {
  int? alternativesCount;
  int? waypointIndex;
  int? matchingsIndex;
  List<double>? location;
  String? name;
  double? distance;
  String? hint;

  Tracepoint({
    this.alternativesCount,
    this.waypointIndex,
    this.matchingsIndex,
    this.location,
    this.name,
    this.distance,
    this.hint,
  });

  factory Tracepoint.fromJson(Map<String, dynamic> json) => Tracepoint(
        alternativesCount: json["alternatives_count"],
        waypointIndex: json["waypoint_index"],
        matchingsIndex: json["matchings_index"],
        location: json["location"] != null
            ? List<double>.from(
                json["location"].map((x) => x?.toDouble() ?? 0.0))
            : null,
        name: json["name"],
        distance: json["distance"]?.toDouble(),
        hint: json["hint"],
      );

  Map<String, dynamic> toJson() => {
        "alternatives_count": alternativesCount,
        "waypoint_index": waypointIndex,
        "matchings_index": matchingsIndex,
        "location": location != null
            ? List<dynamic>.from(location!.map((x) => x))
            : null,
        "name": name,
        "distance": distance,
        "hint": hint,
      };
}
