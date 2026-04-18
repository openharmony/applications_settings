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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

@Component
export struct AvailableDeviceHeaderComponent {
  public tag: string = 'AvailableDeviceHeaderComponent: ';
  @State isScanLoadingShow: boolean = false;
  @State isSearchMessageShow: boolean = false;
  private searchMessageEventCallback = (isScanLoadingShow: boolean) => {
    this.isScanLoadingShow = isScanLoadingShow;
  };

  build() {
    Column() {
      Row() {
        Text($r('app.string.bluetooth_other_device_group'))
          .accessibilityDescription($r('app.string.title'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .lineHeight(19)
          .width('85%')
          .margin({
            top: 4
          })

        Column() {
          LoadingProgress()
            .margin({
              top: 2
            })
            .color($r('sys.color.icon_secondary'))
            .size({ height: '24vp', width: '24vp' })
            .visibility(this.isScanLoadingShow ? Visibility.Visible : Visibility.Hidden)
            .id('loading_progress_')
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(1)
      }
      .id('AvailableDeviceHeaderComponent_row')
    }
    .focusable(false)
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    // 扫描loading图标显隐通知
    EventBus.getInstance().on('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', this.searchMessageEventCallback);

    // 正在搜索文本显隐通知
    EventBus.getInstance().on('Setting.Bluetooth.AvailableDeviceGroup.isSearchMessageShow', (isSearchMessageShow: boolean) => {
      LogUtil.info(`${this.tag} receive isSearchMessageShow change: ${isSearchMessageShow}`);
      this.isSearchMessageShow = isSearchMessageShow;
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach('Setting.Bluetooth.AvailableDeviceGroup.isScanLoadingShow', this.searchMessageEventCallback);
    EventBus.getInstance().off('Setting.Bluetooth.AvailableDeviceGroup.isSearchMessageShow');
  }
}