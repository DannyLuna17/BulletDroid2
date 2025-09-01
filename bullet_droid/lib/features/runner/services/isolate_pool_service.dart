import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:bullet_droid2/bullet_droid.dart' as lunalib;

import 'package:bullet_droid/features/runner/models/job_params.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';
import 'package:bullet_droid/features/runner/utils/cpm_calculator.dart';

class IsolatePoolService {
  static const int maxIsolates = 200;
  static const int initialIsolates = 1;
  final List<IsolateWorker> _workers = [];
  final StreamController<JobProgress> _progressController =
      StreamController.broadcast();
  final StreamController<BotResultUpdate> _botResultsController =
      StreamController.broadcast();
  final StreamController<ProxyUpdate> _proxyUpdateController =
      StreamController.broadcast();

  final Map<String, JobMetadata> _activeJobs = {};

  bool _isInitializing = false;
  bool get isInitializing => _isInitializing;
  bool get isReady => totalWorkerCount > 0;
  bool _selectingWorker = false;

  Stream<JobProgress> get progressStream {
    return _progressController.stream;
  }

  Stream<BotResultUpdate> get botResultsStream => _botResultsController.stream;
  Stream<ProxyUpdate> get proxyUpdatesStream => _proxyUpdateController.stream;

  Future<void> initialize() async {
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    _isInitializing = true;

    try {
      // If already have workers, clean them up first
      if (_workers.isNotEmpty) {
        for (final worker in _workers) {
          await worker.dispose();
        }
        _workers.clear();
      }
      // Ensure at least a minimal pool is available
      final int target = initialIsolates;
      final int toCreate = target - _workers.length;
      for (int i = 0; i < toCreate; i++) {
        final int newId = _workers.length;
        try {
          final worker = await IsolateWorker.spawn(newId);
          _workers.add(worker);
        } catch (e) {
          throw Exception('Failed to create worker $newId: $e');
        }
      }
    } catch (e) {
      // Clean up any partially created workers
      for (final worker in _workers) {
        try {
          await worker.dispose();
        } catch (disposeError) {}
      }
      _workers.clear();

      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<String> startJob(JobParams params, {String? runnerId}) async {
    final jobId = DateTime.now().millisecondsSinceEpoch.toString();

    // Reserve an available worker atomically to avoid race conditions when many jobs start at once
    final worker = await _reserveAvailableWorker();
    if (worker == null) {
      throw Exception('No available workers');
    }

    // Track job metadata
    _activeJobs[jobId] = JobMetadata(
      jobId: jobId,
      runnerId: runnerId,
      startTime: DateTime.now(),
      workerId: worker.id,
      params: params,
    );

    try {
      // Start job on worker
      worker.startJob(
        jobId,
        params,
        _progressController,
        _botResultsController,
        _proxyUpdateController,
        runnerId: runnerId,
      );
      return jobId;
    } catch (e) {
      // Release reservation on failure
      worker.isBusy = false;
      _activeJobs.remove(jobId);
      rethrow;
    }
  }

  Future<void> stopJob(String jobId) async {
    for (int i = 0; i < _workers.length; i++) {
      final worker = _workers[i];
      if (worker.currentJobId == jobId) {
        await worker.stopJob();
        final bool completed = await worker.waitForTerminal(
          timeout: const Duration(milliseconds: 500),
        );
        if (!completed) {
          try {
            await worker.dispose();
          } catch (_) {}
          try {
            final replacement = await IsolateWorker.spawn(worker.id);
            _workers[i] = replacement;
          } catch (_) {}
        }
        _activeJobs.remove(jobId);
        break;
      }
    }
  }

  IsolateWorker? _getAvailableWorker() {
    for (final worker in _workers) {
      if (!worker.isBusy) {
        return worker;
      }
    }
    return null;
  }

  // Atomically reserve a worker. If none available and capacity remains, spawn on demand.
  Future<IsolateWorker?> _reserveAvailableWorker() async {
    while (_selectingWorker) {
      await Future.delayed(const Duration(milliseconds: 5));
    }
    _selectingWorker = true;
    try {
      // Prefer reusing an idle worker
      final existing = _getAvailableWorker();
      if (existing != null) {
        existing.isBusy = true;
        return existing;
      }

      // No idle worker, create one if we have capacity
      if (_workers.length < maxIsolates) {
        try {
          final int newId = _workers.length;
          final worker = await IsolateWorker.spawn(newId);
          worker.isBusy = true;
          _workers.add(worker);
          return worker;
        } catch (_) {
          return null;
        }
      }

      // Pool at capacity, no more workers can be created
      return null;
    } finally {
      _selectingWorker = false;
    }
  }

  // Public method to check if workers are available (or can be created on demand)
  bool get hasAvailableWorkers {
    return _getAvailableWorker() != null || _workers.length < maxIsolates;
  }

  // Public method to get the number of available workers
  int get availableWorkerCount {
    return _workers.where((worker) => !worker.isBusy).length;
  }

  // Public method to get total worker count
  int get totalWorkerCount {
    return _workers.length;
  }

  // Get list of active job IDs
  List<String> getActiveJobs() {
    return _activeJobs.keys.toList();
  }

  // Get job metadata
  JobMetadata? getJobMetadata(String jobId) {
    return _activeJobs[jobId];
  }

  // Get active jobs for specific runner
  List<String> getActiveJobsForRunner(String? runnerId) {
    if (runnerId == null) return [];
    return _activeJobs.values
        .where((metadata) => metadata.runnerId == runnerId)
        .map((metadata) => metadata.jobId)
        .toList();
  }

  Future<void> dispose() async {
    for (final worker in _workers) {
      await worker.dispose();
    }
    _activeJobs.clear();
    await _progressController.close();
    await _botResultsController.close();
    await _proxyUpdateController.close();
  }
}

// Job metadata for tracking and recovery
class JobMetadata {
  final String jobId;
  final String? runnerId;
  final DateTime startTime;
  final int workerId;
  final JobParams params;

  JobMetadata({
    required this.jobId,
    required this.runnerId,
    required this.startTime,
    required this.workerId,
    required this.params,
  });
}

// Custom execution wrapper that provides real-time updates
class ProgressiveExecutionEngine {
  static Future<lunalib.BotData> executeWithProgress(
    lunalib.Config config,
    lunalib.BotData data,
    Function(String) onBlockProgress,
  ) async {
    try {
      data.log('Starting config execution: ${config.metadata.name}');

      for (var i = 0; i < config.blocks.length; i++) {
        final block = config.blocks[i];

        if (block.disabled) {
          data.log('Skipping disabled block: ${block.id}');
          continue;
        }

        // Report current block being processed
        final blockLabel = block.label.isNotEmpty ? block.label : block.id;
        onBlockProgress(
          "<<< PROCESSING BLOCK: ${blockLabel.toUpperCase()} >>>",
        );

        data.log(
          'Executing block ${i + 1}/${config.blocks.length}: ${block.id}',
        );

        try {
          await block.execute(data);

          // Check if status changed and should stop execution
          if (_shouldStopExecution(data.status)) {
            data.log('Stopping execution due to status: ${data.status}');
            break;
          }
        } catch (e, stackTrace) {
          data.logError('Block execution failed: $e');
          data.logError('Block: ${block.id}');
          data.logError('Stack trace: $stackTrace');

          // Report error in block
          onBlockProgress("<<< ERROR IN BLOCK: $blockLabel >>>");

          if (block.safe) {
            data.logWarning('Safe block failed, continuing execution');
            continue;
          } else {
            data.status = lunalib.BotStatus.ERROR;
            data.logError('Non-safe block failed, stopping execution');
            break;
          }
        }
      }

      data.log('Config execution completed with status: ${data.status}');
      return data;
    } catch (e, stackTrace) {
      data.logError('Execution engine error: $e');
      data.logError('Stack trace: $stackTrace');
      data.status = lunalib.BotStatus.ERROR;
      return data;
    }
  }

  static bool _shouldStopExecution(lunalib.BotStatus status) {
    switch (status) {
      case lunalib.BotStatus.ERROR:
        return true;
      case lunalib.BotStatus.SUCCESS:
      case lunalib.BotStatus.FAIL:
      case lunalib.BotStatus.BAN:
      case lunalib.BotStatus.UNKNOWN:
      case lunalib.BotStatus.CUSTOM:
      case lunalib.BotStatus.RETRY:
      case lunalib.BotStatus.NONE:
      case lunalib.BotStatus.TOCHECK:
        return false;
    }
  }
}

class IsolateWorker {
  final int id;
  final Isolate isolate;
  final SendPort sendPort;
  ReceivePort? receivePort;
  StreamSubscription? _subscription;
  Completer<void>? _terminalCompleter;

  bool isBusy = false;
  String? currentJobId;

  IsolateWorker._({
    required this.id,
    required this.isolate,
    required this.sendPort,
  });

  static Future<IsolateWorker> spawn(int id) async {
    final setupPort = ReceivePort();
    final isolate = await Isolate.spawn(_isolateEntryPoint, setupPort.sendPort);

    // Wait for isolate to send its SendPort
    final sendPort = await setupPort.first as SendPort;
    setupPort.close();

    final worker = IsolateWorker._(
      id: id,
      isolate: isolate,
      sendPort: sendPort,
    );

    // Create the communication port that will be used for job messages
    worker.receivePort = ReceivePort();

    return worker;
  }

  void startJob(
    String jobId,
    JobParams params,
    StreamController<JobProgress> progressController,
    StreamController<BotResultUpdate> botResultsController,
    StreamController<ProxyUpdate> proxyUpdateController, {
    String? runnerId,
  }) {
    isBusy = true;
    currentJobId = jobId;
    _terminalCompleter = Completer<void>();

    _subscription?.cancel();
    _subscription = null;

    try {
      receivePort?.close();
    } catch (e) {
    }

    receivePort = ReceivePort();

    // Set up message handling for this job
    _subscription = receivePort!.listen((message) {
      if (message is Map) {
        switch (message['type']) {
          case 'PROGRESS':
            try {
              final progress = JobProgress.fromJson(message['data']);

              progressController.add(progress);

              if (progress.status == JobStatus.completed ||
                  progress.status == JobStatus.failed ||
                  progress.status == JobStatus.cancelled) {
                isBusy = false;
                currentJobId = null;

                // Clean up subscription and receive port when job completes
                _subscription?.cancel();
                _subscription = null;
                _terminalCompleter?.complete();
                _terminalCompleter = null;
              } else {}
            } catch (e) {}
            break;
          case 'BOT_RESULT':
            try {
              final botUpdate = BotResultUpdate.fromJson(message['data']);
              botResultsController.add(botUpdate);
            } catch (e) {}
            break;
          case 'PROXY_UPDATE':
            final proxyUpdate = ProxyUpdate.fromJson(message['data']);
            proxyUpdateController.add(proxyUpdate);
            break;
        }
      }
    });

    // Send job start message to isolate
    sendPort.send({
      'type': 'START_JOB',
      'jobId': jobId,
      'runnerId': runnerId,
      'params': params.toJson(),
      'replyPort': receivePort!.sendPort,
    });
  }

  Future<void> stopJob() async {
    sendPort.send({'type': 'STOP_JOB'});
  }

  Future<void> dispose() async {
    try {
      // Clean up subscription and receive port
      await _subscription?.cancel();
      _subscription = null;
      receivePort?.close();

      sendPort.send({'type': 'DISPOSE'});

      // Give isolate time to clean up gracefully
      await Future.delayed(const Duration(milliseconds: 100));

      isolate.kill(priority: Isolate.immediate);
      _terminalCompleter?.complete();
      _terminalCompleter = null;
    } catch (e) {
      // Force kill if graceful disposal fails
      isolate.kill(priority: Isolate.immediate);
      _terminalCompleter?.complete();
      _terminalCompleter = null;
    }
  }

  Future<bool> waitForTerminal({required Duration timeout}) async {
    final completer = _terminalCompleter;
    if (completer == null) return true;
    try {
      await completer.future.timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  static void _isolateEntryPoint(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    JobRunner? currentRunner;

    await for (final message in receivePort) {
      if (message is Map) {
        switch (message['type']) {
          case 'START_JOB':
            final jobId = message['jobId'] as String;
            final runnerId = message['runnerId'] as String?;
            final params = JobParams.fromJson(message['params']);
            final replyPort = message['replyPort'] as SendPort;

            currentRunner = JobRunner(
              jobId: jobId,
              runnerId: runnerId,
              params: params,
              onProgress: (progress) {
                // Ensure proper JSON serialization across isolate boundary
                final jsonString = jsonEncode(progress.toJson());
                final jsonData = jsonDecode(jsonString);
                replyPort.send({'type': 'PROGRESS', 'data': jsonData});
              },
              onBotResult: (botResult) {
                // Manually serialize to ensure proper JSON conversion
                final botUpdateData = {
                  'jobId': jobId,
                  'runnerId': runnerId,
                  'botResults': [botResult.toJson()],
                };

                replyPort.send({'type': 'BOT_RESULT', 'data': botUpdateData});
              },
              onProxyUpdate: (proxyUpdate) {
                replyPort.send({
                  'type': 'PROXY_UPDATE',
                  'data': proxyUpdate.toJson(),
                });
              },
            );

            await currentRunner.run();
            break;

          case 'STOP_JOB':
            await currentRunner?.stop();
            break;

          case 'DISPOSE':
            receivePort.close();
            break;
        }
      }
    }
  }
}

class JobRunner {
  final String jobId;
  final String? runnerId;
  final JobParams params;
  final void Function(JobProgress) onProgress;
  final void Function(BotExecutionResult) onBotResult;
  final void Function(ProxyUpdate) onProxyUpdate;

  bool _shouldStop = false;
  bool _cancelRequested = false;
  Timer? _cpmTimer;
  Timer? _cleanupTimer;
  DateTime? _lastZeroCpmTime;

  // Shared counters for tracking real progress
  int _realProcessed = 0;
  final List<ValidDataResult> _realHits = [];
  final List<ValidDataResult> _realFails = [];
  final List<ValidDataResult> _realCustoms = [];
  final List<ValidDataResult> _realToChecks = [];

  JobRunner({
    required this.jobId,
    this.runnerId,
    required this.params,
    required this.onProgress,
    required this.onBotResult,
    required this.onProxyUpdate,
  });

  // Update real counters when bot results are processed
  void _updateRealCounters(BotExecutionResult result) {
    final validResult = _createValidDataResult(result);
    _realProcessed++;

    switch (result.status) {
      case BotStatus.SUCCESS:
        _realHits.add(validResult);
        break;
      case BotStatus.CUSTOM:
        _realCustoms.add(validResult);
        break;
      case BotStatus.RETRY:
        _realToChecks.add(validResult);
        break;
      case BotStatus.TOCHECK:
        _realToChecks.add(validResult);
        break;
      default:
        _realFails.add(validResult);
    }
  }

  Future<void> run() async {
    final int totalProcessableLines =
        params.startIndex >= params.dataLines.length
        ? 0
        : (params.dataLines.length - params.startIndex);

    try {
      // Initial progress
      onProgress(
        JobProgress(
          jobId: jobId,
          runnerId: runnerId,
          configId: params.configId,
          status: JobStatus.preparing,
          startTime: DateTime.now(),
          totalLines: totalProcessableLines,
        ),
      );

      // Load config
      final config = await lunalib.ConfigLoader.loadFromFile(params.configPath);

      // Thread-safe result collections
      int processed = 0;
      final List<ValidDataResult> hits = [];
      final List<ValidDataResult> fails = [];
      final List<ValidDataResult> customs = [];
      final List<ValidDataResult> toChecks = [];
      final startTime = DateTime.now();
      DateTime? endTime;

      // Real-time CPM update timer, updates every 500ms for smooth real-time display
      _cpmTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (_shouldStop) {
          timer.cancel();
          return;
        }

        // Calculate current CPM using real counter
        final cpm = CPMCalculator.calculateCPMFromLists(
          hits: _realHits,
          fails: _realFails,
          customs: _realCustoms,
          toChecks: _realToChecks,
        );

        // Track when CPM becomes 0 to stop timer after inactivity
        if (cpm == 0 && _realProcessed >= totalProcessableLines) {
          _lastZeroCpmTime ??= DateTime.now();

          // Stop timer if all data processed and CPM has been 0 for more than 5 seconds
          if (DateTime.now().difference(_lastZeroCpmTime!).inSeconds > 5) {
            timer.cancel();
            _cleanupTimer?.cancel();
            return;
          }
        } else {
          // Reset zero CPM timer if CPM becomes > 0 again or job not complete
          _lastZeroCpmTime = null;
        }

        // Send progress with appropriate status
        final jobStatus = endTime != null
            ? JobStatus.completed
            : JobStatus.running;

        // Send progress update using real counters
        onProgress(
          JobProgress(
            jobId: jobId,
            runnerId: runnerId,
            configId: params.configId,
            status: jobStatus,
            startTime: startTime,
            endTime: endTime,
            totalLines: totalProcessableLines,
            processedLines: _realProcessed,
            hits: _realHits,
            fails: _realFails,
            customs: _realCustoms,
            toChecks: _realToChecks,
            cpm: cpm,
          ),
        );
      });

      // Memory cleanup timer
      _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_shouldStop) {
          timer.cancel();
          return;
        }

        // Cleanup old results to prevent memory issues
        CPMCalculator.cleanupOldResults(_realHits);
        CPMCalculator.cleanupOldResults(_realFails);
        CPMCalculator.cleanupOldResults(_realCustoms);
        CPMCalculator.cleanupOldResults(_realToChecks);
      });

      // If single thread, run sequentially for simplicity
      if (params.threads <= 1) {
        const workerBotId = 1;

        for (int i = params.startIndex; i < params.dataLines.length; i++) {
          if (_shouldStop) {
            break;
          }

          final dataLine = params.dataLines[i];
          final int dataLineIndex =
              i;

          try {
            final result = await _processDataLine(
              config,
              dataLine,
              workerBotId,
              dataLineIndex,
            );

            final validResult = _createValidDataResult(result);

            _updateRealCounters(result);

            processed++;
            switch (result.status) {
              case BotStatus.SUCCESS:
                hits.add(validResult);
                break;
              case BotStatus.CUSTOM:
                customs.add(validResult);
                break;
              case BotStatus.RETRY:
                toChecks.add(validResult);
                break;
              case BotStatus.TOCHECK:
                toChecks.add(validResult);
                break;
              default:
                fails.add(validResult);
            }

            onBotResult(result);
          } catch (e) {
            processed++;

            // Create a failed result
            final failedResult = BotExecutionResult(
              status: BotStatus.FAILED,
              data: dataLine,
              errorMessage: e.toString(),
              botId: workerBotId,
              timestamp: DateTime.now(),
              currentDataIndex: dataLineIndex,
            );

            _updateRealCounters(failedResult);

            final validResult = _createValidDataResult(failedResult);
            fails.add(validResult);

            onBotResult(failedResult);
          }
        }

        // Mark single-thread execution as completed
        endTime = DateTime.now();
      } else {
        // Multi-threaded execution with worker bot queue system

        // Create work queue for data lines
        final workQueue = <({String dataLine, int dataIndex})>[];
        for (int i = params.startIndex; i < params.dataLines.length; i++) {
          workQueue.add((dataLine: params.dataLines[i], dataIndex: i));
        }

        final queueIndex = [0];
        final futures = <Future<void>>[];

        // Create worker bots
        for (
          int workerBotId = 1;
          workerBotId <= params.threads;
          workerBotId++
        ) {
          futures.add(
            _processWorkerBot(config, workerBotId, workQueue, queueIndex, (
              result,
            ) {
              // Thread-safe result handling
              onBotResult(result);
              final validResult = _createValidDataResult(result);

              _updateRealCounters(result);

              // Update old counters atomically
              processed++;
              switch (result.status) {
                case BotStatus.SUCCESS:
                  hits.add(validResult);
                  break;
                case BotStatus.CUSTOM:
                  customs.add(validResult);
                  break;
                case BotStatus.RETRY:
                  toChecks.add(validResult);
                  break;
                case BotStatus.TOCHECK:
                  toChecks.add(validResult);
                  break;
                default:
                  fails.add(validResult);
              }
            }),
          );
        }

        // Wait for all worker bots to complete
        await Future.wait(futures);
      }

      // Mark job execution as completed
      endTime = DateTime.now();

      // Send initial completion progress
      final completionCpm = CPMCalculator.calculateCPMFromLists(
        hits: hits,
        fails: fails,
        customs: customs,
        toChecks: toChecks,
      );

      final terminalStatus = _cancelRequested
          ? JobStatus.cancelled
          : JobStatus.completed;
      onProgress(
        JobProgress(
          jobId: jobId,
          runnerId: runnerId,
          configId: params.configId,
          status: terminalStatus,
          startTime: startTime,
          endTime: DateTime.now(),
          totalLines: totalProcessableLines,
          processedLines: processed,
          hits: hits,
          fails: fails,
          customs: customs,
          toChecks: toChecks,
          cpm: completionCpm,
        ),
      );

      _cpmTimer?.cancel();
      _cleanupTimer?.cancel();

    } catch (e) {
      _cpmTimer?.cancel();
      _cleanupTimer?.cancel();

      onProgress(
        JobProgress(
          jobId: jobId,
          runnerId: runnerId,
          configId: params.configId,
          status: JobStatus.failed,
          startTime: DateTime.now(),
          totalLines: totalProcessableLines,
          processedLines: 0,
          hits: <ValidDataResult>[],
          fails: <ValidDataResult>[],
          customs: <ValidDataResult>[],
          toChecks: <ValidDataResult>[],
          cpm: 0,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> stop() async {
    _shouldStop = true;
    _cancelRequested = true;
    _cpmTimer?.cancel();
    _cleanupTimer?.cancel();
  }

  ValidDataResult _createValidDataResult(BotExecutionResult botResult) {
    return ValidDataResult(
      data: botResult.data,
      status: botResult.status,
      completionTime: botResult.timestamp,
      proxy: botResult.proxy,
      captures: botResult.captures,
      customStatus: botResult.customStatus,
    );
  }

  Future<BotExecutionResult> _processDataLine(
    lunalib.Config config,
    String dataLine,
    int workerBotId,
    int dataLineIndex,
  ) async {
    String? usedProxyString;

    try {
      final botData = lunalib.BotData(input: dataLine);

      // Set custom input variables if available
      if (params.customInputs != null) {
        for (final entry in params.customInputs!.entries) {
          final variable = lunalib.VariableFactory.fromObject(
            entry.key,
            entry.value,
          );
          botData.variables.set(variable);
        }
      }

      // Configure proxy if available and enabled
      if (params.useProxies && params.proxies.isNotEmpty) {
        final proxyString =
            params.proxies[(dataLineIndex) % params.proxies.length];

        final proxy = _parseProxyString(proxyString);
        if (proxy != null) {
          botData.proxy = proxy;
          botData.useProxy = true;
          usedProxyString = proxyString;
        } else {
          usedProxyString = null;
        }
      } else {
        if (!params.useProxies) {
        } else {}
        usedProxyString = null;
      }

      // Send initial bot result to show bot is running
      final runningBotResult = BotExecutionResult(
        botId: workerBotId,
        data: dataLine,
        status: BotStatus.running,
        timestamp: DateTime.now(),
        proxy: usedProxyString,
        elapsed: null,
        customStatus: null,
        currentStatus: "<<< PREPARING >>>",
        currentDataIndex: dataLineIndex,
      );
      onBotResult(runningBotResult);

      // Show processing status
      final processingBotResult = BotExecutionResult(
        botId: workerBotId,
        data: dataLine,
        status: BotStatus.running,
        timestamp: DateTime.now(),
        proxy: usedProxyString,
        elapsed: null,
        customStatus: null,
        currentStatus: "<<< STARTING EXECUTION >>>",
        currentDataIndex: dataLineIndex,
      );
      onBotResult(processingBotResult);

      // Execute with progressive updates
      final result = await ProgressiveExecutionEngine.executeWithProgress(
        config,
        botData,
        (String blockProgress) {
          // Send real-time block progress update
          final blockProgressResult = BotExecutionResult(
            botId: workerBotId,
            data: dataLine,
            status: BotStatus.running,
            timestamp: DateTime.now(),
            proxy: usedProxyString,
            elapsed: null,
            customStatus: null,
            currentStatus: blockProgress,
            currentDataIndex: dataLineIndex,
          );
          onBotResult(blockProgressResult);
        },
      );

      // Map LunaLib status to BulletDroid status
      BotStatus bulletStatus;
      switch (result.status) {
        case lunalib.BotStatus.SUCCESS:
          bulletStatus = BotStatus.SUCCESS;
          break;
        case lunalib.BotStatus.CUSTOM:
          bulletStatus = BotStatus.CUSTOM;
          break;
        case lunalib.BotStatus.RETRY:
          bulletStatus = BotStatus.RETRY;
          break;
        case lunalib.BotStatus.TOCHECK:
          bulletStatus = BotStatus.TOCHECK;
          break;
        case lunalib.BotStatus.NONE:
          bulletStatus = BotStatus.TOCHECK;
          break;
        case lunalib.BotStatus.FAIL:
          bulletStatus = BotStatus.FAILED;
          break;
        default:
          bulletStatus = BotStatus.FAILED;
      }

      if (result.status == lunalib.BotStatus.SUCCESS) {
      } else {}

      // Send final bot result with proper status mapping
      final finalStatus =
          bulletStatus == BotStatus.CUSTOM && result.customStatus != null
          ? result.customStatus!
          : bulletStatus.name;

      final finalResult = BotExecutionResult(
        botId: workerBotId,
        data: dataLine,
        status: bulletStatus,
        timestamp: DateTime.now(),
        proxy: usedProxyString,
        elapsed: null,
        captures: _extractVariablesFromResult(result),
        customStatus: result.customStatus,
        currentStatus: "<<< FINISHED WITH RESULT: $finalStatus >>>",
        currentDataIndex: dataLineIndex,
      );

      return finalResult;
    } catch (e) {
      // Return bot result for exception
      final exceptionResult = BotExecutionResult(
        botId: workerBotId,
        data: dataLine,
        status: BotStatus.FAILED,
        timestamp: DateTime.now(),
        proxy: usedProxyString,
        elapsed: null,
        errorMessage: e.toString(),
        customStatus: null,
        currentStatus: "<<< EXECUTION ERROR >>>",
        currentDataIndex: dataLineIndex,
      );

      return exceptionResult;
    }
  }

  /// Extract variables from LunaLib result for display
  Map<String, String> _extractVariablesFromResult(lunalib.BotData result) {
    final captures = <String, String>{};

    final capturedValues = result.variables.getCapturedValues();
    for (final entry in capturedValues.entries) {
      // Convert all values to strings for consistent display
      final value = entry.value?.toString() ?? '';
      captures[entry.key] = value;
    }

    return captures;
  }

  /// Parse proxy string into LunaLib Proxy object
  lunalib.Proxy? _parseProxyString(String proxyString) {
    try {
      final parts = proxyString.split(':');
      if (parts.length < 2) return null;

      final host = parts[0];
      final port = int.tryParse(parts[1]);
      if (port == null) return null;

      String? username;
      String? password;
      if (parts.length >= 4) {
        username = parts[2];
        password = parts[3];
      }

      return lunalib.Proxy(
        host: host,
        port: port,
        type: lunalib.ProxyType.HTTP,
        username: username,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _processWorkerBot(
    lunalib.Config config,
    int workerBotId,
    List<({String dataLine, int dataIndex})> workQueue,
    List<int> queueIndex,
    void Function(BotExecutionResult) onResult,
  ) async {
    while (true) {
      if (_shouldStop) break;

      ({String dataLine, int dataIndex})? workItem;
      int currentIndex;

      currentIndex = queueIndex[0];
      if (currentIndex >= workQueue.length) {
        // No more work available
        break;
      }

      queueIndex[0] = currentIndex + 1; 
      workItem = workQueue[currentIndex];

      // Process the data line
      final result = await _processDataLine(
        config,
        workItem.dataLine,
        workerBotId,
        workItem.dataIndex,
      );
      onResult(result);

    }
  }
}
