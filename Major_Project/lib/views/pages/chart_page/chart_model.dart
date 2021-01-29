import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:major_project/models/post_model.dart';

class LikesChart extends StatefulWidget {
  final List<Likes> likes;
  LikesChart({Key key, this.likes}) : super(key: key);
  @override
  _LikesChartState createState() => _LikesChartState();
}

class _LikesChartState extends State<LikesChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "charts.likes")),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 500.0,
          child: charts.BarChart(
            [
              charts.Series<Likes, String>(
                id: 'Number of Votes',
                colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                domainFn: (Likes likes, _) => likes.body.length >= 15
                    ? '${likes.body.substring(0, 15)}...'
                    : likes.body,
                measureFn: (Likes likes, _) => likes.likes,
                data: _calculateLikes(),
              ),
            ],
            animate: true,
            vertical: false,
          ),
        ),
      ),
    );
  }

  List<Likes> _calculateLikes() {
    List<Likes> likesData = [];
    for (Likes like in widget.likes) {
      likesData.add(like);
    }
    return likesData;
  }
}
