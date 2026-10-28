import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/controller/feescontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/fee_receipt.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class FeesView extends StatelessWidget {
  FeesView({super.key});

  final FeesController c = Get.put(FeesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: simpleAppBar('My Fees'),
      body: Obx(() {
        if (c.isLoading.value && c.fees.isEmpty) return const LoadingView();
        if (c.error.value.isNotEmpty && c.fees.isEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchFees);
        }
        if (c.fees.isEmpty) {
          return EmptyView(
            icon: Icons.receipt_long_rounded,
            title: 'No fee records yet',
            subtitle: 'Your invoices and payments will show up here once the gym adds them.',
            onRefresh: c.fetchFees,
          );
        }
        return RefreshIndicator(
          color: AppPalette.secondary,
          onRefresh: c.fetchFees,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _Summary(c: c),
              const SizedBox(height: 22),
              SectionHeader('Invoices (${c.fees.length})'),
              for (final f in c.fees)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FeeCard(f: f),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Summary extends StatelessWidget {
  final FeesController c;
  const _Summary({required this.c});

  @override
  Widget build(BuildContext context) {
    final total = c.total;
    final paidShare = total > 0 ? (c.paid / total).clamp(0.0, 1.0) : 0.0;
    return AppCard(
      gradient: AppPalette.headerGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Outstanding balance', style: appText(12.5, color: AppPalette.textSecondary)),
          const SizedBox(height: 4),
          Text(fmtMoney(c.balance),
              style: appText(30,
                  weight: FontWeight.w700,
                  color: c.balance > 0 ? Colors.white : AppPalette.success)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: paidShare,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: AppPalette.success,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('Total', fmtMoney(total)),
              _stat('Paid', fmtMoney(c.paid), color: AppPalette.success),
              _stat('Pending', '${c.pendingCount}',
                  color: c.pendingCount > 0 ? AppPalette.warning : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: appText(11, color: AppPalette.textSecondary)),
            const SizedBox(height: 2),
            Text(value,
                style: appText(14, weight: FontWeight.w700, color: color ?? Colors.white)),
          ],
        ),
      );
}

class _FeeCard extends StatelessWidget {
  final FeeItem f;
  const _FeeCard({required this.f});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (f.isPaid) {
      color = AppPalette.success;
      label = 'PAID';
    } else if (f.isPartial) {
      color = AppPalette.warning;
      label = 'PARTIAL';
    } else {
      color = AppPalette.error;
      label = (f.status ?? 'DUE').toUpperCase();
    }

    final period = [
      if (f.durationType != null) f.durationType!,
      if (f.monthNumber != null) 'Month ${f.monthNumber}',
    ].join(' • ');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.receipt_long_rounded, color: color, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.title ?? (f.invoiceNumber != null ? 'Invoice ${f.invoiceNumber}' : 'Fee'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appText(14.5, weight: FontWeight.w600)),
                    if (period.isNotEmpty || (f.title != null && f.invoiceNumber != null))
                      Text(
                        [if (f.title != null && f.invoiceNumber != null) '#${f.invoiceNumber}', if (period.isNotEmpty) period].join('  •  '),
                        style: appText(11.5, color: AppPalette.textSecondary),
                      ),
                  ],
                ),
              ),
              StatusChip(label: label, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _kv('Amount', fmtMoney(f.amount)),
              _kv('Paid', fmtMoney(f.paidAmount)),
              _kv('Balance', fmtMoney(f.balanceAmount < 0 ? 0 : f.balanceAmount),
                  color: f.balanceAmount > 0 ? AppPalette.warning : null),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppPalette.border),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 14, color: AppPalette.textSecondary),
              const SizedBox(width: 6),
              Text(
                f.isPaid && f.paidDate != null
                    ? 'Paid on ${fmtDate(f.paidDate)}'
                    : 'Due ${fmtDate(f.dueDate)}',
                style: appText(11.5, color: AppPalette.textSecondary),
              ),
              const Spacer(),
              if (f.paymentMethod != null)
                Text(f.paymentMethod!.toUpperCase(),
                    style: appText(11, weight: FontWeight.w600, color: AppPalette.secondary)),
            ],
          ),
          if (f.notes != null) ...[
            const SizedBox(height: 8),
            Text(f.notes!, style: appText(11.5, color: AppPalette.textSecondary)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _action(Icons.picture_as_pdf_rounded,
                    f.isPaid || f.isPartial ? 'View receipt' : 'View invoice',
                    () => FeeReceipt.open(f)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _action(Icons.share_rounded, 'Share', () => FeeReceipt.share(f))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17, color: AppPalette.secondary),
        label: Text(label, style: appText(12, weight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: const BorderSide(color: AppPalette.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _kv(String k, String v, {Color? color}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: appText(11, color: AppPalette.textSecondary)),
            const SizedBox(height: 2),
            Text(v, style: appText(13.5, weight: FontWeight.w600, color: color ?? Colors.white)),
          ],
        ),
      );
}
