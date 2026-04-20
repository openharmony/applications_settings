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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HOTSPOT_CONFIG_CHANGE_EVENT, USER_DATA_LIMIT_CONFIRM_EVENT } from '../utils/HotspotUtils'
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { INPUT_CHANGE_EVENT, INPUT_IS_CUSTOM } from './CustomLimitInputComponent';
import { HotspotLimitDataManager } from '../HotspotLimitDataManager';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
/* instrument ignore file */
const TAG: string = 'HotspotLimitConfimComponent';

@Builder
export function buildConfirmButton(param: object): void {
  HotspotLimitConfimComponent();
}

@Component
export struct HotspotLimitConfimComponent {
  @State isValid: boolean = this.checkEnableState();
  private inputStr: string = '';
  private isCustomInputShow: boolean = false;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.isCustomInputShow = HotspotLimitDataManager.getInstance().isCustomized();
    EventBus.getInstance().on(INPUT_IS_CUSTOM, (isCustom: boolean) => {
      LogUtil.info(`${TAG} INPUT_IS_CUSTOM ${isCustom}`);
      this.isCustomInputShow = isCustom;
    })
    EventBus.getInstance().on(INPUT_CHANGE_EVENT, (input: string) => {
      LogUtil.info(`${TAG} INPUT_CHANGE_EVENT input: ${input}`);
      this.inputStr = input;
    });
    EventBus.getInstance().on(HOTSPOT_CONFIG_CHANGE_EVENT, () => {
      LogUtil.info(`${TAG} HOTSPOT_CONFIG_CHANGE_EVENT`);
      this.isValid = this.checkEnableState();
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
    EventBus.getInstance().off(INPUT_IS_CUSTOM);
    EventBus.getInstance().off(INPUT_CHANGE_EVENT);
    EventBus.getInstance().off(HOTSPOT_CONFIG_CHANGE_EVENT);
  }

  private dealClick(): void {
    LogUtil.info(`${TAG} dealClick.`);
    EventBus.getInstance().emit(USER_DATA_LIMIT_CONFIRM_EVENT);
  }

  private checkEnableState(): boolean {
    if (this.isCustomInputShow) {
      LogUtil.info(`${TAG} is custom. inputStr: ${this.inputStr}`);
      if (StringUtil.isEmpty(this.inputStr)) {
        return false;
      }
      let inputNum: number = parseInt(this.inputStr);
      if (Number.isNaN(inputNum) || inputNum === 0) {
        return false
      }
    }
    return true;
  }

  build() {
    Column() {
      Button() {
        Row() {
          Text($r('app.string.confirm'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .constraintSize({
              minHeight: $r('app.float.wh_value_21'),
            })
            .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .enabled(this.isValid)
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
      .onClick(() => {
        this.dealClick();
      })
      .constraintSize({
        minHeight: 40,
      })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('app.color.component_ultra_thick_panel'))
    .padding({
      bottom: $r('sys.float.padding_level12'),
      top: $r('sys.float.padding_level12'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }
}