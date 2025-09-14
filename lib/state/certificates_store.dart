import 'package:flutter/foundation.dart';
import '../models/certificate.dart';
import '../services/api_service.dart';

class CertificatesStore extends ChangeNotifier {
	CertificatesStore._();
	static final CertificatesStore instance = CertificatesStore._();

	final ValueNotifier<List<CertificateModel>> certificates = ValueNotifier<List<CertificateModel>>([]);
	final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
	final ValueNotifier<String?> error = ValueNotifier<String?>(null);
	final ValueNotifier<bool> hasMorePages = ValueNotifier<bool>(true);
	
	int _currentPage = 1;
	final ApiService _apiService = ApiService.instance;

	// Load certificates from API
	Future<void> loadCertificates({bool refresh = false}) async {
		try {
			if (refresh) {
				_currentPage = 1;
				certificates.value = [];
			}
			
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getMyCertificates(page: _currentPage);
			
			if (response['data'] != null) {
				final List<dynamic> certificatesData = response['data'];
				final newCertificates = certificatesData
					.map((json) => CertificateModel.fromJson(json))
					.toList();
				
				if (refresh) {
					certificates.value = newCertificates;
				} else {
					certificates.value = [...certificates.value, ...newCertificates];
				}
				
				// Check if there are more pages
				hasMorePages.value = response['next_page_url'] != null;
				_currentPage++;
			} else {
				error.value = 'Failed to load certificates';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}

	// Issue certificate via API
	Future<bool> issueCertificate(int registrationId, String certificateId, String pdfUrl) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.issueCertificate(registrationId, certificateId, pdfUrl);
			
			if (response['id'] != null) {
				// Add to local list
				final newCertificate = CertificateModel.fromJson(response);
				final list = List<CertificateModel>.from(certificates.value)..insert(0, newCertificate);
				certificates.value = list;
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to issue certificate';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Load more certificates (pagination)
	Future<void> loadMoreCertificates() async {
		if (!hasMorePages.value || isLoading.value) return;
		await loadCertificates();
	}

	// Clear error
	void clearError() {
		error.value = null;
	}
}
