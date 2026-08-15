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
import MediaQuery from '@ohos.mediaquery';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_0, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';

const TAG: string = 'ElderCareGuidePageContentComponent :';
let isPad: boolean = DeviceUtil.isDevicePad();
let isLargeFold: boolean = DeviceUtil.isLargeInFoldProduct();
let elderCareGuideImage: Resource =
  isPad ? $r('app.media.elder_care_guide_logo_pad') : $r('app.media.elder_care_guide_logo_phone');

@Component
export struct ElderCareGuidePageContentComponent {
  item?: SettingItemModel;
  @State isShowBlockRules: boolean = true;
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  private orientationListener: MediaQuery.MediaQueryListener | undefined = undefined;

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Column() {
            this.buildGuideLogo();
            this.buildGuideTitle();
            this.buildGuideSummary();
            this.buildGuideBlockRulesSummary();
          }
          .width('100%')
          .padding({ start: isPad ? PADDING_0 : PADDING_8, end: isPad ? PADDING_0 : PADDING_8 })
          .align(Alignment.TopStart)
          .backgroundColor(Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level10'))
        }
      }
    }
  }

  @Builder
  buildGuideLogo() {
    Row() {
      Image(elderCareGuideImage)
        .width(this.isPortraitOrientation ? ElderCareUtils.getLogoSize() : ElderCareUtils.getLogoSize())
        .height(this.isPortraitOrientation ? ElderCareUtils.getLogoSize() : ElderCareUtils.getLogoSize())
        .draggable(false)
    }
    .width('100%')
    .borderRadius($r('app.float.length_16'))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGuideTitle() {
    Row() {
      Text($r('app.string.elder_care_guide_page_title'))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_8') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGuideSummary() {
    Row() {
      Text($r('app.string.elder_care_switch_summary_no_sim'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .margin({ bottom: $r('app.float.margin_8') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildGuideBlockRulesSummary() {
    Row() {
      Text($r('app.string.elders_mode_block_rules_summary'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Start)
        .lineHeight(24)
    }
    .width('100%')
    .margin({ bottom: $r('app.float.margin_8') })
    .justifyContent(FlexAlign.Start)
    .visibility(Visibility.None);
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    // 添加平板页面横竖屏的监听器
    if (isPad || isLargeFold) {
      this.isPortraitOrientation = DisplayUtils.isScreenPortraitOrientation();
      this.addOrientationListener();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    // 销毁平板页面横竖屏监听器
    if (isPad || isLargeFold) {
      this.orientationListener?.off('change');
    }
  }

  async addOrientationListener(): Promise<void> {
    this.orientationListener = MediaQuery.matchMediaSync('(orientation: landscape)');
    this.orientationListener.on('change', () => {
      AppStorage.setOrCreate('isPortraitOrientation', DisplayUtils.isScreenPortraitOrientation());
      LogUtil.info(`${TAG} isPortraitOrientation: ${this.isPortraitOrientation}`)
    })
  }
}

