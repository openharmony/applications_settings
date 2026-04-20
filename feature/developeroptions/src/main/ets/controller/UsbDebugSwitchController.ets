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
import emitter from '@ohos.events.emitter';
import settings from '@ohos.settings';
import systemparameter from '@ohos.systemparameter';
import usbManager from '@ohos.usbManager';
import {
  ButtonMenuController,
  CheckboxMenuController,
  MenuController,
  SwitchMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  DefaultPhoneDialogPageStyle,
  DialogMessageMenu,
  DialogPage,
  DialogTitleMenu,
  PhoneBluetoothDialogPageStyle,
  PhoneDialogCenterMsgStyle,
  PhoneDialogMsgStyle,
  PhoneDialogTitleMenuStyle,
  TransparentButtonMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_WIRELESS_STATE_NUM } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';

const FUNCTION_TYPE_HDC = 4;
const CHANGE_USB_DEBUG_SWITCH: string = 'change_usb_debug_switch';
const wirelessCommissioningNum = 7882;
const FUNCTION_TYPE_STORAGE = 512;
const FUNCTION_TYPE_NONE = 0;
const INSIGHT_INTENT_DEBUG_STATE_NUM = 7884;
const INSIGHT_INTENT_DEBUG_SETTING_NAME:string = 'ai_insightintent_debug';
const INSIGHT_INTENT_DEBUG_SETTING_VALUE_CLOSE:string = 'false';
const INSIGHT_INTENT_DEBUG_SETTING_VALUE_OPEN:string = 'true';
/**
 * USB调试开关控制器
 *
 * @since 2022-06-28
 */
export class UsbDebugSwitchController extends SwitchMenuController {
  static CreateUsbDebugSwitchController(menu: SettingsBaseMenu): Controller {
    return new UsbDebugSwitchController(menu);
  }

  public readonly tag: string = 'UsbDebugSwitchController : ';
  public state: boolean = false;
  public timer: number = 0;
  public device: boolean = false;
  public currentFunctions: number = 0;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_USB_STATE,
    ]
  };

  // instrument ignore next
  aboutToAppear() {
    this.updateCheckedState();
    emitter.off(wirelessCommissioningNum);
    emitter.on({
      eventId: wirelessCommissioningNum,
      priority: emitter.EventPriority.IMMEDIATE,
    }, async (eventData: emitter.EventData) => {
      let isChecked: boolean = eventData.data?.isChecked;
      this.state = true;
      if (eventData.data?.buttonType) {
        this.setUsbState(isChecked);
        return;
      }
      this.setChecked(!isChecked);
      if (isChecked) {
        try {
          let functions = eventData.data?.wireless ? FUNCTION_TYPE_STORAGE : FUNCTION_TYPE_HDC;
          usbManager.setDeviceFunctions(functions);
          LogUtil.showInfo(this.tag, `setDeviceFunctions success ${functions}`);
        } catch (err) {
          this.setChecked(!isChecked);
          LogUtil.showError(this.tag, `setCurrentFunctions fail: code: ${err?.code} message: ${err?.message}`);
        }
      } else {
        try {
          let functions: usbManager.FunctionType = FUNCTION_TYPE_STORAGE;
          HiSysEventUtil.reportSwitchEvent(CHANGE_USB_DEBUG_SWITCH, 'on');
          usbManager.setDeviceFunctions(functions);
        } catch (err) {
          this.setChecked(!isChecked);
          LogUtil.showError(this.tag, `setDeviceFunctions fail: code: ${err?.code} message: ${err?.message}`);
        }
      }
    });
  }

  onPageDestroy() {
    emitter.off(wirelessCommissioningNum)
  }

  // instrument ignore next
  async setUsbState(isChecked: boolean) {
    if (isChecked) {
      this.setToggleState(false);
      await systemparameter.set('persist.hdc.mode', 'usb');
      let functions: usbManager.FunctionType;
      functions = FUNCTION_TYPE_HDC;
      HiSysEventUtil.reportSwitchEvent(CHANGE_USB_DEBUG_SWITCH, 'on');
      SystemParamUtil.setParam('persist.hdc.mode.usb', 'enable');
      try {
        this.currentFunctions = usbManager.getDeviceFunctions();
        LogUtil.showInfo(this.tag, `currentFunctions :${this.currentFunctions}`);
        if (this.currentFunctions && this.currentFunctions !== FUNCTION_TYPE_STORAGE) {
          await usbManager.setDeviceFunctions(this.currentFunctions | FUNCTION_TYPE_HDC);
        } else {
          await usbManager.setDeviceFunctions(functions);
        }
        LogUtil.showInfo(this.tag, `open usb switch, currentFunctions: ${usbManager.getDeviceFunctions()}`);
        this.setToggleState(true);
      } catch (err) {
        LogUtil.showError(this.tag, `setDeviceFunctions fail: code: ${err?.code} message: ${err?.message}`);
        this.setToggleState(true);
        this.setChecked(!isChecked);
      }
    } else {
      this.setChecked(isChecked);
    }
  }

  protected updateCheckedState(): boolean {
    let functions: usbManager.FunctionType = 0;
    try {
      functions = usbManager.getDeviceFunctions() || 0;
      LogUtil.showInfo(this.tag, `usbManager getDeviceFunctions success: ${functions}`);
    } catch (err) {
      LogUtil.showError(this.tag, `usbManager getDeviceFunctions fail: code: ${err?.code} message: ${err?.message}`);
    }
    let checked: boolean = (functions & FUNCTION_TYPE_HDC) === FUNCTION_TYPE_HDC;
    this.setChecked(checked);
    return checked;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.showInfo(this.tag, `handleCheckedChange isChecked: ${isChecked}`);

    if (isChecked) {
      this.onRadioChange(true);
    } else {
      this.closeUSBDebug();
    }
    return true;
  }

  // instrument ignore next
  private async closeUSBDebug(): Promise<void> {
    try {
      this.setToggleState(false);
      this.currentFunctions = usbManager.getDeviceFunctions() || 0;
      LogUtil.showInfo(this.tag, `currentFunctions : ${this.currentFunctions}`);
      let functions: number = this.currentFunctions & (~FUNCTION_TYPE_HDC);
      LogUtil.showInfo(this.tag, `functions : ${functions}`);
      if (functions === FUNCTION_TYPE_NONE) {
        await usbManager.setDeviceFunctions(FUNCTION_TYPE_STORAGE);
      } else {
        await usbManager.setDeviceFunctions(this.currentFunctions & (~FUNCTION_TYPE_HDC));
      }
      await systemparameter.set('persist.hdc.mode.usb', 'disable');
      LogUtil.showInfo(this.tag, `close usb switch, currentFunctions: ${usbManager.getDeviceFunctions()}`);
      this.setToggleState(true);
    } catch (err) {
      LogUtil.showError(this.tag, `setCurrentFunctions fail code: ${err?.code} message: ${err?.message}`);
      this.setChecked(false);
      this.setToggleState(true);
    }
  }

  onRadioChange(isChecked: boolean): void {
    LogUtil.showInfo(this.tag, `onRadioChange, isChecked=${isChecked}`);

    if (!this.menu) {
      return;
    }
    let dialogPage = new DialogPage({
      pageUrl: 'pages/developeroptions/DeveloperOptionsSettings/uninstall_dialog',
      controller: {
        createControllerConstructorInter: FullExpDialogController.CreateFullExpDialogController,
      },
      style: new DefaultPhoneDialogPageStyle(),
    });
    let menus = [

      new DialogTitleMenu(
        {
          key: 'usbdebug_dialog_title',
          index: 2, // 页面显示顺序
          title: $r('app.string.whether_usb_debug_title'),
          style: new PhoneDialogTitleMenuStyle()
        }
      ),
      new DialogMessageMenu(
        {
          key: 'usbdebug_dialog_message',
          index: 5,
          title: $r('app.string.usb_dialog_content'),
          style: new PhoneDialogMsgStyle() as Style,
        }
      ),

      new TransparentButtonMenu(
        {
          key: 'usbdebug_dialog_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: $r('app.string.button_tittle_cancel'),
          buttonTittle3: $r('app.string.button_tittle_allow'),
          controller: {
            createControllerConstructorInter: UsbDebugDialogButtonController.CreateUsbDebugDialogButtonController,
          },
          extra: isChecked
        }
      )
    ]
    dialogPage.addMenus(menus);

    this.openDialog(dialogPage, true);
  }
}

@Observed
export class UsbDebugApproveController extends CheckboxMenuController {
  static CreateUsbDebugApproveController(menu: SettingsBaseMenu): Controller {
    return new UsbDebugApproveController(menu);
  }

  public checkout: Boolean = false;

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
export class RecallUsbDebugApproveController extends MenuController {
  static CreateRecallUsbDebugApproveController(menu: SettingsBaseMenu): Controller {
    menu.isGrayed = PreferencesUtil.getSync('usb_debug', false) as boolean;
    return new RecallUsbDebugApproveController(menu);
  }

  public checkout: Boolean = false;

  onMenuClick() {
    this.openChangeBrowserDialog();
    return true;
  }

  private openChangeBrowserDialog(): void {
    LogUtil.info(`${this.tag} openSwtichDialog`);
    let detail = new DialogPage({
      pageUrl: 'pages/display/DisplaySettings/revocation_usb_authorize',
      title: $r('app.string.revocation_usb_authorize'),
      style: new DefaultPhoneDialogPageStyle(),
    });
    let menus = [
      new DialogTitleMenu(
        {
          key: 'open_developer_mode',
          index: 10,
          title: $r('app.string.revocation_usb_authorize'),
          style: new PhoneDialogTitleMenuStyle(),
        },
      ),
      new DialogMessageMenu(
        {
          key: 'open_developer_mode_message',
          index: 10, // 页面显示顺序
          title:  $r('app.string.recall_usb_authorize_title'),
          style: new PhoneDialogCenterMsgStyle() as Style,
        }
      ),
      new TransparentButtonMenu(
        {
          key: 'open_developer_mode_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: $r('app.string.button_tittle_cancel'),
          buttonTittle3: $r('app.string.Confirm_the_cancellation'),
          controller: {
            createControllerConstructorInter: DialogButtonController.CreateDialogButtonController,
          },
        }
      ),
    ]
    detail.setHeader(new MenuGroup(
      {
        key: 'open_developer_mode_header_group',
        index: 10, // 页面显示顺序
        timestamp: Math.random(),
        style: new PhoneBluetoothDialogPageStyle(),
      },
      [menus[0]],
    ))
    detail.setFooter(new MenuGroup(
      {
        key: 'open_developer_mode_footer_group',
        index: 10, // 页面显示顺序
        timestamp: Math.random(),
      },
      [menus[menus.length - 1]],
    ))
    detail.addMenus(
      menus.filter((item, index) => index !== 0 && index !== menus.length - 1)
    );
    this.openDialog(detail, true);
  }
}

@Observed
export class WirelessCommissioningController extends MenuController {
  static CreateWirelessCommissioningController(menu: SettingsBaseMenu): Controller {
    return new WirelessCommissioningController(menu);
  }
  private TAG: string = 'WirelessCommissioningController';

  async aboutToAppear() {
    this.getModeState();
    emitter.on({
      eventId: EVENT_ID_WIRELESS_STATE_NUM,
      priority: emitter.EventPriority.IMMEDIATE,
    }, (eventData: emitter.EventData) => {
      let isChecked: boolean = eventData.data?.isChecked;
      this.getModeState(isChecked);
    })
  }

  onPageDestroy() {
    emitter.off(EVENT_ID_WIRELESS_STATE_NUM);
  }

  async getModeState(isChecked?: boolean) {
    try {
      LogUtil.info(`${this.TAG} isChecked ${isChecked}`);
      this.menu.state = isChecked ? $r('app.string.opened_wireless') : $r('app.string.closed_wireless');
      systemparameter.get('persist.hdc.mode.tcp').then(val => {
        LogUtil.info(`${this.TAG} persist.hdc.mode.tcp: ${val}`);
        this.menu.state = val === 'enable' ? $r('app.string.opened_wireless') : $r('app.string.closed_wireless');
      });
    } catch (err) {
      LogUtil.info(`${this.TAG} persist.hdc.mode code ${err?.code}`);
    }
  }
}

@Observed
export class DialogButtonController extends ButtonMenuController {
  static CreateDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new DialogButtonController(menu);
  }
  public tag: string = 'DialogButtonController : ';
  onButton1Click(): void {
    LogUtil.info(`${this.tag} cancel`);
    this.closeSelf();
  }
  async onButton3Click() {
    try {
      systemparameter.set('persist.hdc.daemon.auth_cancel', 'true');
      LogUtil.info(`persist.hdc.daemon.auth_result`);
      this.closeSelf();
    } catch (err) {
      LogUtil.error(`${this.tag} set unexpected error code: ${err.code} message: ${err.message}`);
    }
  }
}


@Observed
export class UsbDebugDialogButtonController extends ButtonMenuController {
  static CreateUsbDebugDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new UsbDebugDialogButtonController(menu);
  }

  onButton1Click(): void {
    emitter.emit({
      eventId: wirelessCommissioningNum,
    }, { data: { isChecked: false, buttonType: true } });
    this.closeSelf();
  }

  onButton3Click(): void {
    emitter.emit({
      eventId: wirelessCommissioningNum,
    }, { data: { isChecked: true, buttonType: true } });
    this.closeSelf();
  }
}

export class FullExpDialogController extends MenuController implements DialogLifecycleObserverInterface {
  public getObserverKey?: () => string = (): string => {
    return this.menu?.key as string;
  }
  public isChecked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.isChecked = !menu?.status as boolean;
  }

  static CreateFullExpDialogController(menu: SettingsBaseMenu): Controller {
    return new FullExpDialogController(menu);
  }

  onDialogClose(key?: string, data?: Object): void {

  }

  onDialogCancel(key?: string, data?: Object): void {
    emitter.emit({
      eventId: wirelessCommissioningNum,
    }, {
      data: { isChecked: false, buttonType: true }
    });
  }

  onDialogOpen(key?: string, data?: Object): void {
  }
}