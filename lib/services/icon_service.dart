import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class IconService {
  static final Map<String, Uint8List?> _cache = {};

  static Future<Uint8List?> getAppIcon(String lnkPath) async {
    if (_cache.containsKey(lnkPath)) return _cache[lnkPath];

    final safePath = lnkPath.replaceAll("'", "''");
    final script = '''
\$ErrorActionPreference = 'SilentlyContinue'
\$shell = New-Object -ComObject WScript.Shell
\$sc = \$shell.CreateShortcut('$safePath')
\$target = \$sc.TargetPath
if (\$target -and (Test-Path \$target)) {
  Add-Type -AssemblyName System.Drawing
  \$icon = [System.Drawing.Icon]::ExtractAssociatedIcon(\$target)
  if (\$icon) {
    \$bmp = \$icon.ToBitmap()
    \$ms = [System.IO.MemoryStream]::new()
    \$bmp.Save(\$ms, [System.Drawing.Imaging.ImageFormat]::Png)
    [Convert]::ToBase64String(\$ms.ToArray())
  }
}
''';

    try {
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-WindowStyle', 'Hidden', '-Command', script],
      );
      final output = (result.stdout as String).trim();
      if (output.isEmpty) {
        _cache[lnkPath] = null;
        return null;
      }
      final bytes = base64Decode(output);
      _cache[lnkPath] = bytes;
      return bytes;
    } catch (_) {
      _cache[lnkPath] = null;
      return null;
    }
  }
}
