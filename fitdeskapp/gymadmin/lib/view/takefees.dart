import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/takefeescontroller.dart';
import 'package:gymadmin/view/payfees.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class Takefees extends GetView<Takefeescontroller> {
  const Takefees({super.key});

  @override
  Widget build(BuildContext context) {
    // ❌ Do NOT Get.put() here.
    // ✅ Use bindings/routes. If you absolutely must:
    // Get.put(Takefeescontroller()); // but don't, it's wrong.

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Fees Dashboard",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        actions: [
          Container(
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () => Get.toNamed(RouteName.createfees),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text(
                "Create Fees",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isMobile = w < 800;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SummarySection(isMobile: isMobile)),
                SliverToBoxAdapter(child: _FiltersSection(isMobile: isMobile)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  sliver: SliverToBoxAdapter(child: _ContentSection(isMobile: isMobile)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------- SUMMARY ----------------------------
class _SummarySection extends GetView<Takefeescontroller> {
  final bool isMobile;
  const _SummarySection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Obx(() {
        final cards = [
          _MetricCard(
            title: "Total",
            value: controller.totalFeesText,
            icon: Icons.account_balance_wallet_outlined,
            tint: AppPalette.secondary,
          ),
          _MetricCard(
            title: "Paid",
            value: controller.paidText,
            icon: Icons.verified_outlined,
            tint: const Color(0xFF10C25B),
          ),
          _MetricCard(
            title: "Pending",
            value: controller.pendingText,
            icon: Icons.hourglass_bottom_outlined,
            tint: const Color(0xFFFFC107),
          ),
          _MetricCard(
            title: "Overdue",
            value: controller.overdueText,
            icon: Icons.warning_amber_outlined,
            tint: const Color(0xFFF44336),
          ),
        ];

        final crossAxisCount = isMobile ? 2 : 4;

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.55 : 2.8,
          ),
          itemBuilder: (_, i) => cards[i],
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- FILTERS ----------------------------
class _FiltersSection extends GetView<Takefeescontroller> {
  final bool isMobile;
  const _FiltersSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: isMobile ? _MobileFilters() : _DesktopFilters(),
    );
  }
}

class _DesktopFilters extends GetView<Takefeescontroller> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Obx(() {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DropdownField(
              label: "Member",
              width: 280,
              value: controller.selectedMember.value,
              items: controller.memberOptions,
              onChanged: (v) {
                controller.selectedMember.value = v ?? "All Members";
              },
            ),
            _DropdownField(
              label: "Status",
              width: 180,
              value: controller.selectedStatus.value,
              items: controller.statusOptions,
              onChanged: (v) {
                controller.selectedStatus.value = v ?? "All Status";
              },
            ),
            _DropdownField(
              label: "Duration",
              width: 200,
              value: controller.selectedDuration.value,
              items: controller.durationOptions,
              onChanged: (v) {
                controller.selectedDuration.value = v ?? "All Durations";
              },
            ),
            _DropdownField(
              label: "Month",
              width: 160,
              value: controller.selectedMonth.value,
              items: controller.monthOptions,
              onChanged: (v) {
                controller.selectedMonth.value = v ?? "All Months";
              },
            ),
            _DateField(
              label: "From",
              width: 200,
              value: controller.fromDateText,
              onTap: () => controller.pickFromDate(context),
            ),
            _DateField(
              label: "To",
              width: 200,
              value: controller.toDateText,
              onTap: () => controller.pickToDate(context),
            ),
            _SearchField(
              label: "Search",
              width: 320,
              controller: controller.searchCtrl,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PrimaryBtn(
                  text: "Apply",
                  icon: Icons.tune,
                  onTap: controller.applyFilters,
                ),
                const SizedBox(width: 10),
                _GhostBtn(
                  text: "Reset",
                  icon: Icons.restart_alt,
                  onTap: controller.resetFilters,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _MobileFilters extends GetView<Takefeescontroller> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: const Text("Filters", style: TextStyle(fontWeight: FontWeight.w900, color: AppPalette.secondary)),
          subtitle: const Text("Tap to refine results", style: TextStyle(fontWeight: FontWeight.w600)),
          leading: const Icon(Icons.tune, color: AppPalette.secondary),
          children: [
            _DropdownField(
              label: "Member",
              width: double.infinity,
              value: controller.selectedMember.value,
              items: controller.memberOptions,
              onChanged: (v) => controller.selectedMember.value = v ?? "All Members",
            ),
            const SizedBox(height: 10),
            _DropdownField(
              label: "Status",
              width: double.infinity,
              value: controller.selectedStatus.value,
              items: controller.statusOptions,
              onChanged: (v) => controller.selectedStatus.value = v ?? "All Status",
            ),
            const SizedBox(height: 10),
            _DropdownField(
              label: "Duration",
              width: double.infinity,
              value: controller.selectedDuration.value,
              items: controller.durationOptions,
              onChanged: (v) => controller.selectedDuration.value = v ?? "All Durations",
            ),
            const SizedBox(height: 10),
            _DropdownField(
              label: "Month",
              width: double.infinity,
              value: controller.selectedMonth.value,
              items: controller.monthOptions,
              onChanged: (v) => controller.selectedMonth.value = v ?? "All Months",
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: "From",
                    width: double.infinity,
                    value: controller.fromDateText,
                    onTap: () => controller.pickFromDate(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateField(
                    label: "To",
                    width: double.infinity,
                    value: controller.toDateText,
                    onTap: () => controller.pickToDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SearchField(
              label: "Search",
              width: double.infinity,
              controller: controller.searchCtrl,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PrimaryBtn(
                    text: "Apply",
                    icon: Icons.tune,
                    onTap: controller.applyFilters,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GhostBtn(
                    text: "Reset",
                    icon: Icons.restart_alt,
                    onTap: controller.resetFilters,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final double width;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.width,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _FieldShell(
        label: label,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final double width;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.width,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _FieldShell(
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? "dd-mm-yyyy" : value,
                  style: TextStyle(
                    color: value.isEmpty ? AppPalette.textSecondary : AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String label;
  final double width;
  final TextEditingController controller;

  const _SearchField({
    required this.label,
    required this.width,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _FieldShell(
        label: label,
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Search invoice / member",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldShell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPalette.border),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const _GhostBtn({required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.secondary,
          side: const BorderSide(color: AppPalette.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ---------------------------- CONTENT ----------------------------
class _ContentSection extends GetView<Takefeescontroller> {
  final bool isMobile;
  const _ContentSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredInvoices.isEmpty) {
        return const _LoadingBox();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _ErrorBox(
          message: controller.errorMessage.value,
          onRetry: () => controller.fetchFees(reset: true),
        );
      }

      final rows = controller.filteredInvoices;
      if (rows.isEmpty) {
        return const _EmptyBox();
      }

      return isMobile ? _MobileList(rows: rows) : _DesktopTable(rows: rows);
    });
  }
}

class _DesktopTable extends GetView<Takefeescontroller> {
  final List rows;
  const _DesktopTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: DataTable(
              headingRowHeight: 56,
              dataRowMinHeight: 60,
              dataRowMaxHeight: 64,
              columnSpacing: 24,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.secondary),
              columns: const [
                DataColumn(label: Text("Invoice")),
                DataColumn(label: Text("Member")),
                DataColumn(label: Text("Duration")),
                DataColumn(label: Text("Amount"), numeric: true),
                DataColumn(label: Text("Due")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Actions")),
              ],
              rows: List.generate(rows.length, (i) {
                final inv = rows[i];
                final isPaid = inv.status.trim().toLowerCase() == "paid";
                return DataRow(
                  color: WidgetStatePropertyAll(i.isEven ? AppPalette.surface : AppPalette.background),
                  cells: [
                    DataCell(Text(inv.invoiceNo, style: const TextStyle(fontWeight: FontWeight.w900))),
                    DataCell(Text(inv.member)),
                    DataCell(Text(inv.duration)),
                    DataCell(Align(
                      alignment: Alignment.centerRight,
                      child: Text(inv.amountText, style: const TextStyle(fontWeight: FontWeight.w900)),
                    )),
                    DataCell(Text(inv.dueDateText)),
                    DataCell(_StatusPill(status: inv.status)),
                    DataCell(Row(
                      children: [
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () => controller.viewInvoice(inv),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(isPaid ? "View Details" : "Take Fees"),
                          ),
                        ),


                        // IconButton(
                        //   tooltip: "Delete",
                        //   onPressed: () => controller.deleteInvoice(inv),
                        //   icon: const Icon(Icons.delete_outline, color: Colors.red),
                        // ),
                      ],
                    )),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileList extends GetView<Takefeescontroller> {
  final List rows;
  const _MobileList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: rows.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // page already scrolls (CustomScrollView)
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final inv = rows[i];
        final isPaid = inv.status.trim().toLowerCase() == "paid";
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(inv.invoiceNo,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.secondary)),
                  ),
                  _StatusPill(status: inv.status),
                ],
              ),
              const SizedBox(height: 10),
              _kv("Member", inv.member),
              _kv("Duration", inv.duration),
              _kv("Due", inv.dueDateText),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(inv.amountText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => controller.viewInvoice(inv),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(isPaid ? "View Details" : "Take Fees"),
                    ),
                  ),

                  // IconButton(
                  //   tooltip: "Delete",
                  //   onPressed: () => controller.deleteInvoice(inv),
                  //   icon: const Icon(Icons.delete_outline, color: Colors.red),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(k, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.trim().toLowerCase();
    final isPaid = s == "paid";
    final color = isPaid ? const Color(0xFF10C25B) : const Color(0xFFFFC107);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? "Pending" : status,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }
}

// ---------------------------- STATES ----------------------------
class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: const Center(
        child: Text("No invoices found", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Failed to load", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
