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

import CommonEventManager from '@ohos.commonEventManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ButtonMenuController, CheckboxMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  DialogMessageMenu,
  DialogMessageStyle,
  PhoneBluetoothDialogPageStyle,
  TransparentButtonMenu,
  PhoneDialogMsgStyle,
  DialogTitleMenu,
  DialogPage
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { ContainerStyle, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuGroup, SettingsBaseMenu, MenuPage } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleLoadingGroupController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { BusinessError } from '@ohos.base';
import systemparameter from '@ohos.systemparameter';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
/* instrument ignore file */
enum AccessAuthorization {
  UNKNOWN = 0,
  ALLOWED = 1,
  REJECTED = 2,
}

export class UsbDebugDialogController extends PageLifecycleLoadingGroupController {
  public readonly tag: string = 'UsbDebugDialogController : ';
  public isStarted: boolean = false;
  public currentIndex: number = 0;
  public isSearchMessageShow: boolean = false;
  public root: PageRoot;
  public message: string = '';
  public secretMessage: string = '';
  private isInitState = true;

  // 获取USB设备状态发生变化的事件回调
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_USB_STATE,
    ]
  };

  constructor(menu: SettingsBaseMenu, root: PageRoot) {
    super(menu);
    this.menu = menu;
    this.root = root;
  }

  async openMapAuthDialog(): Promise<void> {
    LogUtil.info(`${this.tag} openDialog`);
    if (!DeviceStateUtils.isDeviceProvisioned()) {
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)?.terminateSelf();
      this.setParameter();
      return;
    }
    let value = await systemparameter.get('persist.hdc.client.hostname');
    this.message = await ResourceUtil.getAnyStrFormatString($r('app.string.machine_name'), value);
    let secretValue = await systemparameter.get('persist.hdc.client.pubkey_sha256');
    this.secretMessage = await ResourceUtil.getAnyStrFormatString($r('app.string.public_key_name'), secretValue);
    this.openDialog(this.buildDialog(), false);
  }

  private usbStateChange: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (this.isInitState) {
      this.isInitState = false;
      return;
    }
    if (err?.code !== 0) {
      LogUtil.error(`${this.tag} usbStateCharge err: Code is ${err?.code}, message is ${err?.message}`);
      return;
    }
    LogUtil.info(`${this.tag} usbStateChange :${data?.parameters?.connected}`);
    if (!data?.parameters?.connected) {
      LogUtil.info(`${this.tag} usbStateChange closeDialog`);
      this.root.closeDialog();
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)?.terminateSelf();
      return;
    }
  });

  public registerCommonEvent(): void {
    this.usbStateChange.registerCommonEvent();
  }

  public unRegisterCommonEvent(): void {
    this.usbStateChange.unRegisterCommonEvent();
  }

  private buildDialog(): MenuPage {
    LogUtil.info(`${this.tag} buildDialog:`);
    let mapAuthMenu = new DialogPage({
      pageUrl: 'pages/developeroptions/DeveloperOptionsSettings/infoAuth',
      title: 'test_UsbDebug_dialog',
      style: new PhoneBluetoothDialogPageStyle(),
    });
    let menus: SettingsBaseMenu[];
    LogUtil.info(`${this.tag} buildDialog deviceId:`);
    menus = this.getMapAuthMenus() as Array<SettingsBaseMenu>;

    mapAuthMenu.addMenu(
      new MenuGroup(
        {
          key: 'usbdebug_auth_group',
          index: 10,
          timestamp: Math.random(),
        },
        menus
      ));
    return mapAuthMenu;
  }

  async openDialog(menuPage: MenuPage, autoCancel?: boolean): Promise<void> {
    LogUtil.info(`${this.tag} openDialog, root:${this.root}`);
    this.root.openDialog(menuPage, autoCancel);
  }

  onDialogCancel(key?: string, data?: Object): void {
    LogUtil.info(`${this.tag} onDialogCancel key :${key}`);
    (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession)?.terminateSelf();
  }

  setParameter() {
    let parameterValue = 'auth_result:0';
    let authResult: Promise<void> = systemparameter.set('persist.hdc.daemon.auth_result', parameterValue);
    LogUtil.info(`set persist.hdc.daemon.auth_result success:  ${authResult}`)
  }

  private getMapAuthMenus(): Array<SettingsBaseMenu> | void {
    setTimeout(() => {
      this.closeSelf();
      (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession).terminateSelf();
      this.setParameter()
    }, 180000)

    LogUtil.info(`${this.tag} getMapAuthMenus `);
    let menus: SettingsBaseMenu[] = [
      new DialogTitleMenu(
        {
          key: 'usbdebug_dialog_title',
          index: 1, // 页面显示顺序
          title: $r('app.string.trusted_device_title'),
        }
      ),
      new DialogMessageMenu({
        key: 'usbdebug_dialog_message',
        title: this.message,
        index: 10,
        style: new PhoneDialogMsgStyle() as Style,
      }
      ),
      new DialogMessageMenu({
        key: 'shortKey_Enable_Setting',
        index: 20,
        title: this.secretMessage,
        style: new PhoneDialogMsgStyle() as Style,
      }),
      new TransparentButtonMenu(
        {
          key: 'usbdebug_dialog_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: $r('app.string.always_allow_debug'),
          buttonTittle2: $r('app.string.trusted_device_button_confirm'),
          buttonTittle3: $r('app.string.trusted_device_button_cancel'),
          controller: {
            createControllerConstructorInter: UsbDebugButtonController.CreateUsbDebugButtonController,
          },
          menuType : MenuType.HDC_AUTHORIZATION_COMPONENT,
        }
      ),
    ];
    return menus;
  }
}

export class PhoneBluetoothDialogMsgStyle extends DialogMessageStyle {
  public rootContainer = new PhoneBluetoothDialogMsgContainerStyle();
  public title = new PhoneBluetoothDialogMsgTextStyle();
}

class PhoneBluetoothDialogMsgContainerStyle extends ContainerStyle {
  public margin: Margin = {
    top: $r('app.float.margin_16'),
  };
  public size: SizeOptions = {
    width: '100%',
  };
}

class PhoneBluetoothDialogMsgTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: $r('app.float.size_16'),
    family: 'HarmonyHeiTi',
    weight: FontWeight.Regular,
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public lineHeight = 'app.float.lineHeight_19';
  public textAlign = TextAlign.Start;
}

@Observed
export class UsbDebugApproveController extends CheckboxMenuController {
  static CreateUsbDebugApproveController(menu: SettingsBaseMenu): Controller {
    return new UsbDebugApproveController(menu);
  }

  public checkout: Boolean = false

  onMenuChange(value: boolean): void {
    super.onMenuChange(value);
    if (value !== this.checkout) {
      LogUtil.info(` stateChange: ${value}`);
      this.checkout = value;
      this.publishDataChange(value);
    }
    this.refreshUi();
  }
}


@Observed
export class UsbDebugButtonController extends ButtonMenuController {
  static CreateUsbDebugButtonController(menu: SettingsBaseMenu): Controller {
    return new UsbDebugButtonController(menu);
  }

  public checkBoxState: Boolean = false;

  protected registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange `);
    this.registerControllerDataChange('usbdebug_dialog_approval');
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange `);
    this.unRegisterControllerDataChange('usbdebug_dialog_approval');
  }

  onDataChange(fromKey: string, data: Object): void {
    LogUtil.info(`${this.tag} onDataChange data`);
    if (fromKey === 'usbdebug_dialog_approval') {
      this.checkBoxState = data as boolean;
    }
  }

  onButton1Click(): void {
    this.setParameter('auth_result:2');
  }

  onButton2Click(): void {
    this.setParameter('auth_result:1');
  }

  onButton3Click(): void {
    this.setParameter('auth_result:0');
  }

  setParameter(parameterValue: string) {
    if (CheckEmptyUtils.isEmpty(parameterValue)) {
      return;
    }
    try {
      let authResult: Promise<void> = systemparameter.set('persist.hdc.daemon.auth_result', parameterValue);
      authResult.then((value: void) => {
        LogUtil.info(`set test.parameter.key success:  ${value}`)
        this.closeSelf();
        (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession).terminateSelf();
      }).catch((err: BusinessError) => {
        (AppStorage.get<UIExtensionContentSession>('dialogSession') as UIExtensionContentSession).terminateSelf();
        LogUtil.error(`set test.parameter.key error: ${err.code}`)
      });
    } catch (e) {
      LogUtil.error(`set unexpected error: ${e}`)
    }
  }
}