/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import rpc from '@ohos.rpc';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CarInfo } from './i_idl_data_service';
import type { getConnectedCarInfoCallback } from './i_idl_data_service';
import type IIdlDataService from './i_idl_data_service';

export class IdlErrorCode {
  static readonly SUCCESS: number = 0;
  static readonly FAIL: number = -1;
}

const TAG = 'IdlDataServiceProxy';

export default class IdlDataServiceProxy implements IIdlDataService {
  constructor(proxy) {
    this.proxy = proxy;
  }

  public getHiCarEnable(callback: (isHiCarEnable: boolean) => void): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageSequence();
    let reply = new rpc.MessageSequence();
    data.writeInterfaceToken(IdlDataServiceProxy.HICAR_DESCRIPTOR);
    this.proxy.sendMessageRequest(IdlDataServiceProxy.COMMAND_QUERY_FOUND_DIALOG_ENABLE, data, reply, option)
      .then((result) => {
        if (result.errCode === 0) {
          const data: rpc.MessageSequence = result.reply;
          const errCode: number = data.readInt();
          if (errCode !== IdlErrorCode.SUCCESS) {
            LogUtil.error(`${TAG} getHiCarEnable errCode is not success`);
            callback(true);
            return;
          }
          const isHiCarEnable: boolean = data.readBoolean();
          LogUtil.info(`${TAG} isHiCarEnable: ${isHiCarEnable}`);
          callback(isHiCarEnable);
        } else {
          LogUtil.error(`${TAG} getHiCarEnable error ${result.errCode}`);
          callback(true);
        }
      })
      .catch((e: Error) => {
        LogUtil.info(`${TAG} getHiCarEnable failed, message:${e.message}`);
      })
      .finally(() => {
        LogUtil.info(`${TAG} getHiCarEnable ends`);
        data.reclaim();
        reply.reclaim();
      });
  }

  public getSuperLauncherInfo(callback: (isConnected: boolean, deviceName: string, isEnable: boolean) => void): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageSequence();
    let reply = new rpc.MessageSequence();
    this.proxy.sendMessageRequest(IdlDataServiceProxy.COMMAND_QUERY_SUPER_LAUNCHER_INFO, data, reply, option)
      .then((result) => {
        if (result.errCode === 0) {
          const data: rpc.MessageSequence = result.reply;
          const errCode: number = data.readInt();
          if (errCode !== IdlErrorCode.SUCCESS) {
            LogUtil.error(`${TAG} getSuperLauncherInfo errCode is not success`);
            return;
          }
          const infoString: string = data.readString();
          let info = JSON.parse(infoString);
          callback(info.isConnected, info.deviceName, info.isSuperLauncherEnable);
        } else {
          LogUtil.error(`${TAG} getSuperLauncherInfo error ${result.errCode}`);
        }
      }).catch((e: Error) => {
      LogUtil.error(`${TAG} getSuperLauncherInfo failed, message:${e?.message}`);
    }).finally(() => {
      LogUtil.info(`${TAG} getSuperLauncherInfo ends`);
      data.reclaim();
      reply.reclaim();
    });
  }

  public getConnectedCarInfo(callback: getConnectedCarInfoCallback): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageSequence();
    let reply = new rpc.MessageSequence();
    data.writeInterfaceToken(IdlDataServiceProxy.HICAR_DESCRIPTOR);
    this.proxy.sendMessageRequest(IdlDataServiceProxy.COMMAND_GET_CONNECTED_CAR_INFO, data, reply, option)
      .then(function (result) {
        if (result.errCode === 0) {
          let errCode = result.reply.readInt();
          if (errCode !== 0) {
            callback(errCode, new CarInfo());
            return;
          }
          let reply: rpc.MessageSequence = result.reply;
          let carInfo: CarInfo = new CarInfo();
          reply.readParcelable(carInfo);
          callback(errCode, carInfo);
        } else {
          callback(result.errCode, new CarInfo());
        }
      })
      .catch((e: Error) => {
        LogUtil.info(`${TAG} getConnectedCarInfo failed, message:${e.message}`);
      })
      .finally(() => {
        LogUtil.info(`${TAG} getConnectedCarInfo ends, reclaim parcel`);
        data.reclaim();
        reply.reclaim();
      });
  }

  public getPadCockpitConnectedState(callback: (isEnable: boolean, connectState: number) => void): void {
    let option = new rpc.MessageOption();
    let data = new rpc.MessageSequence();
    let reply = new rpc.MessageSequence();
    data.writeInterfaceToken(IdlDataServiceProxy.PADCOCKPIT_DESCRIPTOR);
    this.proxy.sendMessageRequest(IdlDataServiceProxy.COMMAND_GET_PAD_COCKPIT_CONNECTED_STATE, data, reply, option)
      .then(function (result) {
        let isEnable = result?.reply.readBoolean();
        let connectState = result?.reply.readInt();
        callback(isEnable, connectState);
      })
      .catch((e: Error) => {
        LogUtil.info(`${TAG} getPadCockpitConnectedState failed, message:${e.message}`);
      })
      .finally(() => {
        LogUtil.info(`${TAG} getPadCockpitConnectedState ends, reclaim parcel`);
        data.reclaim();
        reply.reclaim();
      });
  }

  public static readonly COMMAND_GET_CONNECTED_CAR_INFO = 1;
  public static readonly COMMAND_QUERY_FOUND_DIALOG_ENABLE = 16;
  public static readonly COMMAND_QUERY_SUPER_LAUNCHER_INFO = 14;
  public static readonly COMMAND_GET_PAD_COCKPIT_CONNECTED_STATE = 1;
  private static readonly HICAR_DESCRIPTOR = 'HiCarService';
  private static readonly PADCOCKPIT_DESCRIPTOR = 'PadCockpitSettingsStub';
  private proxy;
}
