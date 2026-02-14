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

import type rpc from '@ohos.rpc';
/* instrument ignore file */
export class CarInfo implements rpc.Parcelable {
  public id: number | undefined;
  public deviceName: string | undefined;
  public deviceType: number | undefined;
  public bleMac: string | undefined;
  public lastConnectTime: number | undefined;
  public isAutoConnect: boolean | undefined;
  public isConnected: boolean | undefined;

  marshalling(dataOut: rpc.MessageSequence): boolean {
    dataOut.writeLong(this.id ? this.id : -1);
    dataOut.writeString(this.deviceName);
    dataOut.writeInt(this.deviceType);
    dataOut.writeString(this.bleMac);
    dataOut.writeLong(this.lastConnectTime);
    dataOut.writeBoolean(this.isAutoConnect);
    dataOut.writeBoolean(this.isConnected);
    return true;
  }

  unmarshalling(dataIn: rpc.MessageSequence): boolean {
    let id = dataIn.readLong();
    this.id = id === -1 ? null : id;
    this.deviceName = dataIn.readString();
    this.deviceType = dataIn.readInt();
    this.bleMac = dataIn.readString();
    this.lastConnectTime = dataIn.readLong();
    this.isAutoConnect = dataIn.readBoolean();
    this.isConnected = dataIn.readBoolean();
    return true;
  }
}

export default interface IIdlDataService {
  getConnectedCarInfo(callback: getConnectedCarInfoCallback): void;
}

export type getConnectedCarInfoCallback = (errCode: number, returnValue: CarInfo) => void;
