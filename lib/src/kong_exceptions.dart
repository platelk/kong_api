part of kong;

/// [KongException] is the base class for all the KongException use
class KongException implements Exception {
  final String message;
  final String data;
  const KongException([this.message = "", this.data]);

  String toString() => '[KongException] ${message}\n${data}';
}

/// [KongConflictException] raise when Kong return a [HttpStatus.CONFLICT] status
class ConflictException extends KongException {
  const ConflictException(message, data) : super(message, data);
}
