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

import { BusinessError } from '@ohos.base';
import systemParameter from '@ohos.systemparameter';
import { RadioMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';

export enum TransitionAnimationKey {
  ENTER_TRANSITION_ANIMATION_ENTRY = 'enter_transition_animation_entry',
  ANIMATION_OFF_KEY = 'animation_off',
  ANIMATION_SCALE_0_5_KEY = 'animation_scale_0_5x',
  ANIMATION_SCALE_1_0_KEY = 'animation_scale_1_0x',
  ANIMATION_SCALE_1_5_KEY = 'animation_scale_1_5x',
  ANIMATION_SCALE_2_0_KEY = 'animation_scale_2_0x',
  ANIMATION_SCALE_5_0_KEY = 'animation_scale_5_0x',
  ANIMATION_SCALE_10_0_KEY = 'animation_scale_10_0x',
}

export enum TransitionAnimationValue {
  ANIMATION_OFF_VALUE = '0',
  ANIMATION_SCALE_0_5_VALUE = '0.5',
  ANIMATION_SCALE_1_0_VALUE = '1',
  ANIMATION_SCALE_1_5_VALUE = '1.5',
  ANIMATION_SCALE_2_0_VALUE = '2',
  ANIMATION_SCALE_5_0_VALUE = '5',
  ANIMATION_SCALE_10_0_VALUE = '10',
}
export const CLICK_SCALE: number = 1;

const CHOOSE_TRANSITION_ANIMATION_SCALING_RADIO: string = 'choose_transition_animation_scaling_radio';
const GRAPHIC_ANIMATION_SCALE_NAME = 'persist.sys.graphic.animationscale';
const ARKUI_ANIMATION_SCALE_NAME = 'persist.sys.arkui.animationscale';

const TAG: string = 'AnimationScaleController : ';

export class AnimationScaleController extends RadioMenuController {
  static CreateAnimationScaleController(menu: SettingsBaseMenu): Controller {
    return new AnimationScaleController(menu);
  }

  async onRadioChange(isChecked: boolean): Promise<void> {
    LogUtil.info(`${TAG} onRadioChange, ${isChecked}`);
    this.setRadio(isChecked);
    let scaleDegree: string = this.menu.extra as string;
    LogUtil.info(`${TAG} scaleDegree: ${scaleDegree}`);

    // 设置缩放尺度
    await systemParameter.set(GRAPHIC_ANIMATION_SCALE_NAME, scaleDegree)
      .then(() => {
        LogUtil.info(`${TAG} set graphic parameter success`);
      })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} catch graphic parameter error: ${err}`);
      })

    await systemParameter.set(ARKUI_ANIMATION_SCALE_NAME, scaleDegree)
      .then(() => {
        LogUtil.info(`${TAG} set arkui parameter success`);
      })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG} catch arkui parameter error: ${err}`);
      })

    HiSysEventUtil.reportRadioEvent(CHOOSE_TRANSITION_ANIMATION_SCALING_RADIO, scaleDegree);
    EventBus.getInstance().emit('EVENT_ID_ANIMATION_SCALE_UPDATE_EVENTS');
    this.closeSelf();
  }

  closeSelf(): void {
    super.closeSelf();
    LogUtil.info(`${TAG} closeSelf`);
  }

  updateStatus(): void {
    let animationScale: string =
    systemParameter.getSync(ARKUI_ANIMATION_SCALE_NAME, TransitionAnimationValue.ANIMATION_SCALE_1_0_VALUE);
    LogUtil.info(`${TAG} updateStatus: ${animationScale}`);
    if (animationScale === this.menu.extra) {
      this.setRadio(true);
    }
  }
}