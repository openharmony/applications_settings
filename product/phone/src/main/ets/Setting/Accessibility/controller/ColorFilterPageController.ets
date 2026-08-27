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
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageUrl } from '../../../pages/PageUrl';

const TAG: string = 'ColorFilterPageController : ';

export class ColorFilterPageController implements ComponentControl {
  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAuxiliaryEventGroup.ENTER_COLOR_FILTER_FUNCTIONS, 'pageUrl: ' + PageUrl.ACCESSIBILITY_COLOR_FILTER_PAGE_URL);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
  }
}