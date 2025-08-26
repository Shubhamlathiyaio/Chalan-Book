import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/extensions/context_extension.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final bool showLogo;
  final double? height;

  const LoadingWidget({
    super.key,
    required this.message,
    this.showLogo = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLogo) ...[
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_long,
                    size: 40.w,
                    color: context.colors.primary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
            CircularProgressIndicator(
              color: context.colors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
