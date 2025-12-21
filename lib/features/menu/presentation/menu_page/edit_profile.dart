import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/auth_service.dart';
import '../providers/auth_provider.dart';

class EditAccountPage extends ConsumerStatefulWidget {
  const EditAccountPage({super.key});

  @override
  ConsumerState<EditAccountPage> createState() =>
      _EditAccountPageState();
}

class _EditAccountPageState
    extends ConsumerState<EditAccountPage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController genderCtrl;
  late TextEditingController locationCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user!;

    nameCtrl = TextEditingController(text: user.displayName ?? '');
    phoneCtrl = TextEditingController(text: user.phone ?? '');
    genderCtrl = TextEditingController(text: user.gender ?? '');
    locationCtrl =
        TextEditingController(text: user.location ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sửa tài khoản")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameCtrl,
                decoration:
                const InputDecoration(labelText: 'Họ tên')),
            TextField(
                controller: phoneCtrl,
                decoration:
                const InputDecoration(labelText: 'SĐT')),
            TextField(
                controller: genderCtrl,
                decoration:
                const InputDecoration(labelText: 'Giới tính')),
            TextField(
                controller: locationCtrl,
                decoration:
                const InputDecoration(labelText: 'Địa điểm')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedUser = await AuthService.updateUser(
                    ref.read(authProvider).token!,
                    ref.read(authProvider).user!.id,
                    {
                      "displayName": nameCtrl.text,
                      "phoneNumber": phoneCtrl.text,
                      "gender": genderCtrl.text,
                      "address": locationCtrl.text,
                    },
                  );

                  // Cập nhật lại state trong Riverpod
                  ref.read(authProvider.notifier).updateUser(updatedUser);

                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  // Show error
                }
              },
              child: const Text("Lưu"),
            )
          ],
        ),
      ),
    );
  }
}
