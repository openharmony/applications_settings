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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ComponentControl,
  CompCtrlParam,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType, SettingItemModel, } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AppListInfo } from '../model/SettingAppItemModel';
import { DefaultBrowserUtil } from '../util/DefaultBrowserUtil';
/* instrument ignore file */
const TAG = 'BrowserRadioController: ';

/*
 * 默认浏览器单选框controller
 */
export class BrowserRadioController implements ComponentControl {
  private checkedBrowserInfo?: AppListInfo;
  private checkedCompId: string = '';

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.checkedCompId = param.compId;
  }

  onPageShow(component: SettingBaseModel): void {
  }

  onPageHide(component: SettingBaseModel): void {
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  public initValue(groupId: string, browserInfo: AppListInfo): void {
    LogUtil.info(`${TAG} constructor, ${groupId}, ${browserInfo.bundleName}`);
    this.checkedBrowserInfo = browserInfo;
    this.checkedCompId = `${groupId}.${browserInfo.bundleName}`;
    this.setItemChecked(`${this.checkedCompId}`, true);
  }

  /*
   * 组件事件响应 (用户主动触发 视图已经修改 无需refreshUi)
   */
  public onItemClick(groupId: string, browserInfo: AppListInfo): void {
    LogUtil.info(`${TAG} onItemClick, ${groupId}, ${browserInfo.bundleName}`);
    let changeCompId = `${groupId}.${browserInfo.bundleName}`;
    if (browserInfo.bundleName === 'com.ohos.browser') {
      this.setChecked(changeCompId, browserInfo);
    } else {
      this.openChangeBrowserDialog(changeCompId, browserInfo);
    }
  }

  private setChecked(itemId: string, browserInfo: AppListInfo): void {
    this.setItemChecked(itemId, true);
    this.onRadioChecked(browserInfo, true);
    // 将原先选中的取消掉
    if (this.checkedBrowserInfo?.bundleName !== browserInfo.bundleName) {
      LogUtil.info(`${TAG} onChange, set ${this.checkedCompId} checked false`);
      this.setItemChecked(this.checkedCompId, false);
    }
    this.checkedCompId = itemId;
  }

  private openChangeBrowserDialog(compId: string, browserInfo: AppListInfo): void {
    notifyCompStateChange(`${compId}`,
      new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {
          title: $r('app.string.confirm_replacement'),
          message: $r('app.string.confirm_replacement_content'),
          buttons: [
            {
              value: $r('app.string.button_tittle_cancel'),
              action: (component: SettingItemModel) => {
              },
              style: {
                buttonStyle: ButtonStyleMode.TEXTUAL,
              }
            },
            {
              value: $r('app.string.app_info_replace'),
              action: (component: SettingItemModel) => {
                this.setChecked(compId, browserInfo);
              },
              style: {
                buttonStyle: ButtonStyleMode.TEXTUAL,
              }
            }
          ],
          buttonVertical: true
        } as SettingDialogState]]));
  }

  private async onRadioChecked(browserInfo: AppListInfo, isCheck: boolean): Promise<void> {
    let bundleName: string = browserInfo.bundleName as string;
    let name: string = browserInfo.name as string;
    let moduleName: string = browserInfo.moduleName as string;
    LogUtil.info(`${TAG} onItemClick ${bundleName} | ${name} | ${moduleName} | ${isCheck}`);
    await DefaultBrowserUtil.setDefaultBrowser(bundleName, name, moduleName);
    this.checkedBrowserInfo = browserInfo;
    EventBus.getInstance().emit('DEFAULT_BROWSER_APP_SELECT', bundleName);
    // 上报设置的默认浏览器事件及对应包名
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.SET_DEFAULT_BROWSER,
      bundleName);
  }

  private setItemChecked(compId: string, checked: boolean): void {
    LogUtil.info(`${TAG} refreshUi, compId:${compId} checked:${checked}`);
    const result: SettingResultState = { type: ItemResultType.RESULT_TYPE_RADIO, result: { checked } };
    notifyCompStateChange(compId, new Map<SettingStateType, SettingResultState>([
      [SettingStateType.STATE_TYPE_ITEM_RESULT, result],
    ]));
  }
}