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

import dataShare from '@ohos.data.dataShare';
import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  MenuController,
  DialogButtonMenuController,
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsBaseMenu, MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { displayDataManager } from '@ohos/settings.common/src/main/ets/data/DisplayDataManager';
import {
  DialogPage,
  DialogTitleMenu,
  ButtonMenu,
  DividerMenuGroup,
  RadioMenu,
  TransparentButtonStyle,
  TransparentButtonMenuStyle,
  dialogRadioMenuStyle,
  radioListDialogDividerGroupStyle,
  radioListDialogPageStyle,
  radioListDialogTitleMenuStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { SleepController, SleepTime, SleepKey } from '@ohos/settings.display/src/main/ets/controller/SleepController';
import {
  DialogLifecycleObserverInterface,
  PageLifecycleObserverInterface,
} from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
class CancelButtonStyle extends TransparentButtonStyle {
  public margin: Margin = {
    top: '8vp',
    bottom: '16vp',
  }
}

class DormancyButtonMenuStyle extends TransparentButtonMenuStyle {
  public buttonStyle1 = new CancelButtonStyle();
  public menuContainerPadding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    right: $r('sys.float.ohos_id_default_padding_end'),
  }
}

export let dormancyButtonMenuStyle = new DormancyButtonMenuStyle();
