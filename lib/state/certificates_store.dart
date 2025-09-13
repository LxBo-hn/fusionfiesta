import 'package:flutter/foundation.dart';
import '../models/certificate.dart';

class CertificatesStore {
	CertificatesStore._();
	static final CertificatesStore instance = CertificatesStore._();

	final ValueNotifier<List<CertificateModel>> certificates = ValueNotifier<List<CertificateModel>>(<CertificateModel>[
		const CertificateModel(
			id: 'c1',
			eventTitle: 'Tech Talk: Flutter 2025',
			issuedDate: '16-03-2025',
			code: 'CCD-2345',
			previewAsset: 'assets/splash/onboarding_1.png',
		),
		const CertificateModel(
			id: 'c2',
			eventTitle: 'Hackathon 24H',
			issuedDate: '01-04-2025',
			code: 'CCD-9876',
			previewAsset: 'assets/splash/onboarding_2.png',
		),
	]);
}
