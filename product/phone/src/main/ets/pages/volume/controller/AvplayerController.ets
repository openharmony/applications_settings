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

import fs from '@ohos.file.fs';
import media from '@ohos.multimedia.media';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import audio from '@ohos.multimedia.audio';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const AUDIO_VOLUME_TYPE_MEDIA = audio.AudioVolumeType.MEDIA;

let count: number = 0;
let tempBuffer: ArrayBuffer = new ArrayBuffer(4096 * 100);
let path: string = '';
let readLen: number = 0;
let writeLen: number = 0;
let avPlayerTypeRecode: number = -1;
let sliderValueRecode: number = -1;
let avPlayer: media.AVPlayer | null = null;
let audioRendererInfo: audio.AudioRendererInfo = {
  content: 0, //媒体类型
  usage: 0, //音频流使用类型。
  rendererFlags: 0 //音频渲染器标志
};

enum NumTypeChooes {
  clallNum = 0,
  ringNym = 2,
  mediaNum = 3,
  alarmNum = 4,
};

export class AvplayerController {
  // 注销页面时  清除音频播放
  static releaseAvplayer(): void {
    if (avPlayer != null) {
      avPlayerTypeRecode = -1;
      avPlayer.release();
    }
  };

  // 注册avplayer回调函数
  static setAVPlayerCallback(avPlayer: media.AVPlayer) {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      LogUtil.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      LogUtil.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('volumeChange', (vol: number) => {
      LogUtil.info(`volumeChange success,and new volume is :${vol}`);
    })
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          avPlayer.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          avPlayer.audioRendererInfo = audioRendererInfo;
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          avPlayer.play((err: BusinessError) => {
            if (err == null) {
              LogUtil.info('play preparedsuccess');
            } else {
              LogUtil.error(`play filed,error preparedmessage is :${err.message}`);
            }
          }); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          if (count !== 0) {
            if (avPlayerTypeRecode === AUDIO_VOLUME_TYPE_MEDIA) {
              avPlayer.setVolume(sliderValueRecode);
            } else {
              // 当播放模式不支持seek操作时继续播放到结尾
              LogUtil.info('AVPlayer wait to play end.');
            }
          }
          count++;
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          avPlayer.play((err: BusinessError) => {
            if (err == null) {
              LogUtil.info('play pausedsuccess');
            } else {
              LogUtil.error(`play filed,error pausedmessage is :${err.message}`);
            }
          }); // 再次播放接口开始播放
          break;
        case 'completed': // 播放结束后触发该状态机上报
          LogUtil.info('AVPlayer state completed called.');
          avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          LogUtil.info('AVPlayer state stopped called.');
          avPlayer.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          LogUtil.info('AVPlayer state released called.');
          break;
        default:
          LogUtil.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  // 以下demo为使用资源管理接口获取打包在HAP内的媒体资源文件并通过fdSrc属性进行播放示例
  static async avPlayerFdSrcDemo(sliderValue: number, avPlayerType: number, avPlayerMedia: string) {
    // 判定初始化音频播放
    if (avPlayer !== null) {
      avPlayer.stop(); //调用播放结束接口
      avPlayer.release();
    }
    // 初始化 Avplayer 创建avPlayer实例对象
    avPlayer = await media.createAVPlayer();
    switch (avPlayerType) {
      case NumTypeChooes.mediaNum:
        audioRendererInfo.usage = audio.StreamUsage.STREAM_USAGE_MUSIC;
        break;
      case NumTypeChooes.clallNum:
        audioRendererInfo.usage = audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION;
        break;
      case NumTypeChooes.ringNym:
        audioRendererInfo.usage = audio.StreamUsage.STREAM_USAGE_NOTIFICATION;
        break;
      case NumTypeChooes.alarmNum:
        audioRendererInfo.usage = audio.StreamUsage.STREAM_USAGE_ALARM;
        break;
      default:
        break;
    }

    AvplayerController.setAVPlayerCallback(avPlayer);
    // 保存输入音量、音频类型
    avPlayerTypeRecode = avPlayerType;
    sliderValueRecode = sliderValue;
    // 创建状态机变化回调函数
    let context = getContext(AvplayerController) as common.UIAbilityContext;
    path = context.filesDir;
    let fileDescriptor = await context.resourceManager.getRawFd(`${avPlayerMedia}`);
    readLen = fs.readSync(fileDescriptor.fd, tempBuffer,
      { offset: fileDescriptor.offset, length: fileDescriptor.length });
    let file = fs.openSync(path + '/volume_adjust.wav', 0o102);
    writeLen = fs.writeSync(file.fd, tempBuffer, { length: readLen });
    let avFileDescriptor: media.AVFileDescriptor = { fd: file.fd, offset: 0, length: writeLen };
    avPlayer.fdSrc = avFileDescriptor;
  }
}