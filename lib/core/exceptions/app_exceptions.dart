/// 앱 전체 예외 처리 클래스들 (엔터프라이즈급)
library;

/// 기본 앱 예외 클래스
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final Object? details;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// 네트워크 관련 예외
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});

  factory NetworkException.connectionTimeout() =>
      const NetworkException('연결 시간이 초과되었습니다', code: 'TIMEOUT');

  factory NetworkException.noInternet() =>
      const NetworkException('인터넷 연결을 확인해주세요', code: 'NO_INTERNET');

  factory NetworkException.serverError(final int statusCode) =>
      NetworkException(
        '서버 오류가 발생했습니다 (HTTP $statusCode)',
        code: 'SERVER_ERROR',
      );
}

/// API 관련 예외
class ApiException extends AppException {
  const ApiException(super.message, {super.code, super.details});

  factory ApiException.invalidResponse() =>
      const ApiException('잘못된 API 응답입니다', code: 'INVALID_RESPONSE');

  factory ApiException.rateLimitExceeded() =>
      const ApiException('API 사용량 한도를 초과했습니다', code: 'RATE_LIMIT');

  factory ApiException.unauthorized() =>
      const ApiException('API 키가 유효하지 않습니다', code: 'UNAUTHORIZED');

  factory ApiException.quotaExceeded() =>
      const ApiException('API 할당량이 부족합니다', code: 'QUOTA_EXCEEDED');
}

/// 파일 처리 관련 예외
class FileException extends AppException {
  const FileException(super.message, {super.code, super.details});

  factory FileException.notFound() =>
      const FileException('파일을 찾을 수 없습니다', code: 'FILE_NOT_FOUND');

  factory FileException.invalidFormat() =>
      const FileException('지원하지 않는 파일 형식입니다', code: 'INVALID_FORMAT');

  factory FileException.tooLarge() =>
      const FileException('파일 크기가 너무 큽니다', code: 'FILE_TOO_LARGE');
}

/// 데이터 처리 관련 예외
class DataException extends AppException {
  const DataException(super.message, {super.code, super.details});

  factory DataException.notFound() =>
      const DataException('데이터를 찾을 수 없습니다', code: 'DATA_NOT_FOUND');

  factory DataException.corrupted() =>
      const DataException('데이터가 손상되었습니다', code: 'DATA_CORRUPTED');

  factory DataException.validationFailed(final String field) =>
      DataException('$field 유효성 검사에 실패했습니다', code: 'VALIDATION_FAILED');
}

/// 사용자 입력 관련 예외
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});

  factory ValidationException.required(final String field) =>
      ValidationException('$field는(은) 필수 항목입니다', code: 'REQUIRED');

  factory ValidationException.invalidFormat(final String field) =>
      ValidationException('$field 형식이 올바르지 않습니다', code: 'INVALID_FORMAT');

  factory ValidationException.outOfRange(final String field) =>
      ValidationException('$field가(이) 허용 범위를 벗어났습니다', code: 'OUT_OF_RANGE');
}
