// import 'package:flutter/material.dart';
// import '../data/models/workshop_model.dart';
// import '../config/app_colors.dart';
//
// class WorkshopCard extends StatelessWidget {
//   final WorkshopModel workshop;
//   final VoidCallback onTap;
//   final bool isOwner;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;
//   final VoidCallback? onViewLocation;
//   final VoidCallback? onMessage;
//
//   const WorkshopCard({
//     super.key,
//     required this.workshop,
//     required this.onTap,
//     this.isOwner = false,
//     this.onEdit,
//     this.onDelete,
//     this.onViewLocation,
//     this.onMessage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       color: AppColors.cardBackground,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Row
//               Row(
//                 children: [
//                   // Workshop Image
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: AppColors.grey200,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: _buildWorkshopImage(),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Workshop Info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           workshop.name,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textPrimary,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.access_time,
//                               size: 16,
//                               color: AppColors.textSecondary,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 workshop.workingHours,
//                                 style: const TextStyle(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 12,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         _buildRatingRow(),
//                       ],
//                     ),
//                   ),
//
//                   // Action Menu
//                   if (isOwner)
//                     _buildOwnerMenu()
//                   else
//                     _buildUserActions(),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               // Description
//               Text(
//                 workshop.description,
//                 style: const TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 14,
//                   height: 1.4,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//
//               const SizedBox(height: 12),
//
//               // Location and Status Row
//               Row(
//                 children: [
//                   // Location
//                   Expanded(
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           size: 16,
//                           color: AppColors.primary,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             _getLocationText(),
//                             style: const TextStyle(
//                               color: AppColors.textSecondary,
//                               fontSize: 12,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Status Badge
//                   _buildStatusBadge(),
//                 ],
//               ),
//
//               // Action Buttons Row (for non-owners)
//               if (!isOwner) ...[
//                 const SizedBox(height: 16),
//                 _buildActionButtons(),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWorkshopImage() {
//     if (workshop.profileImage != null && workshop.profileImage!.isNotEmpty) {
//       return Image.network(
//         workshop.profileImage!,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildDefaultIcon();
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return const Center(
//             child: CircularProgressIndicator(
//               color: AppColors.primary,
//               strokeWidth: 2,
//             ),
//           );
//         },
//       );
//     } else {
//       return _buildDefaultIcon();
//     }
//   }
//
//   Widget _buildDefaultIcon() {
//     return Container(
//       color: AppColors.grey100,
//       child: const Icon(
//         Icons.business,
//         color: AppColors.grey400,
//         size: 30,
//       ),
//     );
//   }
//
//   Widget _buildRatingRow() {
//     return Row(
//       children: [
//         ...List.generate(5, (index) {
//           return Icon(
//             Icons.star,
//             size: 14,
//             color: index < 4 ? AppColors.warning : AppColors.grey300,
//           );
//         }),
//         const SizedBox(width: 4),
//         const Text(
//           '4.5',
//           style: TextStyle(
//             color: AppColors.textSecondary,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(width: 2),
//         const Text(
//           '(24)',
//           style: TextStyle(
//             color: AppColors.textHint,
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOwnerMenu() {
//     return PopupMenuButton<String>(
//       onSelected: (value) {
//         switch (value) {
//           case 'edit':
//             if (onEdit != null) onEdit!();
//             break;
//           case 'delete':
//             if (onDelete != null) onDelete!();
//             break;
//           case 'location':
//             if (onViewLocation != null) onViewLocation!();
//             break;
//         }
//       },
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'edit',
//           child: Row(
//             children: [
//               Icon(Icons.edit, size: 16, color: AppColors.info),
//               SizedBox(width: 8),
//               Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'location',
//           child: Row(
//             children: [
//               Icon(Icons.location_on, size: 16, color: AppColors.success),
//               SizedBox(width: 8),
//               Text('View Location', style: TextStyle(color: AppColors.textPrimary)),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'delete',
//           child: Row(
//             children: [
//               Icon(Icons.delete, size: 16, color: AppColors.error),
//               SizedBox(width: 8),
//               Text('Delete', style: TextStyle(color: AppColors.error)),
//             ],
//           ),
//         ),
//       ],
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppColors.grey100,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: const Icon(
//           Icons.more_vert,
//           size: 18,
//           color: AppColors.textSecondary,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserActions() {
//     return Column(
//       children: [
//         if (onMessage != null)
//           GestureDetector(
//             onTap: onMessage,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryWithOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(
//                 Icons.message,
//                 size: 18,
//                 color: AppColors.primary,
//               ),
//             ),
//           ),
//         if (onViewLocation != null) ...[
//           const SizedBox(height: 4),
//           GestureDetector(
//             onTap: onViewLocation,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColors.info.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(
//                 Icons.location_on,
//                 size: 18,
//                 color: AppColors.info,
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildStatusBadge() {
//     bool isOpen = _isWorkshopOpen();
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: isOpen ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isOpen ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(
//               color: isOpen ? AppColors.success : AppColors.error,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             isOpen ? 'Open' : 'Closed',
//             style: TextStyle(
//               color: isOpen ? AppColors.success : AppColors.error,
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Row(
//       children: [
//         if (onViewLocation != null)
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: onViewLocation,
//               icon: const Icon(Icons.location_on, size: 16),
//               label: const Text('Location'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: AppColors.info,
//                 side: const BorderSide(color: AppColors.info),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         if (onViewLocation != null && onMessage != null)
//           const SizedBox(width: 12),
//         if (onMessage != null)
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed: onMessage,
//               icon: const Icon(Icons.message, size: 16),
//               label: const Text('Message'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: AppColors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   String _getLocationText() {
//     if (workshop.latitude == 0.0 && workshop.longitude == 0.0) {
//       return 'Location not set';
//     }
//     return 'Lat: ${workshop.latitude.toStringAsFixed(4)}, Lng: ${workshop.longitude.toStringAsFixed(4)}';
//   }
//
//   bool _isWorkshopOpen() {
//     // Simple logic - in a real app you would parse the working hours
//     // and check against current time
//     final now = DateTime.now();
//     final currentHour = now.hour;
//
//     // Assume most workshops are open between 8 AM and 6 PM
//     return currentHour >= 8 && currentHour < 18;
//   }
// }