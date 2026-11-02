import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:souqna_anaqa/utils/app_colors.dart';
import 'package:souqna_anaqa/widget/loading.dart';

/// صورة من الإنترنت مع تخزين مؤقت وهيكل تحميل لطيف.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.fit = BoxFit.contain,
    this.radius = 0,
    this.width,
    this.height,
  });

  final String? url;
  final BoxFit fit;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // 1. بناء الـ Placeholder بحيث يملأ المساحة المتاحة إذا لم تُحدد الأبعاد
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.sand,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.subtle),
    );

    final Widget image;
    if (url == null || url!.isEmpty) {
      image = placeholder;
    } else if (kIsWeb) {
      image = Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Skeleton(width: width, height: height),
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => Skeleton(width: width, height: height),
        errorWidget: (_, _, _) => placeholder,
      );
    }

    // 2. إذا لم يتم تحديد العرض أو الارتفاع، نغلف الصورة بـ SizedBox.expand أو نتأكد من التوسع
    // وإلا نضع القيود المحددة
    final Widget sizedImage;
    if (width == null && height == null) {
      sizedImage = SizedBox.expand(child: image);
    } else {
      sizedImage = SizedBox(
        width: width,
        height: height,
        child: image,
      );
    }

    return radius == 0
        ? sizedImage
        : ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: sizedImage,
          );
  }
}