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

import data from '@ohos.telephony.data';
import sim from '@ohos.telephony.sim';
import radio from '@ohos.telephony.radio';
import { BusinessError } from '@ohos.base';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { RadioMenu, NewDefaultRadioMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { SimCardSwitchController } from '../controller/SimCardSwitchController';
import { ESimUtils } from '../../../utils/ESimUtils';
/* instrument ignore file */
const TAG: string = 'ResetNetSimController : ';
const BLANK: string = ' ';
const UNDERLINE: string = '_';
const CARD_KEY_PREFIX: string = 'hw_sim_card_';

export class SimRadioMenuStyle extends NewDefaultRadioMenuStyle {
  public menuContainerPadding: Padding = {
    right: '4vp'
  }
  public radioStyle?: RadioStyle = {
    checkedBackgroundColor: $r('sys.color.ohos_id_color_emphasize'),
    uncheckedBorderColor: Color.Transparent
  }
}

let simRadioMenuStyle = new SimRadioMenuStyle();

/**
 * Reset network settings: SIM card controller
 *
 * @author yudenggao
 * @since 2023-08-29
 */
export class OperatorNameGet {
  static async getOperatorName(slotId: number): Promise<string> {
    try {
      let operatorName: string = await radio.getOperatorName(slotId);
      LogUtil.info(`${TAG} getOperatorName info success ${operatorName}`);
      return operatorName;
    } catch (err) {
      LogUtil.info(`${TAG} getOperatorName error: ${err?.message} code: ${err?.code}`);
    }
    return '';
  }
}

export class ResetNetSimController extends MenuGroupController {
  static CreateResetNetSimController(menu: SettingsBaseMenu): Controller {
    return new ResetNetSimController(menu);
  }

  updateStatus() {
    super.updateStatus();
    this.loadSimCards();
  }

  private async loadSimCards() {
    let menus: SettingsBaseMenu[] = [];
    let defaultSimId = await data.getDefaultCellularDataSimId();
    if (defaultSimId == 0) {
      this.setVisible(false);
      return;
    }
    let simAccounts: sim.IccAccountInfo[] = [];
    let promise = sim.getActiveSimAccountInfoList();
    await promise.then(data => {
      LogUtil.info(`${TAG} getActiveSimAccountInfoList success, promise: data ${data?.length}`);
      simAccounts = data;
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getActiveSimAccountInfoList failed, promise: err ${err?.code} msg is ${err?.message}`);
    });
    let index: number = 1;
    if (simAccounts.length == 1) {
      let menuKey = CARD_KEY_PREFIX + index;
      let menu = new RadioMenu({ key: menuKey, style: simRadioMenuStyle });
      let slotIndex = simAccounts[0].slotIndex;
      let operatorName = await OperatorNameGet.getOperatorName(slotIndex);
      menu.title = ESimUtils.getSimCardName(slotIndex) + BLANK + BLANK + operatorName;
      menu.extra = slotIndex + UNDERLINE + defaultSimId as Object;
      menu.controller = {
        createControllerConstructorInter: SimCardSwitchController.createSimCardSwitchController,
      };
      menus.push(menu);
    } else {
      let operatorName1 = await OperatorNameGet.getOperatorName(simAccounts[0].slotIndex);
      let operatorName2 = await OperatorNameGet.getOperatorName(simAccounts[1].slotIndex);
      simAccounts.forEach((item, idx) => {
        let menuKey = CARD_KEY_PREFIX + idx;
        let menu = new RadioMenu({ key: menuKey, style: simRadioMenuStyle });
        let slotIndex = item.slotIndex;
        let cardNumberPrefix: string = ESimUtils.getSimCardName(slotIndex);
        if (idx > 0) {
          menu.title = cardNumberPrefix + BLANK + BLANK + operatorName2;
        } else {
          menu.title = cardNumberPrefix + BLANK + BLANK + operatorName1;
        }
        menu.extra = slotIndex + UNDERLINE + defaultSimId as Object;
        menu.controller = {
          createControllerConstructorInter: SimCardSwitchController.createSimCardSwitchController,
        };
        index += 1;
        menus.push(menu);
      })
    }
    this.addChildren(menus);
    this.refreshUi();
  }
}
