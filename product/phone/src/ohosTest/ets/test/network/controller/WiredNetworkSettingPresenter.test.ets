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

import {
  describe,
  beforeAll,
  it,
  expect,
  TestType
} from '@ohos/hypium';
import {
  IEthernetInfo
} from '@ohos/settings.network/src/main/ets/model/IEthernetInfo';
import {
  EthernetInterfaceInfoModel
} from '@ohos/settings.network/src/main/ets/model/EthernetInterfaceInfoModel';
import {
  WiredNetworkSettingPresenter
} from '@ohos/settings.network/src/main/ets/controller/WiredNetworkSettingPresenter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

let wnsPresenter: WiredNetworkSettingPresenter;
let em: EthernetInterfaceInfoModel;

interface Data {
  netId: number
}

interface NetCapData {
  linkUpBandwidthKbps: number,
  linkDownBandwidthKbps: number,
  networkCap: number[],
  bearerTypes: number[]
}

interface DataDetail {
  netHandle: Data,
  netCap: NetCapData
}

enum NetworkEventType {
  PROPERTIES = 'netConnectionPropertiesChange',
  AVAILABLE = 'netAvailable',
  CAPABILITIES = 'netCapabilitiesChange',
  LOST = 'netLost',
  UNAVAILABLE = 'netUnavailable',
}

export default function WireNetworkSettingPresenterTest() {
  describe('WireNetworkSettingPresenterTest', () => {
    beforeAll(() => {
      LogUtil.info(`beforeAll begin`);
      wnsPresenter = WiredNetworkSettingPresenter.getInstance() as WiredNetworkSettingPresenter;
      wnsPresenter.init();
      em = new EthernetInterfaceInfoModel() as EthernetInterfaceInfoModel;
    })

    it('WireNetworkSettingPresenterTest_000', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_000 begin`);
      if (WiredNetworkSettingPresenter.getInstance()) {
        wnsPresenter.init();
        wnsPresenter.registerNetStatusListener();
      }
      expect(wnsPresenter).not().assertNull();
      LogUtil.info(`WireNetworkSettingPresenterTest_000 end`);
    })

    it('WireNetworkSettingPresenterTest_001', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_001 begin`);
      wnsPresenter.unregisterNetStatusListener();
      wnsPresenter.registerEventCallback(NetworkEventType.PROPERTIES,
        () => {
          LogUtil.info(`WireNetworkSettingPresenterTest_001 registerEventCallback`);
        }, '[Network]');
      wnsPresenter.unregisterEventCallback(NetworkEventType.PROPERTIES,
        () => {
          LogUtil.info(`WireNetworkSettingPresenterTest_001 unregisterEventCallback`);
        }, '[Network]');
      expect(wnsPresenter).not().assertNull();
      LogUtil.info(`WireNetworkSettingPresenterTest_001 end`);
    })

    it('WireNetworkSettingPresenterTest_002', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_002 begin`);
      wnsPresenter.init();
      wnsPresenter.registerEventCallback(NetworkEventType.PROPERTIES,
        () => {
          expect(wnsPresenter).not().assertNull();
          LogUtil.info(`WireNetworkSettingPresenterTest_002 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_003', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_003 begin`);
      wnsPresenter.registerEventCallback(NetworkEventType.AVAILABLE,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_003 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_004', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_004 begin`);
      wnsPresenter.registerEventCallback(NetworkEventType.CAPABILITIES,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_004 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_005', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_005 begin`);
      wnsPresenter.registerEventCallback(NetworkEventType.LOST,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_005 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_006', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_006 begin`);
      wnsPresenter.registerEventCallback(NetworkEventType.UNAVAILABLE,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_006 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_010', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_010 begin`);
      wnsPresenter.unregisterEventCallback(NetworkEventType.PROPERTIES,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_010 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_011', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_011 begin`);
      wnsPresenter.unregisterEventCallback(NetworkEventType.AVAILABLE,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_011 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_012', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_012 begin`);
      wnsPresenter.unregisterEventCallback(NetworkEventType.CAPABILITIES,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_012 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_013', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_013 begin`);
      wnsPresenter.unregisterEventCallback(NetworkEventType.LOST,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_013 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_014', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_014 begin`);
      wnsPresenter.unregisterEventCallback(NetworkEventType.UNAVAILABLE,
        () => {
          expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
          LogUtil.info(`WireNetworkSettingPresenterTest_014 end`);
        }, '[Network]');
    })

    it('WireNetworkSettingPresenterTest_015', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_015 begin`);
      let data: Data = {
        netId: 103
      };
      em.handleNetEvent4NetAvailable(data);
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_015 end`);
    })

    it('WireNetworkSettingPresenterTest_016', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_016 begin`);
      let data: Data = {
        netId: 103
      };
      em.handleNetEvent4NetLost(data);
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_016 end`);
    })

    it('WireNetworkSettingPresenterTest_017', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_017 begin`);
      em.refreshModelData();
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_017 end`);
    })

    it('WireNetworkSettingPresenterTest_018', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_018 begin`);
      let data: Data = {
        netId: 103
      };
      em.handleNetEvent4NetConnectionPropertiesChange(data);
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_018 end`);
    })

    it('WireNetworkSettingPresenterTest_019', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_019 begin`);
      let netHandle: Data = {
        netId: 100
      }
      let netCap: NetCapData = {
        linkUpBandwidthKbps: 0,
        linkDownBandwidthKbps: 0,
        networkCap: [12],
        bearerTypes: [3]
      }
      let data1: DataDetail = {
        netHandle,
        netCap
      };
      em.handleNetEvent4NetCapabilitiesChange(data1);
      expect(AppStorage.get('useInternet') as boolean === false).assertFalse();

      netCap.networkCap.push(16);
      let data2: DataDetail = {
        netHandle,
        netCap
      };
      em.handleNetEvent4NetCapabilitiesChange(data2);
      expect(AppStorage.get('useInternet') as boolean === true).assertFalse();
      LogUtil.info(`WireNetworkSettingPresenterTest_019 end`);
    })

    it('WireNetworkSettingPresenterTest_020', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_020 begin`);
      em.initModel();
      em.registerEventCallback(NetworkEventType.PROPERTIES,
        () => {
          LogUtil.info(`EthernetInterfaceInfoModel registerEventCallback`);
        }, '[Network]')
      em.unregisterEventCallback(NetworkEventType.PROPERTIES,
        () => {
          LogUtil.info(`EthernetInterfaceInfoModel unregisterEventCallback`);
        }, '[Network]')
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length >= 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_020 end`);
    })

    it('WireNetworkSettingPresenterTest_021', TestType.FUNCTION, () => {
      LogUtil.info(`WireNetworkSettingPresenterTest_021 begin`);
      em.unregisterNetStatusListener();
      em.registerEventCallback(NetworkEventType.AVAILABLE,
        () => {
          LogUtil.info(`EthernetInterfaceInfoModel registerEventCallback`);
        }, '[Network]')
      em.unregisterEventCallback(NetworkEventType.AVAILABLE,
        () => {
          LogUtil.info(`EthernetInterfaceInfoModel unregisterEventCallback`);
        }, '[Network]')
      em.unregisterNetStatusListener();
      expect((AppStorage.get('ethernetList') as IEthernetInfo[]).length === 0).assertTrue();
      LogUtil.info(`WireNetworkSettingPresenterTest_021 end`);
    })
  })
}