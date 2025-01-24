part of 'media_meta_data_helper.dart';

const Map<String, String> _mimeToExtension = {
  // Image types
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif',
  'image/svg+xml': '.svg',
  'image/bmp': '.bmp',
  'image/tiff': '.tiff',
  'image/x-icon': '.ico',

  // Audio types
  'audio/mpeg': '.mp3',
  'audio/ogg': '.ogg',
  'audio/wav': '.wav',
  'audio/x-wav': '.wav',
  'audio/aac': '.aac',
  'audio/flac': '.flac',
  'audio/webm': '.weba',

  // Video types
  'video/mp4': '.mp4',
  'video/mpeg': '.mpeg',
  'video/x-msvideo': '.avi',
  'video/webm': '.webm',
  'video/x-flv': '.flv',
  'video/ogg': '.ogv',
  'video/quicktime': '.mov',
  'video/x-matroska': '.mkv',

  // Application types
  'application/pdf': '.pdf',
  'application/zip': '.zip',
  'application/x-rar-compressed': '.rar',
  'application/vnd.ms-powerpoint': '.ppt',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      '.pptx',
  'application/vnd.ms-excel': '.xls',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': '.xlsx',
  'application/msword': '.doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      '.docx',
  'application/vnd.oasis.opendocument.text': '.odt',
  'application/vnd.oasis.opendocument.spreadsheet': '.ods',
  'application/json': '.json',
  'application/javascript': '.js',
  'application/ld+json': '.jsonld',
  'application/x-httpd-php': '.php',
  'application/xml': '.xml',
  'application/xhtml+xml': '.xhtml',
  'application/x-shockwave-flash': '.swf',
  'application/sql': '.sql',
  'application/x-7z-compressed': '.7z',
  'application/vnd.android.package-archive': '.apk',
  'application/x-tar': '.tar',

  // Text types
  'text/html': '.html',
  'text/css': '.css',
  'text/javascript': '.js',
  'text/plain': '.txt',
  'text/markdown': '.md',
  'text/xml': '.xml',

  // Font types
  'font/otf': '.otf',
  'font/ttf': '.ttf',
  'font/woff': '.woff',
  'font/woff2': '.woff2',

  // Archive formats
  'application/x-bzip': '.bz',
  'application/x-bzip2': '.bz2',
  'application/gzip': '.gz',

  // Other formats
  'application/octet-stream': '',
  'application/vnd.visio': '.vsd',
  'application/x-dvi': '.dvi',
  'application/x-font-ttf': '.ttf',
  'application/x-sh': '.sh',
  'application/x-sqlite3': '.sqlite',
  'application/x-java-archive': '.jar',
};

const List<String> _imageExtensions = [
  'jpg',
  'jpeg',
  'png',
  'gif',
  'bmp',
  'webp',
  'svg'
];

const List<String> _videoExtensions = [
  'mp4',
  'avi',
  'mov',
  'mkv',
  'flv',
  'wmv',
  'webm',
  '3gp'
];

const List<String> _audioExtensions = [
  'mp3',
  'wav',
  'flac',
  'aac',
  'ogg',
  'm4a',
  'wma',
  'aiff',
  'alac',
  'opus',
  'pcm',
  'webm'
];
