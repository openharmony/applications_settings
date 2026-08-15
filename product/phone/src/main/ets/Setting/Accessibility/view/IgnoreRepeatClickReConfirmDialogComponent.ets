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
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { IgnoreRepeatedTouchesController } from '../controller/IgnoreRepeatTouchesController';
import { IgnoreRepeatedStateModel } from '../utils/AccessibilityIgnoreRepeatedModel';

const MAX_LINES_10 = 10;
const TAG: string = 'IgnoreRepeatClickReConfirmDialogComponent: ';

@Component
export struct IgnoreRepeatClickReConfirmDialogComponent {
  item?: SettingItemModel;
  private dialogType: string = '';
  private originalValue?: string = '';
  private currentValue?: string = '';
  private dialogTitle: ResourceStr = '';
  private dialogSummary: ResourceStr = '';

  build() {
    Column() {
      Row() {
        Text(this.dialogTitle)
          .id('ignore_repeat_click_reconfirm_dialog_title')
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .maxFontScale(2)
          .constraintSize({
            minHeight: '26vp',
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
          Text(this.dialogSummary)
            .id(`ignore_repeat_click_reconfirm_dialog_message`)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .visibility(Visibility.Visible)
            .textOverflow({ overflow: TextOverflow.None })
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.HYPHENATION)
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

  private initDialogText(): void {
    if (this.dialogType === 'open') {
      this.dialogTitle = $r('app.string.ignore_repeat_click_reconfirm_declaration');
      this.dialogSummary = $r('app.string.ignore_repeat_click_reconfirm_summary');
    } else if (this.dialogType === 'change') {
      this.dialogTitle = $r('app.string.ignore_repeat_click_change_reconfirm_title');
      this.dialogSummary = this.getChangeSummary();
    } else {
      LogUtil.error(`${TAG} dialogType error.`);
    }
  }

  private ConvertIntervalValue(intervalValue: string): number {
    let intervalNum: string = '0';
    try {
      if (intervalValue !== '') {
        intervalNum = intervalValue.replace(/[^\d.]/g, '');
      }
    } catch (err) {
      LogUtil.error(`${TAG} ConvertIntervalValue error: ${err?.code}`);
    }
    return Number(intervalNum);
  }

  private getChangeSummary(): ResourceStr {
    LogUtil.info(`${TAG} getChangeSummary originalValue: ${this.originalValue}, currentValue: ${this.currentValue}`);
    let originalDelay: string =
      ResourceUtil.getPluralStringValueSync($r('app.plural.ignore_repeat_click_change_original_delay'),
        this.ConvertIntervalValue(this.originalValue as string));
    let currentDelay: string =
      ResourceUtil.getPluralStringValueSync($r('app.plural.ignore_repeat_click_change_current_delay'),
        this.ConvertIntervalValue(this.currentValue as string));
    let ignoreSummary: ResourceStr =
      $r('app.string.ignore_repeat_click_change_reconfirm_summary', originalDelay, currentDelay);
    return ignoreSummary;
  }

  private cancelStateChange(): void {
    if (IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal) {
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatTouches', true);
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClick = true;
      IgnoreRepeatedStateModel.getInstance().ignoreRepeatClickOriginal = false;
      IgnoreRepeatedStateModel.getInstance().repeatClickIntervalValueCache = '';
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.initDialogText();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.cancelStateChange();
  }
}