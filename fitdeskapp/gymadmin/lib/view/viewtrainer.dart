import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';


class ViewTrainersPage extends StatelessWidget {
  final ViewTrainerController c = Get.find<ViewTrainerController>();

  ViewTrainersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trainers", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => c.fetchTrainers(page: 1),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.error.value.isNotEmpty) {
          return _ErrorState(
            message: c.error.value,
            onRetry: () => c.fetchTrainers(page: 1),
          );
        }

        if (c.trainers.isEmpty) {
          return _EmptyState(onRefresh: () => c.fetchTrainers(page: 1));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.trainers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final t = c.trainers[i];
            return _TrainerCard(
              name: t.name ?? "-",
              email: t.email ?? "-",
              phone: t.phoneNumber ?? "-",
              qualification: t.qualification ?? "-",
              gender: t.gender ?? "-",
              dob: t.dob ?? "-",
              address: _formatAddress(t),
              isActive: (t.isActive ?? 0) == 1,
              profileUrl: c.toAbsoluteUrl(t.profile),
              hasDocument: (t.document ?? "").trim().isNotEmpty,
              onDownloadOpen: () => c.downloadAndOpenDocument(t),
              onShareDoc: () => c.downloadAndShareDocument(t),
              onViewProfile: () {
                final url = c.toAbsoluteUrl(t.profile);
                if (url.isEmpty) return;
                Get.to(() => _ImagePreview(url: url, title: t.name ?? "Profile"));
              },
              onViewDetails: () => _showTrainerDetails(t),
            );
          },
        );
      }),
    );
  }

  void _showTrainerDetails(dynamic t) {
    Get.defaultDialog(
      title: "Trainer Details",
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420, maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: "Name", value: t.name ?? "-"),
              _DetailRow(label: "Email", value: t.email ?? "-"),
              _DetailRow(label: "Phone", value: t.phoneNumber ?? "-"),
              _DetailRow(label: "Gender", value: t.gender ?? "-"),
              _DetailRow(label: "DOB", value: t.dob ?? "-"),
              _DetailRow(label: "Qualification", value: t.qualification ?? "-"),
              _DetailRow(label: "Address", value: _formatAddress(t)),
              _DetailRow(label: "Status", value: (t.isActive ?? 0) == 1 ? "Active" : "Inactive"),
              _DetailRow(label: "Trainer ID", value: t.trainerId?.toString() ?? "-"),
              _DetailRow(label: "Created At", value: t.createdAt ?? "-"),
            ],
          ),
        ),
      ),
      textConfirm: "Close",
      confirmTextColor: Colors.white,
      buttonColor: AppPalette.primary,
      onConfirm: () => Get.back(),
    );
  }

  String _formatAddress(dynamic t) {
    final parts = [
      t.address,
      t.city,
      t.state,
      t.country,
      t.zipCode,
    ].where((e) => (e ?? "").toString().trim().isNotEmpty).toList();
    if (parts.isEmpty) return "-";
    return parts.join(", ");
  }
}

class _TrainerCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String qualification;
  final String gender;
  final String dob;
  final String address;
  final bool isActive;
  final String profileUrl;
  final bool hasDocument;

  final VoidCallback onDownloadOpen;
  final VoidCallback onShareDoc;
  final VoidCallback onViewProfile;
  final VoidCallback onViewDetails;

  const _TrainerCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.qualification,
    required this.gender,
    required this.dob,
    required this.address,
    required this.isActive,
    required this.profileUrl,
    required this.hasDocument,
    required this.onDownloadOpen,
    required this.onShareDoc,
    required this.onViewProfile,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                GestureDetector(
                  onTap: onViewProfile,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppPalette.surface,
                    backgroundImage: profileUrl.isEmpty
                        ? null
                        : NetworkImage(profileUrl),
                    child: profileUrl.isEmpty
                        ? const Icon(Icons.person, size: 26)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(email,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppPalette.textSecondary)),
                      const SizedBox(height: 2),
                      Text(phone,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppPalette.textSecondary)),
                    ],
                  ),
                ),
                _StatusChip(isActive: isActive),
              ],
            ),

            const SizedBox(height: 12),
            _InfoRow(label: "Qualification", value: qualification),
            _InfoRow(label: "Gender", value: gender),
            _InfoRow(label: "DOB", value: dob),
            _InfoRow(label: "Address", value: address),

            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.info_outline),
              label: Text("View Details",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            ),

            const SizedBox(height: 12),
            Divider(color: AppPalette.border, height: 1),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasDocument ? onDownloadOpen : null,
                    icon: const Icon(Icons.download),
                    label: Text("Download / Open",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasDocument ? onShareDoc : null,
                    icon: const Icon(Icons.share),
                    label: Text("Share",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (!hasDocument) ...[
              const SizedBox(height: 8),
              Text(
                "No document uploaded",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent),
              )
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppPalette.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppPalette.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 60, color: AppPalette.textSecondary),
          const SizedBox(height: 10),
          Text("No trainers found",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text("Something went wrong",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: AppPalette.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String url;
  final String title;

  const _ImagePreview({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 60),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
