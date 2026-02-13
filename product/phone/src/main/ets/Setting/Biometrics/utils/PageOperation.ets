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

import { UIExtensionContentSession } from '@kit.AbilityKit';
// import { HdsNavigationMenuItemOptions } from '@kit.UIDesignKit';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AuthConstant } from '@ohos/settings.common/src/main/ets/constant/AuthConstant';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { PinAuthUtil } from '@ohos/settings.privacy/src/main/ets/PinAuthUtil';
import { LogUtil } from '@ohos/mpchart/src/main/ets/components/utils/LogUtil';

export default class PageOperation {
  public static firstEntryPage: boolean = false; // 首次进入界面

  /**
   * 返回上一级
   *
   * @param params 参数信息
   * @param pathInfos 页面栈
   * @returns true为外部拉起页面 false为内部页面
   */
  public static back(params: PushParam | null | undefined, pathInfos?: NavPathStack): boolean {
    if (PinAuthUtil.isFromUIExtension(params) || WalletManageUtils.isFromWallet()) {
      WalletManageUtils.sendAbilityResultToWallet(AuthConstant.CREATE_PSD_FAIL);
      pathInfos?.pop();
      const uiExtensionContentSession = AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession');
      try {
        if (uiExtensionContentSession) {
          uiExtensionContentSession.sendData({ 'result': AuthConstant.CREATE_PSD_FAIL });
        }
      } catch (e) {
        LogUtil.error(`sendData error ${e?.code} ${e?.message}`);
      }
      return true;
    }
    return false;
  }

  /**
   * 关闭拉起页面
   */
  public static close(): void {
    const uiExtensionContentSession = AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession');
    try {
      if (uiExtensionContentSession) {
        uiExtensionContentSession.sendData({ 'result': AuthConstant.CREATE_PSD_CLOSE });
      }
    } catch (e) {
      LogUtil.error(`sendData error ${e?.code} ${e?.message}`);
    }
  }

  /**
   * 关闭按钮
   *
   * @returns 菜单项
   */
  public static xMarkMenu(): ESObject {
    return {
      // content: {
      //   icon: $r('sys.symbol.xmark'),
      //   action: () => {
      //     PageOperation.close();
      //   },
      //   label: $r('app.string.close_menu')
      // }
    };
  }
}