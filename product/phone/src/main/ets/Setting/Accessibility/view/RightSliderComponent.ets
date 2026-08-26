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
import { UnilateralAdjustmentController } from '../controller/HearingAidUnilateralAdjustmentController';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { AccessibilityHearingAidModel } from '../utils/AccessibilityCommonModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const MAX_LINES_10: number = 10;
export const SWITCH_NULL: string = 'null';

@Component
export struct RightSliderComponent {
  private tag: string = '';
  private title: ResourceStr = '';
  private defaultValue: number = 50;
  private unilateralAdjustmentController: UnilateralAdjustmentController = new UnilateralAdjustmentController();

  private getSliderValue(): number {
    let result: string =
      SettingsDataUtils.getSettingsData(AccessibilityHearingAidModel.RIGHT_EAR_SLIDER_VALUE, SWITCH_NULL);
    if (result === 'null') { //first connected
      SettingsDataUtils.setSettingsData(
        AccessibilityHearingAidModel.RIGHT_EAR_SLIDER_VALUE, this.defaultValue.toString());
      AccessibilityHearingAidModel.setVolume(
        AccessibilityHearingAidModel.rightMacId, AccessibilityHearingAidModel.volumeToDb(this.defaultValue));
      return this.defaultValue;
    }

    if (AccessibilityHearingAidModel.rightSwitchState) {
      AccessibilityHearingAidModel.setVolume(
        AccessibilityHearingAidModel.rightMacId, AccessibilityHearingAidModel.volumeToDb(parseInt(result)));
    }
    return parseInt(result);
  }

  build() {
    Column() {
      Row() {
        Text(this.title)
          .id(`${this.tag}_title`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .width('100%')
          .maxLines(MAX_LINES_10)
          .margin({ top: $r('sys.float.ohos_id_default_padding_start') })
      }
      Row() {
        Slider({
          value: this.getSliderValue(),
          min: 0,
          max: 100,
          style: SliderStyle.InSet
        })
          .blockColor('#FFFFFF')
          .trackColor($r('sys.color.comp_background_secondary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((value: number, mode: SliderChangeMode) => {
            this.unilateralAdjustmentController.onRightSilderChange(value, mode);
          })
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .padding({ left: $r('sys.float.padding_level4'), right: $r('sys.float.padding_level4') })
    .margin({ bottom: $r('sys.float.padding_level4') })
    .constraintSize({ minHeight: '82vp' })
    .visibility(Visibility.Visible)
    .width('100%')
  }
}