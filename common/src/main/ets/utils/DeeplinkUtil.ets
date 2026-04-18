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

import { url } from '@kit.ArkTS';
import { DeviceUtil } from './BaseUtils';
import { CommonUtils } from './CommonUtils';
import { DEEPLINK_SCHEME, NavEntryKey } from './Consts';
import { LogUtil } from './LogUtil';

/* instrument ignore file */
const TAG: string = 'DeeplinkUtil : ';

export class DeeplinkUtil {
  /**
   * 获取deeplink跳转目标
   *
   * @param uri 跳转uri
   * @param whiteUriList 白名单
   * @returns 跳转目标
   */
  public static getDeeplinkJumpUri(uri: string, whiteUriList: string[]): string {
    // 处理deeplink 'settings://子界面entry_key'
    try {
      if (!uri.startsWith(DEEPLINK_SCHEME)) {
        return uri;
      }
      let uriObject: url.URL = url.URL.parseURL(uri);
      if (uriObject.protocol !== DEEPLINK_SCHEME) {
        return uri;
      }
      let hostName: string = uriObject.hostname;
      if (hostName && whiteUriList.includes(hostName)) {
        // 平板/phone设置云空间胶囊选中
        DeeplinkUtil.setCloudSpaceSelected(hostName);
        DeeplinkUtil.setOucDeeplinkInfo(uriObject);
        return hostName;
      }
    } catch (err) {
      LogUtil.warn(`${TAG} parse url error ${err?.code}`);
    }
    return uri;
  }

  private static setCloudSpaceSelected(uri:string): void {
    if (uri !== NavEntryKey.CLOUD_SPACE_ENTRY) {
      return;
    }
    if (!DeviceUtil.isDevicePc()) {
      CommonUtils.setNavigationSelectedItem(NavEntryKey.CLOUD_SPACE_ENTRY);
    }
  }

  private static setOucDeeplinkInfo(uriObject: url.URL): void {
    if (uriObject?.hostname !== NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
      return;
    }

    // 处理deeplink 'settings://com_hmos_ouc_software_update_settings/targetSubRouter?a=xxx&b=xxx'
    let targetSubRouter = uriObject?.pathname?.substring(1) ?? '';
    let uriParams = uriObject?.search?.substring(1) ?? '';
    AppStorage.setOrCreate<string>('com_hmos_ouc_deeplink_target_uri', targetSubRouter);
    AppStorage.setOrCreate<string>('com_hmos_ouc_deeplink_uri_params', uriParams);
  }
}