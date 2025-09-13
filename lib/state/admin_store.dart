import 'package:flutter/foundation.dart';

class AdminApprovalItem {
	final String id;
	final String title;
	final String status; // pending/approved/rejected
	const AdminApprovalItem({required this.id, required this.title, required this.status});
	AdminApprovalItem copyWith({String? status}) => AdminApprovalItem(id: id, title: title, status: status ?? this.status);
}

class AdminUserItem {
	final String id;
	final String name;
	final String role; // student/organizer/admin
	const AdminUserItem({required this.id, required this.name, required this.role});
}

class AdminStore {
	AdminStore._();
	static final AdminStore instance = AdminStore._();

	final ValueNotifier<List<AdminApprovalItem>> approvals = ValueNotifier<List<AdminApprovalItem>>(<AdminApprovalItem>[
		const AdminApprovalItem(id: 'a1', title: 'Workshop Flutter', status: 'pending'),
		const AdminApprovalItem(id: 'a2', title: 'Giải bóng đá', status: 'pending'),
	]);

	final ValueNotifier<List<AdminUserItem>> users = ValueNotifier<List<AdminUserItem>>(<AdminUserItem>[
		const AdminUserItem(id: 'u1', name: 'Minh Nguyen', role: 'student'),
		const AdminUserItem(id: 'u2', name: 'Lan Tran', role: 'organizer'),
		const AdminUserItem(id: 'u3', name: 'Admin', role: 'admin'),
	]);

	void setApprovalStatus(String id, String status) {
		final list = List<AdminApprovalItem>.from(approvals.value);
		final idx = list.indexWhere((e) => e.id == id);
		if (idx != -1) {
			list[idx] = list[idx].copyWith(status: status);
			approvals.value = list;
		}
	}
}
