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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

const TAG: string = 'OucNavigationUtils';

/**
 * OUC页面路由工具类
 *
 * @since 2025-03-31
 */
export class OucNavigationUtils {
  /**
   * OUC页面路由信息处理
   *
   * @param targetUri 页面目标路径
   */
  static setOUCNavigationPushParams(targetUri: string): void {
    let wantParams = AppStorage.get<Want>('wantParams') ?? {};
    let parameters = wantParams.parameters ?? {};
    LogUtil.info(`${TAG} setOUCNavPushParams, pushParams: ${parameters?.pushParams}, subUri: ${parameters?.subUri}`);
    let params: Record<string, Object> = {};
    let subUri: string = targetUri;

    if (!CheckEmptyUtils.isEmpty(parameters?.pushParams) && typeof parameters?.pushParams === 'string') {
      // pushParams是string类型代表subUri通过pushParams传递
      subUri = parameters?.pushParams;
    } else {
      let deeplinkSubUri: string = AppStorage.get<string>('com_hmos_ouc_deeplink_target_uri') ?? '';
      LogUtil.info(`${TAG} setOUCNavPushParams, deeplinkSubUri: ${deeplinkSubUri}`);
      if (!CheckEmptyUtils.checkStrIsEmpty(deeplinkSubUri)) {
        subUri = deeplinkSubUri;
      }
      params = parameters?.pushParams as Record<string, Object> ?? {};
    }
    params.deeplinkParams = AppStorage.get<string>('com_hmos_ouc_deeplink_uri_params') ?? '';

    parameters.pushParams = params;
    parameters.subUri = subUri;
    wantParams.parameters = parameters;
    AppStorage.setOrCreate<Want>('wantParams', wantParams);
    AppStorage.setOrCreate<string>('com_hmos_ouc_deeplink_target_uri', '');
    AppStorage.setOrCreate<string>('com_hmos_ouc_deeplink_uri_params', '');
    AppStorage.setOrCreate<string>('com_hmos_ouc_software_update_settings_target_sub_router', subUri);
  }
}
