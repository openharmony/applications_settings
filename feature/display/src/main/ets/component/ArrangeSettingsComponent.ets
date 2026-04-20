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
import { promptAction } from '@kit.ArkUI';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_12,
  PADDING_13,
  PADDING_6, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { settingDialog } from '@ohos/settings.common/src/main/ets/framework/view/SettingDialog';
import { arrangeDialogStyleDialog, arrangeDialogStyleModel} from '../model/DisplayModel';
import { DeviceDisplayType, DevicesController, DeviceUserType } from '../controller/DevicesController';
import { DragController } from '../controller/DragController';
import { EVENT_DISPLAY_DEVICE_CHANGE } from '../constant/DisplayConstant';

const TAG = `ArrangeSettingsComponent `;

@Component
export struct ArrangeSettingsComponent {
  compId: string = '';
  private tag: string = '';
  private title: ResourceStr = '';
  private dialogId: number = 0;
  private isSplitScreenStatus: boolean = false;
  @State isReArrangeEnable: boolean = true;

  private closeDialog(): void {
    if (this.dialogId === 0) {
      LogUtil.showInfo(TAG, `dialog has been closed, group: ${this.compId}`);
      return;
    }
    LogUtil.showInfo(TAG, `close dialog , group: ${this.compId}, dialogId: ${this.dialogId}`);
    try {
      promptAction.closeCustomDialog(this.dialogId);
      this.dialogId = 0;
    } catch (error) {
      LogUtil.showError(TAG, `closeCustomDialog failed, dialogId: ${this.dialogId}, error: ${error?.message}`);
    }
  }

  private openDialog(tempPositionsFlag: boolean = false): void {
    // Close existing dialog first if dialog exists.
    this.closeDialog();
    let dialogLayout =
      PageConfig.getInstance().getDialogStyle(arrangeDialogStyleDialog(this.isSplitScreenStatus, tempPositionsFlag));
    promptAction.openCustomDialog({
      builder: settingDialog.bind(this, arrangeDialogStyleModel,
        arrangeDialogStyleDialog(this.isSplitScreenStatus, tempPositionsFlag), () => {
        this.closeDialog();
      }),
      width: dialogLayout.width,
      height: dialogLayout.height,
      backgroundColor: dialogLayout.backgroundColor,
      cornerRadius: dialogLayout.cornerRadius,
      alignment: dialogLayout.alignment,
      autoCancel: dialogLayout.autoCancel,
      maskColor: dialogLayout.maskColor,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        LogUtil.showInfo(TAG, `dialog dismiss, group ${this.compId}`);
        dismissDialogAction.dismiss()
        this.dialogId = 0;
      },
    }).then((dialogId: number) => {
      LogUtil.showInfo(TAG, `dialog opened, group ${this.compId} dialogId: ${dialogId}`);
      this.dialogId = dialogId;
    }).catch((reason: Error) => {
      LogUtil.showError(TAG, `open dialog failed, group: ${this.compId}, reason: ${reason.message}`);
    });
  }

  getReArrangeIsEnabled() {
    let devices = DevicesController.getInstance().getDevices();
    // 仅一屏场景
    let isOnlyScreen = devices.find((device) => device.deviceUserFor === DeviceUserType.ONLY_SCREEN) !== undefined;
    let extendCount = devices.filter((d) => !isOnlyScreen && d.deviceUserFor === DeviceUserType.EXTENDED).length;
    let othersCount = devices.filter((d) => d.deviceType === DeviceDisplayType.OTHERS).length;
    LogUtil.info(`${this.tag} get extend Count: ${extendCount} othersCount: ${othersCount}`);
    return (extendCount > 0 || othersCount > 0);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.isSplitScreenStatus = DragController.getInstance().isSplitScreenStatus();
    EventBus.getInstance().on(EVENT_DISPLAY_DEVICE_CHANGE, () => {
      LogUtil.info(`${this.tag} display_current_device_change`);
      this.isReArrangeEnable = this.getReArrangeIsEnabled();
    })
    this.isReArrangeEnable = this.getReArrangeIsEnabled();
    EventBus.getInstance().on('window_split_screen_changed', (flag: boolean) => {
      let previousStatus = this.isSplitScreenStatus;
      this.isSplitScreenStatus = flag;
      LogUtil.info(`${this.tag} window split screen changed: ${previousStatus}->${this.isSplitScreenStatus}`);
      if ((this.isSplitScreenStatus || previousStatus) &&
        this.isSplitScreenStatus !== previousStatus && this.dialogId !== 0) {
        LogUtil.info(`${this.tag} open split screen dialog`);
        DragController.getInstance().saveTempPositions();
        this.openDialog(true);
      }
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().off('window_split_screen_changed');
    this.closeDialog();
  }

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.title)
          .id(`${this.tag}_title`)
          .fontSize('16fp')
          .fontColor($r('sys.color.font_primary'))
          .borderRadius(16)
          .fontWeight(FontWeight.Medium)
          .margin({
            top: '9vp',
            bottom: '9vp'
          })
        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.button_edit'))
            .fontSize('12fp')
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        }
        .padding({
          start: PADDING_12,
          end: PADDING_12,
          top: PADDING_6,
          bottom: PADDING_6
        })
        .id(`button_edit`)
        .enabled(this.isReArrangeEnable)
        .borderRadius($r('sys.float.corner_radius_level4'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.openDialog();
        })
      }
    }
    .alignItems(VerticalAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .padding({ start: PADDING_8, end: PADDING_8 })
    .width('100%')
  }
}