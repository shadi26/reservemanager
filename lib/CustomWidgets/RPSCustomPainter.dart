import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter{

  @override
  void paint(Canvas canvas, Size size) {



    // Layer 1

    Paint paint_fill_0 = Paint()
      ..color = const Color.fromARGB(255, 216, 95, 104)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width*0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;


    Path path_0 = Path();
    path_0.moveTo(size.width*0.5003000,size.height*0.2616143);
    path_0.cubicTo(size.width*0.2875667,size.height*0.2558143,size.width*0.2783667,size.height*0.6222857,size.width*0.2691667,size.height*0.7144143);
    path_0.quadraticBezierTo(size.width*0.2353000,size.height*0.7643714,size.width*-0.0000000,size.height*0.7059415);
    path_0.lineTo(size.width*-0.0016667,size.height*-0.0004217);
    path_0.lineTo(size.width*1.0008333,size.height*-0.0014286);
    path_0.lineTo(size.width*1.0005583,size.height*0.7064804);
    path_0.quadraticBezierTo(size.width*0.7635333,size.height*0.7641429,size.width*0.7319000,size.height*0.7148857);
    path_0.cubicTo(size.width*0.7220333,size.height*0.6219000,size.width*0.7185250,size.height*0.2648286,size.width*0.5003000,size.height*0.2616143);
    path_0.close();

    canvas.drawPath(path_0, paint_fill_0);


  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}