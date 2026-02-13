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
import { BusinessError } from '@kit.BasicServicesKit';
import sim from '@ohos.telephony.sim';
import wifiManager from '@ohos.wifiManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { EAP_METHOD_CHANGED_EVENT, WLAN_CONFIG_INPUT_CHANGE_EVENT } from '../../model/WifiModel';
import { WIFI_EAP_SIM_SELECT } from '../../WifiMenuManager';

const TAG: string = 'EapSimCardSlotController';
const SIM_MAX_NUM: number = 2;

/**
 * 添加网络界面，SIM卡槽选择控制器
 *
 * @since 2025-01-13
 */
export class EapSimCardSlotController implements ComponentControl {
  private compId: string = '';
  private eapConfig?: wifiManager.WifiEapConfig;
  private onEapMethodChange = () => {
    let isShow: boolean = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_SIM;
    this.refreshUi(isShow);
  }

  constructor(eapConfig?: wifiManager.WifiEapConfig) {
    LogUtil.info(`${TAG} EapSimCardSlotController constructor execute`);
    this.eapConfig = eapConfig;
  }

  private refreshUi(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideSimSelectGroup: ${isShow}`);
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private onSelected(index: number): void {
    if (index === 0) {
      LogUtil.info(`${TAG} select not set}`);
      this.initEapSubId();
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
      return;
    }
    let slotId: number = index - 1;
    sim.getSimAccountInfo(slotId).then((accountInfo) => {
      let subId: number = accountInfo.simId;
      LogUtil.info(`${TAG} select sim card id: ${subId}; slot id: ${slotId}`);
      if (!this.eapConfig) {
        LogUtil.warn(`${TAG} eapConfig not exist`);
        return;
      }
      this.eapConfig.eapSubId = subId;
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getSimAccountInfo catch err code: ${err.code}, message: ${err.message}`);
    })
  }

  private getSimMenu(): ResourceStr[] {
    let resultItems: ResourceStr[] = ['(' + ResourceUtil.getStringSync($r('app.string.sim_not_set')) + ')'];
    for (let index = 0; index < SIM_MAX_NUM; index++) {
      let state = sim.getSimStateSync(index);
      LogUtil.info(`${TAG} sim ${index} state: ${state}`);
      if (state === sim.SimState.SIM_STATE_READY || state === sim.SimState.SIM_STATE_LOADED) {
        resultItems.push(this.getSimName(index));
      }
    }
    return resultItems;
  }

  init(param: CompCtrlParam): void {
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    LogUtil.info(`${TAG} init compId: ${param.compId}`);
    this.compId = param.compId;
    this.initEapSubId();
    EventBus.getInstance().on(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChange);
    let items: ResourceStr[] = this.getSimMenu();

    (param.dataSource as DynamicDataSource)?.pushData({
      id: WIFI_EAP_SIM_SELECT,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: ResourceUtil.getStringSync($r('app.string.sim_card_slot'))
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_arrow_pull'),
        style: {
          width: $r('app.float.width_12'),
          height: $r('app.float.width_18'),
          fillColor: $r('sys.color.icon_fourth'),
        },
        menu: {
          items: items,
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            this.onSelected(index);
          },
          defaultFocus: 0,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '(' + ResourceUtil.getStringSync($r('app.string.sim_not_set')) + ')',
        }
      }
    })
  }

  private initEapSubId() {
    LogUtil.info(`${TAG} init eap config subId: 0`);
    if (this.eapConfig) {
      this.eapConfig.eapSubId = 0;
    }
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChange);
  }

  /**
   * 通过卡槽id获取SIM卡名称，包括普通SIM卡和eSIM
   *
   * @param slotId 卡槽id，当前最多支持两个，即：0、1
   * @returns SIM名称
   */
  private getSimName(slotId: number): string {
    if (!DeviceUtil.isSupportEsim()) {
      return `${ResourceUtil.getStringSync($r('app.string.sim_card_slot'))} ${(slotId + 1).toString()}`;
    }
    let simLabel = SimUtils.getSimLabel(slotId);
    LogUtil.showInfo(TAG, `support esim, slotId: ${slotId}, simType: ${simLabel?.simType}, index: ${simLabel?.index}`);
    const idxStr = (simLabel?.index ?? slotId + 1).toString();
    if (simLabel?.simType === sim.SimType.ESIM) {
      return ResourceUtil.getFormatStringSync($r('app.string.esim_card'), idxStr);
    } else {
      return `${ResourceUtil.getStringSync($r('app.string.sim_card_slot'))} ${idxStr}`;
    }
  }
}