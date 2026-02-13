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

import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
/* instrument ignore file */
const TAG: string = 'BoundDeviceTypeChooseDialog : ';

const BONDED_DEVICE_TYPES_ARRAY: string[] = [
  ResourceUtil.getStringSync($r('app.string.device_type_car')),
  ResourceUtil.getStringSync($r('app.string.device_type_headset')),
  ResourceUtil.getStringSync($r('app.string.device_type_hearing')),
  ResourceUtil.getStringSync($r('app.string.device_type_glasses')),
  ResourceUtil.getStringSync($r('app.string.device_type_watch')),
  ResourceUtil.getStringSync($r('app.string.device_type_speaker'))];

@CustomDialog
export struct BoundDeviceTypeChooseDialog {
  controller?: CustomDialogController;
  private handleConfirmClick?: (deviceType: number) => void;
  @Prop deviceType: number = 0;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    Column() {
      Text($r('app.string.bt_bond_device_type'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .width('100%')
        .constraintSize({
          minHeight: '56vp',
        })
        .padding({
          left: '12vp',
          right: '12vp',
        })
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)

      List({ initialIndex: 0 }) {
        ForEach(BONDED_DEVICE_TYPES_ARRAY, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
              Radio({ value: 'type', group: 'radioGroup' })
                .width('20vp')
                .height('20vp')
                .checked(this.deviceType === (index + 1))
                .radioStyle({
                  checkedBackgroundColor: $r('sys.color.ohos_id_color_text_primary_activated')
                })
                .visibility(this.deviceType === (index + 1) ? Visibility.Visible : Visibility.None)
                .onClick((event) => {
                  if (this.handleConfirmClick) {
                    let deviceType: number = index + 1;
                    this.handleConfirmClick(deviceType);
                  }
                })
            }
            .accessibilityGroup(true)
            .accessibilityText(item)
            .accessibilityDescription(this.deviceType === (index + 1) ? $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'))
            .onClick((event) => {
              if (this.handleConfirmClick) {
                let deviceType: number = index + 1;
                this.handleConfirmClick(deviceType);
              }
              AccessibilityUtils.announceRadioSelected();
            })
            .stateStyles({
              normal: this.normalStyles,
              pressed: this.pressedStyles,
            })
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .constraintSize({
              minHeight: '48vp',
            })
            .padding({
              left: '12vp',
              right: '12vp',
            })
          }
        }, (item: string) => item)
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: '12vp',
        endMargin: '12vp',
      })

      Button($r('app.string.dialog_cancel'), {
        type: ButtonType.Capsule,
        stateEffect: true,
      })
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .fontSize($r('sys.float.ohos_id_text_size_button1'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
        .constraintSize({
          minHeight: '40vp',
        })
        .width('100%')
        .margin({
          top: '8vp',
        })
        .onClick(() => {
          this.controller?.close();
        })
    }
    .padding({
      left: '16vp',
      right: '16vp',
      bottom: '16vp',
    })
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
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