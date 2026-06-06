import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const CPUMonitorApp());

class CPUMonitorApp extends StatelessWidget {
  const CPUMonitorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CPU监控', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true, brightness: Brightness.dark),
    home: const CPUHomePage(),
  );
}

class CPUHomePage extends StatefulWidget {
  const CPUHomePage({super.key});
  @override
  State<CPUHomePage> createState() => _CPUHomePageState();
}

class _CPUHomePageState extends State<CPUHomePage> {
  double _cpuUsage = 0;
  double _cpuTemp = 45;
  double _cpuFreq = 2.4;
  int _coreCount = 8;
  List<double> _history = [];
  List<double> _coreUsages = [];
  Timer? _timer;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _coreUsages = List.generate(_coreCount, (_) => 0.0);
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _cpuUsage = 20 + _rng.nextDouble() * 60;
        _cpuTemp = 40 + _rng.nextDouble() * 30;
        _cpuFreq = 1.8 + _rng.nextDouble() * 2.5;
        _history.add(_cpuUsage);
        if (_history.length > 60) _history.removeAt(0);
        _coreUsages = List.generate(_coreCount, (_) => 10 + _rng.nextDouble() * 80);
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Color _getColor(double value) {
    if (value < 50) return Colors.green;
    if (value < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 CPU监控'), centerTitle: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // CPU使用率仪表盘
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          SizedBox(width: 160, height: 160, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 160, height: 160, child: CircularProgressIndicator(value: _cpuUsage / 100, strokeWidth: 12, backgroundColor: Colors.grey.shade200, color: _getColor(_cpuUsage))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${_cpuUsage.toInt()}%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _getColor(_cpuUsage))),
              const Text('CPU使用率', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ])),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildInfo('温度', '${_cpuTemp.toInt()}°C', Icons.thermostat, _cpuTemp > 70 ? Colors.red : Colors.orange),
            _buildInfo('频率', '${_cpuFreq.toStringAsFixed(1)} GHz', Icons.speed, Colors.blue),
            _buildInfo('核心', '$_coreCount 核', Icons.memory, Colors.purple),
          ]),
        ]))),
        const SizedBox(height: 16),
        // 使用率曲线
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('使用率曲线 (60秒)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(height: 120, child: CustomPaint(painter: _ChartPainter(_history), size: Size.infinite)),
        ]))),
        const SizedBox(height: 16),
        // 各核心使用率
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('各核心使用率', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5), itemCount: _coreCount, itemBuilder: (ctx, i) {
            final usage = _coreUsages[i];
            return Container(decoration: BoxDecoration(color: _getColor(usage).withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _getColor(usage).withOpacity(0.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('核心 $i', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text('${usage.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: _getColor(usage))),
            ]));
          }),
        ]))),
        const SizedBox(height: 16),
        // 进程列表
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('占用最高的进程', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildProcess('flutter_app', '15.2%', Colors.blue),
          _buildProcess('browser', '12.8%', Colors.green),
          _buildProcess('system', '8.5%', Colors.orange),
          _buildProcess('antivirus', '6.2%', Colors.red),
          _buildProcess('editor', '4.8%', Colors.purple),
        ]))),
      ])),
    );
  }

  Widget _buildInfo(String label, String value, IconData icon, Color color) {
    return Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
  }

  Widget _buildProcess(String name, String usage, Color color) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
      Text(usage, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
    ]));
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.orange;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * size.width / 60;
      final y = size.height - (data[i] / 100 * size.height);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    // 网格线
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = i * size.height / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
