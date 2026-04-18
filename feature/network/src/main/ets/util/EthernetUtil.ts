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
import type { BusinessError } from '@ohos.base';
import connection from '@ohos.net.connection';
import ethernet from '@ohos.net.ethernet';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { Constants } from '../constant/Constants';
import { IFaceData } from '../model/EthernetInterfaceInfoModel';
import { IEthernetInterfaceInfo } from '../model/IEthernetInterfaceInfo';
import { IEthernetInfo } from '../model/IEthernetInfo';

const TAG: string = 'EthernetUtil : ';
const SET_ETHERNET_IP_DISABLE: string = 'persist.edm.set_ethernet_ip_disable';
const USE_NEW_NETWORK_PAGE: string = 'const.settings.use_new_network_page';

class EthernetUtil {
  /**
   * 获取以太网详细信息
   * @param ifcName 网口名
   * @param callback 将获取到对应网口的数据回调给调用方
   */
  public static getEthernetInterfaceConfig(ifcName: string,
    callback: (d?: ethernet.InterfaceConfiguration) => void): void {
    try {
      LogUtil.info(`${TAG} getEthernetInterfaceConfig ifcName: ${ifcName}`);
      ethernet.getIfaceConfig(ifcName, (error, data) => {
        if (error) {
          LogUtil.error(`${TAG} getIfaceConfig error: ${error.code}`);
        } else {
          callback(data);
          LogUtil.info(`${TAG} getIfaceConfig success!`);
        }
      });
    } catch (err) {
      LogUtil.error(`${TAG} error: ${err?.code}`);
    }
  }

  /**
   * 更新以太网配置
   * @param ifaceName 网口名
   * @param ifaceInfo 以太网详细信息
   * @param callback 更新成功回调
   * @param errorCallback 更新失败回调
   */
  public static updateEthernetIfcConfig(ifaceName: string, ifaceInfo: IEthernetInterfaceInfo, callback?: () => void,
    errorCallback?: (errorCode: number) => void): void {
    try {
      LogUtil.info(`${TAG} updateEthernetIfcConfig ifaceName: ${ifaceName}`);

      ethernet.setIfaceConfig(ifaceName, ifaceInfo as ethernet.InterfaceConfiguration, (error) => {
        if (error) {
          if (errorCallback) {
            errorCallback(error?.code);
          }
          LogUtil.error(`${TAG} updateEthernetIfcConfig error: ${error.code}`);
        } else {
          callback?.();
          LogUtil.info(`${TAG} updateEthernetIfcConfig success`);
        }
      });
    } catch (err) {
      LogUtil.error(`${TAG} error: ${err?.code}`);
    }
  }

  /**
   * 判断传入变量是否合法
   * @param v 传入的网络信息变量
   * @returns 是否合法
   */
  public static isVarStringType(v : string | Array<string> | number): boolean {
    return typeof v === 'string' && v.length > 0;
  }

  /**
   * 获取并更新网口数据
   */
  public static updateActiveIface(): void {
    ethernet.getAllActiveIfaces().then((data: string[]) => {
      LogUtil.info(`${TAG} getAllActiveIfaces data.length = ${data?.length}`);
      for (let i = 0; i < data.length; i++) {
        LogUtil.info(`${TAG} getAllActiveIfaces iface : ${data[i]}`);
        ethernet.isIfaceActive(data[i]).then((isActive: number) => {
          LogUtil.info(`${TAG} isIfaceActive : ${isActive}`);
          if (isActive === 1) {
            AppStorage.setOrCreate('iFaceData', new IFaceData(data[i], true));
            EventBus.getInstance().emit(Constants.ETHERNET_CHANGE_EVENT);
            return;
          }
        }).catch((error: BusinessError) => {
          LogUtil.error(`${TAG} isIfaceActive error : ${error?.code}`);
        });
      }
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} getAllActiveIfaces error : ${error?.code}`);
    });
  }

  public static registerInterfaceStateListener(): void {
    ethernet.on('interfaceStateChange', (data: IFaceData) => {
      // 底层回调接口有BUG，还会上报wlan0口，因此此处要筛选出以太网口
      if (data.iface.includes('eth')) {
        LogUtil.info(`on interfaceStateChange data iface: ${data?.iface}, active: ${data?.active}`);
        AppStorage.setOrCreate('iFaceData', data);
        EventBus.getInstance().emit(Constants.ETHERNET_CHANGE_EVENT);
      }
    });
  }

  public static unregisterInterfaceStateListener(): void {
    ethernet.off('interfaceStateChange', () => {
      LogUtil.info(`${TAG} off interfaceStateChange`);
    });
  }

  /**
   * 判断以太网高级设置入口是否显示
   */
  public static isEthernetAdvancedSettingsShow(): boolean {
    let result: boolean = false;
    let currentIfaceData: IFaceData = AppStorage.get<IFaceData>('iFaceData') as IFaceData;
    let currentEthernetList: IEthernetInfo[] = AppStorage.get<IEthernetInfo[]>('ethernetList') as IEthernetInfo[];
    // 优先根据可用网络来判断当前是否显示
    for (let index = 0; index < currentEthernetList.length; index++) {
      if (currentEthernetList[index].connectionProperties?.interfaceName) {
        LogUtil.info(`${TAG} isEthernetAdvancedSettingsShow EthernetList return ture`);
        return true;
      }
    }
    // 当网络未获取到的时候根据iface网络接口是否激活判断当前是否显示
    result = currentIfaceData?.iface.includes('eth') && currentIfaceData?.active;
    LogUtil.info(`${TAG} isEthernetAdvancedSettingsShow result: ${result}`);
    return result;
  }

  /**
   * 有线网络是否可用
   *
   * @param caps 网络能力
   * @returns true, 网络可用
   */
  public static isEthernetNetworkValidated(caps?: Array<connection.NetCap>): boolean {
    // 首次插入网线会触发探测，"networkCap":[12,15,16,31] 16为网络可用，31为触发探测，在探测过程会同时上报16，只有当存在16没有31的场景才能保证有网
    let networkValidated: boolean =
      (caps?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED) &&
        !(caps?.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY))) as boolean;
    return networkValidated;
  }

  /**
   * 判断以太网面板当前是否有网络信息显示
   * @returns true, 有网络信息显示
   */
  public static isEthernetDetailViewShow(): boolean {
    let isShow: boolean = false;
    let ethernetList = AppStorage.get('ethernetList') as IEthernetInfo[];
    if (!CheckEmptyUtils.isEmpty(ethernetList)) {
      isShow = ethernetList.length > 0;
    }
    return isShow;
  }

  /**
   * 判断以太网高级设置入口是否可用
   *
   * @returns true, 高级设置入口可用; false, 高级设置入口禁用
   */
  public static isEthernetAdvancedSettingsEnable(): boolean {
    let isDisabled: boolean = SystemParamUtil.getParam(SET_ETHERNET_IP_DISABLE, 'false') === 'true';
    LogUtil.info(`${TAG} isEthernetAdvancedSettingsEnable isDisabled: ${isDisabled}`);
    return !isDisabled;
  }

  /**
   * 非PC产品使用融合PC网络的新页面
   *
   * @returns true, 使用融合PC网络的新页面
   */
  public static useNewNetworkPage(): boolean {
    let result: boolean = SystemParamUtil.getParam(USE_NEW_NETWORK_PAGE, 'false') === 'true';
    LogUtil.info(`${TAG} useNewNetworkPage result: ${result}`);
    return result;
  }
}

export { EthernetUtil };