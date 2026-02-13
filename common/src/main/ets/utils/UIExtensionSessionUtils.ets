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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import window from '@ohos.window';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';

/* instrument ignore file */
const TAG: string = 'UIExtensionSessionUtils : ';

/**
 * WLAN UIExtension Session 工具类
 *
 * @since 2024-05-09
 */
export class UIExtensionSessionUtils {
  /**
   * 计算WLAN二三级页面顶部padding高度：oobe场景WLAN二三级页面需要主动避让状态栏，其他场景不需要
   *
   * @context 上下文
   * @returns 距离顶部高度
   */
  static calculateTopPaddingIfNeeded(): number {
    let isOobeWifi: boolean = AppStorage.get<boolean>('OOBEWifi') ?? false;
    return isOobeWifi ? UIExtensionSessionUtils.getStatusBarHeight() : 0;
  }

  /**
   * 获取UIExtension窗口宽和高
   *
   * @returns 窗口矩形区域
   */
  static async getWindowRect(): Promise<window.Rect | undefined> {
    try {
      if (!LocalStorage?.getShared()?.has('session')) {
        LogUtil.showInfo(TAG, `getWindowRect failed: invalid session.`);
        return undefined;
      }
      let session: UIExtensionContentSession = LocalStorage.getShared()?.get('session') as UIExtensionContentSession;
      let uiExtensionRect: window.Rect =
        session?.getUIExtensionHostWindowProxy()?.properties?.uiExtensionHostWindowProxyRect;
      if (CheckEmptyUtils.isEmpty(uiExtensionRect)) {
        LogUtil.showInfo(TAG, `getWindowRect empty.`);
        return undefined;
      }
      LogUtil.showInfo(TAG, `getWindowRect ${uiExtensionRect?.width}, ${uiExtensionRect?.height}.`);
      return uiExtensionRect;
    } catch (error) {
      LogUtil.showError(TAG, `getWindowRect failed: code = ${error?.code}, msg = ${error?.message}`);
    }
    return undefined;
  }

  public static getStatusBarHeight(): number {
    try {
      if (!LocalStorage?.getShared()?.has('session')) {
        LogUtil.showInfo(TAG, `getStatusBarHeight failed: invalid session.`);
        return 0;
      }
      let session: UIExtensionContentSession = LocalStorage.getShared()?.get('session') as UIExtensionContentSession;
      let sysAvoidArea: window.AvoidArea =
        session?.getUIExtensionHostWindowProxy()?.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let statusBarHeight: number =
        CheckEmptyUtils.isEmpty(sysAvoidArea?.topRect) ? 0 : px2vp(sysAvoidArea.topRect.height);
      LogUtil.showInfo(TAG, `getStatusBarHeight result: statusBarHeight = ${statusBarHeight}`);
      return statusBarHeight;
    } catch (error) {
      LogUtil.showError(TAG, `getStatusBarHeight failed: code = ${error?.code}, msg = ${error?.message}`);
    }
    return 0;
  }

  public static sendTitleAnimationDuration(uiExtensionProxy: UIExtensionProxy | undefined | null, startTime: number) {
    if (startTime >= 0) {
      LogUtil.info(`${TAG} title startTime time is ` + startTime);
      uiExtensionProxy?.send({ 'titleAnimationDuration': startTime });
    }
  }
}

