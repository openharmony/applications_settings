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

import { CustomContentDialog, LengthMetrics } from '@kit.ArkUI';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ResourceUtil} from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOffDialog : ';

const COUNT_DOWN_SECOND: number = 60;

const SCROLL_BAR_OFFSET: number = 20;

const FADEOUT_GRADIENT_WIDTH: number = 32;

const storage = LocalStorage.getShared();

/**
 * 关机提示弹窗取消通知
 */
export const POWER_OFF_DIALOG_EVENT: string = 'powerOffDialogEvent';

export const SUBMIT_ACTION: string = 'submit';

export const CANCEL_ACTION: string = 'cancel';

/**
 * page for ScheduledPowerOffDialog
 *
 * @since 2024-12-21
 */
@Entry(storage)
@Component
struct ScheduledPowerOffDialog {
  textTimerController: TextTimerController = new TextTimerController();
  @State countDownTime: number = COUNT_DOWN_SECOND;
  @State format: string = 'ss';
  private hasClickButton: boolean = false;
  private contentScroller: Scroller = new Scroller();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: $r('app.string.power_off_title'),
      contentBuilder: () => {
        this.contentBuilder()
      },
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
            this.onCancel();
          },
        },
        {
          value: $r('app.string.dialog_power_off'),
          action: () => {
            this.onAccept();
          }
        }
      ],
    }),
    cancel: undefined,
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  onCancel() {
    LogUtil.showInfo(TAG, 'onCancel');
    EventBus.getInstance().emit(POWER_OFF_DIALOG_EVENT, CANCEL_ACTION);
    this.textTimerController.pause();
    this.hasClickButton = true;
    this.closeDialog();
  }

  onAccept() {
    LogUtil.showInfo(TAG, 'onAccept');
    EventBus.getInstance().emit(POWER_OFF_DIALOG_EVENT, SUBMIT_ACTION);
    this.hasClickButton = true;
    this.closeDialog();
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.hasClickButton = false;
    this.dialogController.open();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    // 手势上滑关闭走这里
    if (!this.hasClickButton) {
      this.onCancel();
    }
    this.textTimerController.pause();
  }

  private closeDialog(): void {
    try {
      this.dialogController.close();
      (AppStorage.get<UIExtensionContentSession>('scheduledPowerOffDialogSession') as UIExtensionContentSession)?.terminateSelf();
    } catch (error) {
      LogUtil.error(`${TAG} destroyServiceExtensionAbility occur error ${error?.message}`);
    }
  }

  onPageShow(): void {
    this.textTimerController.start();
  }

  @Builder contentBuilder() {
    Column() {
      Scroll(this.contentScroller) {
        Row() {
          Text(ResourceUtil.getPluralStringValueSync($r('app.plural.power_off_message'), this.countDownTime))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .maxFontScale(3.2)
        }
        .width('100%')
        .margin({ end: LengthMetrics.vp(SCROLL_BAR_OFFSET) })
        .width(`calc(100% - ${SCROLL_BAR_OFFSET}vp)`)
        .constraintSize({minHeight: $r('app.float.wh_value_21')})
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }
      .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(FADEOUT_GRADIENT_WIDTH) })
      .nestedScroll({ scrollForward: NestedScrollMode.PARALLEL, scrollBackward: NestedScrollMode.PARALLEL })
      .width('100%')
    }
    .margin({ end: LengthMetrics.vp(-SCROLL_BAR_OFFSET) })
  }

  build() {
    Column() {
      TextTimer({ isCountDown: true, count: COUNT_DOWN_SECOND * 1000, controller: this.textTimerController })
        .format(this.format)
        .fontSize(0)
        .onTimer((utc: number, elapsedTime: number) => {
          this.countDownTime = (COUNT_DOWN_SECOND - elapsedTime < 0) ? 0 : COUNT_DOWN_SECOND - elapsedTime;
          if (this.countDownTime <= 0) {
            this.onAccept();
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}