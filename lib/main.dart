import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:share/share.dart';

var T, A, W = {}, C = {}, G = false, tM = false, bP = false, sTF = sT();

sT() => DateTime.now().millisecondsSinceEpoch;
ln(x, y) => sqrt(x * x + y * y);
sc() => ((sT() - sTF) / 1000).toStringAsFixed(1);
gr(a, List<double> b) => LinearGradient(colors: a, stops: b);

main() async {
  if (W.isEmpty) {
    var jn = await rootBundle.loadString('assets/${C['ch'] ?? 7}.json');
    json.decode(jn).forEach((_) => W[_['type']] = _);
    C = W['_'];
    W.remove('_');
    A ??= await AudioCache().loop(C['mp3']);
  }
  runApp(App());
  if (G && T == null)
    T = Timer.periodic(Duration(milliseconds: 30), (_) => runApp(t() ?? App()));
}

class App extends StatelessWidget {
  build(_) {
    var gsdt = GestureDetector(
      child: LayoutBuilder(builder: (_, c) {
        var mw = c.maxWidth, mh = c.maxHeight;
        if (C['X'] < 1.1) {
          C['X'] *= mw;
          C['Y'] *= mh;
          W.values.forEach((v) {
            if (v['x'] < 1.1) {
              v['x'] *= mw;
              v['y'] *= mh;
            }
          });
        }
        var tm = FlatButton(
          padding: EdgeInsets.only(left: 0, top: mh * 0.95),
          child: Text(sc(), style: TextStyle(color: Colors.grey)),
          onPressed: null,
        );
        return G
            ? Container(color: Colors.black, child: Stack(children: w() + [tm]))
            : tM
                ? Image.asset('assets/tM.png')
                : Image.asset('assets/${C['ch'] ?? 1}-${C['page'] ?? 1}.png');
      }),
      onTapUp: (_) {
        if (C['last'] && C['page'] == 'last') return;
        if (tM) {
          tM = false;
          G = true;
        } else if (C['page'] == C['pages'] || C['page'] is String) {
          C['X'] = G ? _.globalPosition.dx : C['X'];
          C['Y'] = G ? _.globalPosition.dy : C['Y'];
          G = true;
        } else {
          C['page'] += 1;
        }
        main();
      },
      onLongPress: () => Share.share(C['msg'] + sc()),
    );
    return MaterialApp(theme: ThemeData(canvasColor: Colors.black), home: gsdt);
  }
}

w() {
  return W.values.map<Widget>((v) {
    var bs = v['sh']
        .sublist(0, v['sh+'] + 1)
        .map<BoxShadow>((sh) => BoxShadow(
            color: Color(sh['c']),
            offset: Offset(sh['o1'], sh['o2']),
            blurRadius: sh['b'],
            spreadRadius: sh['s']))
        .toList();
    var obj = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gr([Color(v['grad1c']), Color(v['grad2c'])],
            [v['grad1s'], v['grad2s']]),
        boxShadow: bs,
      ),
      transform: Matrix4.identity()
        ..rotateX(v['rx'])
        ..rotateY(v['ry']),
      child: Container(
        width: v['r'],
        height: v['r'],
        child: Icon(IconData(v['icon'], fontFamily: 'MaterialIcons'),
            size: v['iconsize'], color: Color(v['iconcolor'])),
      ),
    );

    var rt = Transform.rotate(
      angle: v['angle'],
      origin: Offset(v['offset1'], v['offset2']),
      child: obj,
    );
    return Positioned(
      left: v['x'],
      top: v['y'],
      child: rt,
    );
  }).toList();
}

t([$, _]) {
  for (var v in W.values) {
    var xd = (($ ?? {})['x'] ?? C['X']) - v['x'],
        yd = (($ ?? {})['y'] ?? C['Y']) - v['y'],
        lnn = ln(xd, yd);

    v['rx'] += v['rx+'];
    v['ry'] += v['ry+'];
    v['angle'] += v['angle+'];

    if (v['type'] == 'pl' && C['X'] > 0) {
      $ = v;
      $['sh+'] = lnn > 10 ? 1 : 0;
      $['x'] += xd * 0.05 * $['sh+'];
      $['y'] += yd * 0.05 * $['sh+'];
    }

    if (v['type'] == 'badpl' && C['X'] > 0 && bP) {
      _ = v;
      _['x'] += xd * 0.01 * C['ch'];
      _['y'] += yd * 0.01 * C['ch'];
      if (lnn < 20 && $['angle+'] == 0) {
        _['x'] = $['x'] - 50;
        _['y'] = $['y'] - 50;
        tM = true;
        bP = G = !tM;
        sTF -= 10000;
      }
    }

    if (v['picked'] != null && v['picked'] == false && lnn <= 10) {
      v['picked'] = bP = true;
      v['icon'] = 0;
      v['sh'][0] = v['sh'][1];
      ++W['pla']['sh+'];
      C['topick'] -= 1;
    }

    if (v['type'] == 'pla' && lnn <= v['r'] * 1.3 && $ != null) {
      $['r'] -= 0.5;
      $['angle+'] = 0.1;
      $['offset1'] = 4.0;

      if ($['r'] < 0) {
        $['x'] = v['x'] + v['r'] * 1.5;
        $['angle+'] = $['offset1'] = 0.0;
        $['r'] = $['r0'];
        $['sh'] = $['sh0'];
        C['X'] = C['Y'] = $['sh+'] = 0;
        C['page'] = v['type'];

        if (C['topick'] == 0) {
          W = {};
          C['page'] = C['last'] ? 'last' : 1;
          C['ch'] += 1;
          bP = false;
        }

        G = false;
        T.cancel();
        T = null;
      }
    }
  }
}
