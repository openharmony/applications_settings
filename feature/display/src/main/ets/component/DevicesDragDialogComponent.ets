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
import { DisplayConstants } from '../constant/DisplayConstant';
import { DragController, Point } from '../controller/DragController';
import { ImageDrag } from './ImageDrag';

@Component
export struct DevicesDragDialogComponent {
  private tag: string = '';
  private title: ResourceStr = '';
  private tempPositionsFlag: boolean = false;
  private dragController: DragController = DragController.getInstance();
  @State positions: Point[] = [];

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} about to appear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} about to disappear`);
  }

  build() {
    Column() {

      Flex({justifyContent: FlexAlign.Start}) {
        Text($r('app.string.location_set_description'))
          .fontFamily('HarmonyHeiTi')
          .lineHeight(DisplayConstants.DIALOG_SUBTITLE_LINE_HEIGHT)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Start)
      }
      .margin({
        top: DisplayConstants.DIALOG_TITLE_SUBTITLE_SPACE,
        bottom: DisplayConstants.DIALOG_SUBTITLE_CONTENT_SPACE
      })

      Column() {
        ImageDrag({
          tempPositionsFlag: this.tempPositionsFlag,
          onDragEndEvent: () => {}
        })
      }
      .height(DisplayConstants.DEFAULT_DRAG_AREA_HEIGHT)
    }
    .width('100%')

  }
}