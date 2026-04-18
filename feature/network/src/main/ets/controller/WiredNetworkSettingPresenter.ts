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
import { EthernetInterfaceInfoModel } from '../model/EthernetInterfaceInfoModel';
import { IEthernetSettingPresenter } from '../model/IEthernetSettingPresenter';
import { IEthernetInterfaceInfoModel } from '../model/IEthernetInterfaceInfoModel';
import { IEthernetEventCallback, NetworkEventType } from '../model/IEthernetConnectionManager';

class WiredNetworkSettingPresenter implements IEthernetSettingPresenter {
  private static instance: IEthernetSettingPresenter | null = null;
  private ethernetModel: IEthernetInterfaceInfoModel | null = null;

  private constructor() {
  }

  public static getInstance(): IEthernetSettingPresenter {
    if (!WiredNetworkSettingPresenter.instance) {
      WiredNetworkSettingPresenter.instance = new WiredNetworkSettingPresenter();
    }
    return WiredNetworkSettingPresenter.instance;
  }

  public init(): void {
    if (this.ethernetModel == null) {
      this.ethernetModel = new EthernetInterfaceInfoModel();
    }
  }

  public registerNetStatusListener(): void {
    if (this.ethernetModel) {
      this.ethernetModel.initModel();
    }
  }

  public unregisterNetStatusListener(): void {
    if (this.ethernetModel) {
      this.ethernetModel.unregisterNetStatusListener();
      this.ethernetModel = null;
    }
  }

  public registerEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string): void {
    if (this.ethernetModel) {
      this.ethernetModel.registerEventCallback(type, callback, key);
    }
  }

  public unregisterEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string): void {
    if (this.ethernetModel) {
      this.ethernetModel.unregisterEventCallback(type, callback, key);
    }
  }
}

export { WiredNetworkSettingPresenter };
