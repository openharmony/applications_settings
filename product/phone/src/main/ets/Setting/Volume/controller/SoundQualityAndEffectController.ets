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

/* instrument ignore file */
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  COMFORT_ENJOY_MODE,
  NOBLE_ENJOY_MODE,
  QUIET_ENJOY_MODE,
  SOUND_QUALITY_EFFECT
} from '../constant/VolumeConstant';

export const NOBLE_ENJOY_MODE_ID: string = 'noble_enjoy_mode';
export const COMFORT_ENJOY_MODE_ID: string = 'comfort_enjoy_mode';
export const QUIET_ENJOY_MODE_ID: string = 'quiet_enjoy_mode';

const TAG: string = 'SoundQualityAndEffectController';

export class SoundQualityAndEffectController implements ComponentControl {
  private currentSoundEffectMode: string = COMFORT_ENJOY_MODE;
  private compId: string = '';
  public onCheckFunc = (isCheck: boolean, mode: string) => {
    if (!isCheck) {
      LogUtil.warn(`${TAG} no need update for isCheck is false`);
      return;
    }
    this.currentSoundEffectMode = (mode === NOBLE_ENJOY_MODE_ID) ? NOBLE_ENJOY_MODE :
      (mode === QUIET_ENJOY_MODE_ID ? QUIET_ENJOY_MODE : COMFORT_ENJOY_MODE);
    LogUtil.info(`${TAG} update sound effect with value:${this.currentSoundEffectMode}`);
    SettingsDataUtils.setSettingsData(SOUND_QUALITY_EFFECT, this.currentSoundEffectMode);
  }

  constructor() {
    this.currentSoundEffectMode =
      SettingsDataUtils.getSettingsData(SOUND_QUALITY_EFFECT, COMFORT_ENJOY_MODE);
    LogUtil.info(`${TAG} getSoundEffectMode with currentSoundEffectMode: ${this.currentSoundEffectMode}`);
  }

  public isChecked(mode: string): boolean {
    switch (mode) {
      case NOBLE_ENJOY_MODE_ID:
        return this.currentSoundEffectMode === NOBLE_ENJOY_MODE;
      case QUIET_ENJOY_MODE_ID:
        return this.currentSoundEffectMode === QUIET_ENJOY_MODE;
      case COMFORT_ENJOY_MODE_ID:
      default:
        return this.currentSoundEffectMode !== QUIET_ENJOY_MODE &&
          this.currentSoundEffectMode !== NOBLE_ENJOY_MODE;
    }
  }

  private updateUI(): void {
    let modeId: string = this.currentSoundEffectMode === QUIET_ENJOY_MODE ? QUIET_ENJOY_MODE_ID :
      (this.currentSoundEffectMode === NOBLE_ENJOY_MODE ? NOBLE_ENJOY_MODE_ID : COMFORT_ENJOY_MODE_ID);
    LogUtil.info(`${TAG} updateUI with modeId: ${modeId}`);
    notifyCompStateChange(`${this.compId}.${modeId}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_RADIO,
        result: { checked: true }
      } as SettingResultState]]));
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.compId = compParam?.compId;
    SettingsDataUtils.registerKeyObserver(SOUND_QUALITY_EFFECT, () => {
      let mode: string = SettingsDataUtils.getSettingsData(SOUND_QUALITY_EFFECT, COMFORT_ENJOY_MODE);
      LogUtil.info(`${TAG} sound effect changed with value: ${mode}, current value: ${this.currentSoundEffectMode}`);
      if (this.currentSoundEffectMode !== mode) {
        this.currentSoundEffectMode = mode;
        this.updateUI();
      }
    })
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    SettingsDataUtils.unregisterKeyObserverUser(SOUND_QUALITY_EFFECT);
  }
}