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
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { LogUtil } from './LogUtil';

/**
 * 设置性能DFX
 *
 * @since 2023-08-16
 */

class LoadFailureEventParam {
  public PACKAGE_NAME: string = '';
  public PROCESS_NAME: string = '';
  public PAGE_NAME: string = '';
  public FROM_PAGE: string = '';
  public PATH: string = '';
}

class PageTransitionEventParam {
  public PACKAGE_NAME: string = '';
  public PROCESS_NAME: string = '';
  public PAGE_NAME: string = '';
  public FROM_PAGE: string = '';
  public DELAY: number = 0;
}

class UiextensionLoadFailureEvent {
  public BUNDLE_NAME: string = '';
  public PACKAGE_NAME: string = '';
  public ABILITY_NAME: string = '';
  public RECONNECT_COUNT: number = 0;
  public ERROR_CODE: number = 0;
}

export class SettingsPerformanceDfx {
  public static readonly UIEXTENSION_LOAD_FAILURE_EVENT: string = 'UIEXTENSION_LOAD_FAILURE_EVENT';
  public static readonly PAGE_TRANSITION_DELAY_STATISTIC: string = 'PAGE_TRANSITION_DELAY_STATISTIC';
  public static readonly PAGE_LOAD_FAILURE_EVENT: string = 'PAGE_LOAD_FAILURE_EVENT';
  public static readonly tag: string = 'SettingDfx: ';
  public lastPageName: string;
  public currentPageName: string = '';
  public startPageTime: number = 0;
  private static instance: SettingsPerformanceDfx | null = null;

  constructor() {
    this.lastPageName = 'launcher';
  }

  setPageTransitionStart(): void {
    this.startPageTime = Date.now();
  }

  static async reportUiextensionLoadFailureEvent(bundleName: string, abilityName: string,
    reconnectCount: number, errorCode: number): Promise<void> {
    let params: UiextensionLoadFailureEvent = {
      BUNDLE_NAME: bundleName,
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      ABILITY_NAME: abilityName,
      RECONNECT_COUNT: reconnectCount,
      ERROR_CODE: errorCode
    }
    HiSysEventUtil.reportFaultEvent(
      SettingsPerformanceDfx.UIEXTENSION_LOAD_FAILURE_EVENT,
      params,
      SettingsPerformanceDfx.UIEXTENSION_LOAD_FAILURE_EVENT);
  }

  async reportPageTransitionTimeEvent(fromPage: string, currentPage: string, delay: number): Promise<void> {
    let params: PageTransitionEventParam = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      PAGE_NAME: currentPage,
      FROM_PAGE: fromPage,
      DELAY: delay,
    }
    this.lastPageName = currentPage;
    LogUtil.info(`${SettingsPerformanceDfx.tag}  page transition from: ${fromPage}  to page ${currentPage}  with delay(ms): ${delay}`);
    HiSysEventUtil.reportStatisticEvent(
      SettingsPerformanceDfx.PAGE_TRANSITION_DELAY_STATISTIC,
      params,
      SettingsPerformanceDfx.PAGE_TRANSITION_DELAY_STATISTIC);
  }

  async reportPageLoadFailureEvent(fromPage: string, currentPage: string, path: string): Promise<void> {
    let params: LoadFailureEventParam = {
      PACKAGE_NAME: HiSysEventUtil.getPkgName(),
      PROCESS_NAME: HiSysEventUtil.getProcessName(),
      PAGE_NAME: currentPage,
      FROM_PAGE: fromPage,
      PATH: path,
    }
    HiSysEventUtil.reportFaultEvent(
      SettingsPerformanceDfx.PAGE_LOAD_FAILURE_EVENT,
      params,
      SettingsPerformanceDfx.PAGE_LOAD_FAILURE_EVENT);
  }

  dumpPageTransitionTime(pageName: string): void {
    let delay = Date.now() - this.startPageTime;
    // write hiSysEvent for page failure.
    this.reportPageTransitionTimeEvent(this.lastPageName, pageName, delay);
  }

  reportLoadFailureEvent(pageName: string, pagePath: string): void {
    this.reportPageLoadFailureEvent(this.lastPageName, pageName, pagePath);
  }

  public static getInstance(): SettingsPerformanceDfx {
    if (SettingsPerformanceDfx.instance === null) {
      SettingsPerformanceDfx.instance = new SettingsPerformanceDfx();
    }
    return SettingsPerformanceDfx.instance;
  }
}