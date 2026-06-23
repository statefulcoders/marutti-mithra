
import 'package:flutter/cupertino.dart';

import '../configs/backend/marutti_backend_configs.dart';

void tradeWarning(dynamic message, {String? tag}) {
  _log(LogLevel.warning, (tag == null || tag.isEmpty) ? null : tag, message);
}

void tradeError(dynamic message, {String? tag}) {
  _log(LogLevel.error, (tag == null || tag.isEmpty) ? null : tag, message);
}

void tradeInfo(dynamic message, {String? tag}) {
  _log(LogLevel.info, (tag == null || tag.isEmpty) ? null : tag, message);
}

void tradeDebug(dynamic message, {String? tag}) {
  _log(LogLevel.debug, (tag == null || tag.isEmpty) ? null : tag, message);
}

void _log(LogLevel level, String? tag, dynamic message) {
  if (MaruttiBackendConfigs.enableLogging && level.level <= MaruttiBackendConfigs.logLevel.level) {
    String detailedMessage = '[${level.name}]';
    if (tag != null) {
      detailedMessage += ' ($tag)';
    }
    detailedMessage += ': $message';
    detailedMessage += ' (${MaruttiBackendConfigs.logTag})';
    debugPrint(detailedMessage);
  }

}

enum LogLevel {
  error('ERROR', 0), warning('WARNING', 1), info('INFO', 2), debug('DEBUG', 3);

  final int level;
  final String _name;

  const LogLevel(this._name, this.level);

  @override
  String toString() => _name;
}