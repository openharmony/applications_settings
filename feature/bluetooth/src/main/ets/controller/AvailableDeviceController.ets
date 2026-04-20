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
import commonEventManager from '@ohos.commonEventManager';
import preferences from '@ohos.data.preferences';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemType,
  SettingIconType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingDialogState,
  SettingIconState,
  SettingStateType,
  SettingTextState,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { BluetoothUtils, UnbondCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  BluetoothAdapter,
  BluetoothBondChangeListener,
  BluetoothDeviceChangeListener,
  BluetoothLoadStateChangeListener,
  BluetoothRemoveSummaryListener,
  BluetoothStateChangeListener
} from '../BluetoothAdapter';
import { BluetoothItemModel } from '../model/BluetoothItemModel';
import { BluetoothDevice, BondState, BondStateParam, PinRequiredParam } from '../model/BluetoothModel';
import { Utils } from '../utils/Utils';
import { pairFailedDialogContentBuilder } from '../view/CustomBuilder';
import { BluetoothDeviceController } from './BluetoothDeviceController';

/* instrument ignore file */
const CLICK_BLUETOOTH_NAME: string = 'click_bluetooth_name';
const HELP_POPUP_SHOW_DELAY: number = 800;

/**
 * 可用蓝牙设备列表控制器
 *
 * @since 2022-04-25
 */
export class AvailableDeviceController implements ComponentControl, BluetoothStateChangeListener,
BluetoothDeviceChangeListener, BluetoothBondChangeListener, BluetoothLoadStateChangeListener,
BluetoothRemoveSummaryListener {
  public tag: string = 'AvailableDeviceController: ';
  public currentIndex: number = 0;
  public isSearchMessageShow: boolean = false;
  public isScanLoadingShow: boolean = false;
  private pairingDeviceId: string = '';
  private isPairing: boolean = false;
  public dataSource?: OrderedDataSource;
  public compId?: string;
  private deviceTimeMap: Map<string, string> = new Map();
  private isAlreadyShowPopup: boolean = false; // 标记本次进入本页面是否已弹气泡
  private isAlreadyClickPair: boolean = false; // 标记本次进入本页面是否已点击可用设备进行配对
  private isPageHide: boolean = false;
  private showHelpPopupTimerId: number | null = null; // 首次进入本页面延时显示气泡，避免还未进入蓝牙设置页面就显示气泡
  private switchStateEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleState is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} receive toggle state change: ${toggleState.state}`);
    this.showOrHideHeader(toggleState.state);
    this.showOrHideGroup(toggleState.state);
  };
  private clickPairEnentCallback = () => {
    LogUtil.info(`${this.tag} receive clickPair event`);
    this.setAlreadyClickPair(true);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init, compId: ${compParam.compId}`);
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.compId = compParam.compId;
    this.registerDataChange();
    EventBus.getInstance().on('Setting.Bluetooth.SwitchGroup.SwitchItem.toggle', this.switchStateEventCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_BLUETOOTH_CLICK_PAIR, this.clickPairEnentCallback);

    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      this.showOrHideGroup(true);
      this.showOrHideHeader(true);
      this.showHelpPopupIfFirstEnter();
    }
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    this.setPageHide(false);
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState) && this.isPairing &&
      !CheckEmptyUtils.checkStrIsEmpty(this.pairingDeviceId)) {
      let bondState: BondState = Utils.getPairState(this.pairingDeviceId);
      if (bondState === BondState.BOND_STATE_BONDED) {
        this.isPairing = false;

        let index: number = this.findMenu(this.pairingDeviceId);
        if (index === -1) {
          LogUtil.info(`${this.tag} not found device`);
          this.pairingDeviceId = '';
          return;
        }

        LogUtil.info(`${this.tag} the device is bonded, delete it right now`);
        this.dataSource?.removeDataByIndex(index);
        this.deviceTimeMap.delete(this.pairingDeviceId);

        this.pairingDeviceId = '';
      } else if (bondState === BondState.BOND_STATE_INVALID) {
        notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(this.pairingDeviceId)}`,
          new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_DESP,
            { content: '' } as SettingTextState]]
          ));
      }
    }
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    this.setPageHide(true);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach('Setting.Bluetooth.SwitchGroup.SwitchItem.toggle', this.switchStateEventCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_BLUETOOTH_CLICK_PAIR, this.clickPairEnentCallback);
    this.setAlreadyClickPair(false);
    this.setAlreadyShow(false);
    clearTimeout(this.showHelpPopupTimerId);
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.BLUETOOTH_ENTRY);
    LogUtil.info(`${this.tag} AvailableDeviceController unRegisterDataChange: ${isExist}`);
    if (isExist) {
      LogUtil.info(`${this.tag} the page exist, not unregister`);
      return;
    }

    this.unRegisterDataChange();
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${this.tag} showOrHideHeader: ${isShow}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  getListenKey(): string {
    return 'Available_Device_Controller';
  }

  onRemoveSummary(deviceId: string): void {
    LogUtil.info(`${this.tag} onRemoveSummary deviceId :  ${BluetoothUtils.getLogMAC(deviceId)}`);
    this.removeSummary(deviceId);
  }

  onBluetoothStateChange(state: number): void {
    LogUtil.info(`AvailableDeviceController onBluetoothStateChange : ${state}`);
    if (BluetoothUtils.isBluetoothStateOff(state)) { // 关闭
      // 停止扫描
      this.removeSearchMessageMenuIfNeed();
      return;
    }
    if (BluetoothUtils.isBluetoothStateOn(state)) { // 开启
      this.addSearchMessageMenuIfNeed();
      this.showHelpPopupIfFirstEnter();
    }
  }

  onDeviceAdded(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onDeviceAdded start, deviceId: ${BluetoothUtils.getLogMAC(device.deviceId)}`);
    if (!device) {
      LogUtil.warn(`${this.tag} onDeviceAdded, param empty`);
      return;
    }
    if (BluetoothAdapter.getInstance().isBondedDevice(device.deviceId)) {
      return;
    }
    let index: number = this.findMenu(device.deviceId);
    if (index !== -1 || !this.dataSource) {
      LogUtil.warn(`${this.tag} device is already added`);
      return;
    }
    this.deviceTimeMap.set(device.deviceId, new Date().getTime().toString() +
    BluetoothUtils.getPreMac(device.deviceId) + BluetoothUtils.getSufMac(device.deviceId));
    this.dataSource?.pushData(this.createBluetoothItemModel(device));
    this.removeSearchMessageMenuIfNeed();
  }

  onAvailableDevicesRefresh(): void {
    LogUtil.info(`${this.tag} refresh available devices`);
    if (this.dataSource == undefined || this.dataSource == null || this.dataSource.length === 0) {
      return;
    }

    let preFirstItemModel: BluetoothItemModel = this.dataSource[0] as BluetoothItemModel;
    let preLastItemModel: BluetoothItemModel = this.dataSource[this.dataSource.length - 1] as BluetoothItemModel;
    this.dataSource?.sort((x1: BluetoothItemModel, x2: BluetoothItemModel) => {
      if (!x1.rssi || !x2.rssi) {
        return 0;
      }
      return x2.rssi - x1.rssi;
    });
    let curFirstItemModel: BluetoothItemModel = this.dataSource[0] as BluetoothItemModel;
    if (preFirstItemModel.device?.deviceId !== curFirstItemModel.device?.deviceId) {
      preFirstItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: false } as SettingCompState
      ]]));
      curFirstItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_IS_GROUP_START, { state: true } as SettingCompState
      ]]));
    }
    let curLastItemModel: BluetoothItemModel = this.dataSource[this.dataSource.length - 1] as BluetoothItemModel;
    if (preLastItemModel.device?.deviceId !== curLastItemModel.device?.deviceId) {
      preLastItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
      ]]));
      curLastItemModel?.onItemEvent?.(new Map([[
        SettingStateType.STATE_TYPE_ITEM_POS, { state: true } as SettingCompState
      ]]));
    }
    this.dataSource?.notifyDataReload();
    this.removeSearchMessageMenuIfNeed();
  }

  private updateDevice(device: BluetoothDevice, index: number): void {
    LogUtil.warn(`${this.tag} updateDevice`);
    if (!this.dataSource || this.dataSource?.length <= index + 1) {
      return;
    }

    if (this.dataSource[index].title?.content !== device.deviceName) {
      this.dataSource[index].title = { content: device.deviceName };
      notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(device.deviceId)}`,
        new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_TITLE, { content: device.deviceName } as SettingTextState]]
        ));
    }
    if (this.dataSource[index].icon?.icon !== device.getIcon()) {
      this.dataSource[index].icon = {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
        isSymbolIcon: true,
      };
      notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(device.deviceId)}`,
        new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_ICON, { icon: device.getIcon() } as SettingIconState]]
        ));
    }

    let item: BluetoothItemModel = this.dataSource[index] as BluetoothItemModel;
    LogUtil.warn(`${this.tag} updateDevice, rssi is ${item.rssi}, ${device.getRssi()}`);
    if (item.rssi !== device.getRssi()) {
      item.rssi = device.getRssi();
    }
  }

  private createBluetoothItemModel(device: BluetoothDevice): BluetoothItemModel {
    let itemModel: BluetoothItemModel = {
      id: this.deviceTimeMap.get(device.deviceId) as string,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: {
          width: 24,
          height: 24,
          fillColor: $r('sys.color.icon_primary'),
          accessibilityText: device.getReadDetail() as Resource
        },
        isSymbolIcon: true,
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
      compare: (dst: ComparableSettingItemModel) => {
        return 0;
      },
      compControl: new BluetoothDeviceController(),
    };
    return itemModel;
  }

  onClick(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onClick, componentId: ${component.id}`);
    HiSysEventUtil.reportButtonEvent(CLICK_BLUETOOTH_NAME, '');
    // 发起配对
    BluetoothAdapter.getInstance().pairDevice(component.id);
  }

  onDeviceAttributesChanged(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onDeviceAttributesChanged, deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}, rssi:${device?.getRssi()}`);
    if (!device) {
      LogUtil.warn(`${this.tag} onDeviceAttributesChanged, param empty`);
      return;
    }

    let index: number = this.findMenu(device.deviceId);
    if (index === -1) {
      this.onDeviceAdded(device);
    } else {
      this.updateDevice(device, index);
      BluetoothAdapter.getInstance().updateCacheDevices(device.deviceId, device.deviceName);
    }
  }

  onAvailableDeviceClear() {
    LogUtil.info(`${this.tag} clear available device`);
    if (this.dataSource !== undefined && this.dataSource.length !== 0) {
      this.dataSource?.splice(0, this.dataSource.length);
      this.dataSource?.notifyDataReload();
    }
    this.deviceTimeMap.clear();
    this.addSearchMessageMenuIfNeed();
  }

  onDeviceDeleted(device: BluetoothDevice): void {
  }

  onBluetoothBondStateChange(stateParam: BondStateParam): void {
    LogUtil.info(`${this.tag} onBluetoothBondStateChange, deviceId: ${BluetoothUtils.getLogMAC(stateParam.deviceId)}, state: ${stateParam.state}`);
    if (!stateParam || !this.dataSource) {
      LogUtil.warn(`${this.tag} onBluetoothBondStateChange, param empty`);
      return;
    }

    let index: number = this.findMenu(stateParam.deviceId);
    if (index === -1) {
      LogUtil.info(`${this.tag} onBluetoothBondStateChange not found device`);
      return;
    }

    if (stateParam.state === BondState.BOND_STATE_BONDED) {
      LogUtil.info(`${this.tag} the device is bonded, delete it right now`);
      this.dataSource.removeDataByIndex(index);
      this.deviceTimeMap.delete(stateParam.deviceId);
      return;
    }

    this.isPairing = stateParam.state === BondState.BOND_STATE_BONDING;
    if (this.isPairing) {
      this.pairingDeviceId = stateParam.deviceId;
    } else {
      this.pairingDeviceId = '';
    }

    notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(stateParam.deviceId)}`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_DESP, {
          content: (stateParam.state === BondState.BOND_STATE_BONDING ? $r('app.string.bt_pairing_summary') : '')
        } as SettingTextState]]
      ));
  }

  removeSummary(deviceId: string): void {
    let index: number = this.findMenu(deviceId);
    if (index === -1 || !this.dataSource) {
      LogUtil.info(`${this.tag} removeSummary fail, not find device`);
      return;
    }

    notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(deviceId)}`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: '' } as SettingTextState]]
      ));
  }

  private findMenu(deviceId: string): number {
    let index: number = -1;
    if (!this.dataSource || this.dataSource?.length < 1) {
      return index;
    }

    let timestamp: string | undefined = this.deviceTimeMap.get(deviceId);
    if (!timestamp) {
      return index;
    }

    for (let i = 0; i < this.dataSource?.length; i++) {
      if (this.dataSource[i].id === timestamp) {
        return i;
      }
    }
    return index;
  }

  private registerDataChange(): void {
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().registerStateChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().registerDeviceChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().registerBondChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterLoadChangeListener(this);
    BluetoothAdapter.getInstance().registerLoadChangeListener(this);

    BluetoothAdapter.getInstance().unRegisterRemoveSummaryListener(this);
    BluetoothAdapter.getInstance().registerRemoveSummaryListener(this);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    BluetoothAdapter.getInstance().unRegisterStateChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterBondChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterLoadChangeListener(this);
    BluetoothAdapter.getInstance().unRegisterRemoveSummaryListener(this);
  }

  onBluetoothPinRequired(pinRequiredParam: PinRequiredParam): void {
  }

  onPairResult(deviceId: string, result: number, isSuccess: boolean): void {
    if (!deviceId) {
      LogUtil.warn(`${this.tag} onPairResult, param empty`);
      return;
    }
    this.closePairDialog();
    if (isSuccess) {
      BluetoothAdapter.getInstance().connectToDeviceAfterPair(deviceId);
      LogUtil.info(`${this.tag} onPairResult success`)
    } else {
      this.openPairFailedDialog(deviceId, result);
    }
  }

  private closePairDialog(): void {
    try {
      commonEventManager.publish(CommonEventConstant.EVENT_BLUETOOTH_CLOSE_PAIR_DIALOG, (error: BusinessError) => {
      });
    } catch (error) {
      LogUtil.error(`${this.tag} commonEventManager createSubscriber error: ${error?.message}`);
    }
  }

  private openPairFailedDialog(deviceId: string, result: number): void {
    if (!deviceId) {
      LogUtil.warn(`${this.tag} openPairFailedDialog, param empty`);
      return;
    }

    LogUtil.warn(`${this.tag} openPairFailedDialog deviceId:${BluetoothUtils.getLogMAC(deviceId)}, result: ${result}`);
    // if (result === UnbondCause.USER_REMOVED) {
    //   // 用户主动取消配对或非设置主动配对，不需要弹窗
    //   LogUtil.warn(`${this.tag} do not need to open dialog, because the user cancel pair or it is bonded from other`);
    //   return;
    // }

    BluetoothAdapter.getInstance().connectTimestampManager.resetDeviceBondedFromLocal(deviceId);
    let itemModel: BluetoothItemModel | null = this.findBluetoothItemModel(deviceId);
    if (!itemModel) {
      return;
    }

    notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(deviceId)}`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: '' } as SettingTextState]]
      ));
    itemModel.pairErrCode = result;

    notifyCompStateChange(`${this.compId}.${this.deviceTimeMap.get(deviceId)}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(pairFailedDialogContentBuilder),
        title: $r('app.string.bt_pair_failed_title'),
        style: {
          padding: {
            start: PADDING_0,
            end: PADDING_0,
          }
        },
        buttons: [
          {
            value: $r('app.string.button_title_ok'),
            action: (component: SettingItemModel) => {
            },
            focused: true,
          },
        ],
      } as SettingDialogState]]
    ));
  }

  private findBluetoothItemModel(deviceId: string): BluetoothItemModel | null {
    if (!this.dataSource) {
      return null;
    }
    let timestamp: string | undefined = this.deviceTimeMap.get(deviceId);
    if (!timestamp) {
      return null;
    }

    for (let index = 0; index < this.dataSource.length; index++) {
      if (this.dataSource[index].id === timestamp) {
        return this.dataSource[index] as BluetoothItemModel;
      }
    }

    return null;
  }

  private addSearchMessageMenuIfNeed(): void {
    LogUtil.info(`${this.tag} addSearchMessageMenuIfNeed: ${this.dataSource?.length}, ${this.isSearchMessageShow}`);
    if (this.isSearchMessageShow || (this.dataSource?.length ?? 0) > 0) {
      return;
    }

    this.setSearchMessageShow(this.isScanLoadingShow);
  }

  private removeSearchMessageMenuIfNeed(): void {
    LogUtil.info(`${this.tag} removeSearchMessageMenuIfNeed: ${this.dataSource?.length}, ${this.isSearchMessageShow}`);
    if (!this.isSearchMessageShow || (this.dataSource?.length ?? 0) < 1) {
      return;
    }

    this.setSearchMessageShow(this.isScanLoadingShow);
  }

  onChangeLoadingStatus(status: boolean): void {
    LogUtil.info(`${this.tag} onChangeLoadingStatus, status: ${status}, isScanLoadingShow: ${this.isScanLoadingShow}, ${this.dataSource?.length}, isAlreadyClickPair: ${this.isAlreadyClickPair}, isAlreadyShowPopup: ${this.isAlreadyShowPopup}, isPageHide: ${this.isPageHide}`);
    if (this.isScanLoadingShow !== status) {
      this.isScanLoadingShow = status;
      EventBus.getInstance().emit(`${this.compId}.isScanLoadingShow`, status);
      if (status && (this.dataSource?.length ?? 0) < 1) {
        this.setSearchMessageShow(status);
      } else {
        this.setSearchMessageShow(false);
      }
    }

    if (status || ((this.dataSource?.length ?? 0) > 0 && this.isAlreadyClickPair)) {
      return;
    }

    if (!this.isAlreadyShowPopup && !this.isPageHide) {
      this.setAlreadyShow(true);
      this.showHelpPopup();
    }
  }

  private setSearchMessageShow(isSearchMessageShow: boolean): void {
    LogUtil.info(`${this.tag} set isSearchMessageShow: ${isSearchMessageShow}`);
    this.isSearchMessageShow = isSearchMessageShow;
  }

  private showHelpPopupIfFirstEnter(): void {
    this.getPopupShowFromPreference().then((isPopupShow) => {
      if (!isPopupShow) {
        this.setAlreadyShow(true);
        this.showHelpPopupTimerId = setTimeout(() => {
          this.showHelpPopup();
          this.showHelpPopupTimerId = null;
        }, HELP_POPUP_SHOW_DELAY);
        this.setPopupShowToPreference();
      }
    });
  }

  private showHelpPopup(): void {
    EventBus.getInstance().emit(CommonEventConstant.EVENT_BLUETOOTH_HELP_POPUP_CHANGE);
  }

  private async getPopupShowFromPreference(): Promise<boolean> {
    let isPopupShow: boolean = true;
    let pref: preferences.Preferences | undefined = await this.getPreference();
    if (!pref) {
      LogUtil.error(`${this.tag} getFromPreference fail: pref is invalid`);
      return isPopupShow;
    }

    try {
      isPopupShow = await pref.get('isPopupShow', false) as boolean;
      LogUtil.info(`${this.tag} getPopupShowFromPreference success: ${isPopupShow}`);
    } catch (err) {
      LogUtil.error(`${this.tag} getPopupShowFromPreference fail: cause: ${err?.code}, ${err?.message}`);
    }
    return isPopupShow;
  }

  private async setPopupShowToPreference(): Promise<void> {
    let pref: preferences.Preferences | undefined = await this.getPreference();
    if (!pref) {
      LogUtil.error(`${this.tag} setPopupShowToPreference fail: pref is invalid`);
      return;
    }

    try {
      await pref.put('isPopupShow', true);
      await pref.flush();
      LogUtil.info(`${this.tag} setPopupShowToPreference success`);
    } catch (err) {
      LogUtil.error(`${this.tag} setPopupShowToPreference fail: cause: ${err?.message}`);
    }
  }

  private async getPreference(): Promise<preferences.Preferences | undefined> {
    let promisePref: Promise<preferences.Preferences> | undefined;
    try {
      promisePref = preferences.getPreferences(AbilityContextManager.getContext(), 'btBondedDevice');
    } catch (err) {
      LogUtil.error(`${this.tag} getPreferences fail: ${err?.code}, ${err?.message}`);
    }
    return promisePref;
  }

  private setAlreadyShow(isAlreadyShow: boolean): void {
    this.isAlreadyShowPopup = isAlreadyShow;
  }

  private setAlreadyClickPair(isAlreadyClickPair: boolean): void {
    this.isAlreadyClickPair = isAlreadyClickPair;
  }

  private setPageHide(isPageHide: boolean): void {
    this.isPageHide = isPageHide;
  }
}