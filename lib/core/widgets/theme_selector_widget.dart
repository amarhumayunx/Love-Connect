// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:love_connect/core/colors/app_colors.dart';
// import 'package:love_connect/core/services/theme_service.dart';
// import 'package:love_connect/core/utils/media_query_extensions.dart';
//
// /// Widget for selecting theme mode and love color
// class ThemeSelectorWidget extends StatelessWidget {
//   const ThemeSelectorWidget({super.key});
//
//   static void show(BuildContext context) {
//     Get.dialog(
//       Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.symmetric(
//           horizontal: context.widthPct(5),
//           vertical: context.heightPct(10),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(24),
//           ),
//           padding: EdgeInsets.all(context.responsiveSpacing(24)),
//           child: const ThemeSelectorWidget(),
//         ),
//       ),
//       barrierDismissible: true,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeService = Get.find<ThemeService>();
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Title
//         Text(
//           'Customize Theme',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.inter(
//             fontSize: context.responsiveFont(24),
//             fontWeight: FontWeight.w700,
//             color: AppColors.primaryDark,
//           ),
//         ),
//         SizedBox(height: context.responsiveSpacing(8)),
//         Text(
//           'Choose your perfect love theme',
//           textAlign: TextAlign.center,
//           style: GoogleFonts.inter(
//             fontSize: context.responsiveFont(14),
//             fontWeight: FontWeight.w400,
//             color: AppColors.textLightPink,
//           ),
//         ),
//         SizedBox(height: context.responsiveSpacing(32)),
//
//         // Love Color Selection
//         Text(
//           'Love Color',
//           style: GoogleFonts.inter(
//             fontSize: context.responsiveFont(16),
//             fontWeight: FontWeight.w600,
//             color: AppColors.primaryDark,
//           ),
//         ),
//         SizedBox(height: context.responsiveSpacing(12)),
//         Obx(
//           () => Wrap(
//             spacing: context.responsiveSpacing(12),
//             runSpacing: context.responsiveSpacing(12),
//             children: LoveColor.values.map((color) {
//               final isSelected = themeService.loveColor.value == color;
//               return GestureDetector(
//                 onTap: () => themeService.setLoveColor(color),
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: color.color,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.primaryDark
//                           : Colors.transparent,
//                       width: 3,
//                     ),
//                     boxShadow: isSelected
//                         ? [
//                             BoxShadow(
//                               color: color.color.withOpacity(0.5),
//                               blurRadius: 12,
//                               spreadRadius: 2,
//                             ),
//                           ]
//                         : null,
//                   ),
//                   child: isSelected
//                       ? Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: context.responsiveImage(24),
//                         )
//                       : null,
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         SizedBox(height: context.responsiveSpacing(8)),
//         Obx(
//           () => Text(
//             themeService.loveColor.value.displayName,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.inter(
//               fontSize: context.responsiveFont(14),
//               fontWeight: FontWeight.w500,
//               color: AppColors.textLightPink,
//             ),
//           ),
//         ),
//
//         SizedBox(height: context.responsiveSpacing(32)),
//
//         // Close Button
//         ElevatedButton(
//           onPressed: () => Get.back(),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryRed,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: EdgeInsets.symmetric(
//               vertical: context.responsiveSpacing(14),
//             ),
//           ),
//           child: Text(
//             'Done',
//             style: GoogleFonts.inter(
//               fontSize: context.responsiveFont(16),
//               fontWeight: FontWeight.w600,
//               color: AppColors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
// }
