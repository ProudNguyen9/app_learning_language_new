import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/login_screen.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/register_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';

class Start_Screen extends StatefulWidget {
  const Start_Screen({super.key});

  @override
  State<Start_Screen> createState() => _Start_ScreenState();
}

class _Start_ScreenState extends State<Start_Screen> {
  final List<String> imgList = [
    'assets/xinchao.gif',
    'assets/gifdocsach.gif',
    'assets/gifintailieu.gif',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSetting.background,
      appBar: AppBar(
        backgroundColor: ColorSetting.background,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset('assets/logoapp.png', width: 50, height: 50),
            ),
            Text(
              ' Anh Lish',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ColorSetting.colorprimary,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(10),
                  Text(
                    'Học tiếng anh để làm gì ?',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: ColorSetting.colorprimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Học mọi lúc, mọi nơi với các bài học từ vựng, ngữ pháp và kỹ năng giao tiếp .Học để sau này không đói !',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: Duration(
                  seconds: 3,
                ), // thời gian giữa các ảnh
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
              items: imgList.map((path) => buildImage(path)).toList(),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: SizedBox(
                  height: 52,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "Đăng nhập",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorSetting.colorprimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Center(
                child: SizedBox(
                  height: 52,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSetting.colorprimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register_Screen(),
                        ),
                      );
                    },
                    child: Text(
                      "Đăng ký",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildImage(String path) => Container(
  margin: EdgeInsets.symmetric(horizontal: 5),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Gif(image: AssetImage(path), fps: 72, autostart: Autostart.loop),
  ),
);
