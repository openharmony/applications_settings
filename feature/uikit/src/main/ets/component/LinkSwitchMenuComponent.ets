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

import { KeyCode } from '@ohos.multimodalInput.keyCode';
import { emitter } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';

const TAG: string = 'LinkSwitchMenuComponent: ';
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

@Component
export struct LinkSwitchMenuComponent {
  tag: string = 'SwitchMenuComponent : ';
  menu?: SettingsBaseMenu;
  controller?: SwitchMenuController = undefined;
  isOn?: boolean = false;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        UIExtensionComponent({
          bundleName: 'com.ohos.fileencryptionmanage',
          abilityName: 'SettingsPwdLinkHwAcccountGetDataAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI'
          }
        })
          .size({ width: 1, height: 1 })
          .onReceive(async data => {
            let linkedHwAccountInfo = data['hwAccountInfoData'];
            LogUtil.info(`${TAG} recoverykey onReceive isFaceAuth:${data['isFaceAuthData']}, isLogin:${data['isLoginData']}, isPwdLink:${data['isPwdLinkData']}, isUnSupported:${data['isUnSupportedData']}`);
            await PreferencesUtil.put('hwAccountInfo', linkedHwAccountInfo);
            await PreferencesUtil.put('isUnSupported', data['isUnSupportedData'] as boolean);
            await PreferencesUtil.put('isFaceAuth', data['isFaceAuthData'] as boolean);
            await PreferencesUtil.put('isPwdLink', data['isPwdLinkData'] as boolean);
            await PreferencesUtil.put('isLogin', data['isLoginData'] as boolean);
            await PreferencesUtil.put('otherLoginAccount', data['otherLoginAccountInfoData']);
            emitter.emit(CommonEventConstant.EVENT_ID_QUERY_RECOVER_KEY_FOR_PWD_UPLOAD);
          })

        Column() {
          Text(this.getMenu().title)
            .visibility(Visibility.Visible)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontSize(16)
            .lineHeight(19)
            .fontWeight(FontWeight.Medium)
            .margin(1)
        }

        Column() {
          Text(this.getMenu().summary)
            .visibility(Visibility.Visible)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(14)
            .lineHeight(16)
            .fontWeight(FontWeight.Regular)
            .margin(1)
        }
        .margin({ top: 2 })
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
      .accessibilityGroup(true);

      Stack() {
        Toggle({
          type: ToggleType.Switch,
          isOn: this.uiRefresher.refreshId ? (this.controller?.getChecked() ?? false) :
            (this.controller?.getChecked() ?? false)
        })
          .id(`entry_toggle_${this.menu?.key}`)
          .onChange((isOn: boolean) => {
            LogUtil.info(`${TAG} Toggle onChange isOn: ${isOn}`);
            this.isOn = isOn;
            this.controller?.onToggleChange(isOn);
          })
          .width(36)
          .height(20)
      }
      // 获焦后按键动作优先触发该回调，返回值为true，视作该按键事件已被消费，拦截Tab键聚焦后回车/空格按键事件
      .onKeyPreIme((event: KeyEvent) => {
        if (event.keyCode === KeyCode.KEYCODE_ENTER || event.keyCode === KeyCode.KEYCODE_SPACE ||
          event.keyCode === KeyCode.KEYCODE_DPAD_CENTER || event.keyCode === KeyCode.KEYCODE_NUMPAD_ENTER) {
          if (event.type === KeyType.Up) {
            this.controller?.onMenuClick();
          }
          return true;
        }
        return false;
      })
      // 拦截子组件触控事件(包括touch类与mouse类事件) HitTestMode.Block屏蔽子组件的触摸测试控制
      .hitTestBehavior(HitTestMode.Block)
      .onClick((event: ClickEvent) => {
        this.controller?.onMenuClick();
      })
      .hoverEffect(HoverEffect.Highlight)
      .borderRadius(10)
      .width(36)
      .height(20)
    }
    .padding({ left: 12, right: 12 })
    .id('LinkSwitchMenuComponent')
    .enabled(this.uiRefresher.refreshId ? this.menu?.enable as boolean : this.menu?.enable as boolean)
    .opacity(this.uiRefresher.refreshId && this.menu?.enable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .constraintSize({ minHeight: 56 })
    .width('100%')
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  aboutToAppear(): void {
    LogUtil.showDebug(this.tag, ` aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SwitchMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.showDebug(this.tag, `aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}