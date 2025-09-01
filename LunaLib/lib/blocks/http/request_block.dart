import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../core/app_configuration.dart';
import '../../parsing/interpolation_engine.dart';
import '../../parsing/line_parser.dart';
import '../../variables/variable.dart';
import '../../services/file_system_service.dart';
import 'multipart_content.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

/// HTTP Request block
class RequestBlock extends BlockInstance {
  String method = 'GET';
  String url = '';
  String content = '';
  String contentType = '';
  Map<String, String> headers = {};
  int timeout = 0;
  bool followRedirects = true;

  // Flags
  bool acceptEncoding = true;
  bool autoRedirect = true;
  bool readResponseSource = true;
  bool parseQuery = false;
  bool encodeContent = false;

  // Default headers
  Map<String, String> defaultHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36',
    'Pragma': 'no-cache',
    'Accept': '*/*'
  };

  // Request types
  String requestType = 'STANDARD'; // STANDARD, MULTIPART, BASICAUTH, RAW

  // Basic Auth
  String authUser = '';
  String authPass = '';

  // Raw request
  String rawData = '';

  // Multipart
  String multipartBoundary = '';
  List<MultipartContent> multipartContents = [];

  // Security
  String securityProtocol = 'SystemDefault';

  // Response handling
  String responseType = 'STRING'; // STRING, FILE, BASE64
  String downloadPath = '';
  String outputVariable = '';
  bool saveAsScreenshot = false;

  Map<String, String> customCookies = {};

  RequestBlock() : super(id: 'Request') {
    timeout = AppConfiguration.httpTimeout;
    followRedirects = AppConfiguration.followRedirects;
  }

  @override
  Future<void> execute(BotData data) async {
    try {
      // Interpolate URL
      final interpolatedUrl =
          InterpolationEngine.interpolate(url, data.variables, data);
      data.log(
          'REQUEST: Preparing to execute $method request to: $interpolatedUrl');

      // Log proxy status
      if (data.useProxy && data.proxy != null) {
        data.log(
            'REQUEST: Proxy configured: ${data.proxy!.host}:${data.proxy!.port} (${data.proxy!.type})');
      } else {
        data.log(
            'REQUEST: No proxy configured (useProxy=${data.useProxy}, proxy=${data.proxy})');
      }

      // Manual redirect handling
      var currentUrl = interpolatedUrl;
      var currentMethod = method;
      var redirectCount = 0;
      Response<List<int>>? response;
      final sessionCookies = <String, String>{};

      while (redirectCount <= AppConfiguration.maxRedirects) {
        final dio = Dio(BaseOptions(
          method: currentMethod,
          connectTimeout: Duration(milliseconds: timeout),
          receiveTimeout: Duration(milliseconds: timeout),
          sendTimeout: Duration(milliseconds: timeout),
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (status) => true,
          responseType: ResponseType.bytes,
          receiveDataWhenStatusError: true,
        ));

        // Configure HttpClient adapter
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.autoUncompress = true;
          client.userAgent = AppConfiguration.defaultUserAgent;

          // Configure proxy if needed
          if (data.useProxy && data.proxy != null) {
            client.findProxy = (uri) {
              return 'PROXY ${data.proxy!.host}:${data.proxy!.port}';
            };
            if (data.proxy!.username != null &&
                data.proxy!.username!.isNotEmpty) {
              client.authenticateProxy = (host, port, scheme, realm) {
                client.addProxyCredentials(
                  data.proxy!.host,
                  data.proxy!.port,
                  realm ?? '',
                  HttpClientBasicCredentials(
                    data.proxy!.username!,
                    data.proxy!.password ?? '',
                  ),
                );
                return Future.value(true);
              };
            }
          }

          return client;
        };

        // Get max redirects from config settings or fall back to environment default
        final maxRedirects =
            data.configSettings?.maxRedirects ?? AppConfiguration.maxRedirects;
        data.log(
            'REQUEST: Type=$requestType, Redirect=$redirectCount/$maxRedirects, Timeout=${timeout}ms');
        data.log('REQUEST: Current URL: $currentUrl');
        data.log(
            'REQUEST: Session cookies before request: ${sessionCookies.keys.toList()}');

        // Prepare request based on type
        switch (requestType) {
          case 'BASICAUTH':
            response = await _executeBasicAuth(
                currentMethod, dio, currentUrl, data, sessionCookies);
            break;
          case 'MULTIPART':
            response = await _executeMultipart(
                currentMethod, dio, currentUrl, data, sessionCookies);
            break;
          case 'RAW':
            response = await _executeRaw(
                currentMethod, dio, currentUrl, data, sessionCookies);
            break;
          default: // STANDARD
            response = await _executeStandard(
                currentMethod, dio, currentUrl, data, sessionCookies);
        }

        data.log('REQUEST: Response status code: ${response.statusCode}');
        data.log('REQUEST: Response real URI: ${response.realUri}');

        _extractAndStoreCookies(response, currentUrl, sessionCookies, data);

        // Check for redirect based on flags and status codes
        if ((autoRedirect || followRedirects)) {
          final decision = _computeRedirectDecision(
              response, currentUrl, currentMethod, data);
          if (decision != null) {
            data.log(
                'REQUEST: Current redirect count: $redirectCount/$maxRedirects');
            if (redirectCount < maxRedirects) {
              final originalUrl = currentUrl;
              currentUrl = decision.nextUrl;
              currentMethod = decision.nextMethod;
              if (decision.clearContent) {
                content = '';
                rawData = '';
                multipartContents.clear();
              }
              redirectCount++;
              data.log('REQUEST: Following redirect from: $originalUrl');
              data.log('REQUEST: Following redirect to: $currentUrl');
              data.log(
                  'REQUEST: Cookies being carried forward: ${sessionCookies.keys.toList()}');
              continue;
            } else {
              data.logWarning(
                  'REQUEST: Max redirects reached ($redirectCount/$maxRedirects)');
            }
          }
        }

        // No more redirects, break the loop
        break;
      }

      if (response == null) {
        throw Exception('No response received');
      }

      // Store response code and address
      data.responseCode = response.statusCode ?? 0;
      data.address = response.realUri.toString();

      data.log(
          'REQUEST: Response received - Status: ${response.statusCode} ${response.statusMessage}');
      data.log('REQUEST: Response size: ${response.data?.length ?? 0} bytes');

      // Log redirect information
      if (data.address != interpolatedUrl) {
        data.log(
            'REQUEST: Redirected from $interpolatedUrl to ${data.address}');
      }

      // Store response headers
      if (AppConfiguration.debugMode) {
        data.log('REQUEST: Response headers:');
      }
      response.headers.forEach((key, values) {
        final value = values.join(', ');
        data.headers[key] = value;
        if (AppConfiguration.debugMode) {
          data.log('  $key: $value');
        }
      });

      // Log received cookies
      if (AppConfiguration.debugMode) {
        data.log('REQUEST: Received cookies:');
        sessionCookies.forEach((key, value) {
          final end = value.length.clamp(0, 20);
          data.log('  $key: ${value.substring(0, end)}...');
        });
      }

      // Handle response based on responseType
      if (readResponseSource) {
        await _handleDioResponse(response, data);
        if (data.responseSource.contains('idsrv.xsrf')) {
          data.log(
              'REQUEST: Response contains XSRF token (good - this is from final URL)');
        } else if (data.responseSource.contains('signin=')) {
          data.log('REQUEST: Response contains signin parameter in body');
        } else {
          data.log(
              'REQUEST: Response snippet: ${data.responseSource.substring(0, 200.clamp(0, data.responseSource.length))}...');
        }
      } else {
        data.responseSource = '';
        data.log('Response source reading skipped');
      }

      data.log(
          'REQUEST $method ${response.statusCode} ${response.statusMessage} - ${response.data?.length ?? 0} bytes');
    } catch (e, stackTrace) {
      if (e is DioException) {
        data.logError('REQUEST failed: ${e.message}');
        if (e.response != null) {
          data.responseCode = e.response!.statusCode ?? 0;
          data.logError('Response status: ${e.response!.statusCode}');
        }
      } else {
        data.logError('REQUEST failed: $e');
      }
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _extractAndStoreCookies(
    Response<List<int>> response,
    String currentUrl,
    Map<String, String> sessionCookies,
    BotData data,
  ) {
    final setCookieHeaders = response.headers.map['set-cookie'];
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
      data.log('REQUEST: No Set-Cookie headers in response');
      return;
    }
    data.log('REQUEST: Extracting cookies from Set-Cookie headers');
    final currentUri = Uri.parse(currentUrl);
    final currentDomain = currentUri.host;
    data.log('REQUEST: Current domain: $currentDomain');

    for (final cookieHeader in setCookieHeaders) {
      data.log('REQUEST: Processing cookie header: $cookieHeader');
      try {
        final parts = cookieHeader.split(';');
        final nameValue = parts[0].split('=');
        if (nameValue.length < 2) continue;
        final name = nameValue[0].trim();
        final value = nameValue.sublist(1).join('=').trim();

        String? cookieDomain;
        String cookiePath = '/';

        for (final attr in parts.skip(1)) {
          final attrTrimmed = attr.trim();
          final attrParts = attrTrimmed.split('=');
          final attrName = attrParts[0].toLowerCase();
          if (attrName == 'domain' && attrParts.length > 1) {
            cookieDomain = attrParts[1].trim();
            if (cookieDomain.startsWith('.')) {
              cookieDomain = cookieDomain.substring(1);
            }
          } else if (attrName == 'path' && attrParts.length > 1) {
            cookiePath = attrParts[1].trim();
          }
        }

        cookieDomain ??= currentDomain;
        bool acceptCookie = cookieDomain == currentDomain ||
            currentDomain.endsWith('.' + cookieDomain);
        if (!acceptCookie) {
          data.logWarning(
              'REQUEST: Rejected cookie $name due to domain mismatch: $cookieDomain vs $currentDomain');
          continue;
        }
        final cookieKey = '$name@$cookieDomain$cookiePath';
        sessionCookies[cookieKey] = value;
        data.cookies[name] = value;
        data.log(
            'REQUEST: Stored cookie: $name = ${value.substring(0, value.length.clamp(0, 30))}... (domain: $cookieDomain, path: $cookiePath)');
      } catch (e) {
        data.logWarning('Failed to parse cookie: $cookieHeader - Error: $e');
      }
    }
  }

  RedirectDecision? _computeRedirectDecision(
    Response<List<int>> response,
    String currentUrl,
    String currentMethod,
    BotData data,
  ) {
    final status = response.statusCode ?? 0;
    if (!(status == 301 ||
        status == 302 ||
        status == 303 ||
        status == 307 ||
        status == 308)) {
      return null;
    }
    final location = response.headers['location']?.first;
    data.log('REQUEST: Got $status redirect response');
    data.log('REQUEST: Location header: $location');
    if (location == null || location.isEmpty) {
      data.logWarning('REQUEST: Redirect response missing Location header!');
      return null;
    }
    String nextUrl;
    if (location.startsWith('/')) {
      final uri = Uri.parse(currentUrl);
      nextUrl = '${uri.scheme}://${uri.host}$location';
    } else if (!location.startsWith('http')) {
      final uri = Uri.parse(currentUrl);
      nextUrl = '${uri.scheme}://${uri.host}/$location';
    } else {
      nextUrl = location;
    }
    String nextMethod = currentMethod;
    bool clearContent = false;
    if (status == 303) {
      data.log(
          'REQUEST: Status 303 - Changing method from $currentMethod to GET');
      nextMethod = 'GET';
      clearContent = true;
    } else if ((status == 301 || status == 302) && currentMethod == 'POST') {
      data.log('REQUEST: Status $status - Changing method from POST to GET');
      nextMethod = 'GET';
      clearContent = true;
    } else if (status == 307 || status == 308) {
      data.log('REQUEST: Status $status - Preserving method: $currentMethod');
    }
    return RedirectDecision(
        nextUrl: nextUrl, nextMethod: nextMethod, clearContent: clearContent);
  }

  Future<Response<List<int>>> _executeStandard(
    String method,
    Dio dio,
    String url,
    BotData data,
    Map<String, String> sessionCookies,
  ) async {
    final headers = await _prepareHeaders(method, data, sessionCookies, url);

    final hasBody = ['POST', 'PUT', 'PATCH'].contains(method.toUpperCase());
    String body = '';

    if (hasBody) {
      body = InterpolationEngine.interpolate(content, data.variables, data);

      data.log('REQUEST: Preparing STANDARD request');
      data.log('REQUEST: Original content: $content');
      data.log('REQUEST: Interpolated body: $body');

      // URL encode content if needed
      if (encodeContent && body.isNotEmpty) {
        body = _urlEncodeContent(body);
        data.log('REQUEST: URL-encoded body: $body');
      }
    } else {
      data.log('REQUEST: Preparing STANDARD request (no body for $method)');
    }

    data.log('REQUEST: Final URL: $url');
    data.log(
        'REQUEST: Executing $method request with body length: ${hasBody ? body.length : 0}');
    data.log('REQUEST: Headers being sent:');
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'cookie') {
        data.log(
            '  $key: ${value.length > 100 ? value.substring(0, 100) + '...' : value}');
      } else {
        data.log('  $key: $value');
      }
    });

    final options = Options(
      headers: headers,
      responseType: ResponseType.bytes,
    );

    return await dio.request<List<int>>(
      url,
      data: hasBody ? body : null,
      options: options,
    );
  }

  /// Execute BASIC AUTH requests by adding Authorization header.
  Future<Response<List<int>>> _executeBasicAuth(
    String method,
    Dio dio,
    String url,
    BotData data,
    Map<String, String> sessionCookies,
  ) async {
    final headers = await _prepareHeaders(method, data, sessionCookies, url);

    // Add Basic Auth header
    final username =
        InterpolationEngine.interpolate(authUser, data.variables, data);
    final password =
        InterpolationEngine.interpolate(authPass, data.variables, data);
    final authString = base64.encode(utf8.encode('$username:$password'));
    headers['Authorization'] = 'Basic $authString';

    final options = Options(
      headers: headers,
      responseType: ResponseType.bytes,
    );

    return await dio.request<List<int>>(url, options: options);
  }

  /// Execute MULTIPART requests
  Future<Response<List<int>>> _executeMultipart(
    String method,
    Dio dio,
    String url,
    BotData data,
    Map<String, String> sessionCookies,
  ) async {
    final headers = await _prepareHeaders(method, data, sessionCookies, url);

    // Generate boundary if not specified
    if (multipartBoundary.isEmpty) {
      multipartBoundary = _generateMultipartBoundary();
    }

    final formData = FormData();

    // Add multipart contents
    for (final content in multipartContents) {
      if (content.type == MultipartContentType.String) {
        final value = InterpolationEngine.interpolate(
            content.value, data.variables, data);
        formData.fields.add(MapEntry(content.name, value));
      } else {
        // File content
        final path = InterpolationEngine.interpolate(
            content.value, data.variables, data);
        if (await fileSystemService.exists(path)) {
          formData.files.add(MapEntry(
            content.name,
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
              contentType: _parseMediaType(content.contentType),
            ),
          ));
        }
      }
    }

    final options = Options(
      headers: headers,
      responseType: ResponseType.bytes,
    );

    return await dio.request<List<int>>(
      url,
      data: formData,
      options: options,
    );
  }

  /// Execute RAW hex-body requests
  Future<Response<List<int>>> _executeRaw(
    String method,
    Dio dio,
    String url,
    BotData data,
    Map<String, String> sessionCookies,
  ) async {
    final headers = await _prepareHeaders(method, data, sessionCookies, url);
    final rawContent =
        InterpolationEngine.interpolate(rawData, data.variables, data);

    // Convert hex to bytes
    final bytes = _hexToBytes(rawContent);

    final options = Options(
      headers: headers,
      responseType: ResponseType.bytes,
    );

    return await dio.request<List<int>>(
      url,
      data: bytes,
      options: options,
    );
  }

  Future<Map<String, String>> _prepareHeaders(
    String method,
    BotData data,
    Map<String, String> sessionCookies,
    String url,
  ) async {
    final requestHeaders = <String, String>{};

    // Parse current URL to get domain
    final currentUri = Uri.parse(url);
    final currentDomain = currentUri.host;
    data.log('REQUEST: Preparing headers for domain: $currentDomain');

    if (headers.isEmpty) {
      // Start with default headers
      defaultHeaders.forEach((key, value) {
        requestHeaders[key] = value;
      });
    }

    // Add custom headers
    headers.forEach((key, value) {
      if (key.trim().isEmpty) {
        data.logWarning(
            'REQUEST: Skipping header with empty key: "$key: $value"');
        return;
      }

      // Skip Host header, it will be handled automatically
      if (key.toLowerCase() == 'host') {
        data.log(
            'REQUEST: Skipping custom Host header, will use URL-based host');
        return;
      }

      // Skip Content-Length and Content-Type headers for requests without body
      final methodUpper = method.toUpperCase();
      final methodsWithoutBody = ['GET', 'HEAD', 'DELETE', 'OPTIONS'];
      if (methodsWithoutBody.contains(methodUpper)) {
        final lowerKey = key.toLowerCase();
        if (lowerKey == 'content-length' || lowerKey == 'content-type') {
          data.logWarning(
              'REQUEST: Skipping $key header for $methodUpper request');
          return;
        }
      }

      requestHeaders[key] =
          InterpolationEngine.interpolate(value, data.variables, data);
    });

    // Add content type if specified (but not for methods without body)
    final methodsWithBody = ['POST', 'PUT', 'PATCH'];
    if (contentType.isNotEmpty &&
        !requestHeaders.containsKey('Content-Type') &&
        methodsWithBody.contains(method.toUpperCase())) {
      requestHeaders['Content-Type'] = contentType;
    }

    // Add default User-Agent only if not already present and no defaults were applied
    bool hasUserAgent =
        requestHeaders.keys.any((key) => key.toLowerCase() == 'user-agent');
    if (!hasUserAgent && headers.isNotEmpty) {
      requestHeaders['User-Agent'] = AppConfiguration.defaultUserAgent;
    }

    // Handle Accept-Encoding only if not already present (case-insensitive check)
    bool hasAcceptEncoding = requestHeaders.keys
        .any((key) => key.toLowerCase() == 'accept-encoding');
    if (acceptEncoding && !hasAcceptEncoding) {
      requestHeaders['Accept-Encoding'] = 'gzip, deflate';
    }

    // Handle cookies
    final allCookies = <String, String>{};

    // Add cookies from bot data first
    data.cookies.forEach((name, value) {
      allCookies[name] = value;
    });

    // Add custom cookies (from block configuration)
    customCookies.forEach((key, value) {
      allCookies[key] =
          InterpolationEngine.interpolate(value, data.variables, data);
    });

    // Session cookies override data cookies
    sessionCookies.forEach((key, value) {
      if (key.contains('@')) {
        final parts = key.split('@');
        final cookieName = parts[0];
        final domainPath = parts[1];

        // Extract domain and path
        String domain = domainPath;
        String path = '/';
        final pathIndex = domainPath.indexOf('/');
        if (pathIndex != -1) {
          domain = domainPath.substring(0, pathIndex);
          path = domainPath.substring(pathIndex);
        }

        bool cookieApplies = false;

        // Domain matching
        if (currentDomain == domain || currentDomain.endsWith('.' + domain)) {
          final currentPath = currentUri.path.isEmpty ? '/' : currentUri.path;
          if (currentPath.startsWith(path)) {
            cookieApplies = true;
          }
        }

        if (cookieApplies) {
          allCookies[cookieName] = value;
        }
      } else {
        allCookies[key] = value;
      }
    });

    // Add cookies to request headers
    if (allCookies.isNotEmpty) {
      if (AppConfiguration.debugMode) {
        data.log('REQUEST: Available cookies before domain filtering:');
        allCookies.forEach((key, value) {
          data.log(
              '  $key: ${value.substring(0, value.length.clamp(0, 30))}...');
        });
      }

      // Send all cookies
      final cookieHeader =
          allCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      requestHeaders['Cookie'] = cookieHeader;
      if (AppConfiguration.debugMode) {
        data.log(
            'REQUEST: Sending cookies to $currentDomain: ${cookieHeader.length > 100 ? cookieHeader.substring(0, 100) + '...' : cookieHeader}');
      }
    } else {
      if (AppConfiguration.debugMode) {
        data.log('REQUEST: No cookies to send');
      }
    }

    // Log headers
    if (AppConfiguration.debugMode) {
      data.log('REQUEST: Prepared headers:');
      requestHeaders.forEach((key, value) {
        if (key.toLowerCase() == 'cookie') {
          data.log(
              '  $key: ${value.length > 100 ? value.substring(0, 100) + '...' : value}');
        } else {
          data.log('  $key: $value');
        }
      });
    }

    return requestHeaders;
  }

  Future<void> _handleDioResponse(
      Response<List<int>> response, BotData data) async {
    switch (responseType) {
      case 'FILE':
        await _saveResponseToFile(response, data);
        break;
      case 'BASE64':
        _saveResponseAsBase64(response, data);
        break;
      default: // STRING
        await _saveResponseAsString(response, data);
    }
  }

  Future<void> _saveResponseAsString(
    Response<List<int>> response,
    BotData data,
  ) async {
    try {
      final bytes = response.data ?? [];

      // Check if response is compressed
      final contentEncoding = response.headers.value('content-encoding');

      if (contentEncoding != null && contentEncoding.contains('gzip')) {
        try {
          final decompressed = gzip.decode(bytes);
          data.responseSource = utf8.decode(decompressed);
        } catch (e) {
          data.responseSource = utf8.decode(bytes, allowMalformed: true);
        }
      } else if (contentEncoding != null &&
          contentEncoding.contains('deflate')) {
        try {
          final decompressed = zlib.decode(bytes);
          data.responseSource = utf8.decode(decompressed);
        } catch (e) {
          data.responseSource = utf8.decode(bytes, allowMalformed: true);
        }
      } else {
        // Try to decode as UTF-8, fallback to Latin-1 if it fails
        try {
          data.responseSource = utf8.decode(bytes);
        } catch (e) {
          data.responseSource = latin1.decode(bytes);
        }
      }
    } catch (e) {
      // Ultimate fallback
      data.responseSource = String.fromCharCodes(response.data ?? []);
    }
  }

  Future<void> _saveResponseToFile(
      Response<List<int>> response, BotData data) async {
    final path =
        InterpolationEngine.interpolate(downloadPath, data.variables, data);
    await fileSystemService.writeFileBytes(
        path, Uint8List.fromList(response.data ?? []));
    data.log('File saved to: $path');
  }

  void _saveResponseAsBase64(Response<List<int>> response, BotData data) {
    final base64String = base64.encode(response.data ?? []);
    data.variables.set(StringVariable(outputVariable, base64String));
    data.log('Response saved to variable $outputVariable as Base64');
  }

  String _urlEncodeContent(String content) {
    // Very dirty but it works
    final rand = Random();
    final nonce = rand.nextInt(9000000) + 1000000;
    var encoded = content
        .replaceAll('&', '$nonce&$nonce')
        .replaceAll('=', '$nonce=$nonce');
    encoded = Uri.encodeComponent(encoded);
    return encoded
        .replaceAll('$nonce%26$nonce', '&')
        .replaceAll('$nonce%3D$nonce', '=');
  }

  Uint8List _hexToBytes(String hex) {
    final cleaned = hex.replaceAll(RegExp(r'\s'), '');
    final bytes = <int>[];
    for (var i = 0; i < cleaned.length; i += 2) {
      final hexByte = cleaned.substring(i, i + 2);
      bytes.add(int.parse(hexByte, radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  String _generateMultipartBoundary() {
    final rand = Random();
    final chars = 'abcdefghijklmnopqrstuvwxyz';
    final boundary = StringBuffer('------WebKitFormBoundary');
    for (var i = 0; i < 16; i++) {
      boundary.write(chars[rand.nextInt(chars.length)]);
    }
    return boundary.toString();
  }

  MediaType? _parseMediaType(String contentType) {
    try {
      return MediaType.parse(contentType);
    } catch (e) {
      // Ignore parse errors
    }
    return null;
  }

  @override
  void fromLoliCode(String loliCode) {
    final lines = loliCode.split('\n');
    bool foundRequestLine = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Parse the REQUEST line
      if (!foundRequestLine && line.startsWith('REQUEST ')) {
        foundRequestLine = true;
        _parseRequestLine(line);
        continue;
      }

      // Parse output directive
      if (line.startsWith('->')) {
        _parseOutputDirective(line);
        continue;
      }

      // Parse other directives
      if (line == 'STANDARD') {
        requestType = 'STANDARD';
      } else if (line == 'MULTIPART') {
        requestType = 'MULTIPART';
      } else if (line == 'BASICAUTH') {
        requestType = 'BASICAUTH';
      } else if (line == 'RAW') {
        requestType = 'RAW';
      } else if (line.startsWith('CONTENT ')) {
        content = LineParser.parseLiteral(line.substring(8));
      } else if (line.startsWith('RAWDATA ')) {
        rawData = _extractQuotedValue(line.substring(8));
      } else if (line.startsWith('CONTENTTYPE ')) {
        contentType = _extractQuotedValue(line.substring(12));
      } else if (line.startsWith('USERNAME ')) {
        authUser = _extractQuotedValue(line.substring(9));
      } else if (line.startsWith('PASSWORD ')) {
        authPass = _extractQuotedValue(line.substring(9));
      } else if (line.startsWith('BOUNDARY ')) {
        multipartBoundary = _extractQuotedValue(line.substring(9));
      } else if (line.startsWith('STRINGCONTENT ')) {
        _parseMultipartString(line.substring(14));
      } else if (line.startsWith('FILECONTENT ')) {
        _parseMultipartFile(line.substring(12));
      } else if (line.startsWith('COOKIE ')) {
        _parseCookie(line.substring(7));
      } else if (line.startsWith('HEADER ')) {
        _parseHeader(line.substring(7));
      } else if (line.startsWith('SECPROTO ')) {
        securityProtocol = line.substring(9).trim();
      }
    }
  }

  void _parseRequestLine(String line) {
    // REQUEST METHOD "URL" [Flags...]
    final regex = RegExp(r'REQUEST\s+(\w+)\s+"([^"]+)"(.*)');
    final match = regex.firstMatch(line);

    if (match != null) {
      method = match.group(1)!;
      url = match.group(2)!;

      // Parse optional flags
      final flagsPart = match.group(3)!.trim();
      if (flagsPart.isNotEmpty) {
        if (flagsPart.contains('AcceptEncoding=False')) acceptEncoding = false;
        if (flagsPart.contains('AutoRedirect=False')) autoRedirect = false;
        if (flagsPart.contains('ReadResponseSource=False'))
          readResponseSource = false;
        if (flagsPart.contains('ParseQuery=True')) parseQuery = true;
        if (flagsPart.contains('EncodeContent=True')) encodeContent = true;
      }
    }
  }

  void _parseOutputDirective(String line) {
    final trimmed = line.trim();

    if (trimmed.contains('-> FILE')) {
      responseType = 'FILE';
      final fileMatch = RegExp(r'-> FILE\s+"([^"]+)"').firstMatch(trimmed);
      if (fileMatch != null) {
        downloadPath = fileMatch.group(1)!;
      }
      if (trimmed.contains('SaveAsScreenshot=True')) {
        saveAsScreenshot = true;
      }
    } else if (trimmed.contains('-> BASE64')) {
      responseType = 'BASE64';
      final varMatch = RegExp(r'-> BASE64\s+"([^"]+)"').firstMatch(trimmed);
      if (varMatch != null) {
        outputVariable = varMatch.group(1)!;
      }
    } else if (trimmed.contains('-> STRING')) {
      responseType = 'STRING';
    }
  }

  void _parseMultipartString(String content) {
    final parts = _parseColonSeparated(content, 2);
    if (parts.length == 2) {
      multipartContents.add(MultipartContent(
        type: MultipartContentType.String,
        name: parts[0],
        value: parts[1],
      ));
    }
  }

  void _parseMultipartFile(String content) {
    final cleaned = _extractQuotedValue(content);

    final spaceParts = cleaned.split(' ');
    if (spaceParts.length >= 2) {
      multipartContents.add(MultipartContent(
        type: MultipartContentType.File,
        name: spaceParts[0],
        value: spaceParts[1],
        contentType:
            spaceParts.length > 2 ? spaceParts[2] : 'application/octet-stream',
      ));
    } else {
      // Fallback to colon-separated format
      final colonParts = _parseColonSeparated(content, 3);
      if (colonParts.length >= 2) {
        multipartContents.add(MultipartContent(
          type: MultipartContentType.File,
          name: colonParts[0],
          value: colonParts[1],
          contentType: colonParts.length > 2
              ? colonParts[2]
              : 'application/octet-stream',
        ));
      }
    }
  }

  void _parseCookie(String content) {
    final parts = _parseColonSeparated(content, 2);
    if (parts.length == 2) {
      customCookies[parts[0]] = parts[1];
    }
  }

  void _parseHeader(String content) {
    // Headers are in the format "Header-Name: Header-Value"
    final cleaned = _extractQuotedValue(content);
    final colonIndex = cleaned.indexOf(':');
    if (colonIndex > 0) {
      final headerName = cleaned.substring(0, colonIndex).trim();
      final headerValue = cleaned.substring(colonIndex + 1).trim();
      headers[headerName] = headerValue;
    }
  }

  List<String> _parseColonSeparated(String input, int expectedParts) {
    final cleaned = _extractQuotedValue(input);
    return cleaned.split(':').map((s) => s.trim()).take(expectedParts).toList();
  }

  String _extractQuotedValue(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  @override
  String toLoliCode() {
    final buffer = StringBuffer();

    // Helper function to escape strings for LoliCode output
    String escapeForLoliCode(String value) {
      return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    }

    // REQUEST line with flags
    buffer.write('REQUEST $method "${escapeForLoliCode(url)}"');
    if (!acceptEncoding) buffer.write(' AcceptEncoding=False');
    if (!autoRedirect) buffer.write(' AutoRedirect=False');
    if (!readResponseSource) buffer.write(' ReadResponseSource=False');
    if (parseQuery) buffer.write(' ParseQuery=True');
    if (encodeContent) buffer.write(' EncodeContent=True');
    buffer.writeln();

    // Request type
    if (requestType != 'STANDARD') {
      buffer.writeln('  $requestType');
    }

    // Request type specific content
    switch (requestType) {
      case 'BASICAUTH':
        if (authUser.isNotEmpty)
          buffer.writeln('  USERNAME "${escapeForLoliCode(authUser)}"');
        if (authPass.isNotEmpty)
          buffer.writeln('  PASSWORD "${escapeForLoliCode(authPass)}"');
        break;

      case 'MULTIPART':
        for (final mc in multipartContents) {
          if (mc.type == MultipartContentType.String) {
            buffer.writeln(
                '  STRINGCONTENT "${escapeForLoliCode(mc.name)}: ${escapeForLoliCode(mc.value)}"');
          } else {
            buffer.writeln(
                '  FILECONTENT "${escapeForLoliCode(mc.name)}: ${escapeForLoliCode(mc.value)}: ${escapeForLoliCode(mc.contentType)}"');
          }
        }
        if (multipartBoundary.isNotEmpty) {
          buffer
              .writeln('  BOUNDARY "${escapeForLoliCode(multipartBoundary)}"');
        }
        break;

      case 'RAW':
        if (rawData.isNotEmpty)
          buffer.writeln('  RAWDATA "${escapeForLoliCode(rawData)}"');
        break;

      default: // STANDARD
        if (content.isNotEmpty) {
          buffer.writeln('  CONTENT "${escapeForLoliCode(content)}"');
        }
    }

    // Content type
    if (contentType.isNotEmpty) {
      buffer.writeln('  CONTENTTYPE "${escapeForLoliCode(contentType)}"');
    }

    // Security protocol
    if (securityProtocol != 'SystemDefault') {
      buffer.writeln('  SECPROTO $securityProtocol');
    }

    // Cookies
    customCookies.forEach((key, value) {
      buffer.writeln(
          '  COOKIE "${escapeForLoliCode(key)}: ${escapeForLoliCode(value)}"');
    });

    // Headers
    headers.forEach((key, value) {
      buffer.writeln(
          '  HEADER "${escapeForLoliCode(key)}: ${escapeForLoliCode(value)}"');
    });

    // Output directive
    switch (responseType) {
      case 'FILE':
        buffer.write('  -> FILE "${escapeForLoliCode(downloadPath)}"');
        if (saveAsScreenshot) buffer.write(' SaveAsScreenshot=True');
        buffer.writeln();
        break;
      case 'BASE64':
        buffer.writeln('  -> BASE64 "${escapeForLoliCode(outputVariable)}"');
        break;
    }

    return buffer.toString();
  }
}

class RedirectDecision {
  final String nextUrl;
  final String nextMethod;
  final bool clearContent;
  RedirectDecision(
      {required this.nextUrl,
      required this.nextMethod,
      required this.clearContent});
}
