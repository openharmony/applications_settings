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
import inputMethod from '@ohos.inputMethod';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { InputMethodUtils } from '@ohos/settings.wifi/src/main/ets/InputMethodUtils';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HotspotPwdConfirmController } from '../controller/HotspotPwdConfirmController';

const TAG: string = 'HotSpotPswConfirmComponent: '

const HOT_SPOT_PSW_INPUT_CHANGE: string = 'HOT_SPOT_PSW_INPUT_CHANGE';

const UX_DESIGN_MARGIN: number = 24;

const HOTSPOT_PWD_MIN_LENGTH: number = 8;

const UX_DESIGN_DEFAULT_MARGIN: number = 48;

@Component
export struct HotSpotPswConfirmComponent {
  item?: SettingGroupModel;
  compControl: HotspotPwdConfirmController = new HotspotPwdConfirmController();
  private inputMethodSetting: inputMethod.InputMethodSetting | undefined = InputMethodUtils.getSetting();
  private hotspotPassword: string = '';
  private isKeyboardVisible: boolean = false;
  @State marginBottom: number = UX_DESIGN_DEFAULT_MARGIN;
  @State isValid: boolean = false;
  @State bottomResource: ResourceColor = $r('app.float.padding_44');

  private imeShowCallBack: (info: Array<inputMethod.InputWindowInfo>) => void =
    (info: Array<inputMethod.InputWindowInfo>) => {
      LogUtil.info(`${TAG} imeShow.`);
      if (info.length <= 0) {
        LogUtil.error(`${TAG} imeShowCallBack occurs error.`);
        return;
      }
      if (DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand()) {
        this.marginBottom = UX_DESIGN_MARGIN;
      } else {
        this.marginBottom = px2vp(info[0].height) + UX_DESIGN_MARGIN;
      }
    };

  private imeHideCallBack: (info: Array<inputMethod.InputWindowInfo>) => void =
    (info: Array<inputMethod.InputWindowInfo>) => {
      LogUtil.info(`${TAG} imeHide.`);
      if (DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand()) {
        this.marginBottom = UX_DESIGN_MARGIN;
      } else {
        this.marginBottom = UX_DESIGN_DEFAULT_MARGIN;
      }
    };

  private onHotSpotPswChangeCallBack = (input: string) => {
    LogUtil.info(`${TAG} on hotSpot password changed.`);
    this.isValid = input.length >= HOTSPOT_PWD_MIN_LENGTH;
    this.hotspotPassword = input;
  };

  build() {
    Column() {
      Button() {
        Row() {
          Text($r('app.string.dialog_sure'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .constraintSize({
              minHeight: $r('app.float.wh_value_21'),
            })
            .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .enabled(this.isValid)
      .onClick(() => {
        this.compControl?.dealClick(this.hotspotPassword);
      })
      .constraintSize({
        minHeight: 40,
      })
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .backgroundColor($r('app.color.component_ultra_thick_panel'))
    .justifyContent(FlexAlign.End)
    .padding({
      bottom: this.bottomResource,
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.compControl.init({ compId: this.item?.id as string, component: this.item as SettingGroupModel });
    if (DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand()) {
      this.marginBottom = UX_DESIGN_MARGIN;
    }
    EventBus.getInstance().on(HOT_SPOT_PSW_INPUT_CHANGE, this.onHotSpotPswChangeCallBack);
    WindowManager.getInstance().onKeyboardHeightChange((data: number) => {
      this.isKeyboardVisible = data > 0;
      // this.bottomResource = this.isKeyboardVisible ? $r('app.float.padding_24') : $r('app.float.padding_44');
    });
    if (this.inputMethodSetting === undefined) {
      LogUtil.error(`${TAG} inputMethodSetting is undefined`);
      return;
    }
    try {
      this.inputMethodSetting?.on('imeShow', this.imeShowCallBack);
      this.inputMethodSetting?.on('imeHide', this.imeHideCallBack);
    } catch (error) {
      LogUtil.error(`${TAG} failed to subscribing imeShow: ${error?.message}`);
    }
    EventBus.getInstance().on(HOT_SPOT_PSW_INPUT_CHANGE, this.onHotSpotPswChangeCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.error(`${TAG} aboutToDisappear.`);
    this.compControl.destroy();
    EventBus.getInstance().detach(HOT_SPOT_PSW_INPUT_CHANGE, this.onHotSpotPswChangeCallBack);
    WindowManager.getInstance().offKeyboardHeightChange();
    if (this.inputMethodSetting === undefined) {
      LogUtil.error(`${TAG} inputMethodSetting is undefined`);
      return;
    }
    try {
      this.inputMethodSetting?.off('imeShow', this.imeShowCallBack);
      this.inputMethodSetting?.off('imeHide', this.imeHideCallBack);
    } catch (error) {
      LogUtil.error(`${TAG} failed to unsubscribing imeShow: ${error?.message}`);
    }
  }
}