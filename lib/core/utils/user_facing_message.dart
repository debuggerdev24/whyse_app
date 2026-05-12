/// Keeps API / proxy error payloads from blowing up UI (toasts, small labels).
const int kMaxUserFacingMessageLength = 220;

bool isUnsuitableUserFacingText(String s) {
  final t = s.trimLeft();
  if (t.length < 10) return false;
  final lower = t.toLowerCase();
  if (lower.startsWith('<!doctype') || lower.startsWith('<html')) return true;
  if (lower.contains('<head') && lower.contains('<body')) return true;
  if (lower.contains('ngrok') && lower.contains('<')) return true;
  return false;
}

/// Short, safe text for toasts and inline error labels.
String userFacingMessage(
  String? raw, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  var s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (isUnsuitableUserFacingText(s)) return fallback;
  if (s.length > kMaxUserFacingMessageLength) {
    return '${s.substring(0, kMaxUserFacingMessageLength)}…';
  }
  return s;
}

/// Long-form fields (e.g. group description). Returns `null` if unusable (HTML, etc.).
String? safeDescriptionForUi(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (isUnsuitableUserFacingText(t)) return null;
  const maxLen = 8000;
  if (t.length > maxLen) {
    return '${t.substring(0, maxLen)}…';
  }
  return t;
}
