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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from "@ohos/hypium";
import { EventBus } from "@ohos/settings.common/src/main/ets/framework/common/EventBus";
import { FusionSwitchGroupController } from '@ohos/settings.fusionconnectivity/src/main/ets/controller/FusionSwitchGroupController';
import { FUSION_SINGLE_SWITCH_CHANGE_EVENT, FUSION_SWITCH_TYPE_BLUETOOTH, FUSION_SWITCH_TYPE_NEARLINK } from '@ohos/settings.fusionconnectivity/src/main/ets/constants/FusionConstants';
import { CompCtrlParam } from "@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel";

class FusionSwitchGroupControllerSub extends FusionSwitchGroupController {
  private testBleState: boolean = false;
  private testNearlinkState: boolean = false;
  private handleTestStateChange = (type: number, isOn: boolean) => {
    if (type === FUSION_SWITCH_TYPE_BLUETOOTH) {
      this.testBleState = isOn;
    } else if (type === FUSION_SWITCH_TYPE_NEARLINK) {
      this.testNearlinkState = isOn;
    } else {
      return;
    }
  }

  init(param: CompCtrlParam): void {
    super.init(param);
    EventBus.getInstance().on(FUSION_SINGLE_SWITCH_CHANGE_EVENT, this.handleTestStateChange);
  }

  destroy(): void {
    EventBus.getInstance().detach(FUSION_SINGLE_SWITCH_CHANGE_EVENT, this.handleTestStateChange);
    super.destroy();
  }

  public getBleState(): boolean {
    return this.testBleState;
  }
}

export default function FusionSwitchGroupControllerTest() {
  describe('FusionSwitchGroupControllerTest', () => {
    beforeAll(() => {

    });
    beforeEach(() => {
    })
    afterEach(() => {
    })
    afterAll(async () => {
    });
    it('fusionSwitchGroupControllerTest_001', 0, fusionSwitchGroupControllerTest_001());
  })
}

function fusionSwitchGroupControllerTest_001(): Function {
  return () => {
    let controller: FusionSwitchGroupControllerSub = new FusionSwitchGroupControllerSub();
    controller.init({
      compId: 'pageid_switchgroup_id_test',
      component: {
        id: 'switchgroup_id_test'
      }
    });
    EventBus.getInstance().emit(FUSION_SINGLE_SWITCH_CHANGE_EVENT, FUSION_SWITCH_TYPE_BLUETOOTH, true);
    expect(controller.getBleState()).assertEqual(true);

    EventBus.getInstance().emit(FUSION_SINGLE_SWITCH_CHANGE_EVENT, FUSION_SWITCH_TYPE_NEARLINK, true);
    expect(controller.getBleState()).assertEqual(true);

    EventBus.getInstance().emit(FUSION_SINGLE_SWITCH_CHANGE_EVENT, FUSION_SWITCH_TYPE_BLUETOOTH, false);
    expect(controller.getBleState()).assertEqual(false);

    EventBus.getInstance().emit(FUSION_SINGLE_SWITCH_CHANGE_EVENT, FUSION_SWITCH_TYPE_NEARLINK, false);
    expect(controller.getBleState()).assertEqual(false);

    controller.destroy();
  }
}