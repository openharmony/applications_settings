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

import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { RadioName } from '../constant/VibrateConstant';
import { ToneType } from './RingtoneParam';

/**
 * 振动参数
 */
export class VibrateParam {

  //铃声类型
  public toneType: ToneType;

  //是否使用默认的振动类型
  public isUseDefault: boolean;

  //是否是系统铃声
  public isSystemRingTone: boolean;

  //卡类型
  public toneHapticsType: systemSoundManager.ToneHapticsType;

  //振动配置
  public toneHapticsSettings: MyToneHapticsSettings;

  //默认的振动按钮名
  public defaultVibrateRadioName: string;

  //选择的振动按钮名
  public checkedVibrateRadioName: string;

  constructor(toneType: ToneType = ToneType.RINGTONE, isUseDefault: boolean = true, isSystemRingTone: boolean = true
    , toneHapticsType: systemSoundManager.ToneHapticsType = systemSoundManager.ToneHapticsType.CALL_SIM_CARD_0,
    toneHapticsSettings: MyToneHapticsSettings = new MyToneHapticsSettings(systemSoundManager.ToneHapticsMode.SYNC)
    , checkedVibrateRadioName: string = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE
    , defaultVibrateRadioName: string = RadioName.VIBRATE_SYNCHRONIZE_WITH_RINGTONE) {
    this.toneType = toneType;
    this.isUseDefault = isUseDefault;
    this.isSystemRingTone = isSystemRingTone;
    this.toneHapticsType = toneHapticsType;
    this.toneHapticsSettings = toneHapticsSettings;
    this.checkedVibrateRadioName = checkedVibrateRadioName;
    this.defaultVibrateRadioName = defaultVibrateRadioName;
  }
}

export class MyToneHapticsSettings implements systemSoundManager.ToneHapticsSettings {
  public mode: systemSoundManager.ToneHapticsMode;
  public hapticsUri?: string;

  constructor(mode: systemSoundManager.ToneHapticsMode, hapticsUri?: string) {
    this.mode = mode;
    if (hapticsUri) {
      this.hapticsUri = hapticsUri;
    }
  }
}