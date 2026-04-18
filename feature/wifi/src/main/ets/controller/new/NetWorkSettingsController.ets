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
import window from '@ohos.window';
import Display from '@ohos.display';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingSheetPageContext } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { PageContext, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingContentState,
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { URL_ADD_OTHER_WLAN_SHEET_PAGE } from '../../AddOtherWlanSheetPage';
import { OPEN_NET_WORK_SHEET_ID } from '../../model/WifiModel';
import { WifiUtils } from '../../WifiUtils';

const WLAN_CLOSE_SHEET_HEIGHT: number = 176;

const EDIT_SHEET_ID: string = 'OpenNetWorkSetting.Wlan.EditSheetConfig.EditSheet';

export function notifyNetWorkSettingsSheetHeightChange(isWifiActive: boolean,
  isCurrentInSheetHomePage?: boolean): void {
  if (DeviceUtil.isDevicePc()) {
    notifyCompStateChange(EDIT_SHEET_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: true,
          sheetHeight: isWifiActive ? 560 : 320,
        } as SettingModalState]]
      ));
    return;
  }
  const session = LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
  let navigationIndicatorHeight: number = 0;
  if (session) {
    let navigationIndicatorArea: window.AvoidArea =
      session.getUIExtensionWindowProxy().getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    navigationIndicatorHeight = navigationIndicatorArea.bottomRect.height;
  }
  let isExtraLargeFontMode: boolean = FontScaleUtils.isExtraLargeFontMode();
  let sheetDetents: [(SheetSize | Length), (SheetSize | Length)?, (SheetSize | Length)?] | undefined =
    isWifiActive ? [SheetSize.MEDIUM] : undefined;
  let sheetHeight: SheetSize | Length | undefined = isWifiActive ?
    SheetSize.MEDIUM : (WLAN_CLOSE_SHEET_HEIGHT + px2vp(navigationIndicatorHeight));
  if (isExtraLargeFontMode) {
    sheetDetents = isWifiActive ? [SheetSize.LARGE] : [SheetSize.MEDIUM];
    sheetHeight = isWifiActive ? SheetSize.LARGE : SheetSize.MEDIUM;
  }
  notifyCompStateChange(EDIT_SHEET_ID,
    new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
      {
        state: true,
        sheetDetents: sheetDetents,
        sheetHeight: sheetHeight
      } as SettingModalState]]
    ));
}

export class NetWorkSettingsController implements ComponentControl {
  public tag: string = 'NetWorkSettingsController: ';
  private sheetPageCtx?: SettingSheetPageContext;
  private onFoldChangeCallBack = (status: number) => {
    this.handleFoldStateChange(status);
  };
  private onAddOtherWlanButtonClickedCallBack = () => {
    LogUtil.info(`${this.tag} add other wlan clicked.`);
    if (!this.sheetPageCtx) {
      return;
    }
    let pageCtx = ModalLoader.getPageContext(URL_ADD_OTHER_WLAN_SHEET_PAGE);
    if (!pageCtx.isPresent()) {
      LogUtil.error(`${this.tag} jump modal page failed.`);
      return;
    }
    PasswordUtil.setPrivacyMode(true);
    this.sheetPageCtx.pathStack?.pushPathByName(URL_ADD_OTHER_WLAN_SHEET_PAGE,
      this.buildPageParam(URL_ADD_OTHER_WLAN_SHEET_PAGE, pageCtx.get()));
    notifyCompStateChange(OPEN_NET_WORK_SHEET_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: true,
          sheetDetents: [SheetSize.LARGE],
        } as SettingModalState]]
      ));
  };

  private onNetWorkSettingsConnectSuccessCallBack = () => {
    LogUtil.info(`${this.tag} connect success.`);
    notifyNetWorkSettingsSheetHeightChange(true, true);
    PasswordUtil.setPrivacyMode(false);
    this.sheetPageCtx?.pathStack?.pop();
    // 通知列表滚动到顶部
    notifyCompStateChange('OpenNetWorkSetting.NetworkSetting',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP,
        { content: '' } as SettingContentState]]));
  };

  private buildPageParam(pageUrl: string, pageCtx: PageContext): PageParams {
    return {
      router: PageRouter.getRouterName(),
      pageUrl: pageUrl,
      pageCtx: {
        configGenerator: pageCtx.configGenerator,
        pageBuilder: pageCtx.pageBuilder
      },
      param: this.sheetPageCtx,
    }
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!compParam || !compParam.param) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} init compId: ${compParam.compId}`);
    this.sheetPageCtx = compParam?.param as SettingSheetPageContext;
    EventBus.getInstance().on('NetWorkSettingsAddOtherWlan', this.onAddOtherWlanButtonClickedCallBack);
    EventBus.getInstance().on('NetWorkSettingsConnectSuccess', this.onNetWorkSettingsConnectSuccessCallBack);
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.registerFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach('NetWorkSettingsAddOtherWlan', this.onAddOtherWlanButtonClickedCallBack);
    EventBus.getInstance().detach('NetWorkSettingsConnectSuccess', this.onNetWorkSettingsConnectSuccessCallBack);
    if (DeviceUtil.isFoldable()) {
      DisplayUtils.unRegisterFoldStatusChange(this.onFoldChangeCallBack);
    }
  }

  private isCurrentInSheetHomePage(): boolean {
    let isCurrentInSheetHomePage: boolean = this.sheetPageCtx?.pathStack?.size() === 0;
    LogUtil.info(`${this.tag} isCurrentInSheetHomePage: ${isCurrentInSheetHomePage}`);
    // 判断当前是否处于半模态首页
    return isCurrentInSheetHomePage;
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.info(`${this.tag} on fold status changed: ${status}`);
    if (this.isCurrentInSheetHomePage()) {
      // 前台界面是半模态首面、折叠展开的时候，高度需要动态变化
      notifyNetWorkSettingsSheetHeightChange(WifiUtils.isWifiActive(), true);
    }
  }
}
