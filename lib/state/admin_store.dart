import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

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

class AdminStore extends ChangeNotifier {
	AdminStore._();
	static final AdminStore instance = AdminStore._();

	final ValueNotifier<List<AdminApprovalItem>> approvals = ValueNotifier<List<AdminApprovalItem>>([]);
	final ValueNotifier<List<UserModel>> users = ValueNotifier<List<UserModel>>([]);
	final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
	final ValueNotifier<String?> error = ValueNotifier<String?>(null);

	final ApiService _apiService = ApiService.instance;

	// Load approvals from API
	Future<void> loadApprovals() async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getApprovals();
			if (response['success']) {
				final List<dynamic> approvalsData = response['data'] ?? [];
				approvals.value = approvalsData
					.map((json) => AdminApprovalItem(
						id: json['id'] ?? '',
						title: json['title'] ?? '',
						status: json['status'] ?? 'pending',
					))
					.toList();
			} else {
				error.value = response['message'] ?? 'Failed to load approvals';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}

	// Load users from API
	Future<void> loadUsers() async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.getUsers();
			if (response['success']) {
				final List<dynamic> usersData = response['data'] ?? [];
				users.value = usersData
					.map((json) => UserModel.fromJson(json))
					.toList();
			} else {
				error.value = response['message'] ?? 'Failed to load users';
			}
		} catch (e) {
			error.value = e.toString();
		} finally {
			isLoading.value = false;
		}
	}

	// Update approval status via API
	Future<bool> setApprovalStatus(String id, String status) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.updateApproval(id, status);
			if (response['success']) {
				// Update local list
				final list = List<AdminApprovalItem>.from(approvals.value);
				final idx = list.indexWhere((e) => e.id == id);
				if (idx != -1) {
					list[idx] = list[idx].copyWith(status: status);
					approvals.value = list;
				}
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to update approval';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Create user via API
	Future<bool> createUser(UserModel user) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.createUser(user.toJson());
			if (response['success']) {
				// Reload users to get updated list
				await loadUsers();
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to create user';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Update user via API
	Future<bool> updateUser(UserModel user) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.updateUser(user.id, user.toJson());
			if (response['success']) {
				// Update local list
				final list = List<UserModel>.from(users.value);
				final idx = list.indexWhere((u) => u.id == user.id);
				if (idx != -1) {
					list[idx] = user;
					users.value = list;
				}
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to update user';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Delete user via API
	Future<bool> deleteUser(String userId) async {
		try {
			isLoading.value = true;
			error.value = null;
			
			final response = await _apiService.deleteUser(userId);
			if (response['success']) {
				// Remove from local list
				final list = List<UserModel>.from(users.value)..removeWhere((u) => u.id == userId);
				users.value = list;
				return true;
			} else {
				error.value = response['message'] ?? 'Failed to delete user';
				return false;
			}
		} catch (e) {
			error.value = e.toString();
			return false;
		} finally {
			isLoading.value = false;
		}
	}

	// Clear error
	void clearError() {
		error.value = null;
	}
}
