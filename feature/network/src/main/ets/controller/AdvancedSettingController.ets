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
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ItemDetailType,
  ItemType,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EthernetUtil } from '../util/EthernetUtil';
import { URL_NETWORK_ETHERNET_DIALOG_PAGE } from '../EthernetDialogPage';
import { Constants } from '../constant/Constants';

const TAG: string = 'AdvancedSettingController: ';
const ETHERNET_ADVANCED_GROUP_ID: string =
  EthernetUtil.useNewNetworkPage() ? 'Setting.Network.pc_ethernet_advanced_group' :
    'Setting.PcNetwork.pc_ethernet_advanced_group';

/**
 * 网络页面控制器类
 */
export class AdvancedSettingController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    EthernetUtil.updateActiveIface();
    EthernetUtil.registerInterfaceStateListener();
    EventBus.getInstance().on(Constants.ETHERNET_CHANGE_EVENT, this.updateState);
    this.dataSource.pushData(this.createAdvanceSettingItem());
    this.updateState();
  }


  private createAdvanceSettingItem(): SettingItemModel {
    return {
      id: 'pc_ethernet_advanced_settings',
      type: ItemType.ITEM_TYPE_STANDARD,
      layout: {
        minHeight: DeviceUtil.isDevicePc() ? $r('app.float.height_56') : $r('app.float.height_64'),
      },
      title: {
        content: $r('app.string.advanced_setting')
      },
      desc: { content: $r('app.string.network_ethernet_describe') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MODAL,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        destination: URL_NETWORK_ETHERNET_DIALOG_PAGE,
        sheetOptions: {
          backgroundColor: Color.Transparent,
          blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          height: SheetSize.FIT_CONTENT,
          width: $r('app.float.ethernet_dialog_with'),
          preferType: SheetType.CENTER,
          dragBar: false,
          onWillDismiss: () => {
            LogUtil.info(`${TAG} onWillDismiss.`);
            EventBus.getInstance().emit(Constants.ADVANCED_ETHERNET_DIALOG_DISMISS_EVENT);
          }
        },
      },
      enabled: EthernetUtil.isEthernetAdvancedSettingsEnable()
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EthernetUtil.unregisterInterfaceStateListener();
    EventBus.getInstance().detach(Constants.ETHERNET_CHANGE_EVENT, this.updateState);
  }

  private updateState(): void {
    let isVisible: boolean = EthernetUtil.isEthernetAdvancedSettingsShow();
    LogUtil.info(`${TAG} updateState ${isVisible}`);
    notifyCompStateChange(ETHERNET_ADVANCED_GROUP_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: isVisible } as SettingCompState]]));
  }
}
