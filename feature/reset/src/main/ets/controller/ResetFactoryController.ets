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

import common from '@ohos.app.ability.common';
import settings from '@ohos.settings';
import distributedAccount from '@ohos.account.distributedAccount';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import {
  DialogMessageContainerStyle,
  PageTitleTextStyle,
  DialogMessageMenu,
  DialogPage,
  DialogTitleMenu,
  TransparentButtonMenu,
  ResetFactoryDialogButtonMenuStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  PageHeaderStyle,
  ContainerStyle,
  Style
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { HiSysRelocateEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResetFactoryManager } from './ResetFactoryManager';
import { AppUtils } from '../../../../../application/src/main/ets/AppUtils';
import { ResetExtraParams } from '../model/SettingsRestoreModel';

/* instrument ignore file */
const TAG: string = 'ResetFactoryController : ';
const HAS_HWBACKUP_RECORD: string = 'has_hwbackup_record';
const BUNDLE_NAME: string = 'com.ohos.findservice';

export const EVENT_COMMIT_TEXT: number = 335336;

/**
 * 恢复出厂的通用逻辑
 *
 * @since 2022-10-13
 */
@Observed
export class ResetFactoryController extends ButtonMenuController {
  private timer: number | undefined = undefined;

  static CreateResetFactoryController(menu: SettingsBaseMenu): Controller {
    return new ResetFactoryController(menu);
  }

  private resetFactory(isResetAll: boolean = false): void {
    distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo().then((data) => {
      LogUtil.info(`${TAG} user no login`);
      ResetFactoryManager.getInstance()
        .LogoutAndReset(AbilityContextManager.getContext() as common.UIAbilityContext, isResetAll);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get osAccount info failed: ${error.message}`);
    });
  }

  private openBackUpAleartDialog(isResetAll: boolean): void {
    let detail = new DialogPage({});
    detail.addMenus([
      new DialogTitleMenu(
        {
          key: 'reset_factory_dialog_title',
          style: new ResetFactoryDialogTitleStyle(),
          index: 1, // 页面显示顺序
          title: DeviceUtil.isDevicePhone() ? $r('app.string.reset_factory_dialog_title')
            : $r('app.string.reset_factory_dialog_title_pc'),
        }
      ),
      new DialogMessageMenu(
        {
          key: 'reset_factory_dialog_content',
          style: new ResetFactoryDialogMessageStyle(),
          index: 10, // 页面显示顺序
          title: $r('app.string.reset_factory_dialog_content'),
        }

      ),
    ]);
    if (isResetAll) {
      detail.addMenus([
        new TransparentButtonMenu(
          {
            key: 'reset_factory_dialog_button',
            timestamp: Math.random(),
            index: 101, // 页面显示顺序
            buttonTittle2: ResourceUtil.getPluralStringValueSync($r('app.plural.dialog_ok_countdown'), 5),
            buttonTittle3: $r('app.string.button_tittle_cancel'),
            style: new ResetFactoryDialogButtonMenuStyle(),
            controller: {
              createControllerConstructorInter: ResetFactoryDialogButtonController
                .CreateResetFactoryDialogButtonController,
            },
          }
        ),
      ]);
    } else {
      detail.addMenus([
        new TransparentButtonMenu(
          {
            key: 'reset_factory_dialog_button',
            timestamp: Math.random(),
            index: 101, // 页面显示顺序
            buttonTittle1: ResourceUtil.getPluralStringValueSync($r('app.plural.dialog_ok_countdown'), 5),
            buttonTittle3: $r('app.string.button_tittle_cancel'),
            style: new ResetFactoryDialogButtonMenuStyle(),
            controller: {
              createControllerConstructorInter: ResetFactoryDialogButtonController
                .CreateResetFactoryDialogButtonController,
            },
          }
        ),
      ]);
    }
    this.openDialog(detail, true);
    let i: number = 4;
    this.timer = setInterval(() => {
      let eventDataObj: emitter.EventData = {
        data: {
          buttonTittle1: i === 0 ? ResourceUtil.getStringSync($r('app.string.ok')) :
            ResourceUtil.getPluralStringValueSync($r('app.plural.dialog_ok_countdown'), i),
          isEnabled: i === 0
        }
      };
      let event: emitter.InnerEvent = {
        eventId: EVENT_COMMIT_TEXT,
        priority: emitter.EventPriority.HIGH
      };
      if (i >= 0) {
        emitter.emit(event, eventDataObj);
      }
      if (i === 0 && this.timer) {
        LogUtil.info(`${TAG} The countdown is over, clear timer: ${this.timer}`);
        clearInterval(this.timer);
      }
      i--;
    }, 1000);
  }

  aboutToAppear() {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (this.timer) {
      LogUtil.warn(`${TAG} aboutToAppear, clear timer: ${this.timer}`);
      clearInterval(this.timer);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.timer) {
      LogUtil.warn(`${TAG} aboutToDisappear, clear timer: ${this.timer}`);
      clearInterval(this.timer);
    }
  }

  onButton1Click(): void {
    LogUtil.info(`${TAG} start factory reset all`);
    this.handleResetFactoryDevice(true);
  }

  onButton2Click(): void {
    LogUtil.info(`${TAG} start factory reset retain eSIM`);
    AlertDialog.show(
      {
        title: $r('app.string.note'),
        message: $r('app.string.reset_factory_dialog_retain_esim_content'),
        primaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.dialog_cancel')),
          fontColor: $r('sys.color.ohos_id_color_emphasize'),
          action: () => {
            LogUtil.info(`${TAG} cancel`);
          }
        },
        secondaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.reset_factory_dialog_continue_reset_button')),
          fontColor: $r('sys.color.ohos_id_color_warning'),
          action: () => {
            LogUtil.info(`${TAG} continue resetting`);
            this.handleResetFactoryDevice();
          }
        },
        cancel: () => {
          LogUtil.info(`${TAG} cancel`);
        }
      }
    )
  }

  onButton3Click() {
    LogUtil.info(`${TAG} start factory reset`);
    this.handleResetFactoryDevice();
  }

  handleResetFactoryDevice(isResetAll: boolean = false): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysRelocateEventGroup.ENTER_RESET_PHONE_CONFIRM);
    if (DeviceUtil.isDeviceEmulator()) {
      this.resetFactory(isResetAll);
      return;
    }
    if (DeviceUtil.isDevicePc()) {
      // 在bundleInfo存在的情况才去执行查找设备
      let bundleInfo: boolean = AppUtils.isBundleExist(BUNDLE_NAME);
      if (bundleInfo) {
        let pathInfoStack: NavPathStack | undefined =
          AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
        DynamicLoader.getInstance().fire(NavEntryKey.START_FIND_DEVICE_ENTRY).then(() => {
          pathInfoStack?.pushPathByName(NavEntryKey.START_FIND_DEVICE_ENTRY, undefined);
        });
      } else {
        this.resetFactory(isResetAll);
      }
    } else {
      // 判断为手机设备时直接恢复出厂设置
      LogUtil.info(`${TAG} directly call factory reset for phone device`);
      ResetFactoryManager.getInstance().safeFactoryReset();
    }
  }
}

export class ResetFactoryDialogButtonController extends ButtonMenuController {
  private isEnabled: boolean = false;

  static CreateResetFactoryDialogButtonController(menu: SettingsBaseMenu): Controller {
    return new ResetFactoryDialogButtonController(menu);
  }

  public tag: string = 'ResetFactoryDialogButtonController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  aboutToAppear() {
    LogUtil.info(`${this.tag} aboutToAppear`);
    emitter.on({ eventId: EVENT_COMMIT_TEXT }, (data) => {
      if (this.menu instanceof TransparentButtonMenu) {
        LogUtil.info(`${this.tag} received event: EVENT_COMMIT_TEXT, refresh button title: ${data?.data?.buttonTittle1}`);
        let transparentButtonMenu: TransparentButtonMenu = this.menu;
        this.isEnabled = data?.data?.isEnabled;
        transparentButtonMenu.buttonTittle1 = data?.data?.buttonTittle1;
        this.refreshUi();
      }
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    emitter.off(EVENT_COMMIT_TEXT);
  }

  isButton1Enabled(): boolean {
    return this.isEnabled;
  }

  async onButton1Click(): Promise<void> {
    LogUtil.info(`${this.tag} onButton1Click`);
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    DynamicLoader.getInstance().fire(NavEntryKey.START_WALLET_ENTRY).then(() => {
      pathInfoStack?.pushPathByName(NavEntryKey.START_WALLET_ENTRY, undefined);
    });
    this.closeSelf();
  }

  async onButton2Click(): Promise<void> {
    LogUtil.info(`${this.tag} onButton2Click`);
    const params: ResetExtraParams = { isResetAll: true };
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    DynamicLoader.getInstance().fire(NavEntryKey.START_WALLET_ENTRY).then(() => {
      pathInfoStack?.pushPathByName(NavEntryKey.START_WALLET_ENTRY, new PushParam(params));
    });
    this.closeSelf();
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click`);
    this.closeSelf();
  }
}

class ResetFactoryDialogTitleContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_56'),
  };
  public padding: Padding = {
    top: $r('app.float.length_14'),
    bottom: $r('app.float.length_14'),
    right: '24vp',
    left: '24vp',
  };
}

class ResetFactoryDialogTitleStyle extends PageHeaderStyle {
  public rootContainer?: ContainerStyle = new ResetFactoryDialogTitleContainerStyle();
  public title?: TextStyle = new ResetFactoryDialogTitleTextStyle();
}

class ResetFactoryDialogTitleTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: '20fp',
    weight: FontWeight.Bold,
    family: 'HarmonyHeiTi',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '27vp'
  };
  public borderRadius = $r('sys.float.ohos_id_corner_radius_dialog');
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
  public maxLines: number = 10;
}

class ResetFactoryDialogMessageContainerStyle extends DialogMessageContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
    right: $r('sys.float.ohos_id_default_padding_bottom_flexible'),
  };
}

class ResetFactoryDialogMessageStyle implements Style {
  public rootContainer?: ContainerStyle = new ResetFactoryDialogMessageContainerStyle();
  public title?: TextStyle = new ResetFactoryDialogMessageTextStyle();
}

class ResetFactoryDialogMessageTextStyle extends PageTitleTextStyle {
  public font: Font = {
    size: '16fp',
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
  };
  public fontColor = $r('sys.color.ohos_id_color_text_primary');
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '21vp'
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}