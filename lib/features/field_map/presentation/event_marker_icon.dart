import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/models/event.dart';

BitmapDescriptor markerIconForType(EventType type) {
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
  switch (type) {
    case EventType.packWalk:
      return 'Pack Walk';
    case EventType.dogPicnic:
      return 'Dog Picnic';
    case EventType.fieldGames:
      return 'Field Games';
  }
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
