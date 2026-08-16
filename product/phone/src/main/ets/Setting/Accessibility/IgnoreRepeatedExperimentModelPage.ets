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

import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { IgnoreRepeatedExperimentModelComponent } from './view/IgnoreRepeatedExperimentModelComponent';

export const IGNORE_REPEATED_EXPERIMENT_MODEL_PAGE: string = 'Setting.Accessibility.IgnoreRepeatedExperimentModel';

@Builder
export function ignoreRepeatedExperimentModelBuilder(item: object) {
  IgnoreRepeatedExperimentModelComponent({ pageParam: (item as PageParams) });
}

// 忽略重复点击试用半模态页面
function customPage(): SettingPageModel {
  return {
    id: 'ignoreRepeatedExperimentModel',
    url: IGNORE_REPEATED_EXPERIMENT_MODEL_PAGE,
    type: PageType.PAGE_TYPE_CUSTOM,
    layout: {
      backgroundColor: $r('app.color.component_ultra_thick_panel')
    },
  }
}

ModalLoader.load(IGNORE_REPEATED_EXPERIMENT_MODEL_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(ignoreRepeatedExperimentModelBuilder),
});