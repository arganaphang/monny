import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:monny/controllers/account_controller.dart';
import 'package:monny/models/models.dart';
import 'package:monny/utils/formatters.dart';
import 'package:monny/pages/add_account_page.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AccountController>();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('accounts'.tr)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddAccountPage()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (ctrl.accounts.isEmpty) {
          return Center(
            child: Text('no_accounts'.tr,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.outline)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.accounts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final account = ctrl.accounts[i];
            return _AccountTile(account: account);
          },
        );
      }),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = Color(account.colorValue);

    return ListTile(
      tileColor: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          IconData(account.iconCodePoint, fontFamily: 'MaterialIcons'), // ignore: non_const_argument_for_const_parameter
          color: accent,
          size: 20,
        ),
      ),
      title: Text(account.name,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(_typeLabel(account.type),
          style: textTheme.labelSmall?.copyWith(color: colors.outline)),
      trailing: Text(formatCurrency(account.balance),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      onTap: () => Get.to(() => AddAccountPage(account: account)),
    );
  }

  String _typeLabel(AccountType type) => switch (type) {
        AccountType.cash => 'account_type_cash'.tr,
        AccountType.bank => 'account_type_bank'.tr,
        AccountType.eWallet => 'account_type_ewallet'.tr,
        AccountType.other => 'account_type_other'.tr,
      };
}
