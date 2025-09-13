import 'package:flutter/material.dart';
import '../../events/events_list_screen.dart';
import '../../../state/registration_store.dart';
import '../../../models/event.dart';
import '../../../state/certificates_store.dart';
import '../../../models/certificate.dart';
import '../../events/registration_qr_screen.dart';

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
		_ProfileTab(),
	];

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: _tabs[_index],
			bottomNavigationBar: NavigationBar(
				selectedIndex: _index,
				onDestinationSelected: (i) => setState(() => _index = i),
				destinations: const [
					NavigationDestination(icon: Icon(Icons.event), label: 'Sự kiện'),
					NavigationDestination(icon: Icon(Icons.fact_check), label: 'Đăng ký'),
					NavigationDestination(icon: Icon(Icons.card_membership), label: 'Chứng chỉ'),
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
		return SafeArea(
			child: ValueListenableBuilder<List<EventModel>>(
				valueListenable: RegistrationStore.instance.registeredEvents,
				builder: (context, events, _) {
					if (events.isEmpty) {
						return const Center(child: Text('Chưa có sự kiện nào đã đăng ký'));
					}
					return SingleChildScrollView(
						padding: const EdgeInsets.fromLTRB(16, 32, 16, 100),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
                Text(
                  'Đã đăng ký',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
								const SizedBox(height: 8),
								ListView.separated(
									shrinkWrap: true,
									physics: const NeverScrollableScrollPhysics(),
									itemBuilder: (context, index) {
										final e = events[index];
										return ListTile(
                      onTap: () => Navigator.of(context).pushNamed(
                        RegistrationQRScreen.routeName,
                        arguments: {
                          'event': e,
                          'code': 'REG-${e.id.toUpperCase()}',
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
											leading: ClipRRect(
												borderRadius: BorderRadius.circular(8),
												child: SizedBox(
													width: 56,
													height: 56,
                          child: Image.asset(
                            e.imageAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      title: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
											subtitle: Text(e.dateText),
											trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (ctx) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: SafeArea(
                                  top: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final bool? confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (dctx) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Xác nhận huỷ vé'),
                                                  content: const Text(
                                                      'Bạn có muốn huỷ vé không?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(dctx)
                                                              .pop(false),
                                                      child: const Text('Không'),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.of(dctx)
                                                              .pop(true),
                                                      child: const Text('Huỷ vé'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if (confirm == true) {
                                              RegistrationStore.instance
                                                  .unregister(e.id);
                                              Navigator.of(ctx).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('Đã huỷ vé'),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Huỷ vé'),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
											),
										);
									},
									separatorBuilder: (_, __) => const Divider(height: 1),
									itemCount: events.length,
								),
							],
						),
					);
				},
			),
		);
	}
}

class _CertificatesTab extends StatelessWidget {
	const _CertificatesTab();
	@override
	Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<CertificateModel>>(
        valueListenable: CertificatesStore.instance.certificates,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có chứng chỉ nào'));
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
                              onPressed: () {},
                              child: const Text('Share'),
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
                        onPressed: () {},
                        child: const Text('Download PDF'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Share'),
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
		return const Center(child: Text('Hồ sơ người dùng (mock)'));
	}
}
