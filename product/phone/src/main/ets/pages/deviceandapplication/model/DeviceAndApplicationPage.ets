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

import { CardMenuSection, NavigationEntry } from '@ohos/settings.uikit';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil, SettingsBaseMenu } from '@ohos/settings.common';
import settings from '@ohos.settings';
import bundleManager from '@ohos.bundle.bundleManager';
import { PageUrl } from '../../PageUrl';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

const COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY: string = 'com.enterprise.enterprise_device_manager_display';
const TAG: string = 'DeviceAndApplicationPage : ';

/*
 * 企业设备和应用管理菜单数据
 *
 * @since 2024-03-23
 */
export class DeviceAndApplicationPage extends SettingHeaderPage {
  private context: Context = AppStorage.get<Context>('pageContext') as Context;

  constructor(params: PushParam) {
    super({
      pageUrl: PageUrl.DEVICE_AND_APPLICATION_PAGE_URL,
      title: $r('app.string.enterprise_device_and_application_management'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      ...this.getEnterpriseDeviceMenu(),
      ...this.getEnterpriseApplicationMenu()
    ]);
  }

  private getEnterpriseDeviceMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    let deviceManagerDisplay: string = 'false';
    try {
      deviceManagerDisplay = settings.getValueSync(this.context,
        COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY, 'false');
    } catch (e) {
      LogUtil.error(`${TAG} settings getValueSync err`);
    }
    if (deviceManagerDisplay === 'true') {
      result.push(
        new CardMenuSection(
          {
            key: 'device_management_group',
            index: 10,
          },
          [
            new NavigationEntry(
              {
                key: 'enterprise_device_management_settings',
                index: 10,
                title: $r('app.string.enterprise_device_management'),
                stateIcon: $r('app.media.ic_settings_arrow'),
                targetPageUrl: PageUrl.ENTERPRISE_DEVICE_MANAGEMENT_PAGE_URL,
              }
            )
          ]
        ),
      )
    }
    return result;
  }

  private getDeveloperInfoArray(): boolean {
    try {
      return bundleManager.getDeveloperIds(bundleManager.AppDistributionType.ENTERPRISE).length !== 0;
    } catch (err) {
      LogUtil.error(`${TAG} bundleManager.getDeveloperIds fail: ${err.message}`);
      return false;
    }
  }

  private getEnterpriseApplicationMenu(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    if (this.getDeveloperInfoArray()) {
      result.push(
        new CardMenuSection(
          {
            key: 'enterprise_application_management_group',
            index: 10,
          },
          [
            new NavigationEntry(
              {
                key: 'enterprise_application_management_settings',
                index: 10,
                title: $r('app.string.enterprise_application_management'),
                stateIcon: $r('app.media.ic_settings_arrow'),
                targetPageUrl: PageUrl.ENTERPRISE_APPLICATION_MANAGEMENT_PAGE_URL,
              }
            )
          ]
        ),
      )
    }
    return result;
  }
}