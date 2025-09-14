import 'package:json_annotation/json_annotation.dart';

part 'certificate.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CertificateModel {
	final int id;
	final int eventId;
	final int studentId;
	final String certificateId;
	final String pdfUrl;
	final DateTime issuedOn;
	final Map<String, dynamic>? event; // Event relationship data
	final String? qrCodeUrl;
	final int feePaid;
	final DateTime createdAt;
	final DateTime updatedAt;

	const CertificateModel({
		required this.id,
		required this.eventId,
		required this.studentId,
		required this.certificateId,
		required this.pdfUrl,
		required this.issuedOn,
		this.event,
		this.qrCodeUrl,
		this.feePaid = 0,
		required this.createdAt,
		required this.updatedAt,
	});

	factory CertificateModel.fromJson(Map<String, dynamic> json) => _$CertificateModelFromJson(json);
	Map<String, dynamic> toJson() => _$CertificateModelToJson(this);

	// Convenience getters
	String get eventTitle => event?['title'] ?? 'Unknown Event';
	String get issuedDate => issuedOn.toIso8601String().split('T')[0];
	String get code => certificateId;
	String get previewAsset => 'assets/certificate_preview.png'; // Default preview

	CertificateModel copyWith({
		int? id,
		int? eventId,
		int? studentId,
		String? certificateId,
		String? pdfUrl,
		DateTime? issuedOn,
		Map<String, dynamic>? event,
		String? qrCodeUrl,
		int? feePaid,
		DateTime? createdAt,
		DateTime? updatedAt,
	}) {
		return CertificateModel(
			id: id ?? this.id,
			eventId: eventId ?? this.eventId,
			studentId: studentId ?? this.studentId,
			certificateId: certificateId ?? this.certificateId,
			pdfUrl: pdfUrl ?? this.pdfUrl,
			issuedOn: issuedOn ?? this.issuedOn,
			event: event ?? this.event,
			qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
			feePaid: feePaid ?? this.feePaid,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
		);
	}
}
