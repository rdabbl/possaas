import 'dart:io';
import 'package:pos_printer_manager/helpers/network_analyzer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';

class NetworkService {}

Future<List<String>> findNetworkPrinter({int port = 9100}) async {
  String? ip = await _getPreferredLocalIp();
  if (ip == null || ip.isEmpty) {
    return <String>[];
  }
  PosPrinterManager.logger.info("ip: $ip");
  final String subnet = ip.substring(0, ip.lastIndexOf('.'));
  PosPrinterManager.logger.info("subnet: $subnet");

  final stream = NetworkAnalyzer.discover2(subnet, port);
  var results = await stream.toList();
  return [...results.where((entry) => entry.exists).map((e) => e.ip)];
}

Future<List<String>> getAddresses() async {
  final interfaces = await NetworkInterface.list();
  final results = <String>[];
  for (final interface in interfaces) {
    results.addAll(interface.addresses.map((address) => address.address));
  }
  return results;
}

Future<String?> _getPreferredLocalIp() async {
  final addresses = await getAddresses();
  for (final address in addresses) {
    if (address.contains('.') &&
        !address.startsWith('127.') &&
        !address.startsWith('169.254.')) {
      return address;
    }
  }
  return addresses.isNotEmpty ? addresses.first : null;
}
