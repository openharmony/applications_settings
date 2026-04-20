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

import bundle from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import emitter from '@ohos.events.emitter';
import { BrowserListPro } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import bundleManager from '@ohos.bundle.bundleManager'
import cardEmulation from '@ohos.nfc.cardEmulation';
import { SettingDefaultNFCController } from './settingDefaultNFCController';
import { IconRadioMenu, NewDefaultRadioMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { EVENT_ID_NFC_SWITCH_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
/* instrument ignore file */
const NFC_LIST_CHANGE: number = 20231220;

export class DefaultPaymentMenuStyle extends NewDefaultRadioMenuStyle {
  public borderRadius: Resource = $r('sys.float.ohos_id_corner_radius_card');
  public margin: Margin = {
    left: '4vp',
    right: '4vp'
  }
}

let defaultPaymentMenuStyle = new DefaultPaymentMenuStyle();

export class DefaultPaymentController extends MenuGroupController {
  public tag: string = 'DefaultPaymentController : ';
  public browserList: bundle.AbilityInfo[] | null = null;
  public pageContext: Context = AbilityContextManager.getContext();

  static CreateDefaultPaymentController(menu: SettingsBaseMenu): Controller {
    return new DefaultPaymentController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    emitter.on({
      eventId: EVENT_ID_NFC_SWITCH_CHANGE,
    }, (eventData: emitter.EventData) => {
      this.menu.enable = eventData?.data?.defaultAppState
      if (this.menu.enable) {
        this.getNfcList().then((nfcListPro) => {
          this.setNFCList(nfcListPro);
        });
      }
      this.refreshUi()
    });
    emitter.on({
      eventId: NFC_LIST_CHANGE,
    }, (eventData: emitter.EventData) => {
      if (this.menu.enable) {
        this.getNfcList().then((nfcListPro) => {
          this.setNFCList(nfcListPro);
        });
        this.refreshUi()
      }
    });
  }

  aboutToDisappear(): void {
    emitter.off(EVENT_ID_NFC_SWITCH_CHANGE);
    emitter.off(NFC_LIST_CHANGE);
  }

  private setNFCList(nfcList: BrowserListPro[]) {
    let menus: SettingsBaseMenu[] = [];
    Promise.all(nfcList.map(nfc => nfc.label)).then((values) => {
      if (values.length) {
        values.forEach((item, index) => {
          const menuList: IconRadioMenu = new IconRadioMenu({
            key: `nfc_list_${nfcList[index].bundleName}_${nfcList[index].labelId}`,
            index: 21,
            title: item,
            icon: nfcList[index].icon,
            style: defaultPaymentMenuStyle,
            controller: {
              createControllerConstructorInter: SettingDefaultNFCController.CreateSettingDefaultNFCController,
            },
            extra: {
              name: item,
              value: `${nfcList[index].bundleName}/${nfcList[index].name}`,
              currentSelectedVal: nfcList[index].labelId,
            }
          });
          menus.push(menuList);
        })
      } else {
        this.menu.state = $r('app.string.not_set')
      };
      if (!menus.length) {
        return;
      }
      this.clearChildren();
      this.addChildren(menus);
      this.refreshUi();
    });
  }

  public async getNfcList(): Promise<BrowserListPro[]> {
    let nfcListPro: BrowserListPro[] = [];
    let nfcList: bundleManager.AbilityInfo[] = [];
    try {
      nfcList = cardEmulation.getPaymentServices();
    } catch (error) {
      LogUtil.error(`${this.tag} getPaymentServices catch error, message:${error?.message}`);
    }
    LogUtil.info(`${this.tag} nfclist.length:${nfcList.length}`);
    nfcList.forEach((nfcListItem: bundleManager.AbilityInfo, index) => {
      LogUtil.info(`${this.tag} nfcListItem name:${nfcListItem.name} bundleName:${nfcListItem.bundleName}`);
      try {
        const resourceManager = ResourceManagerUtil.getBundleResourceManager(nfcListItem?.bundleName);
        if (!resourceManager) {
          LogUtil.info(`${this.tag} resourceManager is null`);
          return;
        }
        const iconDescriptor: DrawableDescriptor = resourceManager.getDrawableDescriptor(nfcListItem?.iconId, 0, 1);
        nfcListPro.push({
          labelId: nfcListItem?.labelId as number,
          label: resourceManager.getStringValue(nfcListItem?.labelId),
          icon: iconDescriptor?.getPixelMap(),
          bundleName: nfcListItem?.bundleName,
          name: nfcListItem?.name,
        });
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      } catch (error) {
        LogUtil.error(`${this.tag} push nfcListItem catch error, message:${error?.message}`);
      }
    });
    LogUtil.info(`${this.tag} nfclistPro.length:${nfcListPro.length}`);
    return nfcListPro;
  }

  onAppListChanged(appList: Array<AppEntry>): void {
    LogUtil.info(`${this.tag} onAppListChanged`);
  }

  onAppUpdate(appEntry: AppEntry): void {
    LogUtil.info(`${this.tag} onAppUpdate`);

  }

  onAppRemove(bundleName: string): void {
    LogUtil.info(`${this.tag} onAppRemove ${bundleName}`);

  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow `);
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide `);
  }
}





