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
import Display from '@ohos.display';
import { window } from '@kit.ArkUI';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ThemeSettingsController } from '../controller/ThemeSettingsController';

const TAG: string = 'LoadingDialog';
const LOADING_PROGRESS_WIDTH: number = 40;
const DIALOG_HEIGHT: number = 96;
const DIALOG_MARGIN: number = 16;
const FOLD_DIALOG_WIDTH: number = 400;
const DIALOG_PADDING_SIZE: number = 24;
const FONT_MAX_SCALE: number = 1.45;

@CustomDialog
export struct LoadingDialog {
  controller?: CustomDialogController;
  @Link contentWidth: number;
  @Prop textContent: Resource = $r('app.string.enableTheme');

  private updateContentWidth(windowStatusType: window.WindowStatusType): void {
    LogUtil.showInfo(TAG, `updateContentWidth start, windowStatusType = ${windowStatusType}`);
    if (windowStatusType === window.WindowStatusType.FULL_SCREEN) {
      const displaySync: Display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
      if (displaySync) {
        this.contentWidth = DisplayUtils.getScreenWidth();
        LogUtil.showInfo(TAG, 'updateContentWidth, current is fullscreen');
      }
    }
  }

  aboutToAppear() {
    this.updateContentWidth(ThemeSettingsController.getInstance().getWindowStatusType());
    LogUtil.showInfo(TAG, `aboutToAppear, this.contentWidth = ${this.contentWidth}`);
  }

  aboutToDisappear() {
    if (this.controller) {
      this.controller.close();
      this.controller = undefined;
    }
  }

  build() {
    Row() {
      Text(this.textContent)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .maxFontScale(FONT_MAX_SCALE)
        .fontWeight(FontWeight.Regular)
      LoadingProgress()
        .width(LOADING_PROGRESS_WIDTH)
    }
    .constraintSize({ minHeight: DIALOG_HEIGHT })
    .width(Math.min(Math.abs(this.contentWidth - 2 * DIALOG_MARGIN), FOLD_DIALOG_WIDTH))
    .padding(DIALOG_PADDING_SIZE)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .backgroundColor($r('sys.color.ohos_id_color_mask_thin'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
