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
import { LengthMetrics } from '@kit.ArkUI';
import { SubHeader } from '@ohos.arkui.advanced.SubHeader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'AudioAdjustmentContentComponent';

@Component
export struct AudioAdjustmentContentComponent {
  private isDevicePad: boolean = DeviceUtil.isDevicePad();
  private start: LengthMetrics = LengthMetrics.vp(this.isDevicePad ? 4 : 0);
  private end: LengthMetrics = LengthMetrics.vp(this.isDevicePad ? 4 : 0);

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  build() {
    Column() {
      SubHeader({
        secondaryTitle: $r('app.string.note'),
        contentMargin: {
          start: this.start,
          end: this.end,
        },
      }).accessibilityGroup(true)

      Column() {
        Column() {
          Text($r('app.string.audio_balance_reminder'))
            .fontColor($r('sys.color.font_secondary'))
            .textOverflow({ overflow: TextOverflow.None })
            .lineHeight($r('app.float.font_19'))
            .font({
              size: $r('sys.float.Body_M'),
              weight: FontWeight.Regular,
            })
            .size({
              width: '100%',
            })
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.HYPHENATION)
        }
        .visibility(Visibility.Visible)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({
          top: $r('sys.float.padding_level4'),
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          bottom: $r('sys.float.padding_level4'),
        })
        .accessibilityGroup(true);
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width('100%')
  }
}