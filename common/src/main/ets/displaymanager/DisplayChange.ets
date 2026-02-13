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

import { DisplayConstant } from '../constant/DisplayConstant';
import { EventBus } from '../framework/common/EventBus';
import { LogUtil } from '../utils/LogUtil';

const TAG: string = 'DisplayChange :';

export class DisplayChange {
  private changeEventSend: boolean = false;

  public emitDisplayChange(): void {
    if (!this.changeEventSend) {
      LogUtil.showInfo(TAG, 'emitDisplayChange');
      this.changeEventSend = true;
      EventBus.getInstance().emit(DisplayConstant.DISPLAY_CHANGE_EVENT);
    }
  }
}