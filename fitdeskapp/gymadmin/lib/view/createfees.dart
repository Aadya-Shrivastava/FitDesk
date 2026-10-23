import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/controller/createfesscontroller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class Createfees extends GetView<Createfesscontroller> {
  const Createfees({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Create Fee',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        // actions: [
        //   Container(
        //     height: 40,
        //     margin: const EdgeInsets.only(right: 8),
        //     child: ElevatedButton(
        //       onPressed: () => Get.toNamed(RouteName.viewfees),
        //       style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        //       child: Text(
        //         'View Fees',
        //         style: GoogleFonts.poppins(
        //           fontWeight: FontWeight.w600,
        //           color: AppPalette.primary,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Fee Details',
                    subtitle: 'Select member and fee duration.',
                    child: Column(
                      children: [
                        _buildMemberDropdown(),
                        _errorText('member'),
                        const SizedBox(height: 12),

                        _buildDurationDropdown(),
                        _errorText('duration'),
                        const SizedBox(height: 12),

                        if (controller.durationType.value == 'monthly')
                          _buildMonthDropdown(),
                        if (controller.durationType.value == 'monthly')
                          _errorText('month'),
                        if (controller.durationType.value == 'monthly')
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Amount & Due Date',
                    subtitle: 'Confirm amount and due date for the fee.',
                    child: Column(
                      children: [
                        _buildAmountField(),
                        _errorText('amount'),
                        const SizedBox(height: 12),

                        _buildDueDateField(),
                        _errorText('dueDate'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Notes',
                    subtitle: 'Optional notes for internal reference.',
                    child: _buildNotesField(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppPalette.primary,
                            side: const BorderSide(color: AppPalette.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.createFee,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Create Fee'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorText(String key) {
    final msg = controller.fieldErrors[key];
    if (msg == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          msg,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildMemberDropdown() {
    return InputDecorator(
      decoration: _inputDecoration(label: 'Select Member'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: controller.selectedMemberId.value,
          items: controller.members
              .map(
                (m) => DropdownMenuItem<int>(
                  value: m['id'] as int,
                  child: Text(m['name'] ?? '-'),
                ),
              )
              .toList(),
          onChanged: controller.onMemberChanged,
          hint: const Text('-- Select Member --'),
        ),
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return InputDecorator(
      decoration: _inputDecoration(label: 'Duration Type'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: controller.durationType.value,
          items: controller.durationTypes
              .map(
                (d) => DropdownMenuItem<String>(
                  value: d['key'] as String,
                  child: Text(d['label'] as String),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.onDurationChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return InputDecorator(
      decoration: _inputDecoration(label: 'Month'),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: controller.selectedMonth.value,
          items: controller.months
              .map(
                (m) => DropdownMenuItem<int>(
                  value: m['key'] as int,
                  child: Text(m['label'] as String),
                ),
              )
              .toList(),
          onChanged: controller.onMonthChanged,
          hint: const Text('-- Select Month --'),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label: 'Amount', prefix: 'Rs '),
      onChanged: (v) {
        controller.amount.value = v;
        controller.clearError('amount');
      },
    );
  }

  Widget _buildDueDateField() {
    final enabled = controller.durationType.value == 'one-time';
    return InkWell(
      onTap: enabled ? controller.pickDate : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Date',
          border: const OutlineInputBorder(),
          enabled: enabled,
        ),
        child: Text(
          controller.dueDate.value.isEmpty
              ? 'yyyy-mm-dd'
              : controller.dueDate.value,
          style: TextStyle(
            color: enabled ? AppPalette.textPrimary : AppPalette.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      maxLines: 3,
      decoration: _inputDecoration(label: 'Notes'),
      onChanged: (v) => controller.notes.value = v,
    );
  }

  InputDecoration _inputDecoration({required String label, String? prefix}) {
    return InputDecoration(
      labelText: label,
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
        borderSide: const BorderSide(color: AppPalette.primary, width: 1.2),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}