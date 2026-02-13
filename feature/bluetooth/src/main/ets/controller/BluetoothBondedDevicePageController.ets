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

import connection from '@ohos.bluetooth.connection';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { BluetoothBondedDeviceType, BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType,
  SettingTextState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { UnpairButtonController } from './BondedDevice/UnpairButtonController';
import { BluetoothDeviceNameController } from './BondedDevice/BluetoothDeviceNameController';
import { HfpStrategySwitchMenuController } from './BondedDevice/HfpStrategySwitchMenuController';
import { MapAuthSwitchController } from './BondedDevice/MapAuthSwitchController';
import {
  BluetoothDeviceVolumeSyncPhoneSwitchMenuController
} from './BondedDevice/BluetoothDeviceVolumeSyncPhoneSwitchMenuController';
import { BluetoothAutoPlayController } from './BondedDevice/BluetoothAutoPlayController';
import { A2dpStrategySwitchMenuController } from './BondedDevice/A2dpStrategySwitchMenuController';
import { HidStrategySwitchMenuController } from './BondedDevice/HidStrategySwitchMenuController';
import { BluetoothStrategySwitchMenuController } from './BondedDevice/BluetoothStrategySwitchMenuController';
import { BluetoothAdapter, BluetoothProfile, BluetoothProfileStateChangeListener } from '../BluetoothAdapter';
import { BluetoothDevice, ProfileId, StateChangeParam } from '../model/BluetoothModel';
import lazy {
  deviceNameItemBuilder,
  profileItemBuilder,
} from '../view/CustomBuilder';
import { Utils } from '../utils/Utils';
import { AccessAuthorization, ShareType } from '../constants/BluetoothConstants';
import { BluetoothDeviceNamePcBuilder } from '../component/BluetoothDeviceNameComponent';

/* instrument ignore file */
const DEVICE_TYPE_RESOURCE_STR: ResourceStr[] = [
  $r('app.string.device_type_car'),
  $r('app.string.device_type_headset'),
  $r('app.string.device_type_hearing'),
  $r('app.string.device_type_glasses'),
  $r('app.string.device_type_watch'),
  $r('app.string.device_type_speaker'),
];

const DEVICE_TYPE: number[] = [
  BluetoothBondedDeviceType.DEVICE_TYPE_CAR,
  BluetoothBondedDeviceType.DEVICE_TYPE_HEADSET,
  BluetoothBondedDeviceType.DEVICE_TYPE_HEARING,
  BluetoothBondedDeviceType.DEVICE_TYPE_GLASSES,
  BluetoothBondedDeviceType.DEVICE_TYPE_WATCH,
  BluetoothBondedDeviceType.DEVICE_TYPE_SPEAKER,
];

const SHARE_TYPES_ARRAY: ResourceStr[] = [
  $r('app.string.bluetooth_name_and_numbers_only'),
  $r('app.string.bluetooth_fulls_detals'),
  $r('app.string.bluetooth_not_share'),
];

/**
 * 已配对蓝牙设备页面控制器类
 *
 * @since 2022-11-21
 */
export class BluetoothBondedDevicePageController implements ComponentControl, BluetoothProfileStateChangeListener {
  public tag: string = 'BluetoothBondedDevicePageController: ';
  public device?: BluetoothDevice;
  public profileMap?: Map<ProfileId, BluetoothProfile>;
  public settingPageModel?: SettingPageModel;
  public groups?: SettingGroupModel[];
  private compId?: string;
  private deviceNameChangeCallback = (newDeviceName: string) => {
    LogUtil.info(`${this.tag} device name change, refresh page title`);
    this.refreshPageTitle(newDeviceName);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId || !compParam.component) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init`);
    this.compId = compParam?.compId;
    this.device = compParam.param as BluetoothDevice;
    this.settingPageModel = compParam.component as SettingPageModel;
    if (!this.settingPageModel) {
      LogUtil.error(`${this.tag} init fail, settingPageModel is invalid`);
      return;
    }

    this.settingPageModel.title = this.device.deviceName ?? this.device.deviceId;
    this.profileMap = this.device?.getConnectableProfiles();
    // 设备名称
    if (DeviceUtil.isDevicePc()) {
      this.setPcDeviceNameMenus();
    } else {
      this.setDeviceNameMenus();
    }
    this.setDeviceTypeMenus(); // 设备类型
    this.setProfileMenus(); // 通话音频、媒体音频、输入设备、共享联系人和历史呼叫记录、信息授权
    this.setVolumeMenu(); // 蓝牙设备音量与手机同步
    this.setAutoPlayMenu(); // 自动播放音乐
    this.setUnpairMenu(); // 取消配对

    EventBus.getInstance().on(`${this.device?.deviceId}updateName`, this.deviceNameChangeCallback);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(connection.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
    }
  }

  private setUnpairMenu(): void {
    let unpairGroupModel: SettingGroupModel = {
      id: 'bt_unpair_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'bt_unpair_key',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.unpair'), },
          compControl: new UnpairButtonController(this.device?.deviceId as string),
        }
      ]
    };

    this.settingPageModel?.groups?.push(unpairGroupModel);
  }

  private setAutoPlayMenu(): void {
    if (!this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE)) {
      return;
    }
    if (!BluetoothAdapter.getInstance().isDeviceConnected(this.device?.deviceId as string)) {
      LogUtil.info(`${this.tag} is not connect state.`);
      return;
    }

    let autoPlayGroupModel: SettingGroupModel = {
      id: 'bt_auto_play_music',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'bt_auto_play_key',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.auto_play_music'), },
          desc: { content: $r('app.string.auto_play_music_desc') },
          result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: true } },
          compControl: new BluetoothAutoPlayController(this.device?.deviceId as string),
        }
      ]
    };

    this.settingPageModel?.groups?.push(autoPlayGroupModel);
  }

  private setVolumeMenu(): void {
    LogUtil.info(`${this.tag} setVolumeMenu ${this.device?.absoluteVolumeSupport}, ${this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE)}, ${this.device?.volumeSyncParam.isOn}`);
    if (this.device?.absoluteVolumeSupport && this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE)) {
      let volumeSyncGroupModel: SettingGroupModel = {
        id: 'bt_sync_volume_with_phone_key',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'bluetooth_device_sync_volume_with_phone_menu_key',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: this.getVolumeMenuTitle(), },
            result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.device?.volumeSyncParam.isOn } },
            compControl: new BluetoothDeviceVolumeSyncPhoneSwitchMenuController(this.device?.deviceId as string,
              this.device?.volumeSyncParam.isOn),
          }
        ]
      };
      this.settingPageModel?.groups?.push(volumeSyncGroupModel);
    }
  }

  private getVolumeMenuTitle(): ResourceStr {
    if (DeviceUtil.isDevicePhone()) {
      return $r('app.string.bluetooth_device_sync_volume_with_phone');
    } else if (DeviceUtil.isDevicePad()) {
      return $r('app.string.bluetooth_device_sync_volume_with_pad');
    } else if (DeviceUtil.isDevicePc()) {
      return $r('app.string.bluetooth_device_sync_volume_with_pc');
    } else {
      return '';
    }
  }

  private setProfileMenus(): void {
    LogUtil.info(`${this.tag} setProfileMenus ${this.profileMap?.has(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY)}, ${this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE)}, ${this.profileMap?.has(ProfileId.PROFILE_HID_HOST)}, ${DeviceUtil.deviceType}`);
    let profileGroupModel: SettingGroupModel = {
      id: 'profile_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [],
    };

    this.setProfileCustomItemModels(profileGroupModel);
    this.setProfileStandardItemModels(profileGroupModel);

    if (profileGroupModel.items?.length ?? 0 > 0) {
      this.settingPageModel?.groups?.push(profileGroupModel);
    }
  }

  setDeviceTypeMenus(): void {
    if (!this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE) &&
      !this.profileMap?.has(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY)) {
      LogUtil.info(`${this.tag} will not show device type menus.`);
      return;
    }

    let deviceTypeGroupModel: SettingGroupModel = {
      id: 'bt_page_bounded_device_type_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: `device_type`,
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.bt_bond_device_type') },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_MENU,
            icon: $r('app.media.ic_arrow_down_new'),
            style: {
              width: 24,
              height: 24,
              fillColor: DeviceUtil.isDevicePc() ? $r('sys.color.icon_primary') : $r('sys.color.icon_tertiary'),
            },
            menu: {
              items: DEVICE_TYPE_RESOURCE_STR,
              selectIcon: $r('app.media.ic_selected_ok'),
              onSelected: (index) => {
                this.onSelectDeviceType(index);
              },
              defaultFocus: (this.device?.defaultDeviceType ?? 0) - 1,
            }
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: {
              content: BluetoothUtils.getBondDeviceType(this.device?.defaultDeviceType ?? -1),
              style: {
                fontColor: DeviceUtil.isDevicePc() ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'),
                fontSize: DeviceUtil.isDevicePc() ? $r('sys.float.Body_L') : $r('sys.float.Body_M')
              }
            }
          }
        }
      ]
    };
    // this.settingPageModel?.groups?.push(deviceTypeGroupModel);
  }

  private onSelectDeviceType(index: number): void {
    LogUtil.info(`${this.tag} onSelectDeviceType index: ${index}`);
    if (!this.device || index >= DEVICE_TYPE.length) {
      return;
    }
    this.device.defaultDeviceType = index + 1;
    connection.setRemoteDeviceType(this.device.deviceId ?? '', DEVICE_TYPE[index]).then(() => {
      LogUtil.info(`${this.tag} setRemoteDeviceType success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${this.tag} setRemoteDeviceType faild : ${error?.message}`);
    });
  }

  setPcDeviceNameMenus(): void {
    const groupModel: SettingGroupModel = {
      id: 'bt_page_bounded_device_name_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'device_name',
          type: ItemType.ITEM_TYPE_CUSTOM,
          builder: wrapBuilder(BluetoothDeviceNamePcBuilder),
          extra: this.device,
        }
      ]
    };
    this.settingPageModel?.groups?.push(groupModel);
  }

  setDeviceNameMenus(): void {
    let deviceNameGroupModel: SettingGroupModel = {
      id: 'bt_page_bounded_device_name_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'device_name',
          type: ItemType.ITEM_TYPE_CUSTOM,
          title: { content: $r('app.string.device_name_settings_title') },
          builder: wrapBuilder(deviceNameItemBuilder),
          compControl: new BluetoothDeviceNameController(this.device as BluetoothDevice),
        }
      ]
    };
    this.settingPageModel?.groups?.push(deviceNameGroupModel);
  }

  private setProfileStandardItemModels(profileGroupModel: SettingGroupModel): void {
    //deviceType会获取到default暂时先放开
    if (DeviceUtil.isDevicePhone() ||DeviceUtil.deviceType === 'default') {
      LogUtil.info(`${this.tag} setProfileStandardItemModels, shareType is ${this.device?.shareType}`);
      // 共享联系人和历史呼叫记录
      let shareAndCallItemModel: SettingItemModel = {
        id: `ap_band`,
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.bluetooth_sharing_and_call_history') },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_MENU,
          icon: $r('app.media.ic_arrow_down_new'),
          style: {
            width: 24,
            height: 24,
            fillColor: $r('sys.color.icon_tertiary'),
          },
          menu: {
            items: SHARE_TYPES_ARRAY,
            selectIcon: $r('app.media.ic_selected_ok'),
            onSelected: (index) => {
              LogUtil.info(`${this.tag} onSelectShareAndCall index: ${index}`);
              this.updateShareType(index);
            },
            defaultFocus: this.device?.shareType,
          }
        },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: Utils.getShareTypeResourceStr(this.device?.shareType ?? 0),
            style: {
              fontColor: $r('sys.color.font_secondary'),
              fontSize: $r('sys.float.Body_M')
            }
          }
        },
      };

      // 信息授权
      let infoAuthorizeItemModel: SettingItemModel = {
        id: 'map_device_key',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.bluetooth_read_info_auth') },
        result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: true } },
        compControl: new MapAuthSwitchController(this.device?.deviceId as string),
      };

      //屏蔽共享联系人和呼叫历史记录和授权读取信息
      // profileGroupModel.items?.push(shareAndCallItemModel);
      // profileGroupModel.items?.push(infoAuthorizeItemModel);
    }
  }

  public updateShareType(shareType: number): void {
    let accessAuthorization: AccessAuthorization = AccessAuthorization.REJECTED;
    switch (shareType) {
      case ShareType.SHARE_NAME_AND_PHONE_NUMBER:
      case ShareType.SHARE_ALL:
        accessAuthorization = AccessAuthorization.ALLOWED;
        break;
      case ShareType.SHARE_NOTHING:
        accessAuthorization = AccessAuthorization.REJECTED;
        break;
      default:
        accessAuthorization = AccessAuthorization.REJECTED;
    }
    let deviceId: string = this.device?.deviceId as string;
    LogUtil.info(`${this.tag} updateShareType: ${shareType}, ${accessAuthorization}`);
    Utils.setShareType(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId, shareType);
    Utils.setPhoneBookAccessAuthorization(BluetoothAdapter.getInstance().profileManager.pbapProfile, deviceId,
      accessAuthorization);
  }

  private setProfileCustomItemModels(profileGroupModel: SettingGroupModel): void {
    let itemModels: SettingItemModel[] = [];
    if (this.profileMap?.has(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY)) {
      let callAudioItemModel: SettingItemModel = {
        id: 'hfp_device_key',
        type: ItemType.ITEM_TYPE_CUSTOM,
        title: { content: $r('app.string.bluetooth_profile_hfp') },
        builder: wrapBuilder(profileItemBuilder),
        compControl: new HfpStrategySwitchMenuController(this.device as BluetoothDevice),
      };
      itemModels.push(callAudioItemModel);
    }

    if (this.profileMap?.has(ProfileId.PROFILE_A2DP_SOURCE)) {
      let a2dpItemModel: SettingItemModel = {
        id: 'a2dp_device_key',
        type: ItemType.ITEM_TYPE_CUSTOM,
        title: { content: $r('app.string.bluetooth_profile_a2dp') },
        builder: wrapBuilder(profileItemBuilder),
        compControl: new A2dpStrategySwitchMenuController(this.device as BluetoothDevice),
      };
      itemModels.push(a2dpItemModel);
    }

    if (this.profileMap?.has(ProfileId.PROFILE_HID_HOST)) {
      let hidItemModel: SettingItemModel = {
        id: 'hid_device_key',
        type: ItemType.ITEM_TYPE_CUSTOM,
        title: { content: $r('app.string.bluetooth_profile_hid') },
        builder: wrapBuilder(profileItemBuilder),
        compControl: new HidStrategySwitchMenuController(this.device as BluetoothDevice),
      };
      itemModels.push(hidItemModel);
    }

    if (itemModels && itemModels.length > 0) {
      if (DeviceUtil.deviceType === 'tablet') {
        let control: ComponentControl = itemModels[itemModels.length - 1].compControl as ComponentControl;
        let switchMenuController: BluetoothStrategySwitchMenuController;
        if (control instanceof BluetoothStrategySwitchMenuController) {
          switchMenuController = control as BluetoothStrategySwitchMenuController;
          switchMenuController.isShowDivider = false;
        }
      }
    }
    profileGroupModel.items?.push(...itemModels);
  }

  private refreshPageTitle(deviceName: string): void {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_PAGE_TITLE, { content: deviceName } as SettingTextState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.device?.deviceId}updateName`, this.deviceNameChangeCallback);
  }

  getListenKey(): string {
    return 'Bluetooth_Bonded_Device_Page_Controller';
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
  }
}