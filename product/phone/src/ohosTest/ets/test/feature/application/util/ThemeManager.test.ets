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

import { describe, expect, it } from '@ohos/hypium';
import { ThemeManager } from '@ohos/settings.application';
import commonEventManager from '@ohos.commonEventManager';
import { AsyncCallback } from '@ohos.base';

export enum PageList {
  APP_LIST_PAGE = 'APP_LIST',
  BATTERY_PAGE = 'POWER_CONSUMPTIONS_APP_LIST',
  MORE_APP_LIST_PAGE = 'MORE_APP_LIST'
}

export default function ThemeManagerTest() {
  describe('ThemeManagerTest', (): void => {
    let themeManager = new ThemeManager();
    it('ThemeManagerTest_001', 0, (done: Function) => {
      try {
        let result = themeManager.finishedRefreshAppList();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_002', 0, (done: Function) => {
      try {
        let result = themeManager.checkIsOnlineIcon();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_003', 0, (done: Function) => {
      try {
        let result = themeManager.checkIsNeedToRefresh(PageList.APP_LIST_PAGE);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_004', 0, (done: Function) => {
      try {
        let params: commonEventManager.CommonEventSubscriber = {
          getCode: (callback: AsyncCallback<number, void>): void => {
          },
        } as commonEventManager.CommonEventSubscriber;
        (themeManager as object)['subscriber'] = params;
        let result = themeManager.subscribeThemeEvent();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_005', 0, (done: Function) => {
      try {
        let params: commonEventManager.CommonEventSubscriber =
          AppStorage.get('params') as commonEventManager.CommonEventSubscriber;
        (themeManager as object)['subscriber'] = params;
        let result = themeManager.unsubscribeThemeEvent();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_006', 0, (done: Function) => {
      try {
        let result = ThemeManager.getInstance();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('ThemeManagerTest_007', 0, (done: Function) => {
      try {
        let themeManagerInstance = new ThemeManager();
        (themeManagerInstance as object)['themeEventCallback'](() => {
        });
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

