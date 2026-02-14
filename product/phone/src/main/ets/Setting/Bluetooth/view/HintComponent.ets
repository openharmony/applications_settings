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
import promptAction from '@ohos.promptAction';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { BluetoothUtils, BLUETOOTH_DEVICE_NAME_COMP_ID } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CompStateEvent, SettingCompState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiSysUpdateDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import lazy {
  NameUpdateSheetComponent
} from '@ohos/settings.commonUikit/src/main/ets/component/NameUpdateSheetComponent';
import { NetworkUtils } from '@ohos/settings.common/src/main/ets/utils/NetworkUtils';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ContextUtils } from '@ohos/settings.common';
import { settings } from '@kit.BasicServicesKit';
import connection from '@ohos.bluetooth.connection';

const CONFIRM_DEVICES_NAME: string = 'confirm_devices_name';
const PAGE_INFO: string = 'Bluetooth';
const DEVICE_NAME_SETTINGS: string = 'DeviceNameSettings';

@Component
export struct HintComponent {
  tag: string = 'HintComponent: ';
  start: ResourceStr = '';
  middle: ResourceStr = '';
  end: ResourceStr = '';
  last: ResourceStr = '';
  @State localDeviceName: ResourceStr = '';
  @State isSwitchOn: boolean = BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isShow: boolean = false;
  @State inputValue: string = '';
  @State isGrayed: boolean = PreferencesUtil.getSync(DEVICE_NAME_SETTINGS, false) as boolean;
  private compStateEvent?: CompStateEvent;
  private largerFontDialogController: CustomDialogController | undefined = undefined;
  private switchEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} recevie toggle state: ${toggleState.state}`);
    this.isSwitchOn = toggleState.state;
    if (this.isSwitchOn) {
      this.updateDeviceNameIfNeed();
    }
  };
  private footerUpdateEventCallback = () => {
    LogUtil.info(`${this.tag} recevie update event`);
    this.updateDeviceNameIfNeed();
  };

  build() {
    if (this.isSwitchOn) {
      Scroll() {
        Text() {
          Span(this.start)
            .fontSize($r('sys.float.Body_S'))
            .constraintSize({ minHeight: $r('app.float.wh_value_16') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))

          Span(this.localDeviceName)
            .fontSize($r('sys.float.Body_S'))
            .constraintSize({ minHeight: $r('app.float.wh_value_16') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))

          Span(this.middle)
            .fontSize($r('sys.float.Body_S'))
            .constraintSize({ minHeight: $r('app.float.wh_value_16') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))

          Span(this.end)
            .fontSize($r('sys.float.Body_S'))
            .constraintSize({ minHeight: $r('app.float.wh_value_16') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor(this.isGrayed ? $r('sys.color.font_secondary') : $r('sys.color.font_emphasize'))
            .onClick(() => {
              this.isShow = true;
            })
        }
        .enabled(!this.isGrayed)
        .visibility(this.isSwitchOn ? Visibility.Visible : Visibility.None)
        .textAlign(TextAlign.Start)
        .width('100%')
        .wordBreak(WordBreak.BREAK_WORD)
        .bindSheet(this.isShow, this.updateNameSheetBuilder(), {
          detents: [DisplayUtils.getScreenHeight() * 0.75],
          height: 320,
          preferType: SheetType.CENTER,
          dragBar: true,
          title: { title: $r('app.string.change_device_name') },
          backgroundColor: $r('sys.color.ohos_id_color_dialog_bg'),
          maskColor: $r('sys.color.mask_fourth'),
          showClose: true,
          keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
          onWillDisappear: () => {
            LogUtil.info(`${this.tag} onWillDisappear`);
            this.isShow = false;
          },
        })
        .onClick(() => {
          this.isShow = true;
        })
      }
      .scrollBar(BarState.Off)
      .constraintSize({ maxHeight: '25%' })
      .padding({ bottom: PADDING_16 })
    }
  }

  @Builder
  updateNameSheetBuilder() {
    Column() {
      NameUpdateSheetComponent({
        hint: CapabilitySupportUtils.isSupportNearLink() ?
          $r('app.string.device_name_settings_summary_with_near_link') :
          $r('app.string.device_name_settings_summary_new'),
        maxLength: 100,
        textValue: this.localDeviceName,
        inputValue: this.inputValue,
        primaryButton: $r('app.string.dialog_sure'),
        confirm: () => {
          LogUtil.info(`${this.tag} confirm`);
          this.changeDeviceName();
        },
        closeDialog: () => {
          LogUtil.info(`${this.tag} close sheet`);
          this.isShow = false;
        },
      })
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(this.tag, `aboutToAppear, isGrayed: ${this.isGrayed}, isSwitchOn: ${this.isSwitchOn}`);
    this.updateHint();
    this.compStateEvent = new CompStateEvent(BLUETOOTH_DEVICE_NAME_COMP_ID, {
      enabled: (enabledState: SettingCompState): void => {
        if (enabledState.state !== undefined && enabledState.state === this.isGrayed) {
          this.isGrayed = !enabledState.state;
        }
      }
    });
    this.compStateEvent.on();
    EventBus.getInstance().on(`Setting.Bluetooth.SwitchGroup.SwitchItem.toggle`, this.switchEventCallback);
    EventBus.getInstance().on(`Setting.Bluetooth.SwitchGroup.footer.update`, this.footerUpdateEventCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.compStateEvent?.detach();
    EventBus.getInstance().detach(`Setting.Bluetooth.SwitchGroup.SwitchItem.toggle`, this.switchEventCallback);
    EventBus.getInstance().detach(`Setting.Bluetooth.SwitchGroup.footer.update`, this.footerUpdateEventCallback);
  }

  private updateHint(): void {
    if (this.isSwitchOn) {
      this.updateDeviceNameIfNeed();
    }
    this.transFormResource();
  }

  private updateDeviceNameIfNeed(): void {
    let deviceName: string = DeviceNameUtil.getDisplayDeviceName();
    LogUtil.info(this.tag+'deviceName::'+deviceName)
    this.localDeviceName = deviceName;
    this.updateBtName(deviceName);
    this.updateBtLocalName(deviceName)
  }

  private transFormResource(): void {
    let res = $r('app.string.bluetooth_device_name_title');
    const START_SEP: string = '%1$s';
    const END_SEP: string = '%2$s';
    let result: string = ResourceUtil.getStringSync(res);
    let endIndex: number = result.indexOf(END_SEP);
    let startIndex: number = result.indexOf(START_SEP);
    this.start = result.slice(0, startIndex);
    this.middle = result.slice(startIndex + START_SEP.length, endIndex);
    this.end = $r('app.string.near_link_edit_device_name');
    this.last = result.slice(endIndex + END_SEP.length, result.length);
  }

  private updateBtName(deviceName: string): void {
    let btName: string = DeviceNameUtil.getDisplayDeviceName();
    if (btName !== deviceName) {
      let result = DeviceNameUtil.setDisplayDeviceNameAsync(btName);
      LogUtil.info(`${this.tag} setLocalName result is : ${result}`);
    }
  }

  private changeDeviceName(): void {
    let deviceName: string = this.inputValue;
    if (CheckEmptyUtils.checkStrIsEmpty(deviceName)) {
      return;
    }
    HiSysEventUtil.reportButtonEvent(CONFIRM_DEVICES_NAME, deviceName);
    let name = DeviceNameUtil.getDisplayDeviceName();
    if (name === deviceName || !BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      LogUtil.warn(`${this.tag} the bluetooth state is on or the deviceName is same: ${BluetoothAdapter.getInstance()
        .currentState}`);
      this.isShow = false;
      return;
    }
    this.updateDeviceName(deviceName);
  }

  private updateDeviceName(deviceName: string): void {
    let btName = DeviceNameUtil.getDeviceNameAsync();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysUpdateDeviceEventGroup.UPDATE_DEVICE_NAME, PAGE_INFO);
    if (btName === deviceName) {
      LogUtil.showWarn(this.tag, `device name is the same`);
      return;
    }
    DeviceNameUtil.setDisplayDeviceNameAsync(deviceName).then((result: boolean) => {
      EventBus.getInstance().emit('deviceNameCheck');
      if (!result) {
        LogUtil.showWarn(this.tag, `updateDeviceName fail`);
        return;
      }
      this.isShow = false;
      const context: Context = ContextUtils.getContext()
      let bluetoothResult = settings.setValueSync(context, settings.general.DEVICE_NAME,deviceName);
      LogUtil.showInfo(this.tag, `updateDeviceName success. setLocalName result: ${bluetoothResult}`);
      homeInitData.deviceName = deviceName;
      this.localDeviceName = deviceName;
      // 同步更新蓝牙广播名称，使其他设备搜索时能看到新名称
      this.updateBtLocalName(deviceName);
    });
  }

  /**
   * 更新蓝牙本地广播名称
   * @param deviceName 新的设备名称
   */
  private updateBtLocalName(deviceName: string): void {
    if (!BluetoothUtils.isBluetoothOn()) {
      LogUtil.info(`${this.tag} bluetooth is off, skip update local name`);
      return;
    }
    try {
      let btName: string = connection.getLocalName();
      if (btName !== deviceName) {
        connection.setLocalName(deviceName);
        LogUtil.info(`${this.tag} setLocalName success.`);
      } else {
        LogUtil.info(`${this.tag} bluetooth local name is already ${(deviceName)}`);
      }
    } catch (error) {
      LogUtil.error(`${this.tag} setLocalName failed, error is ${error?.message}`);
    }
  }

}