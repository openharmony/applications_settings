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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'ConnectFailedDialog : ';

const DIALOG_WIDTH: number = 400;

@CustomDialog
export struct ConnectFailedDialog {
  controller?: CustomDialogController;
  title: ResourceStr = '';
  message: ResourceStr = '';

  build() {
    Column() {
      Text(this.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .height('56vp')
        .padding({
          left: '8vp',
          right: '8vp',
        })
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)

      Text(this.message)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .width('100%')
        .lineHeight('21vp')
        .fontFamily('HarmonyHeiTi')
        .padding({
          left: '8vp',
          right: '8vp',
        })
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)

      Button($r('app.string.button_title_ok'),
        {
          type: ButtonType.Capsule,
          stateEffect: true,
        })
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize('16vp')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .height('40vp')
        .margin({
          top: '16vp',
          bottom: '24vp',
        })
        .onClick(() => {
          LogUtil.info(`${TAG} click ok.`);
          this.controller?.close();
        })
    }
    .width(DIALOG_WIDTH)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      left: '16vp',
      right: '16vp',
    })
    .borderRadius('16vp')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}