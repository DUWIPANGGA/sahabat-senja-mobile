import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final String status;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null 
          ? fromJsonT(json['data']) 
          : null,
      errors: json['errors'] is Map 
          ? Map<String, dynamic>.from(json['errors']) 
          : null,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  @override
  List<Object?> get props => [status, message, data, errors];
}