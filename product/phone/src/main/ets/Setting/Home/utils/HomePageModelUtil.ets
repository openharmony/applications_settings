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

import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { BluetoothController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothController';
import lazy { PageRouteController } from '../../../pages/home/controller/PageRouteController';
import { WlanController } from '../../Wlan/controller/WlanController';
import { HomePageMenuManager } from '../controller/HomePageMenuManager';
import { VolumeController } from '../../Volume/controller/VolumeController';

/* instrument ignore file */
const TAG: string = 'HomePageModelUtil:';

export async function importPage(navEntryKey: string, touchType: TouchType) {
  if (touchType === TouchType.Down) {
    let isHomePageScrolling: boolean | undefined = AppStorage.get<boolean>('scrollingState');
    if (!isHomePageScrolling) {
      // 相对路径层级变深一级需要往上一级
      let pageUrl: string = '../' + PageRouteController.getInstance().getPageUrl(navEntryKey) as string;
      console.log('zzzzzzz ' + pageUrl)
      await import(pageUrl);
      console.log('zzzzzzz ok ' + pageUrl)
    }
  }
}

export class HomePageModelUtil {
  public static getIntelligentItem(): SettingItemModel {
    return {
      id: NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.intelligent_scene')},
      title: {content: $r('app.string.intelligent_scene_settings')},
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY,
      },
      needHide: () => {
        LogUtil.showInfo(TAG, `isMainAccount:${homeInitData.isMainAccount}`);
        let isMainAccount: boolean | undefined = homeInitData.isMainAccount;
        if (isMainAccount === undefined) {
          isMainAccount = true;
        }
        return !CapabilitySupportUtils.isSupportIntelligentScene() || !isMainAccount;
      },
    }
  }

  public static getWlanItem(): SettingItemModel {
    return {
      id: NavEntryKey.WIFI_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_wlan') },
      title: { content: $r('app.string.wifi_settings_title') },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.WIFI_ENTRY,
      },
      compControl: new WlanController(),
      onTouchEvent: async (touchType: TouchType) => {
        await importPage(NavEntryKey.WIFI_ENTRY, touchType);
      }
    };
  }

  public static getBluetoothItem(): SettingItemModel {
    return {
      id: NavEntryKey.BLUETOOTH_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: CapabilitySupportUtils.isSupportFusion() && CapabilitySupportUtils.isSupportNearLink() ?
        $r('app.media.ic_fusion_ble_nearlink') :
        $r('app.media.ic_settings_bluetooth'),
        style: { mirrored: false }
      },
      title: {
        content: CapabilitySupportUtils.isSupportFusion() && CapabilitySupportUtils.isSupportNearLink() ?
        $r('app.string.nearlink_and_bluetooth') :
        $r('app.string.bluetooth_settings_title')
      },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.BLUETOOTH_ENTRY,
      },
      compControl: new BluetoothController(),
      needHide: HomePageMenuManager.getInstance().isEntryNotSupported,
    };
  }

  public static getMobileItem(): SettingItemModel {
    return {
      id: NavEntryKey.MOBILE_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_mobile_network') },
      title: { content: $r('app.string.mobile_network_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.MOBILE_ENTRY,
      },
      needHide: HomePageMenuManager.getInstance().isMobileNetworkPageNotSupport,
    };
  }

  public static getDisplayItem(): SettingItemModel {
    return {
      id: NavEntryKey.DISPLAY_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_display') },
      title: { content: $r('app.string.display_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.DISPLAY_ENTRY,
      },
      onTouchEvent: async (touchType: TouchType) => {
        await importPage(NavEntryKey.DISPLAY_ENTRY, touchType);
      }
    };
  }

  public static getVolumeItem(): SettingItemModel {
    return {
      id: NavEntryKey.VOLUME_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_volume') },
      title: { content: $r('app.string.phone_volume_control_setting_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.VOLUME_ENTRY,
      },
      compControl: new VolumeController(),
    };
  }


  public static getUpdateItem(): SettingItemModel {
    return {
      id: NavEntryKey.SYSTEM_UPDATE_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_system') },
      title: { content: $r('app.string.system_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.SYSTEM_UPDATE_ENTRY,
      },
    };
  }

  public static getPrinterItem(): SettingItemModel {
    return {
      id: NavEntryKey.PAD_PRINTER_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.Settings_printer') },
      title: { content: $r('app.string.print_scan_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PAD_PRINTER_SETTINGS_ENTRY,
      },
      needHide: DeviceUtil.isDevicePhone
    };
  }

  public static getPadTouchItem(): SettingItemModel {
    return {
      id: NavEntryKey.PAD_TOUCHPAD_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_touchpad') },
      title: { content: $r('app.string.touchpad') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PAD_TOUCHPAD_SETTINGS_ENTRY,
      },
      needHide: HomePageMenuManager.getInstance().isTouchpadNotSupport
    };
  }

  public static getKeyboardItem(): SettingItemModel {
    return {
      id: NavEntryKey.PAD_KEYBOARD_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_keyboard') },
      title: { content: $r('app.string.keyboard') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PAD_KEYBOARD_SETTINGS_ENTRY,
      },
      needHide: DeviceUtil.isDevicePhone,
    };
  }

  public static getMouseItem(): SettingItemModel {
    return {
      id: NavEntryKey.PHONE_MOUSE_SETTINGS,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_mouse') },
      title: { content: $r('app.string.mouse_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PHONE_MOUSE_SETTINGS,
      },
      needHide: DeviceUtil.isDevicePhone,
    };
  }

  public static getHiWriteItem(): SettingItemModel {
    return {
      id: NavEntryKey.HI_WRITE_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_pen') },
      title: { content: $r('app.string.hi_write_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.HI_WRITE_SETTINGS_ENTRY,
      },
      needHide: HomePageMenuManager.getInstance().isHiWriteNotSupport,
    };
  }

  public static getPrivacyItem(): SettingItemModel {
    return {
      id: NavEntryKey.PRIVACY_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_privacy') },
      title: { content: $r('app.string.privacy_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PRIVACY_ENTRY,
      },
      needHide: HomePageMenuManager.getInstance().isEntryNotSupported,
    }
  }

  public static getBiometricsItem(): SettingItemModel {
    return {
      id: NavEntryKey.BIOMETRICS_PASSWORD_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_biometrics_password') },
      title: { content: $r('app.string.biometrics_and_password_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.BIOMETRICS_PASSWORD_ENTRY,
      },
    };
  }

  public static getBatteryItem(): SettingItemModel {
    return {
      id: NavEntryKey.BATTERY_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_battery') },
      title: { content: $r('app.string.power_usage_summary_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.BATTERY_ENTRY,
      },
      onTouchEvent: async (touchType: TouchType) => {
        await importPage(NavEntryKey.BATTERY_ENTRY, touchType);
      }
    };
  }

  public static getStorageItem(): SettingItemModel {
    return {
      id: NavEntryKey.STORAGE_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_storage'), style: { mirrored: false } },
      title: { content: $r('app.string.storage_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.STORAGE_ENTRY,
      },
    };
  }

  public static getApplicationItem(): SettingItemModel {
    return {
      id: NavEntryKey.APPLICATION_SERVICE_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_application_and_service') },
      title: { content: $r('app.string.application_and_meta_service_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.APPLICATION_SERVICE_ENTRY,
      },
    };
  }

  public static getNotificationItem(): SettingItemModel {
    return {
      id: NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.notification_icon') },
      title: { content: $r('app.string.systemui_notification_settings') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY,
      },
    };
  }

  public static getThemeItem(): SettingItemModel {
    return {
      id: NavEntryKey.THEME_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_public_themes') },
      title: {
        content: DeviceUtil.isSmallFoldProduct()
          ? $r('app.string.covertheme_settings_title') : $r('app.string.theme_settings_title')
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.THEME_ENTRY,
      },
    };
  }

  public static getMoreConnectionItem(): SettingItemModel {
    return {
      id: NavEntryKey.MORE_CONNECTION_ENTRY,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_settings_multi_device_collaboration_svg') },
      title: { content: $r('app.string.multi_device_collaboration') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.MORE_CONNECTION_ENTRY,
      },
      needHide: HomePageMenuManager.getInstance().isEntryNotSupported,
    };
  }

  public static getNetworkItem(): SettingItemModel {
    return {
      id: NavEntryKey.NETWORK_SETTINGS,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: { icon: $r('app.media.ic_network_icon') },
      title: { content: $r('app.string.network_settings_title') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.NETWORK_SETTINGS,
      },
      needHide: HomePageMenuManager.getInstance().isNetworkPageNotSupport,
    };
  }
}