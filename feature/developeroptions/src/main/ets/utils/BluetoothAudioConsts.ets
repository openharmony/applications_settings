/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import a2dp from '@ohos.bluetooth.a2dp';

/**
 * 蓝牙音频设置页面枚举
 */
export enum BluetoothAudioType {
  DECODER, // 解码器
  L2HC_BITRATE, // L2HC码率
  SAMPLING_RATE, // 采样率
  BITS_PER_SAMPLE, // 采样位深
  CHANNEL_MODE, // 声道数
  FRAME_LENGTH // 帧长
}

export const BLUETOOTH_AUDIO_DECODER_MAP: Map<a2dp.CodecType, string> = new Map([
  [a2dp.CodecType.CODEC_TYPE_L2HCST, 'L2HC'],
  [a2dp.CodecType.CODEC_TYPE_L2HC, 'L2HC'],
  [a2dp.CodecType.CODEC_TYPE_SBC, 'SBC'],
  [a2dp.CodecType.CODEC_TYPE_AAC, 'AAC'],
  [a2dp.CodecType.CODEC_TYPE_LDAC, 'LDAC']
]);

export const BLUETOOTH_AUDIO_BITRATE_MONO_LIST: number[] =
  [a2dp.CodecBitRate.CODEC_BIT_RATE_96000, a2dp.CodecBitRate.CODEC_BIT_RATE_128000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_320000, a2dp.CodecBitRate.CODEC_BIT_RATE_480000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_ABR];

export const BLUETOOTH_AUDIO_BITRATE_STEREO_LIST: number[] =
  [a2dp.CodecBitRate.CODEC_BIT_RATE_192000, a2dp.CodecBitRate.CODEC_BIT_RATE_256000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_320000, a2dp.CodecBitRate.CODEC_BIT_RATE_480000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_640000, a2dp.CodecBitRate.CODEC_BIT_RATE_960000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_ABR, a2dp.CodecBitRate.CODEC_BIT_RATE_1500000,
    a2dp.CodecBitRate.CODEC_BIT_RATE_2300000];

export const BLUETOOTH_AUDIO_BITRATE_MAP: Map<number, string> = new Map([
  [a2dp.CodecBitRate.CODEC_BIT_RATE_96000, '96kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_128000, '128kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_192000, '192kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_256000, '256kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_320000, '320kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_480000, '480kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_640000, '640kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_960000, '960kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_ABR, 'bluetooth_audio_bit_rate_adaptive'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_1500000, '1500kbps'],
  [a2dp.CodecBitRate.CODEC_BIT_RATE_2300000, '2300kbps'],
]);

export const BLUETOOTH_AUDIO_SAMPLING_RATE_MAP: Map<number, string> = new Map([
  [a2dp.CodecSampleRate.CODEC_SAMPLE_RATE_44100, '44.1KHz'],
  [a2dp.CodecSampleRate.CODEC_SAMPLE_RATE_48000, '48KHz'],
  [a2dp.CodecSampleRate.CODEC_SAMPLE_RATE_88200, '88.2KHz'],
  [a2dp.CodecSampleRate.CODEC_SAMPLE_RATE_96000, '96KHz'],
]);


export const BLUETOOTH_AUDIO_BITS_PER_SAMPLE_MAP: Map<number, string> = new Map([
  [a2dp.CodecBitsPerSample.CODEC_BITS_PER_SAMPLE_16, '16bit'],
  [a2dp.CodecBitsPerSample.CODEC_BITS_PER_SAMPLE_24, '24bit'],
  [a2dp.CodecBitsPerSample.CODEC_BITS_PER_SAMPLE_32, '32bit']
]);


export const BLUETOOTH_AUDIO_CHANNEL_MODE_MAP: Map<number, string> = new Map([
  [a2dp.CodecChannelMode.CODEC_CHANNEL_MODE_MONO, 'bluetooth_audio_channel_mode_mono'],
  [a2dp.CodecChannelMode.CODEC_CHANNEL_MODE_STEREO, 'bluetooth_audio_channel_mode_stereo']
]);


export const BLUETOOTH_AUDIO_FRAME_LENGTH_MAP: Map<number, [string, number]> = new Map([
  [a2dp.CodecFrameLength.CODEC_FRAME_LENGTH_5MS, ['bluetooth_audio_frame_length_mode', 5]],
  [a2dp.CodecFrameLength.CODEC_FRAME_LENGTH_10MS, ['bluetooth_audio_frame_length_mode', 10]],
]);

