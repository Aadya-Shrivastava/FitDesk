import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/viewmembershipcontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class MembershipViewPage extends StatelessWidget {
  MembershipViewPage({super.key});

  final ViewMembershipController controller = Get.isRegistered<ViewMembershipController>()
      ? Get.find<ViewMembershipController>()
      : Get.put(ViewMembershipController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Membership List",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.refreshList,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== Header Row ======
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  _headerCell("Title", flex: 2),
                  _headerCell("Package", flex: 2),
                  _headerCell("Fee", flex: 2),
                  _headerCell("Classes", flex: 3),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ====== List ======
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.memberships.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.memberships.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshList,
                    child: ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No memberships found")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshList,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: controller.memberships.length + 1,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        if (index == controller.memberships.length) {
                          return Obx(() {
                            if (controller.isLoadingMore.value) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                        }

                        final m = controller.memberships[index];

                        final classText = (m.classes ?? [])
                            .map((c) => c.title ?? "")
                            .where((t) => t.trim().isNotEmpty)
                            .join(", ");

                        return InkWell(
                          onTap: () => controller.viewMembershipDetails(m),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  _cell(m.title ?? "-", flex: 2, bold: true),
                                  _cell(m.packageLabel ?? m.package ?? "-", flex: 2),
                                  _cell(_feeText(m), flex: 2),
                                  _cell(classText.isEmpty ? "-" : classText, flex: 3),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _feeText(m) {
    final withFee = m.withTrainerFee;
    final withoutFee = m.withoutTrainerFee;
    if (withFee != null && withoutFee != null) {
      return "₹$withFee / ₹$withoutFee";
    }
    return "₹${m.amount ?? 0}";
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _cell(String text, {required int flex, bool bold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
