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

/* instrument ignore file */
import { window } from '@kit.ArkUI';
import { BusinessError } from '@ohos.base';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'ThemeSettingsController';
const THEME_SETTINGS_WINDOW_MOD: string = 'themeSettings.windowMode';

export class ThemeSettingsController {
  private static instance: ThemeSettingsController | undefined = undefined;

  private static windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED;

  public static getInstance(): ThemeSettingsController {
    if (ThemeSettingsController.instance === undefined) {
      ThemeSettingsController.instance = new ThemeSettingsController();
    }
    return ThemeSettingsController.instance;
  }

  public getWindowStatusType(): window.WindowStatusType {
    return ThemeSettingsController.windowStatusType;
  }

  public windowStatusChangeCallback = (windowStatusType: window.WindowStatusType): void => {
    LogUtil.showInfo(TAG, `windowStatusChange, window type is ${windowStatusType}`);
    this.updateWindowStateValue(windowStatusType);
  };

  private themeGalleryProxyCallback(themeGalleryProxy: UIExtensionProxy):
    (windowStatusChange: window.WindowStatusType) => void {
    return (windowStatusChange: window.WindowStatusType) => {
      themeGalleryProxy.send({ 'changeWindowStatusData': windowStatusChange });
      LogUtil.showInfo(TAG, `Successed to enable the listener for window status changes: ${windowStatusChange}`);
    };
  }

  public setWindowStateValue(context: Context): void {
    try {
      window.getLastWindow(context).then((win) => {
        let windowStatus: window.WindowStatusType =
          AppStorage.get<number>('windowMode') ?? window.WindowStatusType.UNDEFINED;
        LogUtil.showInfo(TAG, `setWindowStateValue, windowStatus: ${windowStatus}`);
        const windowRect = win.getWindowProperties().windowRect;
        const displayRect = DisplayUtils.getDefaultDisplaySyncInfo();
        if (!windowRect || !displayRect) {
          LogUtil.showError(TAG, 'windowRect or displayRect is undefined');
          return;
        }
        LogUtil.showInfo(TAG, `windowWidth: ${windowRect.width}, displayWidth: ${displayRect?.width},` +
          `windowHeight: ${windowRect.height}, displayHeight: ${displayRect?.height}`);
        if (windowRect.width < (displayRect?.width ?? 0) || windowRect.height < (displayRect?.height ?? 0)) {
          windowStatus = window.WindowStatusType.FLOATING;
        }
        this.updateWindowStateValue(windowStatus);

        win.on('windowStatusChange', this.windowStatusChangeCallback);
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `getLastWindow failed, err code:${err?.code}, ${err?.message}.`);
      });
    } catch (err) {
      if (!err) {
        LogUtil.showError(TAG, 'setWindowStateValue failed, but err is undefined');
        return;
      }
      LogUtil.showError(TAG, `setWindowStateValue failed, error reason: ${(err as BusinessError).message}`);
    }
  }

  private updateWindowStateValue(windowStatus: window.WindowStatusType): void {
    SettingsDataUtils.setSettingsData(THEME_SETTINGS_WINDOW_MOD, String(windowStatus));
    ThemeSettingsController.windowStatusType = windowStatus;
  }

  public setWindowSystemBar(context: Context): void {
    try {
      window.getLastWindow(context).then((win) => {
        win?.setWindowSystemBarEnable(['status', 'navigation']);
        win?.setWindowLayoutFullScreen(false);
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `getLastWindow failed, err code:${err?.code}, ${err?.message}.`);
      });
    } catch (err) {
      LogUtil.showError(TAG, `set status bar fail ${err?.code} msg ${err?.message}`);
    }
  }

  public async updateThemeGalleryWindowStatus(context: Context, themeGalleryProxy: UIExtensionProxy | null,
    isDestroy: boolean): Promise<void> {
    if (themeGalleryProxy === null) {
      LogUtil.showInfo(TAG, `updateWindowStatus, themeGalleryProxy is null`);
      return;
    }
    LogUtil.showInfo(TAG, `updateWindowStatus, themeGalleryProxy is not null`);
    this.updateWindowStatus(context, this.themeGalleryProxyCallback(themeGalleryProxy), isDestroy);
  }

  private updateWindowStatus(context: Context, callback: Callback<WindowStatusType>, isDestroy: boolean) {
    try {
      window.getLastWindow(context).then((win) => {
        try {
          if (isDestroy) {
            win.off('windowStatusChange', callback);
            LogUtil.showInfo(TAG, 'isDestroy, win.off windowStatusChange');
          } else {
            win.on('windowStatusChange', callback);
          }
        } catch (err) {
          LogUtil.showError(TAG, `Failed in the listener for window status changes, err:${err?.code}, ${err?.message}`);
        }
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `getLastWindow failed, err code:${err?.code}, ${err?.message}.`);
      });
    } catch (e) {
      LogUtil.showError(TAG, `Failed on updateWindowStatus. ${e?.code} - ${e?.message}`);
    }
  }

  public cancelWindowStateChange(context: Context): void {
    LogUtil.showInfo(TAG, 'cancelWindowStateChange start');
    try {
      window.getLastWindow(context).then((win) => {
        win.off('windowStatusChange', this.windowStatusChangeCallback);
        LogUtil.showInfo(TAG, 'windowStatusChange win.off');
      }).catch((err: BusinessError) => {
        LogUtil.showError(TAG, `getLastWindow failed, err code:${err?.code}, ${err?.message}.`);
      });
    } catch (err) {
      if (!err) {
        LogUtil.showError(TAG, `cancelWindowStateChange failed, but err is undefined`);
        return;
      }
      LogUtil.showError(TAG, `cancelWindowStateChange failed, error reason: ${(err as BusinessError).message}`);
    }
  }
}