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
import bluetooth from '@ohos.bluetooth';
import bluetoothManager from '@ohos.bluetoothManager';
import connection from '@ohos.bluetooth.connection';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BlueToothState } from '../constants/BluetoothConstants';
import { ProfileConnectionState} from '../model/BluetoothModel';

export enum ProfileId {
  PROFILE_A2DP_SOURCE = 1,
  PROFILE_HANDS_FREE_AUDIO_GATEWAY = 4,
  PROFILE_HID_HOST = 6
}

const TAG: string = 'PcModeBlueToothViewModel : ';
const PROFILE_ID_LIST: ProfileId[] = [
  ProfileId.PROFILE_A2DP_SOURCE,
  ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY,
  ProfileId.PROFILE_HID_HOST
];
type Profile = bluetoothManager.A2dpSourceProfile | bluetoothManager.HandsFreeAudioGatewayProfile |
bluetoothManager.HidHostProfile | bluetoothManager.PanProfile;

class PcModeBlueToothViewModel {
  /**
   * 单例对象
   */
  private static instance: PcModeBlueToothViewModel;
  private profileList: Profile[] = [];
  private bluetoothStateChangeCallBacks: Function[] = [];

  /**
   * 单例方法
   *
   * @returns 单例对象
   */
  public static getInstance(): PcModeBlueToothViewModel {
    if (!PcModeBlueToothViewModel.instance) {
      PcModeBlueToothViewModel.instance = new PcModeBlueToothViewModel();
    }
    return PcModeBlueToothViewModel.instance;
  }

  constructor() {
    // 初始化状态栏蓝牙图标
    let profile: Profile;
    LogUtil.info(`${TAG} regisiter onBluetoothStateChange`);
    bluetooth.on('stateChange', this.onBluetoothStateChange);
    PROFILE_ID_LIST.forEach(profileId => {
      try {
        profile = bluetoothManager.getProfileInstance(profileId);
        LogUtil.info(`${TAG} getProfileInstance , ProfileId : ${profileId}`);
        profile?.on('connectionStateChange', this.onProfileStateChange);
        LogUtil.info(`${TAG} create connectionStateChange`);
        this.profileList.push(profile);
      } catch (err) {
        LogUtil.error(`${TAG} error, BusinessError code is ${err?.code}`);
      }
    });
  }

  public registerBluetoothStateChangeCallBack(callback: Function): void {
    LogUtil.info(`${TAG} registerBluetoothStateChangeCallBack`);
    this.bluetoothStateChangeCallBacks.push(callback);
  }

  public unregisterBluetoothStateChangeCallBack(callback: Function): void {
    LogUtil.info(`${TAG} unregisterBluetoothStateChangeCallBack`);
    let index = this.bluetoothStateChangeCallBacks.indexOf(callback);
    if (index !== -1) {
      this.bluetoothStateChangeCallBacks.splice(index, 1);
      LogUtil.info(`${TAG} unregisterBluetoothStateChangeCallBack success`);
    }
  }

  public initState(): BlueToothState | undefined {
    let profileStatus: boolean = false;
    let isBluetoothStateOn = BluetoothUtils.isBluetoothStateOn(BluetoothUtils.getCurrentBluetoothState());
    if (!isBluetoothStateOn) {
      return BlueToothState.OFF;
    } else {
      try {
        let connectStatus: ProfileConnectionState = connection.getProfileConnectionState();
        LogUtil.info(`${TAG} getProfileConnectionState status : ${connectStatus}`);
        profileStatus = connectStatus === ProfileConnectionState.STATE_CONNECTED;
        if (profileStatus) {
          return BlueToothState.CONNECTED;
        } else {
          return BlueToothState.ON;
        }
      } catch (businessError) {
        LogUtil.error(`${TAG} failed, BusinessError is ${businessError?.message}`);
        return undefined;
      }
    }
  }

  private onBluetoothStateChange = (state: number): void => {
    LogUtil.info(`${TAG} onBluetoothStateChange , status : ${state}`);
    let iconState: BlueToothState | undefined = undefined;
    if (BluetoothUtils.isBluetoothStateOff(state)) {
      iconState = BlueToothState.OFF;
    } else if (BluetoothUtils.isBluetoothOn()) {
      iconState = BlueToothState.ON;
    }
    if (iconState === undefined) {
      LogUtil.error(`${TAG} onBluetoothStateChange , status got wrong`);
    }

    LogUtil.info(`${TAG} registerBluetoothStateChangeCallBack, BluetoothStateChangeCallBacks size is ${this.bluetoothStateChangeCallBacks.length}`);
    this.bluetoothStateChangeCallBacks.forEach((bluetoothStateChangeCallBack) => {
      if (bluetoothStateChangeCallBack) {
        bluetoothStateChangeCallBack(iconState);
      }
    })
  }

  private onProfileStateChange = (state: bluetoothManager.StateChangeParam): void => {
    LogUtil.info(`${TAG} onProfileStateChange.`);
    let iconState: BlueToothState | undefined = undefined;
    if (!BluetoothUtils.isBluetoothStateOn(BluetoothUtils.getCurrentBluetoothState())) {
      iconState = BlueToothState.OFF;
      return;
    }
    try {
      let status: ProfileConnectionState = connection.getProfileConnectionState();
      LogUtil.info(`${TAG} getProfileConnectionState.}`);
      if (status === ProfileConnectionState.STATE_CONNECTED) {
        iconState = BlueToothState.CONNECTED;
      } else if (BluetoothUtils.getCurrentBluetoothState() === bluetooth.BluetoothState.STATE_ON) {
        iconState = BlueToothState.ON;
      }
    } catch (businessError) {
      LogUtil.error(`${TAG} failed, BusinessError is ${businessError?.message}`);
    }
    LogUtil.info(`${TAG} registerBluetoothStateChangeCallBack, BluetoothStateChangeCallBacks size is ${this.bluetoothStateChangeCallBacks.length}`);
    this.bluetoothStateChangeCallBacks.forEach((bluetoothStateChangeCallBack) => {
      if (bluetoothStateChangeCallBack) {
        bluetoothStateChangeCallBack(iconState);
      }
    })
  }
}

export const pcModeBlueToothViewModel = PcModeBlueToothViewModel.getInstance();