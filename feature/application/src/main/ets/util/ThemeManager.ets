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

import fs from '@ohos.file.fs';
import commonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';

const TAG: string = 'ThemeManager : ';
const FLAG_PATH_A: string = '/data/themes/a/app/flag';
const FLAG_PATH_B: string = '/data/themes/b/app/flag';
const SANDBOX_DESCRIPTION_A: string = '/data/themes/a/app/icons/description.json';
const SANDBOX_DESCRIPTION_B: string = '/data/themes/b/app/icons/description.json';
const KEY_LAST_ICON_THEME_ID: string = 'lastIconThemeId';

export enum PageList {
  APP_LIST_PAGE = 'APP_LIST',
  BATTERY_PAGE = 'POWER_CONSUMPTIONS_APP_LIST',
  MORE_APP_LIST_PAGE = 'MORE_APP_LIST',
  CLONE_APP_MANAGER = 'CLONE_APP_MANAGER'
}

export class ThemeManager {
  private readonly subscribeInfo?: commonEventManager.CommonEventSubscribeInfo = {
    events: ['com.ohos.ActivateTheme']
  };
  private readonly pageList: PageList[] =
    [PageList.APP_LIST_PAGE, PageList.BATTERY_PAGE, PageList.MORE_APP_LIST_PAGE, PageList.CLONE_APP_MANAGER];
  private static themeManager?: ThemeManager;
  private pageRefreshStatus: Map<string, boolean> = new Map<string, boolean>();
  private isOnlineIcon: boolean = false;
  private subscriber?: commonEventManager.CommonEventSubscriber;
  private lastIconThemeId: string = PreferencesUtil.getSync(KEY_LAST_ICON_THEME_ID, '') as string;

  constructor() {
    // 刷新是否在线主题状态
    this.isOnlineIcon = this.refreshThemeStatus();
  }

  public static getInstance(): ThemeManager {
    if (!ThemeManager.themeManager) {
      ThemeManager.themeManager = new ThemeManager();
    }
    return ThemeManager.themeManager;
  }

  public finishedRefreshAppList() {
    this.pageRefreshStatus.set(PageList.APP_LIST_PAGE, false);
    this.pageRefreshStatus.set(PageList.BATTERY_PAGE, false);
    this.pageRefreshStatus.set(PageList.CLONE_APP_MANAGER, false);
    LogUtil.showInfo(TAG, 'theme refresh status reset');
  }

  public checkIsOnlineIcon(): boolean {
    return this.isOnlineIcon;
  }

  public checkIsNeedToRefresh(pageName: PageList): boolean {
    LogUtil.showInfo(TAG, `theme checkIsNeedToRefresh ${pageName}: ${this.pageRefreshStatus.get(pageName)}`);
    return this.pageRefreshStatus.get(pageName) ?? false;
  }

  public resetRefreshStatus(pageName: PageList) {
    this.pageRefreshStatus.set(pageName, false);
  }

  public subscribeThemeEvent(): void {
    LogUtil.showInfo(TAG, `theme event subscribe`);
    if (this.subscriber) {
      return;
    }
    try {
      commonEventManager.createSubscriber(this.subscribeInfo, (error, data) => {
        if (error) {
          LogUtil.showError(TAG, `create subscriber failed ${error?.code} : ${error?.message}`);
          return;
        }
        this.subscriber = data;
        if (!this.subscriber) {
          LogUtil.showError(TAG, 'invalid subscriber.');
          return;
        }
        this.themeEventCallback();
      })
    } catch (error) {
      LogUtil.showError(TAG, `initSubscriber failed. Code:${error?.code}, message:${error?.message}`);
    }
  }

  private refreshAllPage() {
    this.pageList.forEach((value: string) => {
      this.pageRefreshStatus.set(value, true);
    })
  }

  private themeEventCallback(): void {
    try {
      commonEventManager.subscribe(this.subscriber, (error, eventData) => {
        if (error) {
          LogUtil.showError(TAG, `subscribe failed: ${eventData?.event},` +
            `Code:${error?.code}, message:${error?.message}`);
          return;
        }
        this.isOnlineIcon = this.refreshThemeStatus();
        LogUtil.showInfo(TAG, `themeEventCallback isOnlineIcon ${this.isOnlineIcon}`);
      });
    } catch (error) {
      LogUtil.showError(TAG, `subscribe failed: Code:${error?.code}, message:${error?.message}`);
    }
  }

  /**
   * 只有主题更换的时候触发，除了刷新图标以外，判断图标是不是属于在线格式的
   */
  private refreshThemeStatus(): boolean {
    LogUtil.showInfo(TAG, 'check if is ONELINE or Preset');
    let themePath: string = '';
    try {
      if (fs.accessSync(FLAG_PATH_A)) {
        themePath = SANDBOX_DESCRIPTION_A;
      } else if (fs.accessSync(FLAG_PATH_B)) {
        themePath = SANDBOX_DESCRIPTION_B;
      } else {
        LogUtil.showError(TAG, 'refreshThemeStatus there is no FLAG in A/B path.');
        return false;
      }
    } catch (error) {
      LogUtil.showError(TAG, `refreshThemeStatus error in getCurrentThemePath:` +
        `Code:${error?.code}, message:${error?.message}`);
      return false;
    }
    let isOnline: boolean = false;
    try {
      // 读取desscriptioin.json
      const descriptionContent: object | null = JSON.parse(fs.readTextSync(themePath));
      if (!descriptionContent) {
        LogUtil.showError(TAG, 'JSON.parse description returns null.');
        return false;
      }
      let currentIconThemeId: string = descriptionContent['id'];
      LogUtil.showInfo(TAG, `current theme icon id is: ${currentIconThemeId}`)
      if (currentIconThemeId !== this.lastIconThemeId) {
        // 图标主题发生了变化，需要重新刷新应用列表
        LogUtil.showInfo(TAG, `icon theme changed to: ${currentIconThemeId}, old id is ${this.lastIconThemeId}`);
        this.pageList.forEach((value: PageList) => {
          this.pageRefreshStatus.set(value, true);
        });
        this.lastIconThemeId = currentIconThemeId;
        PreferencesUtil.putSync(KEY_LAST_ICON_THEME_ID, currentIconThemeId);
      }
      if (descriptionContent['origin'] === 'online') {
        isOnline = true;
      }
    } catch (error) {
      LogUtil.showError(TAG, `refreshThemeStatus error Code:${error?.code}, message:${error?.message}`)
    }
    return isOnline;
  }

  /**
   * Unregister theme event.
   */
  public unsubscribeThemeEvent(): void {
    if (this.subscriber) {
      commonEventManager.unsubscribe(this.subscriber);
      this.subscriber = undefined;
      LogUtil.showInfo(TAG, `theme event unsubscribe`);
    }
  }

  /**
   * 获取当前图标对应的主题id
   *
   * @returns 当前图标对应的主题id
   */
  public getCurrentThemeId(): string {
    return this.lastIconThemeId;
  }
}

