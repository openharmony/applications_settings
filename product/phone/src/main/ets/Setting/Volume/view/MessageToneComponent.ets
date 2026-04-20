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
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton';
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { ToneAttrs } from '../model/VolumeType';
import { SystemRingTonePage } from './SystemRingToneComponent';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import { RingtoneType } from '../constant/VolumeConstant';
import { RingtoneSimUtil } from '../utils/RingtoneSimUtil';

const TAG: string = 'MessageToneComponent';
const CARD_NUM: number = 2;

@Component
export struct MessageToneComponent {
  private cardType: systemSoundManager.SystemToneType = systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
  private dataKey = 'MessageTone';
  private otaFlagForMessage = 'otaFlagForMessage';
  private localeChangeForMessageTone: string = 'localeChangeForMessageTone';
  @State messageList: Array<ToneAttrs> | null = null;
  @State tabSelectedIndexes: number[] = [0];
  @State tabOptions: SegmentButtonOptions | undefined = RingtoneSimUtil.getSimCardTabs();

  private async getCardData(): Promise<void> {
    let messageList = PreferencesUtil.getSync(this.dataKey, []) as Array<ToneAttrs>;
    this.messageList = messageList;
    let isLocaleChange: boolean = PreferencesUtil.getSync(this.localeChangeForMessageTone, false) as boolean;
    let curVersion: string = AboutDeviceUtils.getSoftwareVersion();
    let otaFlag: boolean = PreferencesUtil.getSync(this.otaFlagForMessage + '_version', '') as string !== curVersion;

    if (!PreferencesUtil.hasSync(this.dataKey) || isLocaleChange || messageList.length === 0 || otaFlag) {
      messageList = await RingtonesUtils.getRingerToneList(this.cardType,
        RingtoneType.RINGTONE_TYPE_SMS);
      this.messageList = messageList;
      LogUtil.showInfo(TAG,
        `getCardData messageList: ${messageList.length}, isLocalChange: ${isLocaleChange}, otaFlag: ${otaFlag}`);
      PreferencesUtil.putSync(this.dataKey, messageList);
      // ota场景刷新一次，避免出现列表不显示问题
      PreferencesUtil.putSync(this.otaFlagForMessage + '_version', curVersion);
      return;
    }
    LogUtil.showInfo(TAG,
      `get messageList from preference : ${messageList.length}, isLocalChange: ${isLocaleChange}, otaFlag: ${otaFlag}`);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getCardData();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  build() {
    Column() {
      Blank().height($r('app.float.navigation_56'))
      if (SimUtils.getCardSlotNum() === CARD_NUM) {
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
      } else {
        if (this.messageList !== null) {
          SystemRingTonePage({
            ringList: this.messageList.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            navKey: NavEntryKey.MESSAGING_TONE_ENTRY,
          })
            .size({ width: '100%', height: '100%' })
            .margin({ top: $r('sys.float.padding_level9') })
        }
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
        if (this.messageList !== null) {
          SystemRingTonePage({
            ringList: this.messageList.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            currentIndex: this.tabSelectedIndexes[0],
            navKey: NavEntryKey.MESSAGING_TONE_ENTRY,
          })
            .size({ width: '100%', height: '100%' })
        }
      } else {
        if (this.messageList !== null) {
          SystemRingTonePage({
            ringList: this.messageList.filter(tone => {
              return tone.customizedType === systemSoundManager.ToneCustomizedType.PRE_INSTALLED
            }),
            currentIndex: this.tabSelectedIndexes[0],
            navKey: NavEntryKey.MESSAGING_TONE_ENTRY,
          })
            .size({ width: '100%', height: '100%' })
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM])
    .justifyContent(FlexAlign.Start)
    .layoutWeight(1)
  }
}