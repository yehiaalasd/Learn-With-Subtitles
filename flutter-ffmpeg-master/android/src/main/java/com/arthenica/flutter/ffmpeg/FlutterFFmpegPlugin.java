/*
 * Copyright (c) 2019-2020 Taner Sener
 *
 * This file is part of FlutterFFmpeg.
 *
 * FlutterFFmpeg is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FlutterFFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FlutterFFmpeg.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.flutter.ffmpeg;

import android.content.Context;
import android.os.AsyncTask;

import com.arthenica.mobileffmpeg.AbiDetect;
import com.arthenica.mobileffmpeg.Config;
import com.arthenica.mobileffmpeg.ExecuteCallback;
import com.arthenica.mobileffmpeg.FFmpeg;
import com.arthenica.mobileffmpeg.FFmpegExecution;
import com.arthenica.mobileffmpeg.Level;
import com.arthenica.mobileffmpeg.LogCallback;
import com.arthenica.mobileffmpeg.LogMessage;
import com.arthenica.mobileffmpeg.MediaInformation;
import com.arthenica.mobileffmpeg.Statistics;
import com.arthenica.mobileffmpeg.StatisticsCallback;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.BinaryMessenger;

/**
 * <h3>Flutter FFmpeg Plugin</h3>
 *
 * @author Taner Sener
 * @since 0.1.0
 */
public class FlutterFFmpegPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    public static final String LIBRARY_NAME = "flutter-ffmpeg";
    public static final String PLATFORM_NAME = "android";

    public static final String KEY_VERSION = "version";
    public static final String KEY_RC = "rc";
    public static final String KEY_PLATFORM = "platform";
    public static final String KEY_PACKAGE_NAME = "packageName";
    public static final String KEY_LAST_RC = "lastRc";
    public static final String KEY_LAST_COMMAND_OUTPUT = "lastCommandOutput";
    public static final String KEY_PIPE = "pipe";

    public static final String KEY_LOG_EXECUTION_ID = "executionId";
    public static final String KEY_LOG_LEVEL = "level";
    public static final String KEY_LOG_MESSAGE = "message";

    public static final String KEY_STAT_EXECUTION_ID = "executionId";
    public static final String KEY_STAT_TIME = "time";
    public static final String KEY_STAT_SIZE = "size";
    public static final String KEY_STAT_BITRATE = "bitrate";
    public static final String KEY_STAT_SPEED = "speed";
    public static final String KEY_STAT_VIDEO_FRAME_NUMBER = "videoFrameNumber";
    public static final String KEY_STAT_VIDEO_QUALITY = "videoQuality";
    public static final String KEY_STAT_VIDEO_FPS = "videoFps";

    public static final String KEY_EXECUTION_ID = "executionId";
    public static final String KEY_EXECUTION_START_TIME = "startTime";
    public static final String KEY_EXECUTION_COMMAND = "command";

    public static final String EVENT_LOG = "FlutterFFmpegLogCallback";
    public static final String EVENT_STAT = "FlutterFFmpegStatisticsCallback";
    public static final String EVENT_EXECUTE = "FlutterFFmpegExecuteCallback";

    private EventChannel.EventSink eventSink;
    private final FlutterFFmpegResultHandler flutterFFmpegResultHandler = new FlutterFFmpegResultHandler();

    private Context context;
    private MethodChannel channel;
    private EventChannel eventChannel;

    /**
     * Registers plugin to registry.
     *
     * @param registrar receiver of plugin registration
     */
    @SuppressWarnings("deprecation")
    public static void registerWith(final io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        FlutterFFmpegPlugin flutterFFmpegPlugin = new FlutterFFmpegPlugin();
        flutterFFmpegPlugin.init(registrar.messenger(), (registrar.activity() != null) ? registrar.activity() : registrar.context());
    }

    private void init(final BinaryMessenger messenger, final Context context) {
        channel = new MethodChannel(messenger, "flutter_ffmpeg");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(messenger, "flutter_ffmpeg_event");
        eventChannel.setStreamHandler(this);
        this.context = context;
    }

    @Override
    public void onAttachedToEngine(final FlutterPluginBinding binding) {
        init(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(final FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }

        if (eventChannel != null) {
            eventChannel.setStreamHandler(null);
            eventChannel = null;
        }
    }

    /**
     * Handles method calls.
     *
     * @param call   method call
     * @param result result callback
     */
    @Override
    public void onMethodCall(final MethodCall call, final MethodChannel.Result result) {
        switch (call.method) {
            case "getPlatform":

                final String abi = AbiDetect.getAbi();
                flutterFFmpegResultHandler.success(result, toStringMap(KEY_PLATFORM, PLATFORM_NAME + "-" + abi));

                break;
            case "getFFmpegVersion":

                final String version = Config.getFFmpegVersion();
                flutterFFmpegResultHandler.success(result, toStringMap(KEY_VERSION, version));

                break;
            case "executeFFmpegWithArguments": {

                List<String> arguments = call.argument("arguments");

                assert arguments != null;
                final FlutterFFmpegExecuteFFmpegAsyncArgumentsTask asyncTask = new FlutterFFmpegExecuteFFmpegAsyncArgumentsTask(arguments, flutterFFmpegResultHandler, result);
                asyncTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

                break;
            }
            case "executeFFmpegAsyncWithArguments": {

                List<String> arguments = call.argument("arguments");

                assert arguments != null;
                long executionId = FFmpeg.executeAsync(arguments.toArray(new String[0]), new ExecuteCallback() {

                    @Override
                    public void apply(long executionId, int returnCode) {
                        final HashMap<String, Object> executeMap = new HashMap<>();
                        executeMap.put("executionId", executionId);
                        executeMap.put("returnCode", returnCode);

                        final HashMap<String, Object> eventMap = new HashMap<>();
                        eventMap.put(EVENT_EXECUTE, executeMap);

                        flutterFFmpegResultHandler.success(eventSink, eventMap);
                    }
                });

                flutterFFmpegResultHandler.success(result, FlutterFFmpegPlugin.toLongMap(FlutterFFmpegPlugin.KEY_EXECUTION_ID, executionId));

                break;
            }
            case "executeFFprobeWithArguments": {

                List<String> arguments = call.argument("arguments");

                assert arguments != null;
                final FlutterFFmpegExecuteFFprobeAsyncArgumentsTask asyncTask = new FlutterFFmpegExecuteFFprobeAsyncArgumentsTask(arguments, flutterFFmpegResultHandler, result);
                asyncTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

                break;
            }
            case "cancel": {

                Integer executionId = call.argument("executionId");
                if (executionId == null) {
                    FFmpeg.cancel();
                } else {
                    FFmpeg.cancel(executionId);
                }

                break;
            }
            case "enableRedirection":

                Config.enableRedirection();

                break;
            case "disableRedirection":

                Config.disableRedirection();

                break;
            case "getLogLevel": {

                final Level level = Config.getLogLevel();
                flutterFFmpegResultHandler.success(result, toIntMap(KEY_LOG_LEVEL, levelToInt(level)));

                break;
            }
            case "setLogLevel": {

                Integer level = call.argument("level");
                if (level == null) {
                    level = Level.AV_LOG_TRACE.getValue();
                }
                Config.setLogLevel(Level.from(level));

                break;
            }
            case "enableLogs":

                Config.enableLogCallback(new LogCallback() {

                    @Override
                    public void apply(final LogMessage logMessage) {
                        emitLogMessage(logMessage);
                    }
                });

                break;
            case "disableLogs":

                Config.enableLogCallback(new LogCallback() {

                    @Override
                    public void apply(LogMessage message) {
                        // EMPTY LOG CALLBACK
                    }
                });

                break;
            case "enableStatistics":

                Config.enableStatisticsCallback(new StatisticsCallback() {

                    @Override
                    public void apply(final Statistics statistics) {
                        emitStatistics(statistics);
                    }
                });

                break;
            case "disableStatistics":

                Config.enableStatisticsCallback(null);

                break;
            case "getLastReceivedStatistics":

                flutterFFmpegResultHandler.success(result, toMap(Config.getLastReceivedStatistics()));

                break;
            case "resetStatistics":

                Config.resetStatistics();

                break;
            case "setFontconfigConfigurationPath": {
                String path = call.argument("path");

                Config.setFontconfigConfigurationPath(path);

                break;
            }
            case "setFontDirectory": {

                String path = call.argument("fontDirectory");
                Map<String, String> map = call.argument("fontNameMap");

                Config.setFontDirectory(context, path, map);

                break;
            }
            case "getPackageName":

                final String packageName = Config.getPackageName();
                flutterFFmpegResultHandler.success(result, toStringMap(KEY_PACKAGE_NAME, packageName));

                break;
            case "getExternalLibraries":

                final List<String> externalLibraries = Config.getExternalLibraries();
                flutterFFmpegResultHandler.success(result, externalLibraries);

                break;
            case "getLastReturnCode":

                int lastReturnCode = Config.getLastReturnCode();
                flutterFFmpegResultHandler.success(result, toIntMap(KEY_LAST_RC, lastReturnCode));

                break;
            case "getLastCommandOutput":

                final String lastCommandOutput = Config.getLastCommandOutput();
                flutterFFmpegResultHandler.success(result, toStringMap(KEY_LAST_COMMAND_OUTPUT, lastCommandOutput));

                break;
            case "getMediaInformation": {
                final String path = call.argument("path");

                assert path != null;
                final FlutterFFmpegGetMediaInformationAsyncTask asyncTask = new FlutterFFmpegGetMediaInformationAsyncTask(path, flutterFFmpegResultHandler, result);
                asyncTask.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

                break;
            }
            case "registerNewFFmpegPipe":

                final String pipe = Config.registerNewFFmpegPipe(context);
                flutterFFmpegResultHandler.success(result, toStringMap(KEY_PIPE, pipe));

                break;
            case "closeFFmpegPipe":
                String ffmpegPipePath = call.argument("ffmpegPipePath");

                assert ffmpegPipePath != null;
                Config.closeFFmpegPipe(ffmpegPipePath);

                break;
            case "setEnvironmentVariable":
                String variableName = call.argument("variableName");
                String variableValue = call.argument("variableValue");

                Config.setEnvironmentVariable(variableName, variableValue);

                break;
            case "listExecutions":

                final List<Map<String, Object>> executionsList = toExecutionsList(FFmpeg.listExecutions());
                flutterFFmpegResultHandler.success(result, executionsList);

                break;
            default:
                flutterFFmpegResultHandler.notImplemented(result);
                break;
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
    }

    protected void emitLogMessage(final LogMessage logMessage) {
        final HashMap<String, Object> logWrapperMap = new HashMap<>();
        final HashMap<String, Object> logMap = new HashMap<>();

        logMap.put(KEY_LOG_EXECUTION_ID, logMessage.getExecutionId());
        logMap.put(KEY_LOG_LEVEL, levelToInt(logMessage.getLevel()));
        logMap.put(KEY_LOG_MESSAGE, logMessage.getText());

        logWrapperMap.put(EVENT_LOG, logMap);

        flutterFFmpegResultHandler.success(eventSink, logWrapperMap);
    }

    protected void emitStatistics(final Statistics statistics) {
        final HashMap<String, Object> statisticsMap = new HashMap<>();
        statisticsMap.put(EVENT_STAT, toMap(statistics));
        flutterFFmpegResultHandler.success(eventSink, statisticsMap);
    }

    public static int levelToInt(final Level level) {
        return (level == null) ? Level.AV_LOG_TRACE.getValue() : level.getValue();
    }

    public static HashMap<String, String> toStringMap(final String key, final String value) {
        final HashMap<String, String> map = new HashMap<>();
        map.put(key, value);
        return map;
    }

    public static HashMap<String, Integer> toIntMap(final String key, final int value) {
        final HashMap<String, Integer> map = new HashMap<>();
        map.put(key, value);
        return map;
    }

    public static HashMap<String, Long> toLongMap(final String key, final long value) {
        final HashMap<String, Long> map = new HashMap<>();
        map.put(key, value);
        return map;
    }

    public static Map<String, Object> toMap(final Statistics statistics) {
        final HashMap<String, Object> statisticsMap = new HashMap<>();

        if (statistics != null) {
            statisticsMap.put(KEY_STAT_EXECUTION_ID, statistics.getExecutionId());

            statisticsMap.put(KEY_STAT_TIME, statistics.getTime());
            statisticsMap.put(KEY_STAT_SIZE, (statistics.getSize() < Integer.MAX_VALUE) ? (int) statistics.getSize() : (int) (statistics.getSize() % Integer.MAX_VALUE));
            statisticsMap.put(KEY_STAT_BITRATE, statistics.getBitrate());
            statisticsMap.put(KEY_STAT_SPEED, statistics.getSpeed());

            statisticsMap.put(KEY_STAT_VIDEO_FRAME_NUMBER, statistics.getVideoFrameNumber());
            statisticsMap.put(KEY_STAT_VIDEO_QUALITY, statistics.getVideoQuality());
            statisticsMap.put(KEY_STAT_VIDEO_FPS, statistics.getVideoFps());
        }

        return statisticsMap;
    }

    public static List<Map<String, Object>> toExecutionsList(final List<FFmpegExecution> ffmpegExecutions) {
        final List<Map<String, Object>> executions = new ArrayList<>();

        for (int i = 0; i < ffmpegExecutions.size(); i++) {
            FFmpegExecution execution = ffmpegExecutions.get(i);

            Map<String, Object> executionMap = new HashMap<>();
            executionMap.put(KEY_EXECUTION_ID, execution.getExecutionId());
            executionMap.put(KEY_EXECUTION_START_TIME, execution.getStartTime().getTime());
            executionMap.put(KEY_EXECUTION_COMMAND, execution.getCommand());

            executions.add(executionMap);
        }

        return executions;
    }

    public static Map<String, Object> toMediaInformationMap(final MediaInformation mediaInformation) {
        Map<String, Object> map = new HashMap<>();

        if (mediaInformation != null) {
            if (mediaInformation.getAllProperties() != null) {
                JSONObject allProperties = mediaInformation.getAllProperties();
                if (allProperties != null) {
                    map = toMap(allProperties);
                }
            }
        }

        return map;
    }

    public static Map<String, Object> toMap(final JSONObject jsonObject) {
        final HashMap<String, Object> map = new HashMap<>();

        if (jsonObject != null) {
            Iterator<String> keys = jsonObject.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                Object value = jsonObject.opt(key);
                if (value != null) {
                    if (value instanceof JSONArray) {
                        value = toList((JSONArray) value);
                    } else if (value instanceof JSONObject) {
                        value = toMap((JSONObject) value);
                    }
                    map.put(key, value);
                }
            }
        }

        return map;
    }

    public static List<Object> toList(final JSONArray array) {
        final List<Object> list = new ArrayList<>();

        for (int i = 0; i < array.length(); i++) {
            Object value = array.opt(i);
            if (value != null) {
                if (value instanceof JSONArray) {
                    value = toList((JSONArray) value);
                } else if (value instanceof JSONObject) {
                    value = toMap((JSONObject) value);
                }
                list.add(value);
            }
        }

        return list;
    }
}
