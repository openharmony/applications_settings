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
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NIGHT_MODE_STATE_ON, NIGHT_MODE_STATE_OFF } from '../constant/Constants';
import { a11yInitData } from '../sendable/A11yInitData';

const MAX_LINES_10 = 10;
const HIGN_CONTRAST_SWITCH_COMID = 'Setting.AccessibilityHighContrastTextPage.single_high_contrast_text_group.' +
  'single_high_contrast_text_switch'
const TAG: string = 'DarkModeDialogContentComponent: ';

@Component
export struct DarkModeDialogContentComponent {
  item?: SettingItemModel;

  build() {
    Column() {
      Row() {
        Text($r('app.string.high_contrast_dialog_title'))
          .id('high_contrast_dialog_title')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .maxFontScale(2)
          .constraintSize({
            minHeight: '26vp',
          })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .justifyContent(FlexAlign.Center)
      .size({
        width: '100%',
      })
      .margin({
        bottom: $r('app.float.margin_15'),
      })
      Column() {
        Scroll() {
          Column() {
            Text($r('app.string.confirm_close_dark_mode_content'))
              .id(`high_contrast_dialog_message`)
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .visibility(Visibility.Visible)
              .textAlign(TextAlign.Center)
              .wordBreak(WordBreak.HYPHENATION)
              .width('100%')
          }.size({
            width: '100%',
          })
          .margin({
            bottom: $r('app.float.margin_8'),
          })
          .justifyContent(FlexAlign.Center)
        }
        .edgeEffect(EdgeEffect.Spring)
        .scrollable(ScrollDirection.Vertical)
        .constraintSize({
          maxHeight: '40%'
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    let nightModeEnable: string = SettingsDataUtils.getSecureValue('ui_night_mode', NIGHT_MODE_STATE_OFF);
    let highContrastTextEnable: boolean = false;
    if (a11yInitData.highContrastTextState !== undefined) {
      highContrastTextEnable = a11yInitData.highContrastTextState as boolean;
    } else {
      LogUtil.error(`${TAG} get a11yInitData highContrastTextState failed`);
    }
    if (highContrastTextEnable === false && nightModeEnable === NIGHT_MODE_STATE_ON) {
      notifyCompStateChange(HIGN_CONTRAST_SWITCH_COMID,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: { state: false }
          } as SettingResultState]]));
    }
  }
}