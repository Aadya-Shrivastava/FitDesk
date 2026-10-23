import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gymadmin/controller/payfeescontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class Payfees extends GetView<Payfeescontroller> {
  const Payfees({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isMobile = c.maxWidth < 980;

            return Obx(() {
              if (controller.isLoading.value && controller.fee.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchFeeDetail,
                  onBack: () => Get.back(),
                );
              }

              final d = controller.fee.value;
              if (d == null) {
                return _ErrorState(
                  message: "No data found.",
                  onRetry: controller.fetchFeeDetail,
                  onBack: () => Get.back(),
                );
              }

              return DefaultTabController(
                length: 2,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeroHeader(
                        invoice: d.invoiceNumber ?? "-",
                        member: d.trainee?.name ?? "-",
                        status: (d.status ?? "Pending").toString(),
                        total: controller.money(d.amount),
                        paid: controller.money(d.paidAmount),
                        balance: controller.money(d.balanceAmount ?? d.amount),
                        onBack: () => Get.back(),
                        isMobile: isMobile,
                        onCollect: isMobile
                            ? () => _openPaymentSheet(context)
                            : null, // desktop panel shows on right
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppPalette.surface,
                        child: const TabBar(
                          labelColor: AppPalette.secondary,
                          unselectedLabelColor: AppPalette.textSecondary,
                          indicatorColor: AppPalette.secondary,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: "Details"),
                            Tab(text: "Payments"),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      sliver: SliverToBoxAdapter(
                        child: isMobile
                            ? _MobileBody()
                            : _DesktopBody(),
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _openPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (ctx, scroll) {
            return SingleChildScrollView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: const _CollectPaymentPanel(isSheet: true),
            );
          },
        );
      },
    );
  }
}

// ====================== DESKTOP / MOBILE BODIES ======================

class _DesktopBody extends GetView<Payfeescontroller> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 640, // keeps layout stable on desktop
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: _panelDecoration(),
              child: const _TabContent(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Column(
              children: const [
                _CollectPaymentPanel(isSheet: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: const _TabContent(),
    );
  }
}

// ====================== HERO HEADER ======================

class _HeroHeader extends StatelessWidget {
  final String invoice;
  final String member;
  final String status;
  final String total;
  final String paid;
  final String balance;
  final VoidCallback onBack;
  final bool isMobile;
  final VoidCallback? onCollect;

  const _HeroHeader({
    required this.invoice,
    required this.member,
    required this.status,
    required this.total,
    required this.paid,
    required this.balance,
    required this.onBack,
    required this.isMobile,
    this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    final isPaid = s == "paid";
    final statusColor = isPaid ? const Color(0xFF10C25B) : const Color(0xFFFFC107);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        border: Border(
          bottom: BorderSide(color: AppPalette.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row
          Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppPalette.secondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppPalette.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Invoice • $invoice",
                      style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.isEmpty ? "Pending" : status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // stats row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: "Total", value: total, icon: Icons.account_balance_wallet_outlined),
              _StatChip(label: "Paid", value: paid, icon: Icons.verified_outlined),
              _StatChip(label: "Balance", value: balance, icon: Icons.hourglass_bottom_outlined),
            ],
          ),

          if (isMobile && onCollect != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onCollect,
                icon: const Icon(Icons.payments_outlined),
                label: const Text("Collect Payment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppPalette.secondary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== TAB CONTENT ======================

class _TabContent extends GetView<Payfeescontroller> {
  const _TabContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 620,
      child: TabBarView(
        children: [
          _DetailsTab(),
          _PaymentsTab(),
        ],
      ),
    );
  }
}

class _DetailsTab extends GetView<Payfeescontroller> {
  String _formatDate(String? raw) {
    final t = (raw ?? "").trim();
    if (t.isEmpty) return "-";

    final parsed = DateTime.tryParse(t);
    if (parsed != null) {
      return DateFormat("dd-MM-yyyy").format(parsed);
    }

    try {
      final d = DateFormat("yyyy-MM-dd").parseStrict(t);
      return DateFormat("dd-MM-yyyy").format(d);
    } catch (_) {
      return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = controller.fee.value!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const _SectionTitle(title: "Fee Information"),
          const SizedBox(height: 10),
          _DefinitionGrid(
            items: [
              _DefItem("Invoice Number", d.invoiceNumber ?? "-"),
              _DefItem("Member", d.trainee?.name ?? "-"),
              _DefItem("Duration Type", d.durationType ?? "-"),
              _DefItem("Month Number", "${d.monthNumber ?? "-"}"),
              _DefItem("Due Date", _formatDate(d.dueDate)),
              _DefItem("Status", (d.status ?? "-").toString()),
              _DefItem("Created", _formatDate(d.createdAt)),
              _DefItem("Updated", _formatDate(d.updatedAt)),
            ],
          ),
          const SizedBox(height: 14),
          const _SectionTitle(title: "Notes"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppPalette.border),
            ),
            child: Text(
              (d.notes ?? "").toString().trim().isEmpty ? "No notes available." : (d.notes ?? "").toString(),
              style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsTab extends GetView<Payfeescontroller> {
  String _formatValueForKey(String key, dynamic value) {
    final k = key.toLowerCase();
    if (k.contains("date")) {
      return _formatDateValue(value);
    }
    return value == null ? "-" : value.toString();
  }

  String _formatDateValue(dynamic value) {
    if (value == null) return "-";

    if (value is int) {
      final ms = value > 1000000000000 ? value : value * 1000;
      final d = DateTime.fromMillisecondsSinceEpoch(ms);
      return DateFormat("dd-MM-yyyy").format(d);
    }

    final t = value.toString().trim();
    if (t.isEmpty) return "-";

    final parsed = DateTime.tryParse(t);
    if (parsed != null) {
      return DateFormat("dd-MM-yyyy").format(parsed);
    }

    try {
      final d = DateFormat("yyyy-MM-dd").parseStrict(t);
      return DateFormat("dd-MM-yyyy").format(d);
    } catch (_) {
      return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = controller.fee.value?.payments ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: list.isEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppPalette.textSecondary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "No payment history found for this fee.",
                      style: TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final raw = list[i].raw;
                final keys = raw.keys.take(6).toList();

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppPalette.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.payments_outlined, color: AppPalette.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Payment #${i + 1}",
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.secondary)),
                            const SizedBox(height: 8),
                            if (keys.isEmpty)
                              const Text("No fields from API.",
                                  style: TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700))
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: keys.map((k) {
                                  return _MiniTag(label: k, value: _formatValueForKey(k, raw[k]));
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ====================== COLLECT PAYMENT PANEL ======================

class _CollectPaymentPanel extends GetView<Payfeescontroller> {
  final bool isSheet;
  const _CollectPaymentPanel({required this.isSheet});

  @override
  Widget build(BuildContext context) {
    final d = controller.fee.value;
    final balanceText = controller.money(d?.balanceAmount ?? d?.amount);

    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: [
          // panel header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: AppPalette.surface,
              border: Border(bottom: BorderSide(color: AppPalette.border)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text("Collect Payment",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppPalette.secondary)),
                ),
                Obx(() {
                  if (controller.isSaving.value) {
                    return const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DueBanner(amountDue: balanceText),
                const SizedBox(height: 14),

                _Field(label: "Payment Amount", child: _textInput(controller.amountCtrl, prefix: "₹ ")),
                const SizedBox(height: 12),

                _Field(
                  label: "Payment Method",
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.selectedMethod.value,
                      items: Payfeescontroller.methodOptions
                          .map((e) => DropdownMenuItem(value: e.value, child: Text(e.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.selectedMethod.value = v;
                      },
                      decoration: _inputDecoration(),
                    );
                  }),
                ),
                const SizedBox(height: 12),

                _Field(label: "Reference", child: _textInput(controller.referenceCtrl, hint: "Txn / UPI / Note")),
                const SizedBox(height: 6),
                Obx(() {
                  final needsRef = controller.selectedMethod.value != "cash";
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      needsRef ? "Required for non-cash payments." : "Optional for cash payments.",
                      style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  );
                }),

                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSaving.value ? null : controller.markAsPaid,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Confirm"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                if (isSheet) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppPalette.border),
                      ),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _DueBanner({required String amountDue}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: AppPalette.secondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Amount Due", style: TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(amountDue, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textInput(TextEditingController c, {String? hint, String? prefix}) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.text,
      decoration: _inputDecoration(hint: hint, prefix: prefix),
    );
  }
}

// ====================== UI HELPERS ======================

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: AppPalette.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppPalette.border),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 10)),
    ],
  );
}

InputDecoration _inputDecoration({String? hint, String? prefix}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefix,
    filled: true,
    fillColor: AppPalette.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppPalette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppPalette.secondary, width: 1.2),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppPalette.secondary));
  }
}

class _DefItem {
  final String k;
  final String v;
  _DefItem(this.k, this.v);
}

class _DefinitionGrid extends StatelessWidget {
  final List<_DefItem> items;
  const _DefinitionGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isTight = c.maxWidth < 620;
        final cols = isTight ? 1 : 2;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isTight ? 4.4 : 3.8,
          ),
          itemBuilder: (_, i) {
            final it = items[i];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    it.k,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w800, fontSize: 10),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    it.v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final String value;
  const _MiniTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorState({required this.message, required this.onRetry, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 46, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text("Something went wrong", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
