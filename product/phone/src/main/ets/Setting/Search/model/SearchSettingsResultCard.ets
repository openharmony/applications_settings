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

import uiAppearance from '@ohos.uiAppearance';
import window from '@ohos.window';
import { CircleShape, LengthMetrics } from '@kit.ArkUI';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_4,
  PADDING_60,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CardRadioMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { HmsAccountIconManager } from '@ohos/settings.common/src/main/ets/data/HmsAccountIconManager';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  FIXED_ICON_ENTRY_LIST,
  FIXED_ICON_CALL_SETTINGS
} from '@ohos/settings.common/src/main/ets/constant/SearchConstant';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { RenderItemChildrenInfo, RenderItemInfo } from '@ohos/settings.search/src/main/ets/model/type';
import { SearchCheckUtil } from '@ohos/settings.search/src/main/ets/util/SearchCheckUtil';
import { HiSysSearchEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { PageRouteController } from '../../../pages/home/controller/PageRouteController';
import { CHECK_PASSWORD_ENTRY_FLAG } from '../../../pages/password/controller/PasswordEntryController';
import { CheckPsdParams } from '../../../pages/password/model/CheckPasswordPage';
import { CREATE_PASSWORD_ENTRY_FLAG, CreatePsdParams } from '../../../pages/password/model/CreatePsdPage';
import { AboutDeviceUtils } from '../../AboutDevice/const/AboutDeviceUtils';
import { SearchSettingsController } from '../controller/SearchSettingsController';
/* instrument ignore file */
const TAG: string = 'SearchSettingsResultCard : ';

const ENTRY_ICON_LIST: Map<string, Resource> = new Map<string, Resource>([
  [NavEntryKey.WIFI_ENTRY, $r('app.media.ic_settings_wlan')],
  [NavEntryKey.BLUETOOTH_ENTRY,
    CapabilitySupportUtils.isSupportFusion() && CapabilitySupportUtils.isSupportNearLink() ?
    $r('app.media.ic_fusion_ble_nearlink') : $r('app.media.ic_settings_bluetooth')],
  [NavEntryKey.MOBILE_ENTRY, $r('app.media.ic_settings_mobile_network')],
  [NavEntryKey.MORE_CONNECTION_ENTRY, $r('app.media.ic_settings_multi_device_collaboration_svg')],
  [NavEntryKey.THEME_ENTRY, $r('app.media.ic_public_themes')],
  [NavEntryKey.DISPLAY_ENTRY, $r('app.media.ic_settings_display')],
  [NavEntryKey.VOLUME_ENTRY, $r('app.media.ic_settings_volume')],
  [NavEntryKey.APPLICATION_SERVICE_ENTRY, $r('app.media.ic_settings_application_and_service')],
  [NavEntryKey.STORAGE_ENTRY, $r('app.media.ic_settings_storage')],
  [NavEntryKey.BATTERY_ENTRY, $r('app.media.ic_settings_battery')],
  [NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, $r('app.media.ic_settings_biometrics_password')],
  [NavEntryKey.USERS_ACCOUNT_ENTRY, $r('app.media.ic_users_accounts')],
  [NavEntryKey.SYSTEM_UPDATE_ENTRY, $r('app.media.ic_settings_system')],
  [NavEntryKey.ABOUT_DEVICE_ENTRY, AboutDeviceUtils.getAboutDeviceMenuIcon()],
  [NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY, $r('app.media.notification_icon')],
  [NavEntryKey.PHONE_MOUSE_SETTINGS, $r('app.media.ic_settings_mouse')],
  [NavEntryKey.PAD_KEYBOARD_SETTINGS_ENTRY, $r('app.media.ic_settings_keyboard')],
  [NavEntryKey.PAD_TOUCHPAD_SETTINGS_ENTRY, $r('app.media.ic_settings_touchpad')],
  [NavEntryKey.PAD_PRINTER_SETTINGS_ENTRY, $r('app.media.Settings_printer')],
  [NavEntryKey.HI_WRITE_SETTINGS_ENTRY, $r('app.media.ic_settings_pen')],
  [NavEntryKey.CLOUD_SPACE_ENTRY, $r('app.media.cloud_space')],
  [NavEntryKey.SUBSCRIBE_PAGE_ENTRY, $r('app.media.iap_ic_app_icon')],
  [NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY, $r('app.media.intelligent_scene')],
  [NavEntryKey.NETWORK_SETTINGS, $r('app.media.ic_network_icon')],
  [FIXED_ICON_CALL_SETTINGS, $r('app.media.call_settings')]
]);

const CARD_RADIUS: number = 20;
const TOUCH_DELAY: number = 300;
const appIconShape: CircleShape =
  new CircleShape({width:'32vp', height:'32vp'}).position({x: '0.5vp', y: '0.5vp'});

export class DefaultAncoBadgeStyle {
  public width: number = 12;
  public height: number = 9.6;
  public offsetX: number = -6;
  public offsetY: number = -6;
  public imgWidth: number = 4.8;
  public imgHeight: number = 5.4;
}

@Component
export struct SearchSettingsResultCard {
  scroller: Scroller = new Scroller;
  style?: CardRadioMenuStyle;
  searchController: SearchSettingsController = new SearchSettingsController();
  radius: number = vp2px(CARD_RADIUS);
  @Prop searchString: string;
  @Prop @Watch('onSearchResultChange') searchResultList: RenderItemInfo[];
  @State uiRefreshId: number = 1;
  @State selectedParentIndex: number = -1;
  @State selectedChildIndex: number = -1;
  @State isScrolling: boolean = false;
  @State timer: number = 0;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State cardWidth: number = 0;
  @State appIcons: Map<string, ResourceStr | PixelMap> = new Map<string, ResourceStr | PixelMap>();
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private curParentIndex: number = -1;
  private curChildIndex: number = -1;
  private isLTR: boolean = LanguageUtils.isLtrDirection();
  private scaleSize: number = 1;
  private badgeStyle: DefaultAncoBadgeStyle = new DefaultAncoBadgeStyle();

  private getIcon(entryKey: string): ResourceStr | PixelMap {
    if (entryKey === NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
      return ENTRY_ICON_LIST.get(NavEntryKey.ABOUT_DEVICE_ENTRY) as Resource;
    }
    if (SearchCheckUtil.isSupportNewNetworkPage() && entryKey === NavEntryKey.MOBILE_ENTRY) {
      return ENTRY_ICON_LIST.get(NavEntryKey.NETWORK_SETTINGS) as Resource;
    }
    return ENTRY_ICON_LIST.get(entryKey) as Resource;
  }

  private initAppIcon(): void {
    LogUtil.info(`${TAG} initAppIcon ${this.searchResultList.length}`);
    if (this.searchResultList && this.searchResultList.length > 0) {
      let appResult: RenderItemInfo[] = this.searchResultList.filter(item => {
        return item.children.length > 0 && (item.children[0].isApp || item.children[0].isService) &&
          FIXED_ICON_ENTRY_LIST.indexOf(item.entryKey) < 0;
      })

      appResult.forEach(item => {
        this.loadAppIcon(item.entryKey, item.children[0].appIndex);
      });
    }
  }

  private async loadAppIcon(bundleName: string, appIndex?: number): Promise<void> {
    let appEntry: AppEntry = AppListLoader.getInstance().getAppEntry(bundleName, appIndex) as AppEntry;
    let icon: ResourceStr | PixelMap = '';
    if (appEntry) {
      LogUtil.info(`${TAG} success get app from cache`);
      icon = appEntry.icon === undefined ? '' : appEntry.icon;
      this.appIcons.set(bundleName, icon);
      return;
    }
    appEntry = await AppListLoader.getInstance().createAndCache(bundleName, appIndex) as AppEntry;
    if (appEntry) {
      LogUtil.info(`${TAG} success add app to cache`);
      icon = appEntry.icon === undefined ? '' : appEntry.icon;
      this.appIcons.set(bundleName, icon);
      return;
    }
    LogUtil.error(`${TAG} not has icon`);
    return;
  }

  private replaceString(str: string): string {
    return str.replace('&#x3c;', '<').replace('&#x3e;', '>').replaceAll('&#x2f;', '/');
  }

  private onTouchEvent(event: TouchEvent, parentIndex: number, childIndex: number): void {
    if (event.type === TouchType.Down) {
      this.timer = setTimeout(() => {
        this.selectedParentIndex = parentIndex;
        this.selectedChildIndex = childIndex;
      }, TOUCH_DELAY);
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      clearTimeout(this.timer);
      this.selectedParentIndex = -1;
      this.selectedChildIndex = -1;
    }
  }

  private getBackgroundColor(parentIndex: number, childIndex: number): ResourceColor {
    if (parentIndex === this.selectedParentIndex && childIndex === this.selectedChildIndex && !this.isScrolling) {
      return this.getBackgroundColorResource();
    }
    return $r('app.color.color_default_white');
  }

  private getBackgroundColorResource(): ResourceColor {
    if (!PageConfig.getInstance().isSplitMode()) {
      return $r('sys.color.interactive_click');
    }
    try {
      LogUtil.info(`${TAG} getDarkMode sucess`);
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.color_pressed_click_dark') : $r('app.color.color_pressed_click');
    } catch (err) {
      LogUtil.error(`${TAG} getDarkMode fail`);
      return $r('app.color.color_pressed_click');
    }
  }

  private entryMenuPage(item: RenderItemChildrenInfo): void {
    if (item.isApp === true || item.isService === true) {
      return this.handleSearchAppItemClick(item);
    }
    let isSamePage: boolean = this.pathInfos.size() > 0 &&
      this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] === item.entryKey;
    let curParams = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as object;
    let isParamsSame: boolean = false;
    if ((curParams as PushParam)?.config) {
      isParamsSame = StringUtil.isSameParams(item.params, String((curParams as PushParam)?.config));
    } else {
      isParamsSame =
        StringUtil.isSameParams(item.params, String(((curParams as PageParams)?.param as PushParam)?.config));
    }

    if (isSamePage && isParamsSame) {
      LogUtil.info(`${TAG} same page, no need to load.`);
      return;
    }

    if (PageRouteController.getInstance().isPageAdapted(item.entryKey)) {
      this.loadNewPage(item);
      return;
    }
    this.loadDefaultPage(item);
  }

  private handleSearchAppItemClick(item: RenderItemChildrenInfo): void {
    LogUtil.info(`${TAG} handleSearchAppItemClick`);
    let navigationMode: NavigationMode | undefined = AppStorage.get<NavigationMode>('navigationMode');
    let isSplitMode: boolean = navigationMode === NavigationMode.Split;
    if (this.isSameApplicationInfo(item.entryKey, item.appIndex)) {
      LogUtil.info(`${TAG} page is shown, no need route`);
      return;
    }

    if (CheckEmptyUtils.isEmpty(AppListLoader.getInstance().getAppEntry(item.entryKey, item.appIndex))) {
      LogUtil.error(`${TAG} app is uninstalled ${item.entryKey}, ${item.appIndex}`);
      return;
    }

    LogUtil.info(`${TAG} AppEntryController onMenuClick ${item.entryKey}`);
    const APP_INFO_ENTRY: string = 'app_info_entry';
    HiSysEventUtil.reportEntryEvent(APP_INFO_ENTRY, item.entryKey);
    AppStorage.setOrCreate('currentAppName', item.appName);
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    let key: string = AppUtils.getAppKey(item.entryKey, item.appIndex);
    if (isSplitMode) {
      PageRouter.replace(NavEntryKey.APPLICATION_INFO_ENTRY, AppUtils.parsePushParamFromAppKey(key));
    } else {
      PageRouter.push(NavEntryKey.APPLICATION_INFO_ENTRY, AppUtils.parsePushParamFromAppKey(key));
    }
  }

  private isSameApplicationInfo(appName: string, appIndex?: number): boolean {
    let curPage = this.pathInfos.size() > 0 ? this.pathInfos.getAllPathName()[this.pathInfos.size() - 1] : '';
    if (curPage != NavEntryKey.APPLICATION_INFO_ENTRY) {
      return false;
    }
    let curParams = this.pathInfos.getParamByIndex(this.pathInfos.size() - 1) as object;
    let appPushParam: PushParam = (curParams as PageParams)?.param as PushParam;
    let curApp = String(appPushParam?.config);
    let currentAppIndex = appPushParam?.appIndex;
    return curApp === appName && appIndex === currentAppIndex;
  }

  private handleOUCEntryKeyTrans(item: RenderItemChildrenInfo): RenderItemChildrenInfo {
    if (item.entryKey === NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
      return {
        title: item.title,
        entryKey: NavEntryKey.ABOUT_DEVICE_ENTRY,
        path: item.path,
        parentKey: item.parentKey,
        params: item.params,
        itemName: item.itemName,
        isOuterApp: false
      };
    }
    return item;
  }

  private loadNewPage(item: RenderItemChildrenInfo):void {
    PageRouter.load(item.entryKey).then((value) => {
      PageStartModeManager.getInstance().setStartReason(PageStartReason.FROM_SEARCH);
      if (AppStorage.get<NavigationMode>('navigationMode') === NavigationMode.Split) {
        if (!item.params.includes('isShowBack:false') && item.entryKey !== 'systemui_notification_settings') {
          item.params = item.params + ',isShowBack:false';
        }
        this.pathInfos?.clear();
        this.pathInfos?.replacePathByName(item.entryKey, {
          router: 'Setting',
          pageUrl: item.entryKey,
          pageCtx: value.get(),
          param: new PushParam(item.params, undefined, undefined, undefined, item.itemName)
        } as PageParams);
      } else {
        this.pathInfos?.pushPathByName(item.entryKey, {
          router: 'Setting',
          pageUrl: item.entryKey,
          pageCtx: value.get(),
          param: new PushParam(item.params, undefined, undefined, undefined, item.itemName)
        } as PageParams);
      }
    })
  }

  private loadDefaultPage(item: RenderItemChildrenInfo): void {
    let navigationMode: NavigationMode | undefined = AppStorage.get<NavigationMode>('navigationMode');
    PageStartModeManager.getInstance().setStartReason(PageStartReason.FROM_SEARCH);
    DynamicLoader.getInstance().fire(item.entryKey).then(() => {
      if (navigationMode === NavigationMode.Split) {
        if (!item.params.includes('isShowBack:false') && item.entryKey !== 'systemui_notification_settings') {
          item.params = item.params + ',isShowBack:false';
        }
        this.pathInfos?.clear();
        this.pathInfos?.replacePathByName(item.entryKey,
          new PushParam(item.params || this.pathInfos?.getParamByName(item.entryKey),
            undefined, undefined, undefined, item.itemName));
      } else {
        this.pathInfos?.pushPathByName(item.entryKey,
          new PushParam(item.params || this.pathInfos?.getParamByName(item.entryKey),
            undefined, undefined, undefined, item.itemName));
      }
    })
  }

  private pushName(key: string, params: PushParam | undefined): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private replaceName(key: string, params: PushParam | undefined): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.replacePathByName(key, params);
    });
  }

  private getSearchAppPath(isApp?: boolean): string {
    let path: string = ResourceUtil.getStringSync($r('app.string.application_and_meta_service_settings_title'));
    let typeName: string = ResourceUtil.getStringSync($r('app.string.wall_paper_application'));
    if (!isApp) {
      typeName = ResourceUtil.getStringSync($r('app.string.meta_service_settings_title'));
    }
    return path + ' > ' + typeName;
  }

  onSearchResultChange(): void {
    this.uiRefreshId += 1;
    this.scroller.scrollToIndex(0);
    this.initAppIcon();
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} searchResultList`);
    this.initAppIcon();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    AppStorage.setOrCreate('isFromSearch', false);
    this.appIcons?.clear();
  }

  onNavigationModeChange(): void {
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode} ${this.pathInfos.size()}}`);
    if (this.navigationMode == NavigationMode.Stack) {
      this.selectedParentIndex = -1;
      this.selectedChildIndex = -1;
    } else if (this.navigationMode == NavigationMode.Split && this.pathInfos.size() > 0) {
      this.selectedParentIndex = this.curParentIndex;
      this.selectedChildIndex = this.curChildIndex;
    }
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
      ? $r('sys.color.ohos_id_color_click_effect') : null)
  }

  @Builder
  emptyResultComponent(): void {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Start
    }) {
      Column() {
        Image($r('app.media.search_no_result'))
          .width(120)
          .height(120)
          .draggable(false)
        Text($r('app.string.no_matching_results'))
          .fontColor($r('sys.color.ohos_id_color_text_hint'))
          .fontSize('14fp')
      }
    }
    .height('calc(100% - 56vp)')
  }

  @Builder
  resultTitleComponent(childItem: RenderItemChildrenInfo): void {
    Text() {
      ForEach(childItem.title, (titleItem: string, itemIndex: number) => {
        if (titleItem !== 'em' && titleItem !== '/em') {
          if (itemIndex !== 0) {
            Span(this.replaceString(titleItem))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .fontColor(childItem.title[itemIndex - 1] === 'em' ? $r('sys.color.ohos_id_color_text_primary_activated')
                : $r('sys.color.ohos_id_color_text_primary'))
          } else {
            Span(this.replaceString(titleItem))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi')
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
          }
        }
      })
    }
    .constraintSize({ minHeight: '22vp' })
    .width(FontScaleUtils.isExtraLargeFontMode() ? 'calc(100% - 60vp)' : 'undefined')
    .id('searchResultItem')
    .margin({ bottom: 2 })
  }

  @Builder
  resultContentComponent(renderItem: RenderItemInfo, childItem: RenderItemChildrenInfo, childIndex: number): void {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center
      }) {
        Column() {
          this.resultTitleComponent(childItem);

          Text((childItem.isApp || childItem.isService) && !childItem.isOuterApp ?
          this.getSearchAppPath(childItem.isApp) :
          childItem.path)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .constraintSize({ minHeight: '19vp' })
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          if (childItem.isOuterApp) {
            SymbolGlyph(this.isLTR ? $r('sys.symbol.arrow_up_right') : $r('sys.symbol.arrow_up_left'))
              .fontSize('20vp')
              .draggable(false)
              .fontColor([$r('sys.color.ohos_id_color_fourth')])
          } else {
            Image($r('app.media.ic_settings_arrow'))
              .width(12)
              .height(24)
              .fillColor($r('sys.color.ohos_id_color_fourth'))
              .draggable(false)
              .matchTextDirection(true)
          }
        }
        .flexGrow(0)
        .alignItems(HorizontalAlign.End)
      }
      .padding({ top: '10vp', bottom: '11vp' })

      if (renderItem.children) {
        if (childIndex !== renderItem.children.length - 1) {
          Divider()
            .color($r('sys.color.ohos_id_color_list_separator'))
            .strokeWidth(0.5)
        }
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('calc(100% - 48vp)')
    .padding({ start: PADDING_8, end: PADDING_8 })
  }

@Builder
  resultIcon(renderItem: RenderItemInfo, childItem: RenderItemChildrenInfo, childIndex: number) {
    RelativeContainer() {
      if (childIndex === 0) {
        if ((childItem.isApp || childItem.isService) && FIXED_ICON_ENTRY_LIST.indexOf(renderItem.entryKey) < 0) {
          Image(this.appIcons.get(renderItem.entryKey))
            .clipShape(appIconShape)
            .width('33vp')
            .draggable(false)
            .margin({ left: '-1vp' })
            .id('baseIcon')
        } else {
          Image(this.getIcon(renderItem.entryKey))
            .width('32vp')
            .height('32vp')
            .borderRadius('16vp')
            .draggable(false)
        }
      }
    }
    .width('48vp')
    .height('36vp')
    .padding({ start: PADDING_8, end: PADDING_4 })
    .margin({ end: FontScaleUtils.isExtraLargeFontMode() ? PADDING_12 : PADDING_0 })
  }
 
  @Builder
  resultLargeComponent(renderItem: RenderItemInfo, childItem: RenderItemChildrenInfo, childIndex: number): void {
    Column() {
      Row() {
        Column() {
          Row() {
            this.resultIcon(renderItem, childItem, childIndex)
            this.resultTitleComponent(childItem);
          }
          Row() {
            Text((childItem.isApp || childItem.isService) && !childItem.isOuterApp ?
            this.getSearchAppPath(childItem.isApp) : childItem.path)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .constraintSize({ minHeight: '19vp' })
              .fontWeight(FontWeight.Regular)
              .fontFamily('HarmonyHeiTi')
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          .padding( {start: PADDING_60} )
        }
        .alignItems(HorizontalAlign.Start)
        .width('calc(100% - 36vp)')
        .margin({ end: PADDING_8 })
        Column() {
          if (childItem.isOuterApp) {
            SymbolGlyph(this.isLTR ? $r('sys.symbol.arrow_up_right') : $r('sys.symbol.arrow_up_left'))
              .fontSize('18vp')
              .draggable(false)
              .fontColor([$r('sys.color.ohos_id_color_fourth')])
          } else {
            Image($r('app.media.ic_settings_arrow'))
              .width(12)
              .height(24)
              .fillColor($r('sys.color.ohos_id_color_fourth'))
              .draggable(false)
              .matchTextDirection(true)
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
 
      if (renderItem.children) {
        if (childIndex !== renderItem.children.length - 1) {
          Divider()
            .color($r('sys.color.ohos_id_color_list_separator'))
            .strokeWidth('1px')
            .margin( { start: PADDING_16, top: FontScaleUtils.getSafetyPadding() })
        }
      }
    }
    .constraintSize({ minHeight: '64vp' })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin((renderItem.children && childIndex !== renderItem.children.length - 1) ?
      { end: PADDING_12, top: FontScaleUtils.getSafetyPadding() } :
      { end: PADDING_12, top: FontScaleUtils.getSafetyPadding(), bottom: FontScaleUtils.getSafetyPadding() })
  }

  @Builder
  searchItemComponent(renderItem: RenderItemInfo, renderItemIndex: number) {
    ListItemGroup() {
      ForEach(renderItem.children, (childItem: RenderItemChildrenInfo, index) => {
        ListItem() {
          Column() {
            if (FontScaleUtils.isExtraLargeFontMode()) {
              this.resultLargeComponent(renderItem, childItem, index);
            } else {
              Row() {
                this.resultIcon(renderItem, childItem, index);
                this.resultContentComponent(renderItem, childItem, index);
              }
              .width('100%')
              .constraintSize({ minHeight: '64vp' })
            }
          }
          .backgroundColor(this.getBackgroundColor(renderItemIndex, index))
          .borderRadius(18)
          .margin({start: PADDING_4, end: PADDING_4})
          .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
          .onClick(() => {
            if (PageConfig.getInstance().isSplitMode()) {
              this.selectedParentIndex = renderItemIndex;
              this.selectedChildIndex = index;
            }
            this.curParentIndex = renderItemIndex;
            this.curChildIndex = index;
            HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.ENTRY_SEARCH_RESULTS_PAGE,
              renderItem.entryKey);
            this.searchController.saveHistoryData(this.searchString);
            HiSysEventUtil.reportButtonEvent(TAG, `clickResultGotoPage ${renderItem.entryKey}`);
            LogUtil.info(`${TAG} renderItemChildrenInfo title: ${childItem.title}`);
            if (childItem.isOuterApp) {
              AbilityUtils.startAbility(childItem.want);
            } else {
              this.entryMenuPage(this.handleOUCEntryKeyTrans(childItem));
            }
          })
          .onTouch((event?: TouchEvent): void => {
            if (event && !PageConfig.getInstance().isSplitMode()) {
              this.onTouchEvent(event, renderItemIndex, index);
            }
          })
        }
        .width('100%')
      })
    }
    .borderRadius(20)
    .margin({
      bottom: $r('app.float.margin_12')
    })
    .padding({ top: '4vp', bottom: '4vp' })
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
  }

  @Builder
  resultListComponent(renderItem: RenderItemInfo, renderItemIndex: number): void {
    if (renderItem.isOuterApp) {
      ListItem() {
        Text(renderItem.appName)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .lineHeight('16sp')
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .width('100%')
          .margin({ start: PADDING_0, bottom: PADDING_8, top: PADDING_16 })
          .direction(this.isLTR ? Direction.Ltr : Direction.Rtl)
      }
      .width('100%')
      .padding({
        start: PADDING_12,
        end: PADDING_12
      })
      .align(Alignment.Bottom)
    }
    this.searchItemComponent(renderItem, renderItemIndex);
  }

  build() {
    if (this.uiRefreshId) {
      if (this.searchResultList.length === 0) {
        this.emptyResultComponent();
      } else {
        Stack({ alignContent: Alignment.End }) {
          Scroll() {
            List({ scroller: this.scroller }) {
              ForEach(this.searchResultList, (renderItem: RenderItemInfo, index) => {
                this.resultListComponent(renderItem, index);
              })
            }
            .id('searchResult')
            .width('100%')
            .height('100%')
            .borderRadius(20)
            .scrollBar(BarState.Off)
            .padding({
              left: $r('app.float.margin_16'),
              right: $r('app.float.margin_16'),
            })
            .onScrollStart(() => {
              this.isScrolling = true;
              focusControl.requestFocus('searchResult')
            })
            .onScrollStop(() => {
              this.isScrolling = false;
            })
            .contentEndOffset(PADDING_60.value)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
          .margin({
            top: PADDING_8,
          })
          .align(Alignment.TopStart)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .onScrollStart(() => {
            focusControl.requestFocus('searchResult')
          })

          ScrollBar({
            scroller: this.scroller,
            direction: ScrollBarDirection.Vertical,
            state: BarState.Auto
          }).margin({ bottom: PADDING_60 })
        }
        .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
          this.cardWidth = vp2px((newValue.width ?? 0) as number - 16 * 2);
        })
      }
    }
  }
}
