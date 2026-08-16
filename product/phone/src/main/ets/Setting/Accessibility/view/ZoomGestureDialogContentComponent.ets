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
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CLICK_SWITCH_OFF, SCREEN_MAGNIFICATION } from '../constant/Constants';

const MAX_LINES_20: number = 20;
const ZOOM_CLICK_TIMES: number = 3;
const ZOOM_GESTURE_MAIN_SWITCH_COMID =
  'Setting.AccessibilityZoomGesturePage.zoomGesture_switch_group.single_zoom_gesture_switch'
const TAG: string = 'ZoomGestureDialogContentComponent: ';

@Component
export struct ZoomGestureDialogContentComponent {
  item?: SettingItemModel;

  build() {
    Column() {
      Row() {
        Text($r('app.string.on_zoom_gesture_dialog_title'))
          .id('on_zoom_gesture_dialog_title')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .maxFontScale(2)
          .constraintSize({
            minHeight: $r('app.float.wh_value_26'),
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .justifyContent(FlexAlign.Center)
      .size({
        width: '100%',
      })
      .margin({
        bottom: $r('app.float.margin_15'),
      })

      Scroll() {
        Row() {
          Text($r('app.string.on_zoom_gesture_dialog_summary', ResourceUtil.getLocalNumberFormat(ZOOM_CLICK_TIMES)))
            .id(`on_zoom_gesture_dialog_summary`)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .visibility(Visibility.Visible)
            .textOverflow({ overflow: TextOverflow.None })
            .wordBreak(WordBreak.HYPHENATION)
            .maxLines(MAX_LINES_20)
            .textAlign(TextAlign.Center)
        }
        .size({
          width: '100%',
        })
        .margin({
          bottom: $r('app.float.margin_8'),
        })
        .justifyContent(FlexAlign.Center)
      }
      .scrollBar(BarState.Auto)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: FontScaleUtils.isExtraLargeFontMode() ? '40%' : '100%'
      })
      .padding({
        left: FontScaleUtils.isExtraLargeFontMode() ? $r('sys.float.padding_level8') : $r('app.float.padding_0'),
        right: FontScaleUtils.isExtraLargeFontMode() ? $r('sys.float.padding_level8') : $r('app.float.padding_0')
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)

  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    let isZoomGestureEnable: string = SettingsDataUtils.getSecureValue(SCREEN_MAGNIFICATION, CLICK_SWITCH_OFF);
    if (isZoomGestureEnable === CLICK_SWITCH_OFF) {
      notifyCompStateChange(ZOOM_GESTURE_MAIN_SWITCH_COMID,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TOGGLE,
            result: { state: false }
          } as SettingResultState]]));
    }
  }
}