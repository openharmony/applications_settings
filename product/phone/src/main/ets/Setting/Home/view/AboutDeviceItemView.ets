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
import uiAppearance from '@ohos.uiAppearance';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EnableUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/EnableUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  NewVersionViewStatus,
  SystemUpdateStatusShowInfo
} from '@ohos/settings.systemUpdate/src/main/ets/model/NewVersionViewStatusModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_10,
  PADDING_16,
  PADDING_4,
  PADDING_48,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AboutDeviceInfo } from '@ohos/settings.aboutdevice/src/main/ets/model/AboutDeviceInfo';
import { AboutDeviceUtils } from '../../AboutDevice/const/AboutDeviceUtils';
import { AboutDeviceController } from '../../AboutDevice/SubHome/controller/AboutDeviceController';

const TAG = 'AboutDeviceItemView';
const PERCENT_33 = '33%';
const PERCENT_67 = '67%';
const BADGE_SIZE = '6vp';

@Component
export struct AboutDeviceItemView {
  item?: SettingBaseModel;
  private isSelected: boolean = false;
  private isPad: boolean = DeviceUtil.isDevicePad();
  @State isHover: boolean = false;
  @State isEnabled: boolean = true;
  @State showSelectedBackColor: boolean = false;
  @State aboutDeviceInfo: AboutDeviceInfo = new AboutDeviceInfo();
  @Consume('pathInfos') @Watch('changeDeviceInfo') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  private controller: AboutDeviceController = new AboutDeviceController(this.aboutDeviceInfo);

  // todo 修改设备名称后首页未同步，暂时先监听这个重新赋值
  private changeDeviceInfo (){
    // LogUtil.info(`this.pathInfos:${JSON.stringify(this.pathInfos)}`)
    this.aboutDeviceInfo = new AboutDeviceInfo();
  }

  private getNormalColor(): ResourceColor {
    LogUtil.info(`${TAG} getNormalColor`);
    if (this.showSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    if (this.isHover) {
      return $r('sys.color.interactive_hover');
    }
    return $r('app.color.color_default_white');
  }

  private getPressedColor(): ResourceColor {
    LogUtil.info(`${TAG} getPressedColor`);
    if ((this.navigationMode === NavigationMode.Split) && this.showSelectedBackColor) {
      return $r('sys.color.interactive_click');
    }
    return $r('sys.color.interactive_pressed');
  }

  private getBackgroundColorResource(): ResourceColor {
    try {
      LogUtil.info(`${TAG} getDarkMode sucess`);
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.color_pressed_click_dark') :
      $r('app.color.color_pressed_click');
    } catch (err) {
      LogUtil.error(`${TAG} getDarkMode fail`);
      return $r('app.color.color_pressed_click');
    }
  }

  private getBackgroundColor(): ResourceColor {
    LogUtil.info(`${TAG} getBackgroundColor sucess`);
    if (this.isSelected) {
      if ((DisplayUtils.isFoldable() || this.isPad) && this.showSelectedBackColor) {
        return $r('app.color.color_pressed_click');
      }
      return $r('app.color.color_1A000000_grey');
    }
    if (this.showSelectedBackColor) {
      return this.getBackgroundColorResource();
    }
    return $r('app.color.color_default_white');
  }

  private onEntryClick(): void {
    LogUtil.showInfo(TAG, 'click to navigate');
    let lastKey: string = AppStorage.get('currentHomeKey') as string;
    notifyCompStateChange(lastKey,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
        { state: false } as SettingCompState]]));
    AppStorage.setOrCreate('currentHomeKey', NavEntryKey.ABOUT_DEVICE_ENTRY);
    this.showSelectedBackColor = this.navigationMode === NavigationMode.Split;

    PageRouter.push(NavEntryKey.ABOUT_DEVICE_ENTRY, this.item);
  }

  private onItemSelectedEvent(data: object): void {
    if (!(data instanceof Map)) {
      LogUtil.showError(TAG, 'invalid eventbus data type.');
      return;
    }

    let recvData: Map<SettingStateType, SettingBaseState> = data as Map<SettingStateType, SettingBaseState>;
    recvData.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (SettingStateType.STATE_TYPE_ITEM_SELECTED === key) {
        let state = value as SettingCompState;
        if (state.state) {
          this.showSelectedBackColor = this.navigationMode === NavigationMode.Split;
        } else {
          this.showSelectedBackColor = false;
        }
      }
    });
  }

  private getSystemUpdateStatusShowInfo(): SystemUpdateStatusShowInfo {
    let systemUpdateStatusShowInfo: SystemUpdateStatusShowInfo = new SystemUpdateStatusShowInfo();

    switch (this.aboutDeviceInfo.systemUpdateStatus) {
      case NewVersionViewStatus.VIEW_CHECK_SUCCESS:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.new_version_found_text');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_DOWNLOADING: // fall through
      case NewVersionViewStatus.VIEW_DOWNLOAD_VERIFYING:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.update_status_downloading');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_DOWNLOAD_PAUSE:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.update_status_download_pause');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_INSTALL_WAIT: // fall through
      case NewVersionViewStatus.VIEW_DOWNLOAD_SUCCESS:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.update_status_wait_install');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_PRE_INSTALLING: // fall through
      case NewVersionViewStatus.VIEW_INSTALLING:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.patch_installing_title');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_INSTALL_SUCCESS:
        systemUpdateStatusShowInfo.systemUpdateStatusText = $r('app.string.check_version_status_to_be_reboot');
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_UPGRADE_VERIFYING: // fall through
      case NewVersionViewStatus.VIEW_UPGRADE_HOT_INSTALLING:
        systemUpdateStatusShowInfo.isShowBadge = true;
        break;
      case NewVersionViewStatus.VIEW_UPGRADE_REBOOTING: // fall through
      default:
        systemUpdateStatusShowInfo.systemUpdateStatusText = '';
        systemUpdateStatusShowInfo.isShowBadge = false;
        break;
    }
    return systemUpdateStatusShowInfo;
  }

  private isShowBadge(): boolean {
    let isShowBadge: boolean = this.aboutDeviceInfo.badge > 0;
    return isShowBadge && !this.aboutDeviceInfo.isPrivacyUser;
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.controller.aboutToAppear();
    let curKey: string = AppStorage.get('currentHomeKey') as string;
    this.showSelectedBackColor =
      curKey === NavEntryKey.ABOUT_DEVICE_ENTRY && this.navigationMode === NavigationMode.Split;
    EventBus.getInstance().on(NavEntryKey.ABOUT_DEVICE_ENTRY, (data: object) => {
      this.onItemSelectedEvent(data);
    })
    if (EnableUtils.getHomePageDisableItems().has(NavEntryKey.ABOUT_DEVICE_ENTRY)) {
      this.isEnabled = false;
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    this.controller.aboutToDisappear();
    EventBus.getInstance().off(NavEntryKey.ABOUT_DEVICE_ENTRY);
  }

  @Builder
  deviceIconBuilder() {
    Image(AboutDeviceUtils.getAboutDeviceMenuIcon())
      .id(`about_device_image`)
      .width('32vp')
      .height('32vp')
      .objectFit(ImageFit.Cover)
      .borderRadius($r('sys.float.corner_radius_level8'))
      .draggable(false)
      .interpolation(ImageInterpolation.Medium)
      .syncLoad(true)
      .margin({ end: PADDING_16 })
  }

  @Builder
  deviceNameLargeBuilder() {
    Text(this.aboutDeviceInfo.deviceName)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .maxLines(3)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .wordBreak(WordBreak.BREAK_ALL)
      .width('calc(100% - 56vp)')
  }

  @Builder
  deviceNameBuilder() {
    Text(this.aboutDeviceInfo.deviceName)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Medium)
      .maxLines(FontScaleUtils.isExtraLargeFontMode() ? 3 : 1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .wordBreak(WordBreak.BREAK_ALL)
      .padding({ end: this.isShowBadge() ? PADDING_16 : PADDING_0 })
      .constraintSize({ maxWidth: this.isShowBadge() ? PERCENT_67 : undefined })
      .flexShrink(this.isShowBadge() ? 0 : 1)
  }

  @Builder
  deviceBadgeBuilder() {
    if (this.isShowBadge()) {
      Row() {
        if (this.getSystemUpdateStatusShowInfo().isShowBadge) {
          this.showTextWithBadge()
        } else {
          this.showText()
        }
      }
      .constraintSize({ minWidth: PERCENT_33 })
      .flexShrink(1)
      .justifyContent(FontScaleUtils.isExtraLargeFontMode() ? FlexAlign.Start : FlexAlign.End)
    }
  }

  @Builder
  showTextWithBadge() {
    Badge({
      value: '',
      position: BadgePosition.Right,
      style: { badgeSize: BADGE_SIZE }
    }) {
      Text(this.getSystemUpdateStatusShowInfo().systemUpdateStatusText)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
        .maxLines(FontScaleUtils.isExtraLargeFontMode() ? undefined : 1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.BREAK_WORD)
        .margin({ end: PADDING_10 })
        .id(`${TAG}_badge_text1`)
    }
  }

  @Builder
  showText() {
    Text(this.getSystemUpdateStatusShowInfo().systemUpdateStatusText)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .fontWeight(FontWeight.Regular)
      .maxLines(FontScaleUtils.isExtraLargeFontMode() ? undefined : 1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .wordBreak(WordBreak.BREAK_WORD)
      .id(`${TAG}_badge_text2`)
  }

  @Builder
  deviceEntryBuilder() {
    SymbolGlyph($r('sys.symbol.chevron_right'))
      .hoverEffect(null)
      .id(`entry_image_about_device`)
      .fontSize('24vp')
      .margin({ start: PADDING_4 })
      .fontColor([$r('sys.color.icon_fourth')])
      .draggable(false)
  }

  @Builder
  deviceLargeBuilder() {
    Column() {
      Row() {
        this.deviceIconBuilder();
        this.deviceNameLargeBuilder()
      }
      Row() {
        this.deviceBadgeBuilder();
        this.deviceEntryBuilder();
      }
      .clip(true)
      .padding({
        start: PADDING_48,
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  build() {
    Row() {
      if (FontScaleUtils.isExtraLargeFontMode() && this.isShowBadge()) {
        this.deviceLargeBuilder();
      } else {
        this.deviceIconBuilder();
        Row() {
          // 设备名称
          this.deviceNameBuilder();
          this.deviceBadgeBuilder();
        }.layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
        this.deviceEntryBuilder();
      }
    }
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .padding({
      top: FontScaleUtils.getSafetyPadding(),
      bottom: FontScaleUtils.getSafetyPadding(),
      start: PADDING_8,
      end: PADDING_8
    })
    .id(this.item?.id)
    .width('100%')
    .backgroundColor(this.getBackgroundColor())
    .borderRadius($r('sys.float.corner_radius_level8'))
    .enabled(this.isEnabled)
    .opacity(!this.isEnabled ? $r('sys.float.alpha_tertiary') : 1)
    .stateStyles({
      normal: {
        .backgroundColor(this.getNormalColor())
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
      pressed: {
        .backgroundColor(this.getPressedColor())
        .borderRadius($r('sys.float.corner_radius_level8'))
      },
    })
    .onClick(() => {
      this.onEntryClick();
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
          this.isSelected = true;
        } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
          this.isSelected = false;
        }
      }
    })
    .onTouch((event?: TouchEvent): void => {
      if (event) {
        if (event.type === TouchType.Down) {
          this.isSelected = true;
        } else if (event.type === TouchType.Up) {
          this.isSelected = false;
        }
      }
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    });
  }
}