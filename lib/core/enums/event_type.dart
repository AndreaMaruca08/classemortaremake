enum EventType {
  ABSENCE,
  DELAY, // Entrance permission
  EARLY_EXIT, // Exit permission
  UNKNOWN,
}

EventType eventTypeFromString(String eventString) {
  final eventLower = eventString.toLowerCase();
  if (eventLower.contains("assenza") || eventLower.contains("absence")) {
    return EventType.ABSENCE;
  } else if (eventLower.contains("permesso di entrare") || eventLower.contains("permission to enter")) {
    return EventType.DELAY;
  } else if (eventLower.contains("permesso di uscire") || eventLower.contains("permission to exit")) {
    return EventType.EARLY_EXIT;
  }
  return EventType.UNKNOWN;
}
