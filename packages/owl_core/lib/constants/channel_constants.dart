// language: Dart, file: lib/core/constants/channel_constants.dart, target: Flutter / Owl MOBA HUD

/// Platform Channel string identifiers for Flutter-to-Native IPC in Owl.
class ChannelConstants {
  ChannelConstants._();

  // Channel Identifiers
  /// MethodChannel identifier for managing overlay HUD lifecycle and positioning.
  static const String overlayChannel = 'owl/overlay_channel';

  /// EventChannel identifier for receiving real-time HUD events (drag, tap, state) from native overlay.
  static const String overlayEvents = 'owl/overlay_events';

  /// MethodChannel / EventChannel identifier for Android MediaProjection screen capture.
  static const String screenProjection = 'owl/screen_projection';

  // Overlay Method Names (for owl/overlay_channel)
  static const String methodShowOverlay = 'showOverlay';
  static const String methodHideOverlay = 'hideOverlay';
  static const String methodUpdateOverlay = 'updateOverlay';
  static const String methodSetOverlayPosition = 'setOverlayPosition';
  static const String methodSetOverlayOpacity = 'setOverlayOpacity';
  static const String methodCheckOverlayPermission = 'checkOverlayPermission';
  static const String methodRequestOverlayPermission = 'requestOverlayPermission';

  // Screen Projection Method Names (for owl/screen_projection)
  static const String methodStartScreenCapture = 'startScreenCapture';
  static const String methodStopScreenCapture = 'stopScreenCapture';
  static const String methodCaptureFrame = 'captureFrame';
  static const String methodCheckProjectionPermission = 'checkProjectionPermission';
  static const String methodRequestProjectionPermission = 'requestProjectionPermission';

  // Overlay Event Types (for owl/overlay_events)
  static const String eventOverlayClicked = 'overlay_clicked';
  static const String eventOverlayDragged = 'overlay_dragged';
  static const String eventOverlayExpanded = 'overlay_expanded';
  static const String eventOverlayCollapsed = 'overlay_collapsed';
  static const String eventOverlayClosed = 'overlay_closed';
}
