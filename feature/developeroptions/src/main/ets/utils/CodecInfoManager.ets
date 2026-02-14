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

import commonEventManager from '@ohos.commonEventManager';
import a2dp from '@ohos.bluetooth.a2dp';
import { BusinessError } from '@ohos.base';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { DECODER_METHOD_CHANGE } from '../controller/BluetoothAudioController';
/* instrument ignore file */

const COMMON_EVENT_BLUETOOTH_ACTIVEADDR_DEVICE_ID: string = 'usual.event.bluetooth.activeaddr.DEVICE_ID';

export class CodecInfoManager {
  public TAG: string = 'CodecInfoManager :';
  private static manager: CodecInfoManager | undefined = undefined;
  private readonly subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [COMMON_EVENT_BLUETOOTH_ACTIVEADDR_DEVICE_ID]
  };
  private deviceId: string = '';
  private a2dpProfile: a2dp.A2dpSourceProfile | undefined = undefined;
  private supportCodecInfos: Array<a2dp.CodecInfoList> | undefined = undefined;
  private codecInfo: a2dp.CodecInfo | undefined = undefined;
  private eventChange: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${this.TAG} codecInfo eventChanged: ${data.event}`);
    if (data?.event === COMMON_EVENT_BLUETOOTH_ACTIVEADDR_DEVICE_ID && data?.parameters?.profiletype === 'a2dp') {
      LogUtil.info(`${this.TAG} codecInfo eventChanged: ${BluetoothUtils.getLogMAC(data?.parameters?.deviceAddr)}`);
      this.deviceId = data?.parameters?.deviceAddr;
      if (!this.deviceId) {
        this.a2dpProfile = undefined;
        this.supportCodecInfos = undefined;
        this.codecInfo = undefined;
        EventBus.getInstance().emit(DECODER_METHOD_CHANGE, a2dp.CodecType.CODEC_TYPE_INVALID);
        return;
      }
      try {
        this.a2dpProfile = a2dp.createA2dpSrcProfile();
        this.supportCodecInfos = this.a2dpProfile.getCurrentFullCodecInfo(this.deviceId);
        LogUtil.info(`${this.TAG} supportCodecInfos:${JSON.stringify(this.supportCodecInfos)}`);
        this.codecInfo = this.a2dpProfile.getCurrentCodecInfo(this.deviceId);
        LogUtil.info(`${this.TAG} codecInfo:${JSON.stringify(this.codecInfo)}`);
        EventBus.getInstance().emit(DECODER_METHOD_CHANGE, this.codecInfo?.codecType);
      } catch (err) {
        LogUtil.error(`${this.TAG} errCode:${(err as BusinessError)?.code}, message:${(err as BusinessError)?.message}`);
      }
    }
  })

  /**
   * 获取管理类实例
   *
   * @returns 管理类实例
   */
  public static getInstance(): CodecInfoManager {
    if (CodecInfoManager.manager) {
      return CodecInfoManager.manager;
    }
    CodecInfoManager.manager = new CodecInfoManager();
    return CodecInfoManager.manager;
  }

  /**
   * 更新CodecInfo
   */
  updateCodecInfo(): void {
    if (this.codecInfo?.codecType !== a2dp.CodecType.CODEC_TYPE_L2HC &&
      this.codecInfo?.codecType !== a2dp.CodecType.CODEC_TYPE_L2HCST) {
      this.codecInfo = {
        codecType: this.codecInfo?.codecType ?? a2dp.CodecType.CODEC_TYPE_INVALID,
        codecBitsPerSample: this.codecInfo?.codecBitsPerSample ?? a2dp.CodecBitsPerSample.CODEC_BITS_PER_SAMPLE_NONE,
        codecChannelMode: this.codecInfo?.codecChannelMode ?? a2dp.CodecChannelMode.CODEC_CHANNEL_MODE_NONE,
        codecSampleRate: this.codecInfo?.codecSampleRate ?? a2dp.CodecSampleRate.CODEC_SAMPLE_RATE_NONE
      } as a2dp.CodecInfo;
    }
    LogUtil.info(`${this.TAG} setCurrentCodecInfo = ${JSON.stringify(this.codecInfo)}`);
    try {
      this.a2dpProfile?.setCurrentCodecInfo(this.deviceId, this.codecInfo);
    } catch (err) {
      LogUtil.error(`${this.TAG} setCodecInfoErr:${(err as BusinessError)?.code} ${(err as BusinessError)?.message}`);
    }
  }

  /**
   * 获取CodecInfo
   *
   * @returns 音频信息
   */
  getCodecInfo(): a2dp.CodecInfo | undefined {
    return this.codecInfo;
  }

  /**
   * 获取当前音频能力集
   *
   * @returns 当前音频能力集
   */
  getCodecInfoListArray(): Array<a2dp.CodecInfoList> | undefined {
    return this.supportCodecInfos;
  }

  /**
   * 设置解码类型
   *
   * @param key 解码类型
   */
  setCodecType(key: number): void {
    if (!this.codecInfo || !this.supportCodecInfos) {
      return;
    }
    for (let index = 0; index < this.supportCodecInfos.length; index++) {
      if (this.supportCodecInfos[index]?.codecType === key) {
        let codecInfoList: a2dp.CodecInfoList = this.supportCodecInfos[index];
        this.codecInfo.codecType = codecInfoList.codecType;
        if (!CheckEmptyUtils.isEmptyArr(codecInfoList.codecBitRateArray) &&
          (key === a2dp.CodecType.CODEC_TYPE_L2HC || key === a2dp.CodecType.CODEC_TYPE_L2HCST)) {
          this.codecInfo.codecBitRate = codecInfoList.codecBitRateArray[0];
        } else {
          this.codecInfo.codecBitRate = undefined;
        }
        if (!CheckEmptyUtils.isEmptyArr(codecInfoList.codecSampleRateArray)) {
          this.codecInfo.codecSampleRate = codecInfoList.codecSampleRateArray[0];
        }
        if (!CheckEmptyUtils.isEmptyArr(codecInfoList.codecBitsPerSampleArray)) {
          this.codecInfo.codecBitsPerSample = codecInfoList.codecBitsPerSampleArray[0];
        }
        if (!CheckEmptyUtils.isEmptyArr(codecInfoList.codecChannelModeArray)) {
          this.codecInfo.codecChannelMode = codecInfoList.codecChannelModeArray[0];
        }
        if (!CheckEmptyUtils.isEmptyArr(codecInfoList.codecFrameLengthArray)) {
          this.codecInfo.codecFrameLength = codecInfoList.codecFrameLengthArray[0];
        }
        break;
      }
    }
  }


  /**
   * 设置码率
   *
   * @param key 码率
   */
  setCodecBitRate(key: number): void {
    if (this.codecInfo) {
      this.codecInfo.codecBitRate = key;
    }
  }

  /**
   * 设置采样率
   *
   * @param key 采样率
   */
  setCodecSampleRate(key: number): void {
    if (this.codecInfo) {
      this.codecInfo.codecSampleRate = key;
    }
  }

  /**
   * 设置采样位深
   *
   * @param key 采样位深
   */
  setCodecBitsPerSample(key: number): void {
    if (this.codecInfo) {
      this.codecInfo.codecBitsPerSample = key;
    }
  }

  /**
   * 设置声道
   *
   * @param key 声道
   */
  setCodecChannelMode(key: number): void {
    if (this.codecInfo) {
      this.codecInfo.codecChannelMode = key;
    }
  }

  /**
   * 设置帧长
   *
   * @param key 帧长
   */
  setCodecFrameLength(key: number): void {
    if (this.codecInfo) {
      this.codecInfo.codecFrameLength = key;
    }
  }

  /**
   * 注册监听
   */
  registerCommonEvent() {
    CodecInfoManager.getInstance().eventChange.registerCommonEvent();
  }

  /**
   * 取消注册监听
   */
  unRegisterCommonEvent() {
    CodecInfoManager.getInstance().eventChange.unRegisterCommonEvent();
    this.a2dpProfile = undefined;
    this.supportCodecInfos = undefined;
    this.codecInfo = undefined;
  }
}