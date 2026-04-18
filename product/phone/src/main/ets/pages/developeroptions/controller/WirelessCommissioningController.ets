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

import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import systemparameter from '@ohos.systemparameter';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import wifiManager from '@ohos.wifiManager';
import {
  DefaultPhoneDialogPageStyle,
  DefaultStatesMenuStyle,
  DividersGroupStyle,
  PhoneBluetoothDialogPageStyle,
  PhoneDialogTitleMenuStyle,
  TransparentButtonMenu,
  PhoneDialogMsgStyle,
  DialogMessageLabelStyle,
  DialogMessageMenu,
  DialogPage,
  DialogTitleMenu,
  DividerMenuGroup,
  StateMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TextStyle, Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu, MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  SwitchMenuController,
  ButtonMenuController,
  MenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DialogLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  EVENT_ID_WIRELESS_STATE_NUM,
  EVENT_ID_WIRELESS_TYPE_NUM,
} from '@ohos/settings.common/src/main/ets/event/types';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

/* instrument ignore file */
const TAG: string = 'wirelessCommissioningController : ';

export class PhoneDialogMsgStyleLabel extends DialogMessageLabelStyle {
  public title = new PhoneMsgTextStyle();
}

class PhoneMsgTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_primary');
  public font: Font = {
    size: 'app.float.size_16',
    family: 'HarmonyHeiTi',
    weight: FontWeight.Medium,
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_42'),
  };
  public margin:Margin = {
    top:$r('app.float.wh_value_16'),
  }
  public lineHeight = 'app.float.lineHeight_19';
  public textAlign = TextAlign.Start;
}


@Observed
export default class WirelessSwitchController extends SwitchMenuController {
  static CreateWirelessSwitchController(menu: SettingsBaseMenu): Controller {
    return new WirelessSwitchController(menu);
  }

  public checked: boolean = false;
  public state: boolean = false;
  public wirelessState: boolean = false;
  public stateType: boolean = false;
  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    if (isChecked) {
      this.getWifiStatus(isChecked);
    } else {
      try {
        let mode: Promise<void> = systemparameter.set('persist.hdc.mode', '');
        mode.then(async (value: void) => {
          if (this.stateType) {
            await systemparameter.set('persist.hdc.mode.tcp', 'disable');
            emitter.emit({ eventId: EVENT_ID_WIRELESS_TYPE_NUM }, { data: { isChecked: false } });
            this.stateType = false;
          }
          this.setEmitState();
        }).catch((err: BusinessError) => {
          LogUtil.error(`${TAG} ${err.code} BusinessError`);
        });
      } catch (e) {
        LogUtil.error(`${TAG} set unexpected error: ${e?.message}`);
      }
    }
    return true;
  }

  async getWifiStatus(isChecked: boolean) {
    try {
      let wifiName = await WifiUtils.wifiLinkedInfo();
      if (!wifiName) {
        this.dialogShowErr();
        this.setChecked(false);
        return;
      }
    } catch (err) {
      LogUtil.error(`${TAG} get wifiName error ${err?.message}`);
      this.dialogShowErr();
      this.setChecked(false);
      return;
    }
    // 如果是小艺语音唤醒打开无线调试的开关，则界面中不出现提示弹框
    const openType: boolean = AppStorage.get<boolean>('openWirelessIntent') as boolean;
    if (openType) {
      AppStorage.set('openWirelessIntent', false);
      return;
    }
    await this.openWireless(isChecked);
  }

  private async openWireless(isChecked: boolean): Promise<void> {
    let lastLinkedInfo: wifiManager.WifiLinkedInfo = await wifiManager.getLinkedInfo();
    let message: string = lastLinkedInfo.ssid;
    let address: ResourceStr = WifiUtils.number2IpString(lastLinkedInfo.ipAddress).toString();
    this.openWirelessDialog(message, isChecked, address);
  }

  setEmitState() {
    emitter.emit({ eventId: EVENT_ID_WIRELESS_STATE_NUM }, { data: { isChecked: false } });
  }

  openWirelessDialog(message: string, isChecked: boolean, address:string) {
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
          key: 'wireless_dialog_title',
          index: 2, // 页面显示顺序
          title: $r('app.string.allow_wireless'),
          style: new PhoneDialogTitleMenuStyle()
        }
      ),
      new DividerMenuGroup(
        {
          key: 'ip_settings_group',
          index: 20,
          style: new DividersGroupStyle() as Style,
        },
        [
          new StateMenu(
            {
              key: 'ap_connect_state',
              index: 10,
              title: $r('app.string.network_name_ssid'),
              state: message,
              style: new DefaultStatesMenuStyle() as Style,
            }
          ),
          new StateMenu(
            {
              key: 'ap_ip_address',
              index: 70,
              title: $r('app.string.wlan_address_bssid'),
              state: address,
              style: new DefaultStatesMenuStyle() as Style,
            }
          ),
        ]
      ),

      new TransparentButtonMenu(
        {
          key: 'wireless_dialog_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: $r('app.string.button_tittle_cancel'),
          buttonTittle3: $r('app.string.wifi_button_tittle_allow'),
          controller: {
            createControllerConstructorInter: WirelessDialogButtonController.CreateWirelessDialogButtonController,
          },
          extra: isChecked
        }
      ),
    ]

    dialogPage.addMenus(
      menus
    );
    this.openDialog(dialogPage, true);
  }

  dialogShowErr() {
    let dialogPage = new DialogPage({
      pageUrl: 'pages/developeroptions/DeveloperOptionsSettings/uninstall_dialog',
      style: new DefaultPhoneDialogPageStyle(),
    });

    let menus = [
      new DialogTitleMenu(
        {
          key: 'wireless_dialog_no_title',
          index: 2, // 页面显示顺序
          title: $r('app.string.link_wireless'),
          style: new PhoneDialogTitleMenuStyle()
        }
      ),
      new DialogMessageMenu(
        {
          key: 'wireless_dialog_no_message',
          index: 5,
          title: $r('app.string.link_wlan'),
          style: new PhoneDialogMsgStyle() as Style,

        }
      ),

      new TransparentButtonMenu(
        {
          key: 'wireless_dialog_no_button',
          timestamp: Math.random(),
          index: 101, // 页面显示顺序
          buttonTittle1: $r('app.string.dialog_know'),
          controller: {
            createControllerConstructorInter: WirelessDialogNoButtonController.CreateWirelessDialogNoButtonController,
          },
        }
      ),
    ]
    dialogPage.addMenus(menus);

    this.openDialog(dialogPage, true);
  }

  aboutToAppear() {
    this.updateCheckedState();
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    emitter.on({
      eventId: EVENT_ID_WIRELESS_TYPE_NUM,
    }, (eventData: emitter.EventData) => {
      this.setChecked(eventData.data?.isChecked);
      if (eventData.data?.buttonType) {
        this.stateType = true;
      }
    });
    return this.getHdcState();
  }

  private getHdcState(): boolean {
    try {
      let type = systemParameterEnhance.getSync('persist.hdc.mode.tcp');
      this.wirelessState = type === 'enable';
      this.setChecked(this.wirelessState);
      this.stateType = this.wirelessState;
    } catch (error) {
      LogUtil.error(`${TAG} getHdcState error. code:${error?.code} message:${error?.message}`);
    }
    return this.wirelessState;
  }

  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.refreshUi();
  }

  setModeUsb() {
    try {
      let mode: Promise<void> = systemparameter.set('persist.hdc.mode', '');
      mode.then(async (value: void) => {
        await systemparameter.set('persist.hdc.mode.tcp', 'disable');
        this.setChecked(false);
        systemparameter.set('ohos.ctl.stop', 'hdcd');
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} BusinessError ${err.message}`);
      });
    } catch (e) {
      LogUtil.error(`${TAG} set unexpected error: ${e?.message}`);
    }
  }
}


export class WirelessDialogButtonController extends ButtonMenuController {
  static CreateWirelessDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new WirelessDialogButtonController(menu);
  }

  public isChecked: boolean = false;

  onButton1Click(): void {
    emitter.emit({ eventId: EVENT_ID_WIRELESS_TYPE_NUM }, { data: { isChecked: false } });
    this.closeSelf();
  }

  async onButton3Click(): Promise<void> {
    try {
      this.isChecked = this.menu.extra as boolean;
      let timer = setTimeout(async () => {
        await systemparameter.set('persist.hdc.port', '0');
        await systemparameter.set('persist.hdc.mode', 'tcp');
        LogUtil.info(`${TAG}  persist.hdc.mode success`);
        await systemparameter.set('persist.hdc.mode.tcp', 'enable');
        LogUtil.info(`${TAG}  persist.hdc.port success`);
        emitter.emit({ eventId: EVENT_ID_WIRELESS_STATE_NUM }, { data: { isChecked: true } });
       let timers = setTimeout(async () => {
          emitter.emit({ eventId: EVENT_ID_WIRELESS_TYPE_NUM }, { data: { isChecked: true, buttonType:true } });
         clearTimeout(timers);
        }, 300)
        clearTimeout(timer);
      }, 300)
    } catch (err) {
      LogUtil.error(`${TAG} onButton3Click fail ${err.message}`);
    }

    this.closeSelf()
  }
}

export class DeviceShowController extends MenuController {
  static CreateDeviceShowController(menu: SettingsBaseMenu): Controller {
    return new DeviceShowController(menu);
  }

  aboutToAppear() {
    let type = SystemParamUtil.getParam('persist.hdc.mode.tcp', 'disable');
    this.setVisible(type === 'enable');
    emitter.on({
      eventId: EVENT_ID_WIRELESS_TYPE_NUM,
    }, (eventData: emitter.EventData) => {
      this.setVisible(eventData.data?.isChecked);
    });
  }

  aboutToDisappear() {
    emitter.off(EVENT_ID_WIRELESS_TYPE_NUM);
  }
}

export class IpAddressController extends MenuController {
  static CreateIpAddressController(menu: SettingsBaseMenu): Controller {
    return new IpAddressController(menu);
  }
  private TAG: string = 'IpAddressController';
  private wirelessChangeTimer: number = 0;

  aboutToAppear() {
    try {
      LogUtil.info(`${this.TAG} aboutToAppear`);
      wifiManager.getLinkedInfo().then(async val => {
        let ipName = WifiUtils.number2IpString(val.ipAddress).toString();
        if (ipName) {
          let port = await systemparameter.get('persist.hdc.port');
          ipName = `${ipName}:${port}`;
        }
        this.menu.state = ipName;
        this.menu.accessibilityDescription = ' ';
      });
    } catch (err) {
      LogUtil.error(`${TAG} aboutToAppear ${err?.message}`);
    }
    this.registerWirelessChangeEvent();
  }

  private registerWirelessChangeEvent() {
    emitter.on({
      eventId: EVENT_ID_WIRELESS_TYPE_NUM,
    }, async (eventData: emitter.EventData) => {
      if (eventData.data?.isChecked) {
        this.wirelessChangeTimer = setTimeout(async () => {
          let port = await systemparameter.get('persist.hdc.port');
          let lastLinkedInfo = await wifiManager.getLinkedInfo();
          let ipName = WifiUtils.number2IpString(lastLinkedInfo.ipAddress).toString();
          let ipAddress = await WifiUtils.wifiIpAddress();
          AppStorage.Delete('wifi_ip_mode');
          AppStorage.SetOrCreate('wifi_ip_mode', ipAddress);
          LogUtil.info(`${TAG}  getDeviceMacAddress success`);
          ipName = `${ipName}:${port}`;
          this.menu.state = ipName;
          this.menu.accessibilityDescription = ' ';
          this.refreshUi();
          clearTimeout(this.wirelessChangeTimer);
        }, 1000);
      }
    });
  }

  private unRegisterWirelessChangeEvent() {
    emitter.off(EVENT_ID_WIRELESS_TYPE_NUM);
  }
  aboutToDisappear() {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.unRegisterWirelessChangeEvent();
    clearTimeout(this.wirelessChangeTimer);
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
      eventId: EVENT_ID_WIRELESS_TYPE_NUM,
    }, {
      data: { isChecked: false }
    });
  }

  onDialogOpen(key?: string, data?: Object): void {
  }
}


export class WirelessDialogNoButtonController extends ButtonMenuController {
  static CreateWirelessDialogNoButtonController(menu: SettingsBaseMenu): Controller {
    return new WirelessDialogNoButtonController(menu);
  }

  onButton1Click(): void {
    this.closeSelf();
  }
}