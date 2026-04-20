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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { TextClickPosition } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { WifiHilinkController } from '../controller/new/WifiHilinkController';
import { HiLinkModel } from '../model/HiLinkModel';

@Component
export struct WifiHiLinkComponent {
  private compControl?: WifiHilinkController;
  public tag: string = 'WifiHiLinkComponent : ';
  private hiLinkModel?: object;
  // 首位文本
  @State start: string | ResourceStr = '';
  // 中间可点击的文本
  @State middle: string | ResourceStr = '';
  // 末尾文本
  @State end: string | ResourceStr = '';
  // 文本状态标注
  @State clickTextPosition: string = '';

  build() {
    if ((this.hiLinkModel as HiLinkModel).isHiLinkNetwork) {
      Row() {
        Text() {
          Span(this.start)
            .fontSize($r('app.float.font_14'))
            .fontColor(this.clickTextPosition === TextClickPosition.START ?
            $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)

        Span(this.middle)
          .fontSize($r('app.float.font_14'))
          .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
          $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)

        Span(this.end)
          .fontSize($r('app.float.font_14'))
          .fontColor((this.clickTextPosition === TextClickPosition.END) ?
          $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
      }
      .maxFontScale(1.6)
    }
    .size({ width: '100%' })
      .padding({ top: '0vp', left: DeviceUtil.isDevicePc() ? 0 : $r('app.float.wh_value_12') })
    }
  }

  private transFormResource(resource: Resource): void {
    let result: string = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = 'H';
          this.middle = result.slice(0, i);
          this.end = result.slice(i + 2, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + 2, result.length);
          this.end = 'H';
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = 'H';
          this.end = result.slice(i + 2, result.length);
        }
        return;
      }
    }
  }

  aboutToAppear(): void {
    this.transFormResource($r('app.string.wifi_hlink_description'));
    let groupModel: SettingGroupModel = this.hiLinkModel as SettingGroupModel;
    this.compControl = groupModel.compControl as WifiHilinkController;
    this.compControl?.aboutToAppear();
  }

  aboutToDisappear(): void {
    this.compControl?.aboutToDisappear();
  }
}