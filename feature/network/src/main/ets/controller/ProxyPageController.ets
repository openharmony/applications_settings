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
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { Constants } from '../constant/Constants';
import { URL_NETWORK_PROXY_DIALOG_PAGE } from '../ProxyDialogPage';
import { ProxySettingController } from './ProxySettingController';

const TAG: string = 'ProxyPageController:';

/**
 * 网络页面控制器类
 */
export class ProxyPageController implements ComponentControl {
  private settingPageModel?: SettingPageModel;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.settingPageModel = compParam.component as SettingPageModel;
    this.addProxyGroup();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  addProxyGroup(): void {
    // 使用代理服务器
    let model: SettingGroupModel = {
      id: 'pc_proxy_settings_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      header: { id: 'pc_manual_set_proxy', content: $r('app.string.set_proxy_manual_title') },
      items: [
        {
          id: 'pc_proxy_settings',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.use_proxy_server_title')
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_MODAL,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            iconType: SettingIconType.ICON_TYPE_ARROW,
            destination: URL_NETWORK_PROXY_DIALOG_PAGE,
            sheetOptions: {
              backgroundColor: Color.Transparent,
              blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
              height: SheetSize.FIT_CONTENT,
              width: $r('app.float.proxy_dialog_with'),
              preferType: SheetType.CENTER,
              dragBar: false,
              onWillDismiss: () => {
                LogUtil.info(`${TAG} onWillDismiss.`);
                EventBus.getInstance().emit(Constants.PROXY_DIALOG_DISMISS_EVENT);
              }
            },
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: { content: '' },
          },
          compControl: new ProxySettingController(),
        },
      ],
    };
    this.settingPageModel?.groups?.push(model);
  }
}
