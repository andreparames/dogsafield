import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/models/event.dart';
import 'package:dogsafield/i18n/strings.g.dart';

BitmapDescriptor markerIconForType(EventType type, {bool isRsvpd = false}) {
  if (isRsvpd) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
  }
  switch (type) {
    case EventType.packWalk:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    case EventType.dogPicnic:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    case EventType.fieldGames:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  }
}

String eventTypeLabel(EventType type) {
  return switch (type) {
    EventType.packWalk => t.event.type.packWalk,
    EventType.dogPicnic => t.event.type.dogPicnic,
    EventType.fieldGames => t.event.type.fieldGames,
  };
}

IconData eventTypeIcon(EventType type) {
  switch (type) {
    case EventType.packWalk:
      return Icons.directions_walk;
    case EventType.dogPicnic:
      return Icons.weekend;
    case EventType.fieldGames:
      return Icons.sports;
  }
}
