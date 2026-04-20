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
import { SegmentButton, SegmentButtonOptions } from '@ohos.arkui.advanced.SegmentButton';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { RingtoneType } from '../constant/VolumeConstant';
import { ToneAttrs } from '../model/VolumeType';
import { RingtoneSimUtil } from '../utils/RingtoneSimUtil';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { SystemRingTonePage } from './SystemRingToneComponent';

const TAG: string = 'RingToneSettingsComponent : ';
const CARD_NUM: number = 2;

@Component
export struct RingToneSettingsComponent {
  private card1Type: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
  private card2Type: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_1;
  private dataKey1 = 'RingToneCard1';
  private dataKey2 = 'RingToneCard2';
  private otaFlagForRingtone = 'otaFlagForRingtone';
  private localeChangeForRingtone: string = 'localeChangeForRingtone';
  @State ringCard1List: Array<ToneAttrs> | null = null;
  @State ringCard2List: Array<ToneAttrs> | null = null;
  @State tabSelectedIndexes: number[] = [0];
  @State tabOptions: SegmentButtonOptions | undefined = RingtoneSimUtil.getSimCardTabs();

  private async getCardData(): Promise<void> {
    this.ringCard1List = PreferencesUtil.getSync(this.dataKey1, []) as Array<ToneAttrs>;
    this.ringCard2List = PreferencesUtil.getSync(this.dataKey2, []) as Array<ToneAttrs>;
    let isLocaleChange: boolean = PreferencesUtil.getSync(this.localeChangeForRingtone, false) as boolean;
    let curVersion: string = AboutDeviceUtils.getSoftwareVersion();
    let otaFlag: boolean = PreferencesUtil.getSync(this.otaFlagForRingtone + '_version', '') as string !== curVersion;
    if (!PreferencesUtil.hasSync(this.dataKey1) || isLocaleChange || this.ringCard1List.length === 0 ||
      this.ringCard2List.length === 0 || otaFlag) {
      this.ringCard1List = await RingtonesUtils.getRingerToneList(this.card1Type,
        RingtoneType.RINGTONE_TYPE_SIM);
      this.ringCard2List = await RingtonesUtils.getRingerToneList(this.card2Type,
        RingtoneType.RINGTONE_TYPE_SIM);
      PreferencesUtil.putSync(this.dataKey1, this.ringCard1List);
      PreferencesUtil.putSync(this.dataKey2, this.ringCard2List);
      // ota场景刷新一次，避免出现列表不显示问题
      PreferencesUtil.putSync(this.otaFlagForRingtone + '_version', curVersion);
      LogUtil.showInfo(TAG, `getCardData ringCardList: ${this.ringCard1List.length}, ${this.ringCard2List.length}, isLocalChange: ${isLocaleChange}, otaFlag: ${otaFlag}`);
      return;
    }
    LogUtil.showInfo(TAG, `get ringtone list from preference : ${this.ringCard1List.length}, ${this.ringCard2List.length}, otaFlag: ${otaFlag}`);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getCardData();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  build() {
    if (SimUtils.getCardSlotNum() === CARD_NUM) {
      Column() {
        SegmentButton({ options: this.tabOptions, selectedIndexes: $tabSelectedIndexes })
          .focusable(false)
          .defaultFocus(false)
          .margin({
            top: $r('app.float.wh_value_16'),
            bottom: $r('app.float.wh_value_12'),
            left: $r('app.float.wh_value_16'),
            right: $r('app.float.wh_value_16')
          })
          .constraintSize({ minHeight: $r('app.float.wh_value_40')})
        this.buildContent();
      }
    } else {
      if (this.ringCard1List !== null) {
        SystemRingTonePage({
          ringList: this.ringCard1List.filter(tone => {
            return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
          }),
          navKey: NavEntryKey.RING_TONE_ENTRY,
        })
          .size({ width: '100%', height: '100%' })
          .margin({ top: $r('sys.float.padding_level9') })
      }
    }
  }
  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  @Builder
  buildContent() {
    Column() {
      if (this.tabSelectedIndexes[0] === 0) {
        if (this.ringCard1List !== null) {
          SystemRingTonePage({
            ringList: this.ringCard1List.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            currentIndex: this.tabSelectedIndexes[0],
            navKey: NavEntryKey.RING_TONE_ENTRY,
          })
            .size({ width: '100%', height: '100%' })
        }
      } else {
        if (this.ringCard2List !== null) {
          SystemRingTonePage({
            ringList: this.ringCard2List.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            currentIndex: this.tabSelectedIndexes[0],
            navKey: NavEntryKey.RING_TONE_ENTRY,
          })
            .size({ width: '100%', height: '100%' })
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }
}