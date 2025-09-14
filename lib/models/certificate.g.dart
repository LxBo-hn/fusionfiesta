// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateModel _$CertificateModelFromJson(Map<String, dynamic> json) =>
    CertificateModel(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      certificateId: json['certificate_id'] as String,
      pdfUrl: json['pdf_url'] as String,
      issuedOn: DateTime.parse(json['issued_on'] as String),
      event: json['event'] as Map<String, dynamic>?,
      qrCodeUrl: json['qr_code_url'] as String?,
      feePaid: (json['fee_paid'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CertificateModelToJson(CertificateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'student_id': instance.studentId,
      'certificate_id': instance.certificateId,
      'pdf_url': instance.pdfUrl,
      'issued_on': instance.issuedOn.toIso8601String(),
      'event': instance.event,
      'qr_code_url': instance.qrCodeUrl,
      'fee_paid': instance.feePaid,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
