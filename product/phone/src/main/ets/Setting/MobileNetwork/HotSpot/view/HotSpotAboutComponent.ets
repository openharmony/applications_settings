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
import wifiManager from '@ohos.wifiManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';

const TAG: string = 'HotSpotAboutComponent: ';
const HOTSPOT_TOGGLE_KEY: string = 'Setting.hotspot_data_entry.hotspot_switch.hotspot_switch_setting';
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

@Component
export struct HotSpotAboutComponent {
  param: object | undefined = undefined;
  private isHotspotOpen: boolean = false;
  private isEnable: boolean = true;
  @State title: string = '';
  @State isHotspotSwitchOn: boolean = false;
  @State aboutContentStringArray: string[] = [];
  @Consume('pathInfos') pathInfos: NavPathStack;

  private onToggleChange = (state: SettingToggleState) => {
    let isChecked: boolean = state.state;
    LogUtil.info(`${TAG} receive hot spot switch change event: ${isChecked}`);
    this.isHotspotOpen = isChecked;
    this.updateStatus();
  }

  build() {
    Column() {
      Text(this.title)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_M'))
        .fontFamily('HarmonyHeiTi')
        .width('100%')
        .textAlign(TextAlign.Start)
        .constraintSize({
          minHeight: 19,
        })

      ForEach(this.aboutContentStringArray, (item: string, index: number) => {
        Text(item)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontFamily('HarmonyHeiTi')
          .width('100%')
          .textAlign(TextAlign.JUSTIFY)
          .wordBreak(WordBreak.BREAK_ALL)
          .margin({
            top: index === 0 ? $r('sys.float.padding_level8') : $r('sys.float.padding_level4'),
          })
          .constraintSize({
            minHeight: 19,
          })
      }, (item: string) => item)
    }
    .padding({
      top: $r('sys.float.padding_level10'),
    })
    .opacity(this.isEnable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.isEnable = (this.param as SettingBaseModel).enabled ?? true;
    this.updateHotspotState();
    this.updateStatus();
    EventBus.getInstance().on(`${HOTSPOT_TOGGLE_KEY}.toggle`, this.onToggleChange);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(`${HOTSPOT_TOGGLE_KEY}.toggle`, this.onToggleChange);
  }

  private updateHotspotState(): void {
    try {
      let ret: boolean = wifiManager.isHotspotActive();
      LogUtil.info(`${TAG} updateHotspotState isHotspotActive: ${ret}`);
      this.isHotspotOpen = ret;
    } catch (error) {
      LogUtil.error(`${TAG} get isHotspotActive fail`);
    }
  }

  updateStatus(): void {
    this.title = this.isHotspotOpen
      ? ResourceUtil.getCapitalStringSync($r('app.string.hotspot_open_about'))
      : ResourceUtil.getCapitalStringSync($r('app.string.hotspot_about'));
    try {
      if (this.isHotspotOpen) {
        let tipsString: string = ResourceUtil.getAnyStrFormatStringSync(
          $r('app.string.hotspot_open_about_content'), '1',
          wifiManager.getHotspotConfig().ssid, '2').replace('Wi-Fi', 'WLAN');
        this.aboutContentStringArray = tipsString.split('\n\n');
      } else {
        let aboutContentString: string =
          ResourceUtil.getAnyNumFormatStringSync($r('app.string.hotspot_about_content'), 1, 2, 8, 3, 4, 4);
        this.aboutContentStringArray = aboutContentString.split('\n\n\n');
      }
    } catch (error) {
      LogUtil.error(`${TAG} getHotspotConfig fail: ${error?.message}`);
    }
  }
}