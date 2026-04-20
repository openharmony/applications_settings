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

import { configPolicy } from '@kit.BasicServicesKit';
import { PADDING_12, PADDING_20, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  EVENT_ID_DARK_MODE_CACHE,
  EVENT_ID_MAINABILITY_ON_BACKGROUND,
  EVENT_ID_MAINABILITY_ON_FOREGROUND
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
/* instrument ignore file */
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'NFCAnimationComponent: ';
const RESOURCE_PATH_PREFIX: string = 'etc/settings/nfc_guide_animation/';
const FILE_PREFIX: string = 'file://';
const ANIMATION_WHITE: string = 'NFC_White.mp4';
const ANIMATION_DARK: string = 'NFC_Dark.mp4';

@Component
export struct NFCAnimationComponent {
  private controller: VideoController = new VideoController();
  @State isVisible: Visibility = Visibility.Hidden;
  @State innerResource: string = this.getAnimationResource(AppStorage.get<number>('changeMode') === 0);

  private eventDarkModeChange = (isDarkMode: boolean) => {
    this.innerResource = this.getAnimationResource(isDarkMode);
    LogUtil.showInfo(TAG, `eventDarkModeChange, isDarkMode: ${isDarkMode}`);
  };
  private mainAbilityOnForeground = () => {
    this.controller.start();
    LogUtil.showInfo(TAG, 'mainAbilityOnForeground');
  };
  private mainAbilityOnBackground = () => {
    this.controller.pause();
    LogUtil.showInfo(TAG, 'mainAbilityOnBackground');
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    EventBus.getInstance().on(EVENT_ID_DARK_MODE_CACHE, this.eventDarkModeChange);
    EventBus.getInstance().on(EVENT_ID_MAINABILITY_ON_FOREGROUND, this.mainAbilityOnForeground);
    EventBus.getInstance().on(EVENT_ID_MAINABILITY_ON_BACKGROUND, this.mainAbilityOnBackground);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(EVENT_ID_DARK_MODE_CACHE, this.eventDarkModeChange);
    EventBus.getInstance().detach(EVENT_ID_MAINABILITY_ON_FOREGROUND, this.mainAbilityOnForeground);
    EventBus.getInstance().detach(EVENT_ID_MAINABILITY_ON_BACKGROUND, this.mainAbilityOnBackground);
  }

  build() {
    Column() {
      Column() {
        Video({
          src: this.innerResource,
          controller: this.controller
        })
          .size({
            width: $r('app.float.width_300'),
            height: $r('app.float.height_288'),
          })
          .visibility(this.isVisible)
          .loop(true)
          .autoPlay(true)
          .controls(false)
          .focusable(false)
          .accessibilityLevel(AccessibilityLevelType.NO)
          .onStart(() => {
            this.isVisible = Visibility.Visible
          })
      }
      .justifyContent(FlexAlign.Center)
      .size({
        width: '100%',
        height: $r('app.float.height_288'),
      })
      .constraintSize({ minHeight: '24vp' })
      .borderRadius($r('app.float.length_16'))

      Column() {
        Text($r('app.string.nfc_how_to_use_description_text'))
          .width('100%')
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .constraintSize({ minHeight: 56 })
      .padding({
        start: PADDING_12,
        end: PADDING_12,
        bottom: PADDING_20,
        top: PADDING_24
      })
      .justifyContent(FlexAlign.End)
    }
    .accessibilityGroup(true)
  }

  private getAnimationResource(isDarkMode: boolean): string {
    let filePath: string = '';
    let resourceName: string = isDarkMode ? ANIMATION_DARK : ANIMATION_WHITE;
    try {
      filePath = FILE_PREFIX + configPolicy.getOneCfgFileSync(RESOURCE_PATH_PREFIX + resourceName);
    } catch (err) {
      LogUtil.error(`${TAG} getCcmPageConfigStr exception:${err?.code}  ${err?.message}`);
    }
    return filePath;
  }
}