import 'package:flutter/material.dart';
import '../../events/events_list_screen.dart';
import '../../../state/certificates_store.dart';
import '../../../models/certificate.dart';
import '../../../services/profile_service.dart';
import '../../../services/registration_service.dart';
import '../../../services/auth_service.dart';
import '../../events/registration_qr_screen.dart';
import '../../auth/role_selection_screen.dart';
import '../../../main.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/services.dart';
import 'profile_components.dart';
import '../../organizer/qr_scanner_screen.dart';

class StudentDashboard extends StatefulWidget {
	static const String routeName = '/student';
	const StudentDashboard({super.key});

	@override
	State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
	int _index = 0;

	final List<Widget> _tabs = const [
		EventsListScreen(),
		_MyRegistrationsTab(),
		_CertificatesTab(),
		_QRScannerTab(),
		_ProfileTab(),
	];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				automaticallyImplyLeading: false,
				backgroundColor: Theme.of(context).colorScheme.primary,
				foregroundColor: Colors.white,
			),
			body: _tabs[_index],
			bottomNavigationBar: NavigationBar(
				selectedIndex: _index,
				onDestinationSelected: (i) => setState(() => _index = i),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.event), label: 'Sự kiện'),
					NavigationDestination(icon: Icon(Icons.fact_check), label: 'Đăng ký'),
					NavigationDestination(icon: Icon(Icons.card_membership), label: 'Chứng chỉ'),
					NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Quét QR'),
					NavigationDestination(icon: Icon(Icons.person), label: 'Hồ sơ'),
				],
			),
		);
	}

}

class _MyRegistrationsTab extends StatelessWidget {
	const _MyRegistrationsTab();

	@override
	Widget build(BuildContext context) {
		final svc = RegistrationService.instance;
		return SafeArea(
			child: AnimatedBuilder(
				animation: svc,
				builder: (context, _) {
					if (svc.isLoading.value && svc.myRegistrations.isEmpty) {
						return const Center(child: CircularProgressIndicator());
					}
					if (svc.error.value != null && svc.myRegistrations.isEmpty) {
						return Center(child: Text(svc.error.value!));
					}
					final items = svc.myRegistrations;
					if (items.isEmpty) {
						svc.loadMyRegistrations(refresh: true);
						return const Center(child: CircularProgressIndicator());
					}
					return RefreshIndicator(
						onRefresh: () => svc.loadMyRegistrations(refresh: true),
						child: ListView.separated(
							padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
							itemCount: items.length,
							separatorBuilder: (_, __) => const SizedBox(height: 10),
									itemBuilder: (context, index) {
								final r = items[index];
								return Card(
									child: ListTile(
										onTap: () {
											Navigator.of(context).pushNamed(
                        RegistrationQRScreen.routeName,
                        arguments: {
													'event': {'title': r.eventTitle},
													'code': r.checkinCode ?? r.qrCode ?? 'REG-${r.id}',
												},
											);
										},
										title: Text(r.eventTitle),
										subtitle: Text('Status: ${r.statusDisplayName}'),
										trailing: Wrap(
											spacing: 8,
                                    children: [
												OutlinedButton(
													onPressed: () {
													Navigator.of(context).pushNamed(
														RegistrationQRScreen.routeName,
														arguments: {
															'event': {'title': r.eventTitle},
															'code': r.checkinCode ?? r.qrCode ?? 'REG-${r.id}',
														},
													);
												},
												child: const Text('QR'),
											),
											TextButton(
                                          onPressed: () async {
													final ok = await showDialog<bool>(
                                              context: context,
														builder: (_) => AlertDialog(
															title: const Text('Huỷ đăng ký?'),
															content: Text('Bạn có chắc muốn huỷ tham gia "${r.eventTitle}"?'),
                                                  actions: [
																TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không')),
																FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Huỷ')),
															],
														),
													);
													if (ok == true) {
														final success = await svc.unregisterFromEvent(r.eventId);
														if (success) {
															// Refresh the list after successful unregistration
															await svc.loadMyRegistrations(refresh: true);
															if (context.mounted) {
																ScaffoldMessenger.of(context).showSnackBar(
																	const SnackBar(content: Text('Đã hủy đăng ký thành công')),
																);
															}
														} else if (context.mounted) {
															ScaffoldMessenger.of(context).showSnackBar(
																SnackBar(content: Text(svc.error.value ?? 'Huỷ đăng ký thất bại')),
															);
														}
													}
												},
												child: const Text('Huỷ'),
											),
                                    ],
                                  ),
                                ),
                              );
                            },
						),
					);
				},
			),
		);
	}
}

class _CertificatesTab extends StatefulWidget {
	const _CertificatesTab();

	@override
	State<_CertificatesTab> createState() => _CertificatesTabState();
}

class _CertificatesTabState extends State<_CertificatesTab> {
	bool _initialized = false;

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (!_initialized) {
				_initialized = true;
				CertificatesStore.instance.loadCertificates(refresh: true);
			}
		});
	}

	@override
	Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<CertificateModel>>(
        valueListenable: CertificatesStore.instance.certificates,
        builder: (context, items, _) {
          if (items.isEmpty && CertificatesStore.instance.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chứng chỉ của bạn',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final c = items[index];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.asset(
                              c.previewAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        title: Text(
                          c.eventTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle:
                            Text('Issued: ${c.issuedDate}  •  Code: ${c.code}'),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            OutlinedButton(
                              onPressed: () => _preview(context, c),
                              child: const Text('View'),
                            ),
                            FilledButton.tonal(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
                                );
                              },
                              child: const Text('Chia sẻ'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: items.length,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _preview(BuildContext context, CertificateModel c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(
                        c.previewAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.eventTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Issued: ${c.issuedDate}  •  Code: ${c.code}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () async {
                          final url = c.pdfUrl;
                          try {
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Không thể mở PDF trên emulator. Vui lòng copy URL để mở trên thiết bị thật.'),
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: 'Copy URL',
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: url));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('URL đã copy vào clipboard')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi mở PDF: $e'),
                                  action: SnackBarAction(
                                    label: 'Copy URL',
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: url));
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('URL đã copy vào clipboard')),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Mở PDF'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
                          );
                        },
                        child: const Text('Chia sẻ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
	}
}

class _ProfileTab extends StatelessWidget {
	const _ProfileTab();
	@override
	Widget build(BuildContext context) {
		final service = ProfileService.instance;
		return SafeArea(
			child: AnimatedBuilder(
				animation: service,
				builder: (context, _) {
					if (service.isLoading.value) {
						return const Center(child: CircularProgressIndicator());
					}
					if (service.error.value != null) {
						return Center(child: Text(service.error.value!));
					}
					final profile = service.currentProfile;
					if (profile == null) {
						service.loadProfile();
						return const Center(child: CircularProgressIndicator());
					}
					return SingleChildScrollView(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								// Header
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text(
											'Hồ sơ cá nhân',
											style: Theme.of(context).textTheme.headlineSmall?.copyWith(
												fontWeight: FontWeight.w700,
											),
										),
										IconButton(
											onPressed: () {
												// TODO: Navigate to edit profile
												ScaffoldMessenger.of(context).showSnackBar(
													const SnackBar(content: Text('Tính năng chỉnh sửa đang phát triển')),
												);
											},
											icon: const Icon(Icons.edit),
											style: IconButton.styleFrom(
												backgroundColor: Theme.of(context).colorScheme.primaryContainer,
											),
										),
									],
								),
								const SizedBox(height: 24),
								
								// Profile Card
								Card(
									child: Padding(
										padding: const EdgeInsets.all(20),
										child: Column(
											children: [
												// Avatar and basic info
												Center(
													child: CircleAvatar(
														radius: 50,
														backgroundColor: Theme.of(context).colorScheme.primary,
														child: Text(
															profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
															style: const TextStyle(
																fontSize: 32,
																fontWeight: FontWeight.bold,
																color: Colors.white,
															),
														),
													),
												),
												const SizedBox(height: 16),
												Text(
													profile.name,
													style: Theme.of(context).textTheme.headlineSmall?.copyWith(
														fontWeight: FontWeight.w600,
													),
												),
												const SizedBox(height: 4),
												Text(
													profile.email,
													style: Theme.of(context).textTheme.bodyLarge?.copyWith(
														color: Theme.of(context).colorScheme.onSurfaceVariant,
													),
												),
											],
										),
									),
								),
								const SizedBox(height: 24),
								
								// Personal Information
								Text(
									'Thông tin cá nhân',
									style: Theme.of(context).textTheme.titleLarge?.copyWith(
										fontWeight: FontWeight.w600,
									),
								),
								const SizedBox(height: 16),
								
								Card(
									child: Column(
										children: [
											ProfileInfoTile(
												icon: Icons.badge,
												label: 'Mã sinh viên',
												value: profile.detail?.studentCode ?? 'Chưa cập nhật',
												onTap: () {
													// TODO: Edit student code
												},
											),
											const Divider(height: 1),
											ProfileInfoTile(
												icon: Icons.school,
												label: 'Khoa',
												value: profile.detail?.departmentId?.toString() ?? 'Chưa cập nhật',
												onTap: () {
													// TODO: Edit department
												},
											),
											const Divider(height: 1),
											ProfileInfoTile(
												icon: Icons.phone,
												label: 'Số điện thoại',
												value: profile.detail?.phone ?? 'Chưa cập nhật',
												onTap: () {
													// TODO: Edit phone
												},
											),
											const Divider(height: 1),
											ProfileInfoTile(
												icon: Icons.cake,
												label: 'Ngày sinh',
												value: profile.detail?.dob != null 
													? profile.detail!.dob!.toIso8601String().split('T')[0]
													: 'Chưa cập nhật',
												onTap: () {
													// TODO: Edit date of birth
												},
											),
											const Divider(height: 1),
											ProfileInfoTile(
												icon: Icons.person,
												label: 'Giới tính',
												value: profile.detail?.gender ?? 'Chưa cập nhật',
												onTap: () {
													// TODO: Edit gender
												},
											),
										],
									),
								),
								const SizedBox(height: 24),
								
								// Account Status
								Text(
									'Trạng thái tài khoản',
									style: Theme.of(context).textTheme.titleLarge?.copyWith(
										fontWeight: FontWeight.w600,
									),
								),
								const SizedBox(height: 16),
								
								Card(
									child: Column(
										children: [
											ProfileInfoTile(
												icon: Icons.email,
												label: 'Email',
												value: profile.isEmailVerified ? 'Đã xác thực' : 'Chưa xác thực',
												trailing: profile.isEmailVerified 
													? null
													: IconButton(
														icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
														onPressed: () {
															// TODO: Send verification email
															ScaffoldMessenger.of(context).showSnackBar(
																const SnackBar(content: Text('Đã gửi email xác thực')),
															);
														},
													),
											),
											const Divider(height: 1),
											ProfileInfoTile(
												icon: Icons.calendar_today,
												label: 'Tham gia từ',
												value: profile.formattedJoinDate,
												onTap: null,
											),
										],
									),
								),
								const SizedBox(height: 24),
								
								// Action Buttons
								Row(
									children: [
										Expanded(
											child: OutlinedButton.icon(
												onPressed: () {
													// TODO: Change password
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('Tính năng đổi mật khẩu đang phát triển')),
													);
												},
												icon: const Icon(Icons.lock),
												label: const Text('Đổi mật khẩu'),
											),
										),
										const SizedBox(width: 12),
										Expanded(
											child: FilledButton.icon(
												onPressed: () => _showProfileLogoutDialog(context),
												icon: const Icon(Icons.logout),
												label: const Text('Đăng xuất'),
											),
										),
									],
								),
								const SizedBox(height: 24),
							],
						),
					);
				},
			),
		);
	}

	void _showProfileLogoutDialog(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Đăng xuất'),
				content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Hủy'),
					),
					FilledButton(
						onPressed: () async {
							Navigator.pop(context);
							print('🔄 Starting logout process...');
							await AuthService.instance.logout();
							print('✅ Logout completed, navigating to role selection...');
							
							// Use global navigator key to ensure navigation works
							FusionFiestaApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
								RoleSelectionScreen.routeName,
								(route) => false,
							);
						},
						child: const Text('Đăng xuất'),
					),
				],
			),
		);
	}
}

class _QRScannerTab extends StatelessWidget {
	const _QRScannerTab();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.qr_code_scanner,
							size: 80,
							color: Theme.of(context).colorScheme.primary,
						),
						const SizedBox(height: 24),
						Text(
							'Quét QR Check-in',
							style: Theme.of(context).textTheme.headlineSmall?.copyWith(
								fontWeight: FontWeight.bold,
							),
						),
						const SizedBox(height: 16),
						Text(
							'Quét mã QR để check-in vào sự kiện',
							style: Theme.of(context).textTheme.bodyLarge?.copyWith(
								color: Colors.grey[600],
							),
							textAlign: TextAlign.center,
						),
						const SizedBox(height: 32),
						FilledButton.icon(
							onPressed: () {
								// Mở QR Scanner
								Navigator.push(
									context,
									MaterialPageRoute(
										builder: (context) => const QRScannerScreen(
											event: null, // Student có thể quét bất kỳ event nào
										),
									),
								);
							},
							icon: const Icon(Icons.qr_code_scanner),
							label: const Text('Bắt đầu quét QR'),
							style: FilledButton.styleFrom(
								backgroundColor: Theme.of(context).colorScheme.primary,
								padding: const EdgeInsets.symmetric(
									horizontal: 32,
									vertical: 16,
								),
							),
						),
						const SizedBox(height: 16),
						OutlinedButton.icon(
							onPressed: () {
								// Hướng dẫn sử dụng
								_showQRInstructions(context);
							},
							icon: const Icon(Icons.help_outline),
							label: const Text('Hướng dẫn'),
							style: OutlinedButton.styleFrom(
								foregroundColor: Theme.of(context).colorScheme.primary,
								side: BorderSide(
									color: Theme.of(context).colorScheme.primary,
								),
								padding: const EdgeInsets.symmetric(
									horizontal: 32,
									vertical: 16,
								),
							),
						),
					],
				),
			),
		);
	}

	void _showQRInstructions(BuildContext context) {
		showDialog(
			context: context,
			builder: (context) => AlertDialog(
				title: const Text('Hướng dẫn quét QR'),
				content: const Column(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text('1. Nhấn "Bắt đầu quét QR"'),
						Text('2. Hướng camera về phía mã QR'),
						Text('3. Đợi app tự động nhận diện'),
						Text('4. Xác nhận check-in thành công'),
						SizedBox(height: 16),
						Text(
							'Lưu ý: Chỉ có thể check-in trong thời gian sự kiện diễn ra.',
							style: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.orange,
							),
						),
					],
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(context),
						child: const Text('Đóng'),
					),
				],
			),
		);
	}
}