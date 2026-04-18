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
import osAccount from '@ohos.account.osAccount';
import promptAction from '@ohos.promptAction';
import Router from '@ohos.router';
import { LengthMetrics } from '@ohos.arkui.node';
import { PasswordConstant } from '@ohos/settings.common/src/main/ets/constant/PasswordConstant';
import {
  FOCUS_BOX_PADDING_METRICS,
  FOCUS_BOX_PADDING_METRICS_5,
  PADDING_2,
  PADDING_9,
  StyleConstant
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { Controller, PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CommonDeviceNameController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import {
  BondDeviceTypeController,
  ButtonMenuController,
  ButtonWithVariableTitleMenuController,
  CanvasMenuController,
  CheckboxMenuController,
  CommonCircleController,
  DialogChainTextInputController,
  LoadingMenuController,
  MenuController,
  MultiCheckboxMenuController,
  MultiCheckImageMenuController,
  PasswordCircleController,
  PatternPasswordController,
  RadioMenuController,
  SimpleVolumeMenuController,
  SingleChoiceListController,
  SliderMenuController,
  SwitchMenuController,
  TextInputMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  BaseBrowserRadioMenu,
  BaseButtonMenu,
  BaseCardRadioMenu,
  BaseCheckboxOptionStyle,
  BaseSliderMenu,
  BaseTextInputMenu,
  ButtonMenuStyle,
  CanvasMenuStyle,
  CardRadioMenuStyle,
  CheckboxMenuStyle,
  EntryMenuStyle,
  ImageMenuStyle,
  PhoneCommonButtonMenuStyle,
  RadioIconAndText,
  SelectImageMenuStyle,
  SliderMenuStyle,
  TextInputMenuStyle,
  UnderLineTextInputBaseMenu,
  BasePairEntryMenu,
  PairIcon,
  PairIconType
} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import {
  BaseStyle,
  ButtonStyle,
  DividerStyle,
  ImageStyle,
  Style,
  SubHeaderStyle,
  SymbolGlyphStyle,
  TextInputStyle,
  TextStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  AccessibilityLevelType,
  AccessibilityUtils,
  TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS,
  TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS
} from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { BoundDeviceTypeChooseDialog } from '../dialog/bluetooth/BoundDeviceTypeChooseDialog';
import {
  defaultCardRadioMenuStyle,
  defaultCheckboxMenuStyle,
  DefaultEntryMenuStyle,
  DefaultLoadingMenuStyle,
  defaultRadioMenuStyle,
  defaultSelectImageMenuStyle,
  DefaultSliderMenuStyle,
  DefaultStateMenuStyle,
  EditMenu,
  EditMenuStyle,
  HomeEntryMenuStyle,
  NavigationEntryMenuStyle,
  PasswordCircleMenuStyle,
  PermissionMenu,
  ProfileSwitchMenuStyle,
  SingleChoiceEntryMenu,
  SingleChoiceMenuOnlyStyle,
  SingleChoiceMenuStyle,
  SingleSelectMenuItem,
  SpaceHeaderStyle,
  StepSliderMenuStyle,
  SwitchToggleStyle,
  UnderLineEditMenu,
  UnderLineEditMenuStyle,
  UnderLineTextInputMenuStyle
} from '../menus/Menu';
import { TitleSummaryEntryComponent } from './AtomicComponent';
import {
  AboutDeviceEntryComponent,
  AppListEntryComponent,
  AppStyle,
  EntryComponent,
  EntryInfoComponent,
  LoadingComponent,
  SecondComponent,
  SelectEntryComponent,
  SettingHomeEntryComponent,
  SpaceComponent,
  TextComponent,
  TextListComponent
} from './BaseComponent';

const TAG: string = 'MenuComponent : ';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const KEY_INPUT_WIFI_SSID: string = 'key_input_wifi_ssid';
const KEY_INPUT_HOT_SPOT: string = 'hotspot_pwd';
const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');
const OPACITY_PERCENT_SIXTY: number = 0.6;
const OPACITY_PERCENT_FORTY: number = 0.4;
const PAD_MARGIN: number = 24;
const ADD_WIFI_MAX_LENGTH: number = 32;
const TEXT_MARGIN = 8;
const ONCLICK_DISTANCE_THRESHOLD: number = 15;
const BUNDLE_NAME: string = 'com.ohos.security.privacycenter';
const ABILITY_NAME: string = 'SettingsPermissionAbility';

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
  .borderRadius(0)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
    ? $r('sys.color.ohos_id_color_click_effect') : null)
}

@Component
export struct EntryMenuComponent {
  tag: string = 'EntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      }).margin({
        left: -4,
        right: -4
      });
    }
    .enabled(this.menu?.enable as boolean && !this.menu?.isGrayed as boolean)
    .opacity((this.menu?.enable && !this.menu?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .onClick(() => {
      this.onEntryClick();
    })
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover ? true : false);
    })
    .borderRadius($r('app.float.list_item_background_radius'))
    .margin({
      left: 4,
      right: 4
    })
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu?.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu?.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu?.targetPageUrl,
      });
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SingleChooseComponent {
  tag: string = 'SingleChooseComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;
  @State deviceType: number = 0;

  private deviceTypeDialogController = new CustomDialogController({
    builder: BoundDeviceTypeChooseDialog({
      handleConfirmClick: (deviceType: number) => {
        this.deviceTypeDialogController?.close();
        if (this.controller && this.menu) {
          this.menu.extra = deviceType;
          (this.controller as MenuController).onMenuClick();
          this.deviceType = deviceType;
          this.menu.state = BluetoothUtils.getBondDeviceType(deviceType);
          this.uiRefresher.refreshUi();
        }
      },
      deviceType: this.deviceType,
    }),
    gridCount: 4,
    autoCancel: true,
    customStyle: false,
    alignment: DialogAlignment.Center,
  });

  @Styles
  normalStyles() {
    .borderRadius((this.style as EntryMenuStyle)?.rootContainer?.borderRadius ??
    $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .borderRadius((this.style as EntryMenuStyle)?.rootContainer?.borderRadius ??
    $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      });
    }
    .enabled((this.menu?.enable && !this.menu?.isGrayed) as boolean)
    .opacity((this.menu?.enable && !this.menu?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .onClick(() => {
      this.deviceTypeDialogController.open();
    })
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover ? true : false);
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
    if (this.controller) {
      (this.controller as BondDeviceTypeController).getRemoteDeviceType().then((type: number) => {
        this.deviceType = type;
        if (this.menu) {
          this.menu.state = BluetoothUtils.getBondDeviceType(type);
        }
        this.uiRefresher.refreshUi();
      });
    }
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct NavEntryMenuComponent {
  tag: string = 'NavEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | NavigationEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;
  @State isHover: boolean = false;
  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_click') : Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  private getBorderRadius(): Length {
    const style = (this.style as NavigationEntryMenuStyle);
    if (!style || !style.rootContainer.borderRadius) {
      return $r('app.float.list_item_background_radius');
    }
    return style.rootContainer.borderRadius;
  }

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      }).margin({
        left: -4,
        right: -4
      });
    }
    .enabled((this.menu?.enable && !this.menu?.isGrayed) ? true : false)
    .opacity(this.menu?.opacity ?? ((this.menu?.enable && !this.menu?.isGrayed)
      ? OPACITY_PERCENT_FULL : ALPHA_DISABLED))
    .onClick(() => {
      this.onEntryClick();
    })
    .onHover((isHover?: boolean) => {
      this.isHover = isHover ?? false;
      this.controller?.handleHoverEvent(isHover as boolean);
    })
    .borderRadius(this.getBorderRadius())
    .margin({
      left: 4,
      right: 4
    })
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStyles
    })
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    LogUtil.info(this.tag + 'onEntryClick');
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.key) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}; key: ${this.menu?.key}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(this.menu.key as string, null);
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct NavPairEntryMenuComponent {
  @State menu?: BasePairEntryMenu = undefined;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State menuHover: Map<string, boolean> = new Map();
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State controller?: Controller = undefined;
  @State isRefresh: boolean = false;
  private pairController?: Map<string, Controller>;
  private tag: string = 'NavPairEntryMenuComponent : ';

  @Builder
  cardMenu(key: string, title: ResourceStr, state: ResourceStr, icon: PairIcon, grayed: boolean) {
    Column() {
      Column() {
        Column() {
          Column() {
            if (icon?.type === PairIconType.SYMBOL) {
              SymbolGlyph(icon.icon as Resource)
                .fontSize($r('app.float.size_32'))
                .fontColor(icon.fontColor)
            } else {
              Image(icon?.icon)
                .height($r('app.float.size_32'))
                .width($r('app.float.size_32'))
            }
          }
          .alignItems(HorizontalAlign.Start)
          Column() {
            Text(title)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.Body_M'))
            Text(state)
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Medium)
              .opacity(0.6)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .backgroundColor(!this.menuHover.get(key) ? Color.Transparent : $r('sys.color.interactive_hover'))
        .height($r('app.float.height_140'))
        .padding($r('app.float.padding_8'))
        .width('100%')
        .borderRadius($r('sys.float.corner_radius_level6'))
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .onHover((isHover: boolean) => {
          this.menuHover.set(key, isHover);
        })
      }
      .width('100%')
      .padding($r('app.float.padding_4'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .enabled(!grayed)
      .opacity(grayed ? ALPHA_DISABLED : OPACITY_PERCENT_FULL)
      .onClick(() => {
        if (this.pairController && this.pairController.has(key) && this.menu) {
          const controller = this.pairController.get(key);
          this.onEntryClick(controller);
        }
      })
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    }
    .width('calc(50% - 6vp)')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  private onEntryClick(controller?: Controller): void {
    LogUtil.showInfo(this.tag, 'onEntryClick');
    if (controller && controller.onMenuClick()) {
      return;
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.pairController = this.menu?.getPairControllerInstance(this.uiRefresher);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.pairController?.forEach((controller, key) => {
      LogUtil.info(`${this.tag} ${key} disappear`);
      controller?.aboutToDisappear();
    });
    this.controller?.aboutToDisappear();
  }

  @Builder
  showCardMenu() {
    if (this.menu) {
      ForEach(this.menu.pairKey, (key: string, index) => {
        if (this.menu) {
          this.cardMenu(key, this.menu.pairTitle[index], this.menu.pairState[index],
            this.menu.pairIcon[index], this.menu.pairGrayed[index])
        }
      })
    }
  }

  build() {
    Row({ space: 12 }) {
      if (this.uiRefresher.isRender) {
        this.showCardMenu();
      } else {
        this.showCardMenu();
      }
    }
  }
}

@Component
export struct NavInfoEntryMenuComponent {
  tag: string = 'NavInfoEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | NavigationEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;

  @Styles
  normalStyles() {
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    Column() {
      EntryInfoComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        showSelectedBackColor: false,
        isSecondSelected: this.isSecondSelected,
      })
    }
    .enabled(this.menu?.enable ? true : false)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_SIXTY)
    .onClick(() => {
      this.onEntryClick();
    })
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover as boolean);
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(this.menu.key as string, null);
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}


@Component
export struct StateMenuComponent {
  tag: string = 'StateMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | DefaultStateMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      });
    }
    .enabled(this.menu?.enable ? true : false)
    .opacity((this.menu?.enable || (this.style as DefaultStateMenuStyle)?.fullOpacity) ?
      OPACITY_PERCENT_FULL : OPACITY_PERCENT_SIXTY)
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover as boolean);
    })
    .onClick(() => {
      this.controller?.onMenuClick();
    })
    .focusable(this.menu?.focusable)
    .accessibilityDescription(this.getDescription())
    .accessibilityFocusDrawLevel(FocusDrawLevel.TOP)
    .accessibilityLevel(this.menu?.accessibilityLevel ? this.menu?.accessibilityLevel : AccessibilityLevelType.AUTO)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getDescription(): string {
    if (!this.controller?.onMenuClick || this?.menu?.accessibilityDescription === ' ') {
      return ' ';
    }
    return '';
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style as Style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PermissionMenuComponent {
  tag: string = 'PermissionMenuComponent : ';
  uiExtensionProxy?: UIExtensionProxy;
  @State menu?: SettingsBaseMenu = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State userId: Number = 100;
  @State exTensionHeight: number = 740.5;
  @State isUpdateUi: boolean = false;
  @State showHeight: number = 1000;
  @State observedData: ObservedData = new ObservedData();
  @State isAppEnable: boolean = false;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume scrollDirection: ScrollDirection;
  private appIndex: number = 0;

  private appEnableSwitchEventCb = (data: object) => {
    let result = Boolean(data).valueOf() ?? false;
    LogUtil.info(`${this.tag} appEnableSwitch result is ${result}`);
    this.setIsAppEnable(result);
  };

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  // 校验子用户
  async getUserId(): Promise<void> {
    let accountManager = osAccount.getAccountManager();
    try {
      this.userId = await accountManager.getOsAccountLocalId();
      LogUtil.info(`${this.tag} verificationSubUser, userId: ${this.userId}`);
    } catch (err) {
      LogUtil.error(`${this.tag} verificationSubUser getOsAccountLocalId exception: ${err?.message}`);
    }
  }

  build() {
    Column() {
      UIExtensionComponent({
        bundleName: 'com.ohos.security.privacycenter',
        abilityName: 'SettingsPermissionAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'bundleName': this.menu?.extra as string,
          'userId': this.userId,
          'reconnect': this.observedData.reconnect,
          'appIndex': this.appIndex,
        }
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${this.tag} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((data) => {
          LogUtil.info(`${this.tag} UIExtensionComponent onReceive`);
          if (data) {
            if (data['action'] === 'jump') {
              DynamicLoader.getInstance().fire(NavEntryKey.APPLICATION_PERMISSION_SETTINGS_ENTRY).then(() => {
                const key: string = NavEntryKey.APPLICATION_PERMISSION_SETTINGS_ENTRY
                this.menu?.pathInfos?.pushPathByName(key,
                  new PushParam(data['uri'] as string, undefined, undefined, this.appIndex));
              })
            }
            if ((data['newHeight'] !== undefined) && (data['newHeight'] !== null)) {
              this.showHeight = data['newHeight'] as number;
              this.scrollDirection = ScrollDirection.Vertical;
            }
          }
        })
        .width('100%')
        .height(this.showHeight)
        .visibility(this.isAppEnable ? Visibility.Visible : Visibility.None)
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    if (this.menu instanceof PermissionMenu) {
      this.appIndex = (this.menu as PermissionMenu)?.appIndex ?? 0;
      this.isAppEnable = (this.menu as PermissionMenu)?.isEnableValid ?? true;
    }
    this.getUserId();
    this.scrollDirection = ScrollDirection.None;
    EventBus.getInstance().on('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach('EVENT_ID_APP_ENABLE_SWITCH_EVENTS', this.appEnableSwitchEventCb);
    this.viewModel.destroyListening();
  }

  private setIsAppEnable(isEnableValid: boolean) {
    LogUtil.info(`${this.tag} setIsEnableValid ${isEnableValid}`);
    this.isAppEnable = isEnableValid;
  }
}

@Component
export struct SecondMenuComponent {
  tag: string = 'StateMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | DefaultStateMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;

  build() {
    Column() {
      SecondComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      });
    }
    .enabled(this.menu?.enable ? true : false)
    .opacity((this.menu?.enable || (this.style as DefaultStateMenuStyle)?.fullOpacity) ? OPACITY_PERCENT_FULL :
      OPACITY_PERCENT_SIXTY)
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover as boolean);
    })
    .onClick(() => {
      this.controller?.onMenuClick();
    })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .accessibilityGroup(true);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style as Style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct NavigatorEntryMenuComponent {
  tag: string = 'NavigatorEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;

  @Styles
  normalStyles() {
    .borderColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
    .borderWidth('2vp')
  }

  @Styles
  pressedStyles() {
    .borderColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  focusStyle() {
    .borderColor($r('sys.color.ohos_id_color_focused_outline'))
    .borderRadius('16vp')
    .borderWidth('2vp')
  }

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        showSelectedBackColor: false,
        isSecondSelected: this.isSecondSelected,
        pathInfos: this.pathInfos,
      });
    }
    .onClick(() => {
      this.onEntryClick();
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
      focused: this.focusStyle,
    })
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}


@Component
export struct NavigationEntryMenuComponent {
  tag: string = 'NavigationEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | NavigationEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;

  @Styles
  normalStyles() {
    .borderColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  @Styles
  pressedStyles() {
    .borderColor($r('sys.color.ohos_toggle_bg_transparent'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  focusStyle() {
    .borderColor($r('sys.color.ohos_id_color_focused_outline'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        showSelectedBackColor: false,
        isSecondSelected: this.isSecondSelected,
        pathInfos: this.pathInfos,
      });
    }
    .onClick(() => {
      this.onEntryClick();
    })
    .margin((this.style as HomeEntryMenuStyle)?.marginStatus)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
      focused: this.focusStyle,
    })
    .enabled(!this.menu?.isGrayed)
    .opacity(this.menu?.isGrayed ? ALPHA_DISABLED : OPACITY_PERCENT_FULL)
  }

  clear() {
    this.pathInfos?.clear();
  }

  replaceName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.replacePathByName(key, params);
    });
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.menu?.key === NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY &&
      this.pathInfos?.getAllPathName() &&
      this.pathInfos?.getAllPathName().indexOf(NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY) >= 0) {
      this.clear();
      this.replaceName(this.menu?.key as string, null);
    } else {
      LogUtil.info(`${this.tag} onEntryClick this.menu.key : ${this.menu?.key}`);
      this.clear();
      this.pushName(this.menu?.key as string, null);
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct NavigationEntryAboutDeviceMenuComponent {
  tag: string = 'NavigationEntryAboutDeviceMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | NavigationEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;

  @Styles
  normalStyles() {
    .borderColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  @Styles
  pressedStyles() {
    .borderColor($r('sys.color.ohos_toggle_bg_transparent'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  @Styles
  focusStyle() {
    .borderColor($r('sys.color.ohos_id_color_focused_outline'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    AboutDeviceEntryComponent({
      menu: $menu,
      style: $style,
      controller: $controller,
      uiRefresher: $uiRefresher,
      showSelectedBackColor: false,
      isSecondSelected: this.isSecondSelected,
      pathInfos: this.pathInfos,
    })
      .onClick(() => {
        this.onEntryClick();
      })
      .margin((this.style as HomeEntryMenuStyle)?.marginStatus)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
        focused: this.focusStyle,
      })
  }

  clear() {
    this.pathInfos?.clear();
  }

  replaceName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.replacePathByName(key, params);
    });
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.menu?.key === NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY && this.pathInfos?.getAllPathName() &&
      this.pathInfos?.getAllPathName().indexOf(NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY) >= 0) {
      this.clear();
      this.replaceName(this.menu?.key as string, null);
    } else {
      LogUtil.info(`${this.tag} onEntryClick this.menu.key : ${this.menu?.key}`);
      this.clear();
      this.pushName(this.menu?.key as string, null);
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct TextMenuComponent {
  tag: string = 'TextMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
        TextComponent({
          menu: $menu,
          uiRefresher: $uiRefresher,
        });
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .padding(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.padding)) // 空值检测默认值为0
    .margin(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.margin))
    .visibility(this.uiRefresher.refreshId ? (this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None) :
      (this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None));
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct TextListMenuComponent {
  tag: string = 'TextListMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      TextListComponent({
        menu: $menu,
        uiRefresher: $uiRefresher,
      });
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .padding(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.padding)) // 空值检测默认值为0
    .margin(StyleConstant.getLocalizedPadding((this.menu?.style as SubHeaderStyle)?.rootContainer?.margin))
    .visibility(this.uiRefresher.refreshId ? (this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None) :
      (this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None));
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct RowTextMenuComponent {
  tag: string = 'TextMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Row(){
        Text() {
          Span(this.menu?.title)
            .id(`text_title_${this.menu?.key}`)
            .visibility(this.uiRefresher.refreshId ? (this.menu?.title ? Visibility.Visible : Visibility.None) :
              (this.menu?.title ? Visibility.Visible : Visibility.None))
            .fontSize('48vp')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.ohos_id_color_primary'));
        }
        .margin({ top: '12vp', bottom: '10vp'});
        Text() {
          Span('%')
            .id(`text_title_${this.menu?.key}`)
            .visibility(this.uiRefresher.refreshId ? (this.menu?.title ? Visibility.Visible : Visibility.None) :
              (this.menu?.title ? Visibility.Visible : Visibility.None))
            .fontSize('48vp')
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.ohos_id_color_primary'));
        }.margin({ top: '12vp', bottom: '10vp', left: '3.5vp' });
      }
      .height('64vp')
      .margin({ top: '12vp', left: '18vp'});

      Row() {
        Text() {
          Span(this.menu?.summary ?? '')
            .id(`text_title_${this.menu?.key}`)
            .visibility(this.uiRefresher.refreshId ? (this.menu?.summary ? Visibility.Visible : Visibility.None) :
              (this.menu?.summary ? Visibility.Visible : Visibility.None))
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'));
        }
        .height('19vp')
        .margin({ top: '10vp', bottom: '68vp', left: '18vp' });
      }

      Stack(){
        Row(){
          Progress({ value: Number(this.menu?.title), total: 100, type: ProgressType.Linear })
            .width(300)
            .height(118)
            .color(this.menu?.appType)
            .style({ strokeWidth: 118, strokeRadius: 0, enableSmoothEffect: false })
            .borderRadius('18vp')
            .clip(true)
          Column() {}
          .width('10vp')
          .height('32vp')
          .backgroundColor(this.menu?.badge === 100 ? '#34C759' : $r('sys.color.comp_background_secondary'))
          .borderRadius('3vp')
          .margin({left:'2vp'})
        }
        Image(this.menu?.stateIcon)
          .visibility(this.uiRefresher.refreshId ? (this.menu?.enable ? Visibility.Visible : Visibility.None) :
            (this.menu?.enable ? Visibility.Visible : Visibility.None))
          .width('14vp')
          .height('40vp')
          .opacity(0.7)
      }
      .margin({left:'18vp'})
    }
    .width('100%')
    .height('328vp')
    .margin({top:'16'})
    .borderRadius('20vp')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct BatteryMenuPadComponent {
  tag: string = 'BatteryMenuPadComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Row() {
      Column() {
        Row() {
          Text() {
            Span(this.menu?.title)
              .id(`text_title_${this.menu?.key}`)
              .visibility(this.uiRefresher.refreshId ? (this.menu?.title ? Visibility.Visible : Visibility.None) :
                (this.menu?.title ? Visibility.Visible : Visibility.None))
              .fontSize('48vp')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_primary'));
          }
          .margin({ top: '12vp' });
          Text() {
            Span('%')
              .id(`text_title_${this.menu?.key}`)
              .visibility(this.uiRefresher.refreshId ? (this.menu?.title ? Visibility.Visible : Visibility.None) :
                (this.menu?.title ? Visibility.Visible : Visibility.None))
              .fontSize('48vp')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_primary'));
          }.margin({ top: '12vp', left: '3.5vp' });
        }

        Text() {
          Span(this.menu?.summary ?? '')
            .id(`text_title_${this.menu?.key}`)
            .visibility(this.uiRefresher.refreshId ? (this.menu?.summary ? Visibility.Visible : Visibility.None) :
              (this.menu?.summary ? Visibility.Visible : Visibility.None))
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'));
        }
        .margin({ top: '10vp' })
        .textAlign(TextAlign.Start)
      }.margin({ left: '10vp' })


      Stack() {
        Row() {
          Progress({ value: Number(this.menu?.title), total: 100, type: ProgressType.Linear })
            .width(210)
            .height(88.5)
            .color(this.menu?.appType)
            .style({ strokeWidth: 118, strokeRadius: 0, enableSmoothEffect: false })
            .borderRadius('18vp')
            .clip(true)
          Column() {
          }
          .width('10vp')
          .height('32vp')
          .backgroundColor(Number(this.menu?.title) === 100 ? '#34C759' : $r('sys.color.comp_background_secondary'))
          .borderRadius('3vp')
          .margin({ left: '2vp' })
        }

        Image(this.menu?.stateIcon)
          .visibility(this.uiRefresher.refreshId ? (this.menu?.summary ? Visibility.Visible : Visibility.None) :
            (this.menu?.summary ? Visibility.Visible : Visibility.None))
          .width('14vp')
          .height('40vp')
          .opacity(0.7)
      }
      .margin({ right: '67vp' })
    }
    .width('100%')
    .height('148vp')
    .borderRadius('20vp')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ParagraphComponent {
  tag: string = 'TextMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: DefaultEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  paragraphTextArray: Array<string> | undefined = [];

  build() {
    Column() {
      if (this.paragraphTextArray) {
        ForEach(this.paragraphTextArray, (paragraphText: string) => {
          Text(paragraphText)
            .textStyle(this.style?.title)
        })
      }
    }
    .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear() {
    if (this.menu?.title) {
      this.paragraphTextArray = (this.menu?.title as string).split('\n');
    }
    this.style = this.menu?.style as DefaultEntryMenuStyle;
  }
}

@Component
export struct EditComponent {
  tag: string = 'EditComponent : ';
  menu?: EditMenu;
  @State controller?: CommonDeviceNameController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isHover: boolean = false;
  @State isPressed: boolean = false;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {

      Row() {
        if (this.getMenu().icon) {
          Image(this.getMenu().icon)
            .visibility(this.getMenu().icon ? Visibility.Visible : Visibility.None)
            .imageStyle((this.getMenu().style as EditMenuStyle)?.iconImage);
        }


        Column() {
          if (this.getMenu().title) {
            Text(this.getMenu().title)
              .onClick(this.controller?.onTitleClick)
              .visibility(this.getMenu().title ? Visibility.Visible : Visibility.None)
              .textStyle((this.getMenu().style as EditMenuStyle)?.title)
              .key(this.controller?.flashFocusTargetKey)
              .focusable(true);
          }

          if (this.getMenu().summary) {
            Text(this.getMenu().summary)
              .onClick(this.controller?.onSummaryClick)
              .visibility(this.getMenu().summary ? Visibility.Visible : Visibility.None)
              .textStyle((this.getMenu().style as EditMenuStyle)?.summary);
          }
        }
        .alignItems(HorizontalAlign.Start);
      }
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start);

      Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
        Text(this.uiRefresher.refreshId ? this.getMenu().secondState : this.getMenu().secondState)
          .textStyle((this.getMenu().style as EditMenuStyle)?.secondState)
          .visibility(this.uiRefresher.refreshId && !this.controller?.isEditVisible() ? Visibility.Visible :
          Visibility.None)
          .onClick(this.controller?.onDeviceNameTextClick);
        TextInput({
          placeholder: (this.getMenu() as SettingsBaseMenu as BaseTextInputMenu)?.hint,
          text: this.controller?.getCurrentTextInput(),
          controller: this.controller?.inputController
        })
          .draggable(false)
          .defaultFocus(true)
          .key(this.controller?.getKey())
          .textInputStyle((this.getMenu().style as EditMenuStyle)?.textInputStyle)
          .onChange((input) => {
            this.controller?.onTextInputChange(input);
          })
          .onEditChange((isEditing: boolean) => {
            this.controller?.onEditChange(isEditing);
          })
          .onFocus(() => {
            this.controller?.onFocusChange();
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.controller?.onSubmit(enterKey);
          })
          .visibility(this.uiRefresher.refreshId && this.controller?.isEditVisible() ?
          Visibility.Visible : Visibility.None);
        Row() {
          Image(this.uiRefresher.refreshId ? this.getMenu().stateIcon : this.getMenu().stateIcon)
            .fillColor($r('sys.color.ohos_id_color_secondary'))
            .imageStyle((this.getMenu().style as EditMenuStyle)?.stateIcon)
            .draggable(false)
            .opacity(this.controller?.isStateIconEnable() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY);
        }
        .size({
          height: $r('app.float.height_40'),
          width: $r('app.float.width_40'),
        })
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
        .enabled(this.controller?.isStateIconEnable() as boolean)
        .onHover((isHover?: boolean, event?: HoverEvent) => {
          this.isHover = isHover as boolean;
        })
        .onTouch((event?: TouchEvent) => {
          if (!event) {
            return;
          }
          if (event.type === TouchType.Down) {
            this.isPressed = true;
          } else if (event.type === TouchType.Up) {
            this.isPressed = false;
          }
        })
        .backgroundColor(this.getBackgroundColor())
        .onClick((event?: ClickEvent) => {
          if (this.controller?.onStateIconClick) {
            this.controller?.onStateIconClick();
          }
          this.isHover = this.controller?.isStateIconEnable() as boolean;
        })
        .justifyContent(FlexAlign.Center)
        .visibility(this.uiRefresher.refreshId && this.controller?.isEditVisible() ?
        Visibility.Visible : Visibility.None);
      }
      .onTouch((event: TouchEvent) => {
        (event.stopPropagation as () => void)();
      })
      .margin(this.uiRefresher.refreshId ?
        (this.getMenu().style as EditMenuStyle)?.stateContainer?.margin : (this.getMenu()
          .style as EditMenuStyle)?.stateContainer?.margin);
    }
    .enabled(!this.getMenu()?.isGrayed)
    .opacity((this.controller?.isEditEnabled() && !this.getMenu()?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .height((this.getMenu().style as EditMenuStyle)?.rootContainer?.size?.height)
    .width((this.getMenu().style as EditMenuStyle)?.rootContainer?.size?.width as Length)
    .constraintSize((this.getMenu().style as EditMenuStyle)?.rootContainer?.constraintSize)
    .padding((this.getMenu().style as EditMenuStyle)?.rootContainer?.padding ?? 0)
    .margin((this.getMenu().style as EditMenuStyle)?.rootContainer?.margin ?? 0)
    .layoutWeight((this.getMenu().style as EditMenuStyle)?.rootContainer?.layoutWeight ?? 0)
    .clip((this.getMenu().style as EditMenuStyle)?.rootContainer?.clip)
    .borderRadius((this.getMenu().style as EditMenuStyle)?.rootContainer?.borderRadius as Length)
    .backgroundColor((this.getMenu().style as EditMenuStyle)?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isPressed) {
      return $r('sys.color.ohos_id_color_click_effect');
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return Color.Transparent;
  }

  private getMenu(): EditMenu {
    return this.controller ? this.controller.menu as EditMenu : this.menu as EditMenu;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as CommonDeviceNameController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

/*
   性能优化，减少状态变量刷新。
 */
@Component
export struct BtLoadingComponent {
  tag: string = 'BtLoadingComponent : ';
  menu?: SettingsBaseMenu;
  controller: LoadingMenuController | undefined = undefined;
  uiRefresher: UiRefresher = new UiRefresher();
  @StorageLink('btListLoadingVisible') loadingVisible: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.getMenu().title)
          .textStyle((this.getStyle() as DefaultLoadingMenuStyle)?.title)
          .layoutWeight(1)
        LoadingProgress()
          .color($r('sys.color.ohos_id_color_progress'))
          .size({ height: '24vp', width: '24vp' })
          .margin({ bottom: '8vp' })
          .visibility(this.loadingVisible ? Visibility.Visible : Visibility.Hidden)
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .size({ width: '100%' })
    .constraintSize({ minHeight: '36vp' })
    .padding((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.padding ?? 0)
    .justifyContent(FlexAlign.End)
  }

  private getStyle(): Style {
    return this.controller ? this.controller.menu?.style as Style : this.getMenu().style as Style;
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  aboutToAppear(): void {
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as LoadingMenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct LoadingMenuComponent {
  tag: string = 'LoadingMenuComponent : ';
  menu?: SettingsBaseMenu;
  controller?: MenuController | undefined = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      LoadingComponent({
        menuKey: this.getMenu().key,
        title: this.getMenu().title,
        summary: this.getMenu().summary,
        style: this.getMenu().style,
        controller: this.controller as LoadingMenuController,
        uiRefresher: $uiRefresher,
      });
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

/*
   性能优化，减少状态变量刷新。
 */
@Component
export struct SimpleSpaceComponent {
  menu?: SettingsBaseMenu;
  controller?: MenuController = undefined;
  uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Row() {
        Divider()
          .height(this.getSpace() ?? 0)
          .color($r('app.color.color_default_white'))
      }
      .width('100%')
    }
  }

  private getSpace(): Length {
    if (this.isFirstVisibleMenu()) {
      return (this.getMenu().style as SpaceHeaderStyle)?.firstVisibleSpace;
    }
    return this.isFirstVisibleContentMenu() ? 0 : (this.getMenu().style as SpaceHeaderStyle)?.space;
  }

  private isFirstVisibleMenu(): boolean {
    return this.menu?.getRoot()?.isFirstVisibleChild(this.menu) ? true : false;
  }

  private isFirstVisibleContentMenu(): boolean {
    return this.menu?.getRoot()?.isFirstVisibleContentChild(this.menu) ? true : false;
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  aboutToAppear(): void {
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SpaceMenuComponent {
  tag: string = 'SpaceMenuComponent : ';
  menu?: SettingsBaseMenu;
  controller?: MenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      AdjustableSpaceMenuComponent({
        menu: this.getMenu(),
        style: this.getMenu().style,
        uiRefresher: $uiRefresher,
      });
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct DividerMenuComponent {
  tag: string = 'DividerMenuComponent : ';
  menu?: SettingsBaseMenu;

  build() {
    Row() {
      Divider()
        .vertical((this.menu?.style as DividerStyle)?.vertical ?? false)
        .strokeWidth((this.menu?.style as DividerStyle)?.strokeWidth as string | number)
        .color((this.menu?.style as BaseStyle)?.backgroundColor)
        .lineCap(LineCapStyle.Square);
    }
    .width('100%')
    .padding((this.menu?.style as CardRadioMenuStyle)?.menuContainerPadding as Padding)
    .size((this.menu?.style as CardRadioMenuStyle)?.size)
    .margin((this.menu?.style as CardRadioMenuStyle)?.margin as Padding)
  }
}

@Component
struct AdjustableSpaceMenuComponent {
  tag: string = 'AdjustableSpaceMenuComponent : ';
  menu?: SettingsBaseMenu;
  style?: Style;
  @Link uiRefresher: UiRefresher;

  build() {
    Column() {
      SpaceComponent({
        space: this.getSpace(),
        uiRefresher: $uiRefresher,
      });
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getSpace(): Length {
    if (this.isFirstVisibleMenu()) {
      return (this.style as SpaceHeaderStyle)?.firstVisibleSpace;
    }
    return this.isFirstVisibleContentMenu() ? 0 : (this.style as SpaceHeaderStyle)?.space;
  }

  private isFirstVisibleMenu(): boolean {
    return this.menu?.getRoot()?.isFirstVisibleChild(this.menu) ? true : false;
  }

  private isFirstVisibleContentMenu(): boolean {
    return this.menu?.getRoot()?.isFirstVisibleContentChild(this.menu) ? true : false;
  }
}

@Component
export struct PadWallpaperPreviewMenuComponent {
  tag: string = 'WallpaperPreviewMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @StorageLink('isPortraitOrientation') @Watch('getWallpaperSize') isPortraitOrientation: boolean = false;
  @StorageProp('calNavBarWidth') @Watch('getWallpaperSize') calNavBarWidth: number = 0;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State imageWidth: number = 0;

  build() {
    Row() {
      Column() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: this.getFlexAlign() }) {
          if (this.getMenu().key === 'wall_paper') {
            Image(!this.isPortraitOrientation ? $r('app.media.wallpaper_pad') : $r('app.media.wallpaper'))
              .draggable(false)
              .onClick(() => {
                this.itemOnClick();
              })
              .size(this.getWallpaperSize())
              .borderRadius((this.getMenu().style as BaseStyle)?.borderRadius)
          } else if (this.getMenu().key === 'screen_off_display') {
            Image(!this.isPortraitOrientation ? $r('app.media.aod_pad') : $r('app.media.aod'))
              .draggable(false)
              .onClick(() => {
                this.itemOnClick();
              })
              .size(this.getWallpaperSize())
              .borderRadius((this.getMenu().style as BaseStyle)?.borderRadius)
          } else if (this.getMenu().key === 'font_style_edit') {
            Image($r('app.media.font_style'))
              .draggable(false)
              .onClick(() => {
                this.itemOnClick();
              })
              .size(this.getWallpaperSize())
              .borderRadius((this.getMenu().style as BaseStyle)?.borderRadius)
          } else if (this.getMenu().key === 'icon_edit') {
            Image(!this.isPortraitOrientation ? $r('app.media.icon_pad') : $r('app.media.icon'))
              .draggable(false)
              .onClick(() => {
                this.itemOnClick();
              })
              .size(this.getWallpaperSize())
              .borderRadius((this.getMenu().style as BaseStyle)?.borderRadius)
          }
          Text(this.getMenu().title)
            .margin({ top: TEXT_MARGIN })
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .lineHeight((this.getMenu().style as BaseStyle)?.borderRadius)
            .width(this.imageWidth)
            .height('20vp')
            .textAlign(TextAlign.Center)
            .lineHeight('20vp')
        }
      }
      .margin((this.getMenu().style as BaseStyle)?.margin)
    }
    .width('100%')
    .padding({ top: '4vp' })
  }

  pushName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private getMenu(): SettingsBaseMenu {
    return this.menu as SettingsBaseMenu;
  };

  private onEntryClick(): void {
    LogUtil.info(this.tag + 'onEntryClick');
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(this.menu.key as string, null);
    }
  };

  private itemOnClick(): void {
    try {
      promptAction.showToast({ message: $r('app.string.uncompleted') });
      this.onEntryClick();
    } catch (e) {
      LogUtil.error(`${this.tag} showToast args error`);
    }
  }

  private getWallpaperWidth(): number {
    const wallPaperMargin: number = 12; // 壁纸图片间隔宽度
    const contentWidth: number = DisplayUtils.getScreenWidth() - px2vp(this.calNavBarWidth) - PAD_MARGIN * 2;
    return (contentWidth - wallPaperMargin) / 2;
  }

  private getWallpaperSize() {
    let size: SizeOptions;
    this.imageWidth = this.getWallpaperWidth();
    if (this.isPortraitOrientation) {
      size = {
        width: this.imageWidth + 'vp',
        height: this.imageWidth + 'vp',
      }
    } else {
      size = {
        height: (this.imageWidth / DisplayUtils.getScreenRation()) + 'vp',
        width: this.imageWidth + 'vp',
      }
    }
    return size;
  }

  private getFlexAlign(): FlexAlign {
    if (this.getMenu().key === 'wall_paper') {
      return FlexAlign.Start;
    } else if (this.getMenu().key === 'screen_off_display' || this.getMenu().key === 'font_style_edit') {
      return FlexAlign.Center;
    } else {
      return FlexAlign.End;
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
    this.imageWidth = this.getWallpaperWidth();
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PadSwiperMenuComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @StorageLink('isPortraitOrientation') @Watch('updatePadSwiperProp') isPortraitOrientation: boolean = false;
  @StorageProp('calNavBarWidth') @Watch('updatePadSwiperProp') calNavBarWidth: number = 0;
  @State padSwiperList: Resource[] = [$r('app.media.theme_wallpaper_4'), $r('app.media.theme_wallpaper_4'),
    $r('app.media.theme_wallpaper_4')]; // 横屏假数据
  private swiperTextList: string[] = ['活力', '风景', '安静']; // 假数据
  private swiperStatus: boolean = true; // 给画廊点击事件加防抖状态
  private distance: number = 0; // 暂存的画廊偏移量
  private imageMargin: number = 16;
  private imageHeightGrowth: number = 24;
  private initialIndex: number = 0; // 画廊初始显示主题的索引
  private finalIndex: number = this.padSwiperList.length; // 画廊最终索引
  @State padImageHeight: number = 0; // 画廊 focus 图片高度
  @State padImageWidth: number = 0; // 画廊 focus 图片宽度
  @State otherPadImageHeight: number = 0; // 其他图片高度
  @State otherPadImageWidth: number = 0; // 其他图片宽度
  @State padInitialSpace: number = 0; // 画廊初始位置
  @State padImageWidthGrowth: number = 0;
  @State slidingIndexValue: number = this.initialIndex; // 画廊当前显示主题索引
  @State inApplicationIndexValue: number = this.initialIndex; // 应用中的画廊主题索引
  @State slidingValue: number = 0; // 画廊滑动距离
  @State start: number = 0; // 手指按下位置
  @State end: number = 0; // 手指离开位置
  @State middle: number = 0; // 手指滑动距离
  private animateConfig: AnimateParam = { // 动画
    duration: 300, // 动画时长
    curve: Curve.EaseOut,
    iterations: 1, // 动画播放次数
    playMode: PlayMode.Normal,
  };
  private r45: RotateOptions = { // 绕z周逆时针旋转45°
    x: 0,
    y: 0,
    z: 1,
    centerX: '50%',
    centerY: '50%',
    angle: -45,
  };
  private r0: RotateOptions = { // 绕z周逆时针旋转0°
    x: 0,
    y: 0,
    z: 1,
    centerX: '50%',
    centerY: '50%',
    angle: 0,
  };

  build() {
    Column() {
      Row() {
        Text(this.swiperTextList[this.slidingIndexValue])
          .height('21vp')// 主题标题行高度
          .fontSize('16vp')// 主题标题字体大小
          .fontColor($r('sys.color.ohos_id_color_secondary'))// 主题标题字体颜色
          .fontWeight(FontWeight.Regular)
          .lineHeight('21vp')// 主题标题行高
          .width(this.padImageWidth + 'vp')// 主题标题行宽度
          .margin({ left: this.padInitialSpace + 'vp', })
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .margin({ top: '16vp', }) // 主题标题上边距

      Row() {
        Row({ space: '16vp' }) { // 画廊主题之间的间距
          ForEach(this.padSwiperList, (item: string, index: number) => {
            Column() {
              Image(item)
                .width(index === this.finalIndex ? '40vp' : this.padSwiperWidth(index))// 画廊滑动到最右侧添加主题图标宽
                .height(index === this.finalIndex ? '40vp' : this.padSwiperHeight(index))// 画廊滑动到最右侧添加主题图标高
                .rotate(index === this.finalIndex ? this.r45 : this.r0)
                .fillColor($r('sys.color.ohos_id_color_secondary'))
                .borderRadius('16vp')// 主题圆角
                .animation(this.animateConfig)
            }
            .onClick((event) => {
              this.onClickEvent(index);
            })
            .backgroundColor(index === this.finalIndex ? 'rgba(0,0,0,0.05)' : '') // 画廊背景颜色
            .width(this.padSwiperWidth(index))
            .height(this.padSwiperHeight(index))
            .justifyContent(FlexAlign.Center)
            .borderRadius('16vp')
          })
        }
        .width(this.padSwiperList.length *
          (this.otherPadImageWidth + this.imageMargin) + this.padInitialSpace) // 画廊总宽度
        .margin({ left: this.slidingValue })
        .height(this.padImageHeight + 'vp') // 画廊高度
        .animation(this.animateConfig)
      }
      .onTouch((event: TouchEvent) => {
        this.onTouchEvent(event);
      })
      .width('100%')
      .clip(true)
      .margin({ top: '12vp' }) // 画廊主题与画廊标题的距离

      // 导航下标
      Row({ space: '8vp' }) { // 导航点间距
        ForEach(this.padSwiperList, (item: string, index: number) => {
          Row() {
          }
          .width(this.slidingIndexValue === index ? '12vp' : '6vp') // 导航点宽度
          .height('6vp') // 导航点高度
          .backgroundColor(this.slidingIndexValue === index ? 'rgba(0,0,0,0.8)' : 'rgba(0,0,0,0.1)') // 导航点背景颜色
          .borderRadius('3vp') // 导航点圆角化
          .animation(this.animateConfig)
        })
      }
      .width('100%')
      .height('32vp') // 导航栏高度
      .margin({ top: '4vp' }) // 导航栏距离画廊距离
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // 控制按钮
      Row() {
        if (this.slidingIndexValue !== this.finalIndex) {
          Button() {
            Image($r('app.media.ic_public_edit'))
              .opacity(0.6)
          }
          .onClick(() => {
            this.itemOnClick();
          })
          .height('40vp') // 编辑按钮高度
          .width('40vp') // 编辑按钮宽度
          .backgroundColor($r('sys.color.ohos_id_color_button_normal')) // 编辑按钮背景颜色
          .borderRadius($r('sys.float.ohos_id_corner_radius_button')) // 编辑按钮圆角化
        }

        Button() {
          Text(this.swiperApplyStatus())
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
        }
        .onClick(() => {
          this.itemOnClick();
        })
        .height('40vp') // 应用按钮高度
        .width(this.isPortraitOrientation ? '266vp' : '394.7vp') // 应用按钮宽度
        .backgroundColor(this.slidingIndexValue === this.finalIndex ? '#0A59F7' :
          this.slidingIndexValue === this.inApplicationIndexValue ? 'rgba(0,0,0,0.05)' : '#0A59F7')
        .borderRadius($r('sys.float.ohos_id_corner_radius_button')) // 应用按钮圆角化
        .fontColor(this.slidingIndexValue === this.finalIndex ? '#FFFFFF' :
          this.slidingIndexValue === this.inApplicationIndexValue ? 'rgba(0,0,0,0.6)' : '#FFFFFF')
        .margin({ left: '16vp', right: '16vp' })

        if (this.slidingIndexValue !== this.finalIndex) {
          Button() {
            Image($r('app.media.ic_public_cancel'))
              .opacity(0.6)
              .fillColor($r('sys.color.ohos_id_color_secondary'))
          }
          .rotate(this.r45)
          .onClick(() => {
            this.itemOnClick();
          })
          .height('40vp') // 添加按钮高度
          .width('40vp') // 添加按钮宽度
          .backgroundColor($r('sys.color.ohos_id_color_button_normal')) // 添加按钮背景颜色
          .borderRadius($r('sys.float.ohos_id_corner_radius_button')) // 添加按钮圆角化
        }
      }
      .height('40vp') // 控制栏高度
      .margin({ top: '4vp', bottom: '16vp' }) // 控制栏边距
    }
    .width('100%')
  }

  private onClickEvent(index: number): void {
    if (this.swiperStatus && this.slidingIndexValue > index) {
      --this.slidingIndexValue;
      this.swiperStatus = false;
    } else if (this.swiperStatus && this.slidingIndexValue < index) {
      ++this.slidingIndexValue;
      this.swiperStatus = false;
    }
    this.slidingValue = -this.slidingIndexValue * (this.otherPadImageWidth + this.imageMargin) + this.padInitialSpace;
    setTimeout(() => {
      this.swiperStatus = true;
    }, 1000);
    if (index === this.finalIndex) {
      try {
        promptAction.showToast({ message: $r('app.string.uncompleted') });
      } catch (e) {
        LogUtil.error(`showToast args error`);
      }
    }
  }

  private itemOnClick(): void {
    try {
      promptAction.showToast({ message: $r('app.string.uncompleted') });
    } catch (e) {
      LogUtil.error(`showToast args error`);
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.distance = this.slidingValue;
      this.start = event.touches[0].x;
    }
    if (event.type === TouchType.Move) {
      this.middle = event.touches[0].x;
      this.slidingValue = this.distance + this.middle - this.start;
    }
    if (event.type === TouchType.Up) {
      this.end = event.touches[0].x;
      const baseLength: number = this.padImageWidth - this.padImageWidthGrowth / 2 + this.imageMargin;
      const deltaLength: number = this.end - this.start;
      if (deltaLength < -baseLength && deltaLength > -(baseLength * 2) &&
        this.slidingIndexValue < (this.padSwiperList.length - 1)) {
        this.slidingIndexValue++;
      } else if (deltaLength < -(baseLength * 2) && this.slidingIndexValue < (this.padSwiperList.length - 2)) {
        this.slidingIndexValue++;
        this.slidingIndexValue++;
      } else if (deltaLength > (baseLength * 2) && this.slidingIndexValue > 1) {
        this.slidingIndexValue--;
        this.slidingIndexValue--;
      } else if (deltaLength > baseLength && deltaLength < (baseLength * 2) && this.slidingIndexValue > 0) {
        this.slidingIndexValue--;
      }
      this.slidingValue = -this.slidingIndexValue * (this.otherPadImageWidth + this.imageMargin) + this.padInitialSpace;
    }
  }

  private updatePadSwiperProp(): void {
    const distance: number = (DisplayUtils.getScreenWidth() - px2vp(this.calNavBarWidth) - PAD_MARGIN * 2) / 2;
    if (this.isPortraitOrientation) {
      this.padSwiperList = [$r('app.media.theme_wallpaper_5'), $r('app.media.theme_wallpaper_5'),
        $r('app.media.theme_wallpaper_5')];
      this.padImageHeight = 432; // 竖屏图片高度
    } else {
      this.padSwiperList = [$r('app.media.theme_wallpaper_4'), $r('app.media.theme_wallpaper_4'),
        $r('app.media.theme_wallpaper_4')];
      this.padImageHeight = 276; // 横屏图片高度
    }
    this.swiperListPush();
    this.padImageWidth = DisplayUtils.getScreenRation() * this.padImageHeight;
    this.padInitialSpace = distance - this.padImageWidth / 2;
    this.otherPadImageHeight = this.padImageHeight - this.imageHeightGrowth; // 其他图片高度
    this.otherPadImageWidth = DisplayUtils.getScreenRation() * this.otherPadImageHeight; // 其他图片宽度
    this.padImageWidthGrowth = this.padImageWidth - this.otherPadImageWidth;
    // 转屏后复原位置
    this.slidingIndexValue = this.initialIndex;
    this.slidingValue = -this.slidingIndexValue * (this.otherPadImageHeight + this.imageMargin) + this.padInitialSpace;
  }

  private padSwiperWidth(index: number): number {
    const distance: number = this.slidingValue + index * (this.otherPadImageWidth + this.imageMargin) -
    this.padInitialSpace;
    const baseLength: number = this.padImageWidth - this.padImageWidthGrowth / 2 + this.imageMargin;
    if (distance >= 0 && distance < baseLength) {
      return this.padImageWidth - this.padImageWidthGrowth * distance / baseLength;
    } else if (distance < 0 && distance > -baseLength) {
      return this.padImageWidth + this.padImageWidthGrowth * distance / baseLength;
    } else {
      return (this.padImageWidth - this.padImageWidthGrowth);
    }
  }

  private padSwiperHeight(index: number): number {
    const distance: number = this.slidingValue + index * (this.otherPadImageWidth + this.imageMargin) -
    this.padInitialSpace;
    const baseLength: number = this.padImageWidth - this.padImageWidthGrowth / 2 + this.imageMargin;
    if (distance >= 0 && distance < baseLength) {
      return this.padImageHeight - this.imageHeightGrowth * distance / baseLength;
    } else if (distance < 0 && distance > -baseLength) {
      return this.padImageHeight + this.imageHeightGrowth * distance / baseLength;
    } else {
      return (this.padImageHeight - this.imageHeightGrowth);
    }
  }

  private swiperApplyStatus(): Resource {
    if (this.slidingIndexValue === this.padSwiperList.length - 1) {
      return $r('app.string.wall_paper_adding_a_theme');
    } else if (this.slidingIndexValue === this.inApplicationIndexValue) {
      return $r('app.string.wall_paper_applied');
    } else {
      return $r('app.string.wall_paper_application');
    }
  }

  private swiperListPush(): void {
    let add = $r('app.media.ic_public_cancel');
    this.padSwiperList.push(add);
  }

  aboutToAppear(): void {
    this.updatePadSwiperProp();
  }
}

@Component
export struct SwitchMenuComponent {
  tag: string = 'SwitchMenuComponent : ';
  menu?: SettingsBaseMenu;
  controller?: SwitchMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Column() {
          Text(this.getMenu().title)
            .visibility(this.uiRefresher?.refreshTitleId ? (this.getStyle()
              .title ? Visibility.Visible : Visibility.None) :
              (this.getMenu().title ? Visibility.Visible : Visibility.None))
            .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.title : this.getStyle()?.title)
        }

        Column() {
          Text(this.getMenu().summary)
            .visibility(this.uiRefresher?.refreshTitleId ? (this.getMenu()
              .summary ? Visibility.Visible : Visibility.None) :
              (this.getMenu().summary ? Visibility.Visible : Visibility.None))
            .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.summary : this.getStyle()?.summary)
        }
        .margin(this.getMenu().summary ? this.getStyle().summary?.margin : 0)
      }
      .opacity(this.menu?.opacity ?? (this.uiRefresher.refreshId ?
        ((this.menu?.enable && !this.getMenu()?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED) :
        (this.menu?.enable && !this.getMenu()?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED))
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
      .accessibilityGroup(true);

      Toggle({ type: ToggleType.Switch, isOn: this.uiRefresher.refreshId ?
        (this.controller?.getChecked() ?? false) : (this.controller?.getChecked() ?? false) })
        .id(`entry_toggle_${this.menu?.key}`)
        .onChange((isOn: boolean) => {
          this.controller?.onToggleChange(isOn);
        })
        .hoverEffect((DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad()) ? HoverEffect.Highlight : HoverEffect.None)
        .onHover((isHover?: boolean) => {
          this.controller?.handleHoverEvent(isHover ? true : false);
        })
        .margin(StyleConstant.getLocalizedPadding(this.getStyle()?.toggleStyle?.margin))// Toggle默认外边距是8vp，此处修改默认0vp
        .enabled(this.uiRefresher.refreshId ?
          (this.menu?.enable && (this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed) :
        (this.menu?.enable && (this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed))
        .flexShrink(0)
        .defaultFocus(true)
    }
    .id('SwitchMenuComponent')
    .enabled((this.getMenu()?.enable && !this.getMenu()?.isGrayed) ? true : false)
    .height(this.getStyle()?.rootContainer?.size?.height as Length)
    .width(this.getStyle()?.rootContainer?.size?.width as Length)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(StyleConstant.getLocalizedPadding(this.getStyle()?.rootContainer?.padding)) // 默认对齐格式为0
    .margin(StyleConstant.getLocalizedPadding(this.getStyle()?.rootContainer?.margin)) // 默认边距为0
    .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .onClick(() => {
      this.controller?.onMenuClick();
    })
    .accessibilityDescription(' ')
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): ProfileSwitchMenuStyle {
    return this.getMenu().style as ProfileSwitchMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SwitchMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SwitchMenuLargeComponent {
  tag: string = 'SwitchMenuLargeComponent : ';
  menu?: SettingsBaseMenu;
  controller?: SwitchMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Row() {
        Text(this.getMenu().title)
          .visibility(this.uiRefresher?.refreshTitleId ? (this.getStyle()
            .title ? Visibility.Visible : Visibility.None) :
            (this.getMenu().title ? Visibility.Visible : Visibility.None))
          .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.title : this.getStyle()?.title)
          .width('85%')
        Toggle({ type: ToggleType.Switch, isOn: this.uiRefresher.refreshId ?
          (this.controller?.getChecked() ?? false) : (this.controller?.getChecked() ?? false) })
          .id(`entry_toggle_${this.menu?.key}`)
          .onChange((isOn: boolean) => {
            this.controller?.onToggleChange(isOn);
          })
          .hoverEffect((DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad()) ? HoverEffect.Highlight : HoverEffect.None)
          .onHover((isHover?: boolean) => {
            this.controller?.handleHoverEvent(isHover ? true : false);
          })
          .margin(this.getStyle()?.toggleStyle?.margin ?? 0)// Toggle默认外边距是8vp，此处修改默认0vp
          .enabled(this.uiRefresher.refreshId ?
            ((this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed && this.getMenu()?.enable) :
            (this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed && this.getMenu()?.enable)
          .flexShrink(0)
          .defaultFocus(true)
      }
      .opacity(this.uiRefresher.refreshId ?
        ((this.menu?.enable && !this.getMenu()?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED) :
        (this.menu?.enable && !this.getMenu()?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);
      Column() {
        Text(this.getMenu().summary)
          .visibility(this.uiRefresher?.refreshTitleId ? (this.getMenu()
            .summary ? Visibility.Visible : Visibility.None) :
            (this.getMenu().summary ? Visibility.Visible : Visibility.None))
          .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.summary : this.getStyle()?.summary)
      }
      .margin(this.getMenu().summary ? this.getStyle().summary?.margin : 0)
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .enabled((this.getMenu()?.enable && !this.getMenu()?.isGrayed) ? true : false)
    .height(this.getStyle()?.rootContainer?.size?.height as Length)
    .width(this.getStyle()?.rootContainer?.size?.width as Length)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0) // 默认对齐格式为0
    .margin(this.getStyle()?.rootContainer?.margin ?? 0) // 默认边距为0
    .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): ProfileSwitchMenuStyle {
    return this.getMenu().style as ProfileSwitchMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SwitchMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SliderMenuComponent {
  tag: string = 'SliderMenuComponent : ';
  @State menu?: SettingsBaseMenu | undefined = undefined;
  @State controller?: SliderMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Row() {
        Image(this.getTopIcon())
          .visibility(this.getTopIcon() ? Visibility.Visible : Visibility.None)
          .opacity(this.getStyle()?.topImage?.opacity)
          .fillColor($r('sys.color.ohos_id_color_text_primary'))
          .imageStyle(this.getStyle()?.topImage)
          .syncLoad(true)
        Text(this.getMenu().title)
          .visibility(this.getMenu().title ? Visibility.Visible : Visibility.None)
          .textStyle(this.getStyle()?.title)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .opacity(this.getStyle()?.rootContainer?.opacity)
      }.margin({ left: this.getMenu().state === 'mode' ? $r('app.float.margin_5') : '' })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image(this.getStartIcon())
          .fillColor($r('sys.color.ohos_id_color_text_primary'))
          .visibility(this.getStartIcon() ? Visibility.Visible : Visibility.None)
          .imageStyle(this.getStyle()?.startImage)
          .accessibilityText(this.getStyle()?.startIconAccessibilyText ?? '')
          .onClick(() => {
            this.controller?.onStartIconClick();
          });

        if (this.menu?.startSymbolIcon) {
          SymbolGlyph(this.getStartSymbolIcon() as Resource)
            .visibility(this.getStartSymbolIcon() ? Visibility.Visible : Visibility.None)
            .symbolGlyphStyle(this.getStyle()?.startSymbolIcon)
            .accessibilityText(this.getStyle()?.startIconAccessibilyText ?? '')
            .onClick(() => {
              this.controller?.onStartIconClick();
            });
        }

        Slider({
          value: this.uiRefresher.refreshId ? this.controller?.getSliderValue() : this.controller?.getSliderValue(),
          min: this.controller?.getSliderMin(),
          max: this.controller?.getSliderMax(),
          step: this.controller?.getSliderStep(),
          style: this.getStyle()?.sliderStyle ?? SliderStyle.InSet
        })
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.controller?.onSliderChange(value, mode);
          })
          .selectedColor((this.getStyle() as StepSliderMenuStyle)?.selectedColor ?? $r('sys.color.ohos_id_color_emphasize'))
          .blockColor('#ffffff')
          .showSteps((this.getStyle() as StepSliderMenuStyle)?.showSteps)
          .padding(this.getStyle()?.sliderPadding as Padding)
          .margin(this.getStyle()?.sliderMargin as Margin ?? 0)

        Image(this.getEndIcon())
          .fillColor($r('sys.color.ohos_id_color_text_primary'))
          .visibility(this.getEndIcon() ? Visibility.Visible : Visibility.None)
          .imageStyle(this.getStyle()?.endImage)
          .accessibilityText(this.getStyle()?.endIconAccessibilyText ?? '')
          .onClick(() => {
            this.controller?.onEndIconClick();
          });

        if (this.menu?.endSymbolIcon) {
          SymbolGlyph(this.getEndSymbolIcon() as Resource)
            .visibility(this.getEndSymbolIcon() ? Visibility.Visible : Visibility.None)
            .symbolGlyphStyle(this.getStyle()?.endSymbolIcon)
            .accessibilityText(this.getStyle()?.startIconAccessibilyText ?? '')
            .onClick(() => {
              this.controller?.onEndIconClick();
            });
        }
      }
      .constraintSize(this.getStyle()?.sliderConstraintSize)
    }
    .alignItems((this.getStyle() as DefaultSliderMenuStyle)?.horizontalAlign)
    .justifyContent(FlexAlign.Center)
    .size(this.getStyle()?.rootContainer?.size)
    .padding(this.getStyle()?.rootContainer?.padding as Padding)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getTopIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.topIcon as ResourceStr : '';
  }

  private getStartIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.starIcon as ResourceStr : '';
  }

  private getStartSymbolIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.startSymbolIcon as ResourceStr : '';
  }

  private getEndIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.endIcon as ResourceStr : '';
  }

  private getEndSymbolIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.endSymbolIcon as ResourceStr : '';
  }

  private getStyle(): SliderMenuStyle {
    return this.getMenu().style as SliderMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SliderMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct CanvasMenuComponent {
  tag: string = 'CanvasMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: CanvasMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Canvas(this.controller?.getCanvasRenderingContext())
        .size(this.getStyle().canvas?.size)
        .onReady(() => {
          this.controller?.onCanvasReady();
        })
        .onDisAppear(() => {
          this.controller?.onCanvasDisappear();
        });
    }
    .justifyContent(FlexAlign.Center)
    .size(this.getStyle()?.rootContainer?.size)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0)
    .margin(this.getStyle()?.rootContainer?.margin ?? 0)
    .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): CanvasMenuStyle {
    return this.getMenu().style as CanvasMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as CanvasMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ImageMenuComponent {
  tag: string = 'ImageMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: MenuController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Stack({ alignContent: this.getStyle()?.rootContainer?.align }) {
        Column() {
          RelativeContainer() {
            Image(this.getMenu().icon)
              .id(`image_menu_${this.getMenu().key}`)
              .visibility(this.getMenu().icon ? Visibility.Visible : Visibility.None)
              .interpolation(ImageInterpolation.Medium)
              .autoResize(false)
              .imageStyle(this.getStyle()?.iconImage);
            // 分身应用的角标
            if (this.isCloneApp()) {
              Image($r(`app.media.app_icon_clone_index_${this.getAppIndex()}`))
                .height('18vp')
                .width('18vp')
                .offset({ start: LengthMetrics.vp(6), top: LengthMetrics.vp(2) })
                .alignRules({
                  right: { anchor: `image_menu_${this.getMenu().key}`, align: HorizontalAlign.End },
                  bottom: { anchor: `image_menu_${this.getMenu().key}`, align: VerticalAlign.Bottom },
                })
            }
          }
          .width(this.getStyle()?.iconImage?.size?.width)
          .height(this.getStyle()?.iconImage?.size?.height)
          .margin(this.getStyle()?.iconImage?.margin)

          Text(this.getMenu()?.title)
            .visibility((this.getMenu()?.title) ? Visibility.Visible : Visibility.None)
            .textStyle((this.getStyle() as Style as ProfileSwitchMenuStyle)?.title)
            .opacity(OPACITY_PERCENT_FORTY);
        }

        Image(this.getMenu().stateIcon)
          .visibility(this.getMenu().stateIcon ? Visibility.Visible : Visibility.None)
          .interpolation(ImageInterpolation.Medium)
          .autoResize(false)
          .imageStyle(this.getStyle()?.stateIcon);
      }
      .alignContent(Alignment.Center)
      .size(this.getStyle()?.rootContainer?.size)
      .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
      .padding(StyleConstant.getLocalizedPadding(this.getStyle()?.rootContainer?.padding))
      .margin(StyleConstant.getLocalizedPadding(this.getStyle()?.rootContainer?.margin))
      .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
      .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
  }

  private isCloneApp(): boolean {
    const index = this.getAppIndex();
    return index > 0 && index <= 5;
  }

  private getAppIndex(): number {
    const appIndex = this.getMenu().appIndex || 0;
    return appIndex;
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): ImageMenuStyle {
    return this.getMenu().style as ImageMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct TextInputMenuComponent {
  tag: string = 'TextInputMenuComponent : ';
  menu?: BaseTextInputMenu;
  @State messageFlag: boolean = false;
  @State controller?: TextInputMenuController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State dividerBackgroundColor: Resource = $r('sys.color.ohos_id_color_subheading_separator');

  build() {
    Column() {
      Text(this.getMenu()?.summary)
        .visibility(this.getMenu()?.summary ? Visibility.Visible : Visibility.None)
        .textStyle(this.getStyle()?.summaryStyle);
      Row() {
        Text(this.getMenu()?.state)
          .visibility(this.getMenu()?.state ? Visibility.Visible : Visibility.None)
          .textStyle(this.getStyle()?.stateStyle);
        TextInput({
          placeholder: this.getMenu()?.hint,
          text: this.uiRefresher.refreshId ? this.getMenu()?.title : this.getMenu()?.title,
        })
          .enableAutoFill(this.getStyle()?.textInputStyle?.enableAutoFill !== false)
          .id(`textinput_title_${this.menu?.key}`)
          .key(this.menu?.key)
          .focusable(true)
          .defaultFocus(true)
          .textInputStyle(this.getStyle()?.textInputStyle)
          .copyOption(this.isAllowCopy() ? CopyOptions.LocalDevice : CopyOptions.None)
          .inputFilter(this.getStyle()?.textInputStyle?.inputFilter ?? '')
          .onChange((input: string) => {
            if (this.menu) {
              this.menu.title = input;
            }
            if (this.menu?.key === KEY_INPUT_WIFI_SSID && input?.length >= ADD_WIFI_MAX_LENGTH) {
              this.messageFlag = true;
            } else {
              this.messageFlag = false;
            }
            this.controller?.onTextInputChange(input);
          })
          .onEditChange((isEditing: boolean) => {
            this.controller?.onEditChange(isEditing);
            this.dividerBackgroundColor = isEditing ? $r('sys.color.ohos_id_color_focused_content_primary') :
            $r('sys.color.ohos_id_color_subheading_separator');
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.controller?.onSubmit(enterKey);
          })
          .onClick((event) => {
            this.controller?.onMenuClick();
          })
      };

      Column() {
        Divider();
      }
      .visibility(this.getStyle()?.dividerStyle?.backgroundColor ? Visibility.Visible : Visibility.None)
      .backgroundColor(this.uiRefresher.refreshId ?
        (this.getMenu()?.showError ? $r('app.color.font_color_error') : this.dividerBackgroundColor) :
        (this.getMenu()?.showError ? $r('app.color.font_color_error') : this.dividerBackgroundColor))
      .size(this.getStyle()?.dividerStyle?.size)
      .alignItems(HorizontalAlign.Center);

      if (this.messageFlag) {
        Text($r('app.string.wifi_name_max'))
          .fontSize('12vp')
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .margin({
            top: '10vp'
          })
      }
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.getStyle()?.rootContainer?.margin ?? 0) // 空值检测默认值为0
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseTextInputMenu {
    return this.controller ? this.controller.menu as BaseTextInputMenu : this.menu as BaseTextInputMenu;
  }

  private getStyle(): TextInputMenuStyle {
    return this.getMenu().style as TextInputMenuStyle;
  }

  private isAllowCopy(): boolean {
    if (this.menu?.key === KEY_INPUT_HOT_SPOT || this.getStyle()?.textInputStyle?.inputType === InputType.Password) {
      return false;
    }
    return true;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as TextInputMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ChainedTextInputMenuComponent {
  tag: string = 'ChainedTextInputMenuComponent : ';
  menu?: BaseTextInputMenu;
  @State controller?: DialogChainTextInputController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State dividerBackgroundColor: Resource = $r('sys.color.ohos_id_color_subheading_separator');

  build() {
    Column() {
      Text(this.getMenu()?.summary)
        .visibility(this.getMenu()?.summary ? Visibility.Visible : Visibility.None)
        .textStyle(this.getStyle()?.summaryStyle);
      Row() {
        Text(this.getMenu()?.state)
          .visibility(this.getMenu()?.state ? Visibility.Visible : Visibility.None)
          .textStyle(this.getStyle()?.stateStyle);
        TextInput({
          placeholder: this.getMenu()?.hint,
          text: this.uiRefresher.refreshId ? this.getMenu()?.title : this.getMenu()?.title,
        })
          .defaultFocus(true)
          .textInputStyle(this.getStyle()?.textInputStyle)
          .type(this.controller?.isChecked ? InputType.Normal : InputType.Number)
          .onChange((input: string) => {
            if (this.menu) {
              this.menu.title = input;
            }
            this.controller?.onTextInputChange(input);
          })
          .onEditChange((isEditing: boolean) => {
            this.controller?.onEditChange(isEditing);
            this.dividerBackgroundColor = isEditing ? $r('sys.color.ohos_id_color_focused_content_primary') :
            $r('sys.color.ohos_id_color_subheading_separator');
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.controller?.onSubmit(enterKey);
          })
          .onClick((event) => {
            this.controller?.onMenuClick();
          });
      };

      Column() {
        Divider();
      }
      .visibility(this.getStyle()?.dividerStyle?.backgroundColor ? Visibility.Visible : Visibility.None)
      .backgroundColor(this.dividerBackgroundColor)
      .size(this.getStyle()?.dividerStyle?.size)
      .alignItems(HorizontalAlign.Center);
    }
    .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.getStyle()?.rootContainer?.margin ?? 0) // 空值检测默认值为0
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseTextInputMenu {
    return this.controller ? this.controller.menu as BaseTextInputMenu : this.menu as BaseTextInputMenu;
  }

  private getStyle(): TextInputMenuStyle {
    return this.getMenu().style as TextInputMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as DialogChainTextInputController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ButtonMenuComponent {
  tag: string = 'ButtonMenuComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
              this.getMenu()?.buttonTittle1 as ResourceStr, { type: ButtonType.Normal })
              .id(`button_1_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
              .opacity(this.menu?.enable && this.menu?.isGrayed ? ALPHA_DISABLED : OPACITY_PERCENT_FULL)
              .stateEffect(this.menu?.stateEffect)
              .enabled(this.controller?.isButton1Enabled() as boolean)
              .borderRadius((this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius ?
                (this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius : (DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : $r('app.float.border_radius_20')))
              .padding({
                top:FontScaleUtils.getButtonTopPadding(),
                bottom: FontScaleUtils.getButtonTopPadding()
              })
              .onClick((event) => {
                this.controller?.onButton1Click();
              });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton1Span())
          .gridOffset(this.getButton1Offset());

          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
              this.getMenu()?.buttonTittle2 as ResourceStr, { type: ButtonType.Normal })
              .id(`button_2_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
              .opacity(this.menu?.enable && this.menu?.isGrayed ? ALPHA_DISABLED : OPACITY_PERCENT_FULL)
              .stateEffect(this.menu?.stateEffect)
              .enabled(this.controller?.isButton2Enabled() as boolean)
              .borderRadius((this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius ?
                (this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius : (DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : $r('app.float.border_radius_20')))
			        .padding({
                top:FontScaleUtils.getButtonTopPadding(),
                bottom: FontScaleUtils.getButtonTopPadding()
              })
              .onClick((event) => {
                this.controller?.onButton2Click();
              });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton2Span())
          .gridOffset(this.getButton2Offset());

          Column() {
            Button({ type: this.uiRefresher.refreshId ? ButtonType.Normal : ButtonType.Normal }) {
              Row() {
                if (this.getMenu()?.buttonTittleLoading && this.controller?.isClicked) {
                  LoadingProgress().width(20).height(20).color(DeviceUtil.isDevicePc() ? '#FFFFFFFF' :
                  $r('sys.color.ohos_id_color_emphasize'));
                }
                Text(this.uiRefresher.refreshId ? (this.controller?.isClicked ? this.getMenu()?.buttonTittleLoading :
                  this.getMenu()?.buttonTittle3 as ResourceStr) :
                  (this.controller?.isClicked ? this.getMenu()?.buttonTittleLoading :
                    this.getMenu()?.buttonTittle3 as ResourceStr))
              }.alignItems(VerticalAlign.Center)
            }
            .id(`button_3_${this.menu?.key}`)
            .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
            .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
            .opacity(this.menu?.enable && this.menu?.isGrayed ? ALPHA_DISABLED : OPACITY_PERCENT_FULL)
            .stateEffect(this.menu?.stateEffect)
            .enabled(this.controller?.isButton3Enabled() as boolean)
            .borderRadius((this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius ?
              (this.getStyle()?.buttonStyle1 as ButtonStyle)?.borderRadius : (DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : $r('app.float.border_radius_20')))
            .padding({
              top: FontScaleUtils.getButtonTopPadding(),
              bottom: FontScaleUtils.getButtonTopPadding()
            })
            .defaultFocus(true)
            .onKeyEvent((event: KeyEvent) => {
              this.controller?.onKeyEvent(event);
            })
            .onClick((event) => {
              this.controller?.onButton3Click();
            });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton3Span())
          .gridOffset(this.getButton3Offset())
        }
        .width('100%')
      }
      .focusable(true)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding((this.getStyle() as Style as CardRadioMenuStyle)?.menuContainerPadding as Padding)
    .size((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.size)
    .margin((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.margin as Padding)
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getColumns(): number {
    if ((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns) {
      return (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getButton1Span(): number {
    return (this.getMenu()?.buttonTittle1) ? (this.getStyle()?.buttonStyle1?.gridSpan ?? 1) : 0;
  }

  private getButton2Span(): number {
    return (this.getMenu()?.buttonTittle2) ? (this.getStyle()?.buttonStyle2?.gridSpan ?? 1) : 0;
  }

  private getButton3Span(): number {
    return (this.getMenu()?.buttonTittle3) ? (this.getStyle()?.buttonStyle3?.gridSpan ?? 1) : 0;
  }

  private getButton1Offset(): number {
    if (!(this.getMenu()?.buttonTittle1)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle3?.gridOffset ?? this.getColumns() - 1;
    }
    return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
  }

  private getButton2Offset(): number {
    if (!(this.getMenu()?.buttonTittle2)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle3) ? 1 : 0);
    }
    return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 1 : 0);
  }

  private getButton3Offset(): number {
    if (!(this.getMenu()?.buttonTittle3)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
    }
    return this.getStyle()?.buttonStyle3?.gridOffset ?? this.getColumns() - 1;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = (this.menu as BaseButtonMenu).getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ConnectButtonMenuComponent {
  tag: string = 'ConnectButtonMenuComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
              this.getMenu()?.buttonTittle1 as ResourceStr, { type: ButtonType.Normal })
              .id(`button_1_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
              .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
              .enabled(this.controller?.isButton1Enabled() as boolean)
			        .borderRadius($r('app.float.border_radius_20'))
              .height('40vp')
              .onClick((event) => {
                this.controller?.onButton1Click();
              });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton1Span())
          .gridOffset(this.getButton1Offset());

          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
              this.getMenu()?.buttonTittle2 as ResourceStr, { type: ButtonType.Normal })
              .id(`button_2_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
              .height('40vp')
              .opacity(this.controller?.isButton2Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
              .enabled(this.controller?.isButton2Enabled() as boolean)
			        .borderRadius($r('app.float.border_radius_20'))
              .onClick((event) => {
                this.controller?.onButton2Click();
              });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton2Span())
          .gridOffset(this.getButton2Offset());

          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle3 as ResourceStr :
              this.getMenu()?.buttonTittle3 as ResourceStr, { type: ButtonType.Normal })
              .id(`button_3_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
              .height('40vp')
              .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
              .enabled(this.controller?.isButton3Enabled() as boolean)
			        .borderRadius($r('app.float.border_radius_20'))
              .defaultFocus(true)
              .onKeyEvent((event: KeyEvent) => {
                this.controller?.onKeyEvent(event);
              })
              .onClick((event) => {
                this.controller?.onButton3Click();
              });
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .gridSpan(this.getButton3Span())
          .gridOffset(this.getButton3Offset())
        }
        .width('100%')
      }
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.menuContainerPadding as Padding))
    .size((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.size)
    .margin(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.margin as Padding))
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getColumns(): number {
    if ((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns) {
      return (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getButton1Span(): number {
    return (this.getMenu()?.buttonTittle1) ? (this.getStyle()?.buttonStyle1?.gridSpan ?? 1) : 0;
  }

  private getButton2Span(): number {
    return (this.getMenu()?.buttonTittle2) ? (this.getStyle()?.buttonStyle2?.gridSpan ?? 1) : 0;
  }

  private getButton3Span(): number {
    return (this.getMenu()?.buttonTittle3) ? (this.getStyle()?.buttonStyle3?.gridSpan ?? 1) : 0;
  }

  private getButton1Offset(): number {
    if (!(this.getMenu()?.buttonTittle1)) {
      return this.getColumns();
    }

    return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
  }

  private getButton2Offset(): number {
    if (!(this.getMenu()?.buttonTittle2)) {
      return this.getColumns();
    }
    return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 1 : 0);
  }

  private getButton3Offset(): number {
    if (!(this.getMenu()?.buttonTittle3)) {
      return this.getColumns();
    }
    return this.getStyle()?.buttonStyle3?.gridOffset ?? this.getColumns() - 1;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = (this.menu as BaseButtonMenu).getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct DivideButtonMenuComponent {
  tag: string = 'DivideButtonMenuComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
              this.getMenu()?.buttonTittle1 as ResourceStr)
              .id(`button_1_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
              .buttonDivideStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
              .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
              .enabled(this.controller?.isButton1Enabled() as boolean)
              .flexGrow(1)
              .onClick((event) => {
                this.controller?.onButton1Click();
              })
              .focusBox({
                margin: FOCUS_BOX_PADDING_METRICS
              })
          }
          .gridSpan(this.getButton1Span())
          .gridOffset(this.getButton1Offset());

          Column() {
            Divider()
              .vertical(true)
              .strokeWidth(px2vp(2))
              .color($r('sys.color.ohos_id_color_list_separator'))
              .lineCap(LineCapStyle.Round)
              .height('24vp')
              .visibility(Visibility.Visible)
          }

          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
              this.getMenu()?.buttonTittle2 as ResourceStr)
              .id(`button_2_${this.menu?.key}`)
              .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
              .buttonDivideStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
              .opacity(this.controller?.isButton2Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
              .enabled(this.controller?.isButton2Enabled() as boolean)
              .flexGrow(1)
              .onClick((event) => {
                this.controller?.onButton2Click();
              })
              .focusBox({
                margin: FOCUS_BOX_PADDING_METRICS
              })
          }
          .gridSpan(this.getButton2Span())
          .gridOffset(this.getButton2Offset());
        }
      }
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .padding((this.getStyle() as Style as CardRadioMenuStyle)?.menuContainerPadding as Padding)
    .size((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.size)
    .margin((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.margin as Padding)
  }

  private getButton1Span(): number {
    return (this.getMenu()?.buttonTittle1) ? (this.getStyle()?.buttonStyle1?.gridSpan ?? 1) : 0;
  }

  private getButton2Span(): number {
    return (this.getMenu()?.buttonTittle2) ? (this.getStyle()?.buttonStyle2?.gridSpan ?? 1) : 0;
  }

  private getButton1Offset(): number {
    if (!(this.getMenu()?.buttonTittle1)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle1?.gridOffset ?? ((this.getMenu()?.buttonTittle2) ? 1 : 0);
    }
    return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
  }

  private getButton2Offset(): number {
    if (!(this.getMenu()?.buttonTittle2)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 0 : 1);
    }
    return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 1 : 0);
  }

  private getColumns(): number {
    if ((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns) {
      return (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = (this.menu as BaseButtonMenu).getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct ButtonMenuLargeComponent {
  tag: string = 'ButtonMenuLargeComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          GridRow({ columns: 1 }) {
            GridCol() {
              Row() {
                Button({ type: ButtonType.Normal }) {
                  Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
                    this.getMenu()?.buttonTittle1 as ResourceStr)
                    .maxLines(this.getStyle()?.buttonStyle1?.maxLines ?? 1)
                    .maxFontScale(2)
                    .textAlign(TextAlign.Center)
                }
                .id(`button_1_${this.menu?.key}`)
                .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
                .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
                .margin(0)
                .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
                .enabled(this.controller?.isButton1Enabled() as boolean)
                .padding({
                  top: FontScaleUtils.getButtonTopPadding(),
                  bottom: FontScaleUtils.getButtonTopPadding(),
                  left: $r('sys.float.padding_level8'),
                  right: $r('sys.float.padding_level8')
                })
                .height('auto')
                .onClick((event) => {
                  this.controller?.onButton1Click();
                })
                .focusBox({
                  margin: FOCUS_BOX_PADDING_METRICS
                })
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .margin({ bottom: '12vp' })

            GridCol() {
              Row() {
                Button({ type: ButtonType.Normal }) {
                  Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
                    this.getMenu()?.buttonTittle2 as ResourceStr)
                    .maxLines(this.getStyle()?.buttonStyle2?.maxLines ?? 1)
                    .maxFontScale(2)
                    .textAlign(TextAlign.Center)
                }
                .id(`button_2_${this.menu?.key}`)
                .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
                .customButtonStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
                .margin(0)
                .opacity(this.controller?.isButton2Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
                .enabled(this.controller?.isButton2Enabled() as boolean)
                .padding({
                  top: FontScaleUtils.getButtonTopPadding(),
                  bottom: FontScaleUtils.getButtonTopPadding(),
                  left: $r('sys.float.padding_level8'),
                  right: $r('sys.float.padding_level8')
                })
                .height('auto')
                .onClick((event) => {
                  this.controller?.onButton2Click();
                })
                .focusBox({
                  margin: FOCUS_BOX_PADDING_METRICS
                })
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .margin({ bottom: '12vp' })

            GridCol() {
              Row() {
                Button({ type: ButtonType.Normal }) {
                  Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle3 as ResourceStr :
                    this.getMenu()?.buttonTittle3 as ResourceStr)
                    .maxLines(this.getStyle()?.buttonStyle3?.maxLines ?? 1)
                    .maxFontScale(2)
                    .textAlign(TextAlign.Center)
                }
                .id(`button_3_${this.menu?.key}`)
                .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
                .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
                .margin(0)
                .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FULL)
                .enabled(this.controller?.isButton3Enabled() as boolean)
                .padding({
                  top: FontScaleUtils.getButtonTopPadding(),
                  bottom: FontScaleUtils.getButtonTopPadding(),
                  left: $r('sys.float.padding_level8'),
                  right: $r('sys.float.padding_level8')
                })
                .height('auto')
                .defaultFocus(true)
                .onKeyEvent((event: KeyEvent) => {
                  this.controller?.onKeyEvent(event);
                })
                .onClick((event) => {
                  this.controller?.onButton3Click();
                })
                .focusBox({
                  margin: FOCUS_BOX_PADDING_METRICS
                })
              }
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .margin({ bottom: '8vp'})
          }
        }
        .justifyContent(FlexAlign.Center)
      }
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.menuContainerPadding as Padding))
    .size((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.size)
    .margin(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.margin as Padding))
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getColumns(): number {
    if ((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns) {
      return (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = (this.menu as BaseButtonMenu).getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct TransparentButtonMenuLargeComponent {
  tag: string = 'TransparentButtonMenuLargeComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          GridRow({ columns: 1 }) {
            GridCol() {
              Row() {
                Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
                  this.getMenu()?.buttonTittle1 as ResourceStr)
                  .maxFontScale(2)
                  .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
                  .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
                  .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
                  .enabled(this.controller?.isButton1Enabled() as boolean)
                  .padding({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level4') })
                  .onClick((event) => {
                    this.controller?.onButton1Click();
                  });
              }
              .margin({bottom: $r('sys.float.padding_level2'), top: $r('sys.float.padding_level4'),
                left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8')});
            }
            GridCol() {
              Row() {
                Button() {
                  Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle3 as ResourceStr :
                    this.getMenu()?.buttonTittle3 as ResourceStr)
                    .maxFontScale(2)
                    .maxLines(1)
                    .padding({ top: $r('sys.float.padding_level4'), bottom: $r('sys.float.padding_level4') })
                }
                  .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
                  .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
                  .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
                  .enabled(this.controller?.isButton3Enabled() as boolean)
                  .onClick((event) => {
                    this.controller?.onButton3Click();
                  });
              }
              .margin({ bottom: $r('sys.float.padding_level4'), left: $r('sys.float.padding_level8'),
                right: $r('sys.float.padding_level8') })
            }
          }
        }
        .width('100%')
      }
    }
    .size(this.getStyle()?.rootContainer?.size)
    .margin(this.getStyle()?.rootContainer?.margin as Padding)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getColumns(): number {
    if (this.getStyle()?.rootContainer?.gridColumns) {
      return this.getStyle()?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct DivideButtonMenuLargeComponent {
  tag: string = 'DivideButtonMenuLargeComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Column() {
          Button() {
            Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
              this.getMenu()?.buttonTittle1 as ResourceStr)
              .maxFontScale(2)
              .maxLines(1)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
          }
            .id(`button_1_${this.menu?.key}`)
            .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
            .buttonDivideStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
            .padding({
              top: FontScaleUtils.getButtonTopPadding(),
              bottom: FontScaleUtils.getButtonTopPadding()
            })
            .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
            .enabled(this.controller?.isButton1Enabled() as boolean)
            .flexGrow(1)
            .onClick((event) => {
              this.controller?.onButton1Click();
            })
            .focusBox({
              margin: FOCUS_BOX_PADDING_METRICS
            })
        }
        .margin({
          bottom: this.getMenu()?.buttonTittle2 ? $r('app.float.margin_4') : $r('app.float.margin_0')
        })

        Column() {
          Button() {
            Text(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
              this.getMenu()?.buttonTittle2 as ResourceStr)
              .maxFontScale(2)
              .maxLines(1)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
          }
            .id(`button_2_${this.menu?.key}`)
            .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
            .buttonDivideStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
            .padding({
              top: FontScaleUtils.getButtonTopPadding(),
              bottom: FontScaleUtils.getButtonTopPadding()
            })
            .opacity(this.controller?.isButton2Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
            .enabled(this.controller?.isButton2Enabled() as boolean)
            .flexGrow(1)
            .onClick((event) => {
              this.controller?.onButton2Click();
            })
            .focusBox({
              margin: FOCUS_BOX_PADDING_METRICS
            })
        }
      }
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .padding(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.menuContainerPadding as Padding))
    .size((this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.size)
    .margin(StyleConstant.getLocalizedPadding(
      (this.getStyle() as Style as CardRadioMenuStyle)?.rootContainer?.margin as Padding))
  }


  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = (this.menu as BaseButtonMenu).getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct TransparentButtonMenuComponent {
  tag: string = 'ButtonMenuComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({
        columns: this.getColumns(),
        sizeType: SizeType.Auto,
        gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
        margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
      }) {
        Row() {
          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
              this.getMenu()?.buttonTittle1 as ResourceStr)
              .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
              .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
              .enabled(this.controller?.isButton1Enabled() as boolean)
              .onClick((event) => {
                this.controller?.onButton1Click();
              });
          }
          .gridSpan(this.getButton1Span())
          .gridOffset(this.getButton1Offset());

          if (this.getMenu()?.buttonTittle2 || this.getMenu()?.buttonTittle3) {
            Divider()
              .vertical(true)
              .strokeWidth(px2vp(2))
              .height($r('app.float.padding_24'))
              .color($r('sys.color.comp_divider'))
              .margin((this.getStyle()?.buttonStyle1 as ButtonStyle)?.margin ?? 0)
              .padding((this.getStyle()?.buttonStyle1 as ButtonStyle)?.padding ?? 0)
              .visibility(DeviceUtil.isDevicePc() ? Visibility.None : Visibility.Visible)
          }

          Column() {
            Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle3 as ResourceStr :
              this.getMenu()?.buttonTittle3 as ResourceStr)
              .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
              .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
              .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
              .enabled(this.controller?.isButton3Enabled() as boolean)
              .onClick((event) => {
                this.controller?.onButton3Click();
              });
          }
          .gridSpan(this.getButton3Span())
          .gridOffset(this.getButton3Offset())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .size(this.getStyle()?.rootContainer?.size)
    .margin(this.getStyle()?.rootContainer?.margin as Padding)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getColumns(): number {
    if (this.getStyle()?.rootContainer?.gridColumns) {
      return this.getStyle()?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.getMenu()?.buttonTittle1) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle2) {
      columns++;
    }
    if (this.getMenu()?.buttonTittle3) {
      columns++;
    }
    return columns;
  }

  private getButton1Span(): number {
    return (this.getMenu()?.buttonTittle1) ? (this.getStyle()?.buttonStyle1?.gridSpan ?? 1) : 0;
  }

  private getButton2Span(): number {
    return (this.getMenu()?.buttonTittle2) ? (this.getStyle()?.buttonStyle2?.gridSpan ?? 1) : 0;
  }

  private getButton3Span(): number {
    return (this.getMenu()?.buttonTittle3) ? (this.getStyle()?.buttonStyle3?.gridSpan ?? 1) : 0;
  }

  private getButton1Offset(): number {
    if (!(this.getMenu()?.buttonTittle1)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle3?.gridOffset ?? this.getColumns() - 1;
    }
    return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
  }

  private getButton2Offset(): number {
    if (!(this.getMenu()?.buttonTittle2)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 0 : 1);
    }
    return this.getStyle()?.buttonStyle2?.gridOffset ?? ((this.getMenu()?.buttonTittle1) ? 1 : 0);
  }

  private getButton3Offset(): number {
    if (!(this.getMenu()?.buttonTittle3)) {
      return this.getColumns();
    }
    if (!LanguageUtils.isLtrDirection()) {
      return this.getStyle()?.buttonStyle1?.gridOffset ?? 0;
    }
    return this.getStyle()?.buttonStyle3?.gridOffset ?? this.getColumns() - 1;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct VerticalButtonMenuComponent {
  tag: string = 'VerticalButtonMenuComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    GridContainer({
      columns: this.getStyle()?.rootContainer?.gridColumns ?? 2, // 定义column数目 默认为2
      sizeType: SizeType.Auto,
      gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '24vp',
      margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '24vp',
    }) {
      Column() {
        Column() {
          Button(this.getMenu()?.buttonTittle1 as ResourceStr)
            .visibility((this.getMenu()?.buttonTittle1) ? Visibility.Visible : Visibility.None)
            .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
            .enabled(this.uiRefresher.refreshId ? this.controller?.isButton1Enabled() as boolean :
              this.controller?.isButton1Enabled() as boolean)
            .onClick((event) => {
              this.controller?.onButton1Click();
            });
        }
        .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
        .gridSpan((this.getMenu()?.buttonTittle1) ? (this.getStyle()?.buttonStyle1?.gridSpan ?? 1) : 0)
        .gridOffset(this.getStyle()?.buttonStyle1?.gridOffset ?? 0);

        Column() {
          Button(this.getMenu()?.buttonTittle2 as ResourceStr)
            .visibility((this.getMenu()?.buttonTittle2) ? Visibility.Visible : Visibility.None)
            .customButtonStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
            .enabled(this.uiRefresher.refreshId ? this.controller?.isButton2Enabled() as boolean :
              this.controller?.isButton2Enabled() as boolean)
            .onClick((event) => {
              this.controller?.onButton2Click();
            });
        }
        .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
        .gridSpan(this.getMenu()?.buttonTittle2 ? (this.getStyle()?.buttonStyle2?.gridSpan ?? 1) : 0)
        .gridOffset(this.getStyle()?.buttonStyle2?.gridOffset ?? 0);

        Column() {
          Button(this.getMenu()?.buttonTittle3 as ResourceStr)
            .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
            .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
            .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
            .enabled(this.controller?.isButton3Enabled() as boolean)
            .onClick((event) => {
              this.controller?.onButton3Click();
            });
        }
        .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
        .gridSpan(this.getMenu()?.buttonTittle3 ? (this.getStyle()?.buttonStyle3?.gridSpan ?? 1) : 0)
        .gridOffset(this.getStyle()?.buttonStyle3?.gridOffset ?? 0);
      }
      .width('100%')
      .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
      .justifyContent(FlexAlign.Center)
    }
    .width(this.getStyle()?.rootContainer?.size?.width as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getStyle(): ButtonMenuStyle {
    return this.getMenu().style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.getMenu()?.getLogKey()}`);
    this.controller = this.getMenu()?.getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.getMenu()?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct EmailRadioMenuComponent {
  tag: string = 'EmailRadioMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: RadioMenuController = undefined;
  style?: CardRadioMenuStyle;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  };

  build() {
    Column() {
      if (this.menu) {
        Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Image(this.menu.icon)
              .width(40)
              .height(40)
              .visibility(this.isIconVisible(this.getIcon()))
              .draggable(false);
            Text(this.menu.title)
              .margin({ left: 9 })
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor($r('sys.color.ohos_id_color_foreground'))
              .fontWeight(FontWeight.Medium);
          }

          Radio({ value: 'sound', group: 'radioGroup' })
            .checked(this.controller?.isChecked ? true : false)
            .width(24)
            .height(24)
            .id(`email_radiomenu_radio_${this.menu?.key}`)
            .radioStyle({
              uncheckedBorderColor: Color.Transparent,
            })
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isChecked = isChecked;
              }
            })
            .onClick((event) => {
              LogUtil.info(`${this.tag} isCheckedisCheckedisCheckedisChecked`);
              this.controller?.onRadioChange(true);
            });
        }
        .accessibilityGroup(true)
        .accessibilityText(this.menu?.title as Resource)
        .accessibilityDescription((this.controller?.isChecked ? true : false) ? $r('app.string.be_chosen') :
          $r('app.string.not_selected_click_tips'))
        .width('100%')
        .height(64)
        .align(Alignment.Start | Alignment.Center)
        .padding(this.style?.padding as Padding)
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick((event) => {
          LogUtil.info(`${this.tag} onClick, onClickonClickonClickisChecked=`);
          this.controller?.onRadioChange(true);
        });
      }
    }
    .clip(true)
    .borderRadius(this.style?.borderRadius as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private isIconVisible(icon: Resource | string): Visibility {
    if (icon === undefined) {
      return Visibility.None;
    } else {
      return Visibility.Visible;
    }
  }

  private getIcon(): ResourceStr {
    return ((this.menu instanceof SettingsBaseMenu) ? this.menu.icon : '') as ResourceStr;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }

      if (!this.style) {
        this.style = defaultCardRadioMenuStyle;
      }

      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof RadioMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu?.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct CardRadioMenuComponent {
  tag: string = 'CardRadioMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: RadioMenuController = undefined;
  style?: CardRadioMenuStyle;
  @State uiRefresher: UiRefresher = new UiRefresher();

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  };

  build() {
    Column() {
      Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image(this.getIcon(0))
            .width(24)
            .height(24)
            .margin(this.style?.rootContainer?.margin as Padding)
            .visibility(this.isIconVisible(this.getIcon(0)))
            .draggable(false);
          Text(this.getText(0))
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_foreground'))
            .fontWeight(FontWeight.Medium);
        }

        Radio({ value: 'sound', group: 'radioGroup' })
          .checked(!this.controller?.isChecked)
          .width(this.style?.rootContainer?.size?.width as Length)
          .height(this.style?.rootContainer?.size?.height as Length)
          .onClick((event) => {
            this.controller?.onRadioChange(false);
          });
      }
      .accessibilityGroup(true)
      .accessibilityText(this.getText(0)?.toString())
      .accessibilityDescription(this.controller?.isChecked ? $r('app.string.be_chosen') :
        $r('app.string.not_selected_click_tips'))
      .width('100%')
      .height(64)
      .align(Alignment.Start | Alignment.Center)
      .backgroundColor(this.style?.backgroundColor)
      .padding(this.style?.padding as Padding)
      .stateStyles({
        pressed: this.pressedStyles,
      })
      .onClick((event) => {
        this.controller?.onRadioChange(false);
      });

      Column() {
        Column() {
        }
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .height(0.5)
        .width('100%')
      }
      .padding({ left: 48, right: 12 })
      .height(0.5)
      .width('100%')

      Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image(this.getIcon(1))
            .width(24)
            .height(24)
            .margin(this.style?.rootContainer?.margin as Padding)
            .visibility(this.isIconVisible(this.getIcon(1)))
            .draggable(false);
          Text(this.getText(1))
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_foreground'))
            .fontWeight(FontWeight.Medium);
        }

        Radio({ value: 'silent', group: 'radioGroup' }).checked(this.controller?.isChecked ? true : false)
          .width(this.style?.rootContainer?.size?.width as Length)
          .height(this.style?.rootContainer?.size?.height as Length)
          .onClick((event) => {
            this.controller?.onRadioChange(true)
          });
      }
      .accessibilityGroup(true)
      .accessibilityText(this.getText(1)?.toString())
      .accessibilityDescription(this.controller?.isChecked ? $r('app.string.be_chosen') :
        $r('app.string.not_selected_click_tips'))
      .width('100%')
      .height(64)
      .backgroundColor(this.style?.backgroundColor)
      .padding(this.style?.padding as Padding)
      .stateStyles({
        pressed: this.pressedStyles,
      })
      .onClick((event) => {
        this.controller?.onRadioChange(true)
      });
    }
    .clip(true)
    .backgroundColor(this.style?.backgroundColor)
    .borderRadius(this.style?.borderRadius as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private isIconVisible(icon: Resource | string): Visibility {
    if (icon === undefined) {
      return Visibility.None;
    } else {
      return Visibility.Visible;
    }
  }

  private getText(index: number): ResourceStr {
    return ((this.menu instanceof BaseCardRadioMenu) ?
    this.menu.radioIconAndText[index].radioText : '') as ResourceStr;
  }

  private getIcon(index: number): ResourceStr {
    return ((this.menu instanceof BaseCardRadioMenu) ?
    this.menu.radioIconAndText[index].radioIcon : '') as ResourceStr;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }

      if (!this.style) {
        this.style = defaultCardRadioMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof RadioMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu?.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct IconRadioMenuComponent {
  tag: string = 'IconRadioMenuComponent : ';
  menu?: SettingsBaseMenu;
  isAppIconStyle: boolean = false;
  @State controller?: RadioMenuController = undefined;
  style?: CardRadioMenuStyle;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  };

  build() {
    Column() {
      if (this.menu) {
        Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            if (this.isAppIconStyle) {
              Image(this.menu.icon)
                .width(40)
                .height(40)
                .visibility(this.isIconVisible(this.getIcon()))
                .borderRadius($r('sys.float.corner_radius_level5'))
                .interpolation(ImageInterpolation.Medium)
                .border({
                  width: '1px',
                  color: '#99808080',
                })
                .draggable(false);
            } else {
              Image(this.menu.icon)
                .width(40)
                .height(40)
                .visibility(this.isIconVisible(this.getIcon()))
                .draggable(false);
            }
            Text(this.menu.title)
              .margin({ start: PADDING_9 })
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor($r('sys.color.ohos_id_color_foreground'))
              .fontWeight(FontWeight.Medium)
              .width('calc(100% - 49vp)');
          }

          Radio({ value: 'sound', group: 'radioGroup' })
            .checked(this.uiRefresher.refreshId ? this.controller?.isChecked : this.controller?.isChecked)
            .hitTestBehavior(HitTestMode.None)
            .width(20)
            .height(20)
            .id(`icon_radiomenu_radio_${this.menu?.key}`)
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isChecked = isChecked;
              }
            })
            .onClick((event) => {
              LogUtil.info(`${this.tag} isCheckedisCheckedisCheckedisChecked`);
              this.controller?.onRadioChange(true);
            });
        }
        .width('100%')
        .constraintSize({ minHeight: '56vp' })
        .align(Alignment.Start | Alignment.Center)
        .padding(this.style?.padding as Padding)
        .borderRadius(this.style?.borderRadius)
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick((event) => {
          LogUtil.info(`${this.tag} onClick, onClickonClickonClickisChecked=`);
          this.controller?.onRadioChange(true);
        })
        .accessibilityGroup(true)
        .accessibilityText(this.menu?.title as Resource)
        .accessibilityDescription(this.controller?.isChecked ? $r('app.string.be_chosen') :
          $r('app.string.not_selected_click_tips'));
      }
    }
    .clip(true)
    .margin(this.style?.margin)
    .borderRadius(this.style?.borderRadius as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private isIconVisible(icon: Resource | string): Visibility {
    if (icon === undefined) {
      return Visibility.None;
    } else {
      return Visibility.Visible;
    }
  }

  private getIcon(): ResourceStr {
    return ((this.menu instanceof SettingsBaseMenu) ? this.menu.icon : '') as ResourceStr;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu?.parent?.getKey() === 'default_payment_app') {
      this.isAppIconStyle = true;
    }
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }

      if (!this.style) {
        this.style = defaultCardRadioMenuStyle;
      }

      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof RadioMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu?.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct BrowserRadioMenuComponent {
  tag: string = 'BrowserRadioMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: RadioMenuController = undefined;
  style?: CardRadioMenuStyle;
  @State uiRefresher: UiRefresher = new UiRefresher();

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  };

  build() {
    Column() {
      ForEach((this.menu as BaseBrowserRadioMenu).radioIconAndText, (
        radioIconAndText: RadioIconAndText, index: number) => {
        Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Image(radioIconAndText.radioIcon)
              .width(48)
              .height(48)
              .margin({ left: 12 })
              .visibility(this.isIconVisible(this.getIcon(index)))
              .draggable(false);
            Text(radioIconAndText.radioText)
              .margin({ left: 16 })
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontColor($r('sys.color.ohos_id_color_foreground'))
              .fontWeight(FontWeight.Medium);
          }

          Radio({ value: 'sound', group: 'radioGroup' })
            .margin({ right: 14 })
            .checked(radioIconAndText.radioText === (this.menu as BaseBrowserRadioMenu).defaultName ? true : false)
            .width(this.style?.rootContainer?.size?.width as Length)
            .height(24)
            .onClick((event) => {
              this.controller?.onRadioChange(true);
            });
        }
        .accessibilityGroup(true)
        .accessibilityText(radioIconAndText?.radioText?.toString())
        .accessibilityDescription((radioIconAndText?.radioText === (this.menu as BaseBrowserRadioMenu).defaultName) ?
          $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'))
        .width('100%')
        .height(64)
        .align(Alignment.Start | Alignment.Center)
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .padding(this.style?.padding as Padding)
        .stateStyles({
          pressed: this.pressedStyles,
        })
        .onClick((event) => {
          this.controller?.onRadioChange(true);
        });

        if (index === (this.menu as BaseBrowserRadioMenu).radioIconAndText.length - 1) {
          Column() {
          }
        } else {
          Column() {
            Column() {
            }
            .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
            .height(0.5)
            .width('100%')
          }
          .padding({ left: 76, right: 12 })
          .height(0.5)
          .width('100%')
        }

      })
    }
    .clip(true)
    .backgroundColor($r('sys.color.ohos_id_color_background'))
    .borderRadius(this.style?.borderRadius as Length)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private isIconVisible(icon: Resource | string): Visibility {
    if (icon === undefined) {
      return Visibility.None;
    } else {
      return Visibility.Visible;
    }
  }

  private getText(index: number): ResourceStr {
    return ((this.menu instanceof BaseBrowserRadioMenu) ?
    this.menu.radioIconAndText[index].radioText : '') as ResourceStr;
  }

  private getIcon(index: number): ResourceStr {
    return ((this.menu instanceof BaseBrowserRadioMenu) ?
    this.menu.radioIconAndText[index].radioIcon : '') as ResourceStr;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }

      if (!this.style) {
        this.style = defaultCardRadioMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof RadioMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu?.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct RadioMenuComponent {
  tag: string = 'RadioMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State isHover: boolean = false;
  @State controller?: RadioMenuController = undefined;
  style?: CardRadioMenuStyle;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;

  @Styles
  normalStateCardStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
    .borderRadius(this.isHover ? $r('sys.float.corner_radius_level8') : this.style?.borderRadius)
  }

  @Styles
  pressedStateCardStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  @Styles
  normalStateRadioStyles() {
    .backgroundColor(DeviceUtil.isDevicePc() ?
      this.isHover ? $r('sys.color.ohos_id_color_hover') : $r('sys.color.ohos_id_color_switch_bg_off') : null)
  }

  build() {
    Column() {
      if (this.menu) {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Column() {
            Text(this.menu.title)
              .textStyle(this.style?.title)
              .constraintSize({ minHeight: $r('app.float.length_22') })

            Column() {
              Text(this.menu.summary)
                .visibility(this.menu.summary ? Visibility.Visible : Visibility.None)
                .textStyle(this.style?.summary)
                .constraintSize({ minHeight: $r('app.float.length_19') })
            }
            .margin(StyleConstant.getLocalizedPadding(this.style?.summary?.margin as Padding))
          }
          .flexGrow(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            if (this.controller?.isChecked) {
              Radio({
                value: this.menu.getLogKey(),
                group: this.menu.group ? this.menu.group : 'radioGroup'
              })
                .checked(this.controller?.isChecked)
                .onChange((isChecked: boolean) => {
                  if (this.controller) {
                    this.controller.isChecked = isChecked;
                  }
                })
                .radioStyle({
                  checkedBackgroundColor: this.style?.radioStyle?.checkedBackgroundColor ??
                  $r('sys.color.background_emphasize'),
                  uncheckedBorderColor: this.style?.radioStyle?.uncheckedBorderColor ??
                  $r('sys.color.ohos_id_color_switch_outline_off'),
                  indicatorColor: $r('sys.color.ohos_id_color_foreground_contrary')
                })
                .stateStyles({
                  normal: this.normalStateRadioStyles
                })
                .border(DeviceUtil.isDevicePc() ? {
                  width: 2,
                  radius: $r('sys.float.corner_radius_level8'),
                  color: this.isHover ? $r('sys.color.ohos_id_color_hover') : Color.Transparent
                } : {})
                .margin(0)
                .enabled(this.uiRefresher.refreshId ? this.menu?.enable as boolean : this.menu?.enable as boolean)
                .height(this.style?.rootContainer?.size?.height as Length)
                .width(this.style?.rootContainer?.size?.width as Length)
                .padding(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.padding as Padding))
                .hitTestBehavior(HitTestMode.None)
                .responseRegion(this.style?.rootContainer?.responseRegion)
                .id(`radiomenu_radio_${this.menu?.key}`)
                .onClick((event) => {
                  this.controller?.onRadioChange(true)
                })
            }
          }
          .height(this.style?.rootContainer?.size?.height as Length)
          .width(this.style?.rootContainer?.size?.width as Length)
          .margin(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.margin as Padding))
        }
        .constraintSize(this.style?.constraintSize as ConstraintSizeOptions)
        .width(this.style?.size?.width as Length)
        .enabled(this.uiRefresher.refreshId ? this.menu?.enable as boolean : this.menu?.enable as boolean)
        .height(this.style?.size?.height as Length)
        .padding(StyleConstant.getLocalizedPadding(this.style?.padding as Padding))
        .stateStyles({
          normal: this.normalStateCardStyles,
          pressed: this.pressedStateCardStyles,
        })
      }
    }
    .id('RadioMenuComponent_column')
    .enabled(this.uiRefresher.refreshId ? this.menu?.enable as boolean : this.menu?.enable as boolean)
    .padding(StyleConstant.getLocalizedPadding(this.style?.menuContainerPadding as Padding))
    .onTouch((event) => {
      this.onTouchEvent(event);
    })
    .onClick((event) => {
      this.controller?.onRadioChange(true);
    })
    .onHover((isHover: boolean) => {
      this.isHover = isHover;
    })
    .accessibilityLevel(this.menu ? AccessibilityLevelType.YES : AccessibilityLevelType.NO)
    .accessibilityGroup(true)
    .accessibilityText(this.getAccessibilityText(this.menu))
    .accessibilityDescription(this.controller?.isChecked ? TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS :
      TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS)
  }

  private getAccessibilityText(menu: SettingsBaseMenu | undefined): string {
    let text: string = '';
    if (this.controller?.isChecked) {
      text = ResourceUtil.getStringSync($r('app.string.be_chosen')) + ' ';
    }
    text += ResourceUtil.getStringSync(menu?.title);
    if (menu?.summary) {
      text += ' ' + ResourceUtil.getStringSync(menu?.summary);
    }
    return text;
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private getVisibility() {
    if (this.controller?.isChecked) {
      return Visibility.Visible;
    } else {
      return Visibility.Hidden;
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey');
    }
    return this.style?.backgroundColor as ResourceColor;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }
      if (!this.style) {
        this.style = defaultRadioMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof RadioMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct CoalesceRadioMenuComponent {
  tag: string = 'CoalesceRadioMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: SimpleVolumeMenuController = undefined;
  @State style?: CardRadioMenuStyle = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  };

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  };

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.Center }) {
        ForEach((this.menu as BaseCardRadioMenu).radioIconAndText, (radioIconAndText: RadioIconAndText, index:
          number) => {
          Row() {
            Flex({ justifyContent: FlexAlign.Center }) {
              Row() {
                Flex({
                  justifyContent: FlexAlign.Center,
                  alignItems: ItemAlign.Center,
                  direction: FlexDirection.Column
                }) {
                  Image(this.controller?.audioRingMode === (radioIconAndText.extra as number) ?
                  radioIconAndText.radioIconSelect : radioIconAndText.radioIcon)
                    .width(this.style?.rootContainer?.size?.width as Length)
                    .height(this.style?.rootContainer?.size?.height as Length)
                    .fillColor(this.controller?.audioRingMode === (radioIconAndText.extra as number) ?
                    Color.White : $r('sys.color.ohos_id_color_text_primary'))
                    .draggable(false)
                    .margin({ bottom: $r('app.float.margin_13') })
                    .syncLoad(true)
                  Text(radioIconAndText.radioText)
                    .fontSize($r('sys.float.ohos_id_text_size_button2'))
                    .fontColor(this.controller?.audioRingMode === (radioIconAndText.extra as number) ?
                    Color.White : $r('sys.color.ohos_id_color_text_primary'))
                    .opacity(this.controller?.audioRingMode === (radioIconAndText.extra as number) ? 1 : 0.6)
                    .fontWeight(FontWeight.Medium);
                }
              }
            }
          }
          .width(100 / 3 + '%')
          .margin(index === 1 ? { left: '2vp', right: '2vp' } : {})
          .padding({ top: $r('app.float.padding_20'), bottom: $r('app.float.padding_20') })
          .backgroundColor(this.controller?.audioRingMode === (radioIconAndText.extra as number) ?
          $r('sys.color.ohos_id_color_emphasize') :
          $r('sys.color.ohos_id_color_list_card_bg'))
          .onClick((event) => {
            this.controller?.onRadioChange(radioIconAndText.extra);
          })
        })
      }
    }
    .height('96vp')
    .width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    if (this.menu) {
      if (this.menu.style instanceof CardRadioMenuStyle) {
        this.style = this.menu.style;
      }
      if (!this.style) {
        this.style = defaultCardRadioMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof SimpleVolumeMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct DataPanelCircleMenuComponent {
  tag: string = 'DataPanelCircleMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: CommonCircleController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Flex({ justifyContent: FlexAlign.Center }) {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Column({ space: 5 }) {
            DataPanel(this.uiRefresher.refreshId ? {
              values: this.getValues(),
              max: this.getTotalValue(),
              type: DataPanelType.Circle
            } : { values: this.getValues(), max: this.getTotalValue(), type: DataPanelType.Circle })
              .align(Alignment.Center)
              .width(288)
              .height(288)
              .strokeWidth(24)
              .valueColors(this.uiRefresher.refreshId ? this.getValueColors() : this.getValueColors())
          }
          .margin({ top: 5 })

          Column() {
            Row() {
              Blank()
            }
            .layoutWeight(1)

            Row() {
              Column() {
                Blank()
              }
              .layoutWeight(1)

              Text(`${this.uiRefresher.refreshId ? this.getUsedProportion() : this.getUsedProportion()}`)
                .fontSize($r('sys.float.ohos_id_text_size_headline3'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.ohos_id_color_primary'))
                .margin({ end: PADDING_2 })

              Flex({ alignItems: ItemAlign.Baseline }) {
                Text(`${this.uiRefresher.refreshId ? this.getPercentSign() : this.getPercentSign()}`)
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .textOverflow({ overflow: TextOverflow.None })

                Text(' ')
                  .fontSize($r('sys.float.ohos_id_text_size_headline3'))
              }
              .layoutWeight(1)
            }
            .width('100%')

            Row() {
              Text(`${this.uiRefresher.refreshId ? this.getMessage() : this.getMessage()}`)
                .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                .fontColor(Color.Grey)
                .alignSelf(ItemAlign.Start)
                .fontColor($r('sys.color.ohos_id_color_primary'))
                .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
                .fontWeight(FontWeight.Regular)
                .id('circle_text_' + this.menu?.key)
            }
            .layoutWeight(1)
          }
          .width(288)
          .height(288)
          .padding({ bottom: '32vp' })
        }
      }
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as CommonCircleController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }

  getUsedProportion(): number | string {
    return this.controller?.proportion ?? '';
  }

  getPercentSign(): number | string {
    return this.controller?.proportion ? '%' : '';
  }

  getValues(): number[] {
    return this.controller?.categoryValues ?? [];
  }

  getTotalValue(): number {
    return this.controller?.totalValue ?? 1;
  }

  getValueColors(): Array<ResourceColor> {
    return this.controller?.valueColors as Array<ResourceColor> ?? [];
  }

  getMessage(): string {
    return this.controller?.message ?? '';
  }
}

@Component
export struct CircleMenuComponent {
  tag: string = 'CircleMenuComponent : ';
  menu?: SettingsBaseMenu;
  @State controller?: CommonCircleController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      GridContainer({ gutter: 24, margin: 24 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column({ space: 5 }) {
            Progress({ value: this.getUsedProportion(), type: ProgressType.Ring })
              .align(Alignment.Center)
              .width(250)
              .color('#4C89F0')
              .backgroundColor('#E9EBED')
              .height(250)
              .style({ strokeWidth: '24vp' })
          }
          .width(250)
          .height(250)
          .margin({ top: 5 })

          Column() {
            Row() {
              Blank()
            }
            .layoutWeight(1)

            Row() {
              Column() {
                Blank()
              }
              .layoutWeight(1)

              Text(`${this.getUsedProportion()}`)
                .fontSize('50vp')
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.ohos_id_color_primary'))
                .margin({ right: '2vp' })

              Flex({ alignItems: ItemAlign.Baseline }) {
                Text('%')
                  .fontSize('16vp')
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .textOverflow({ overflow: TextOverflow.None })

                Text(' ')
                  .fontSize('50fp')
              }
              .layoutWeight(1)
            }
            .width('100%')

            Row() {
              Text(`${this.getMessage()}`)
                .fontSize('15vp')
                .fontColor(Color.Grey)
                .alignSelf(ItemAlign.Start)
                .fontColor($r('sys.color.ohos_id_color_primary'))
                .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
                .fontWeight(FontWeight.Regular)
                .id('circle_text_' + this.menu?.key)
            }
            .layoutWeight(1)
          }
          .width(250)
          .height(250)
          .padding({ bottom: '32vp' })
        }
      }
      .padding({ bottom: $r('sys.float.ohos_id_elements_margin_vertical_m') })
      .margin({ bottom: '24vp' })
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as CommonCircleController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }

  getUsedProportion(): number {
    LogUtil.info(`${this.tag} this.controller?.proportion ${this.controller?.proportion}`);
    return this.controller?.proportion as number;
  }

  getUsedSpace(): string {
    LogUtil.info(`${this.tag} this.controller?.usedSpace ${this.controller?.usedBytes}`);
    return this.controller?.usedBytes as string;
  }

  getTotalSpace(): string {
    LogUtil.info(`${this.tag} this.controller?.totalSpace ${this.controller?.totalBytes}`);
    return this.controller?.totalBytes as string;
  }

  getMessage(): string {
    LogUtil.info(`${this.tag} this.controller?.message ${this.controller?.message}`);
    return this.controller?.message as string;
  }
}

@Component
export struct PasswordCircleMenuComponent {
  tag: string = 'PasswordCircleMenuComponent : ';
  passwordCircleKey: string = 'passwordCircle';
  isRetailVersion: boolean = PreferencesUtil.getSync(this.passwordCircleKey, false) as boolean;
  menu?: SettingsBaseMenu;
  @State controller?: PasswordCircleController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State pwdInputTextKey: string = '';
  circleAddMargins: number = 36;
  lessThanOneMargin: number = 23.5;

  getWidth(): number {
    let res = 0;
    if( this.controller ) {
      res = this.controller.getPasswordCircle().length * this.circleAddMargins - this.lessThanOneMargin;
    }
    return res;
  }

  build() {
    Column() {
      Row() {
        GridContainer({ gutter: 24, margin: 24 }) {
          Stack() {
            TextInput({ placeholder: '', text: this.controller?.getPassword() })
              .key(this.pwdInputTextKey)
              .opacity(0)// 透明度设为0，避免光标出现
              .fontColor(($r('sys.color.ohos_id_color_text_primary')))
              .inputFilter('[0-9]')
              .textInputStyle(this.getStyle()?.textInputStyle)
              .defaultFocus(this.controller?.isFocus())
              .enabled(!this.isRetailVersion)
              .enableKeyboardOnFocus(true)
              .enableAutoFill(false)
              .onAppear(() => {
                if (!this.controller?.isFocus()) {
                  LogUtil.info(`${this.tag} pwdInputTextKey = ${this.pwdInputTextKey}`);
                  return;
                }
                let isSuccess = focusControl.requestFocus(this.pwdInputTextKey);
                LogUtil.info(`${this.tag} focusControl isSuccess = ${isSuccess},
                pwdInputTextKey = ${this.pwdInputTextKey},
                enableKeyboardOnFocus: ${this.isRetailVersion}`);
              })
              .onChange((value: string) => {
                LogUtil.info(`${this.tag} onChange`);
                this.controller?.onTextInputChange(value);
              })
              .onSubmit((enterKey) => {
                this.controller?.onSubmit(enterKey);
              })// 无需展示眼睛图标，防止点击第五个和第六密码圆圈无法拉起软键盘
              .showPasswordIcon(false)
              .maxLength(this.controller?.getMaxLength())

            List({ space: 24 }) {
              ForEach(this.controller?.getPasswordCircle(), (item: string, index) => {
                ListItem() {
                  Column()
                    .id(this.passwordCircleKey + index)
                    .width(12)
                    .height(12)
                    .backgroundColor(item === '' ? $r('app.color.white') : $r('app.color.black'))
                    .border({ width: 1.5, color: $r('app.color.black'), radius: 25 })
                    .margin({ top: 12 })
                }
              })
            }
            .width(this.getWidth())
            .hitTestBehavior(HitTestMode.Transparent)
            .listDirection(Axis.Horizontal)
          }
          .margin(StyleConstant.getLocalizedPadding(this.getStyle()?.rootContainer?.margin))
          .size(this.getStyle()?.rootContainer?.size)
          .hitTestBehavior(HitTestMode.Block)
          .accessibilityGroup(true)
          .accessibilityText(this.getPasswordReadText())
          .accessibilityDescription(' ')
          .onClick(() => {
            focusControl.requestFocus(this.pwdInputTextKey);
          })
        }
      }
    }
    .focusable(true)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getPasswordReadText(): string {
    let length: number = this.controller?.getPasswordCircle()?.length ?? 0;
    let num: number = this.controller?.getPassword()?.length ?? 0;
    let begin: string = ResourceUtil.getPluralStringValueSync($r('app.plural.password_edit_read_begin'), length);
    let end: string = ResourceUtil.getPluralStringValueSync($r('app.plural.password_edit_read_end'), num);
    return `${begin} ${end}`;
  }

  private getMenu(): SettingsBaseMenu {
    return this.menu as SettingsBaseMenu;
  }

  private getStyle(): PasswordCircleMenuStyle {
    return this.getMenu().style as PasswordCircleMenuStyle;
  }

  aboutToAppear(): void {
    if (this.menu) {
      LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu.getLogKey()}`);
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof PasswordCircleController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
        this.pwdInputTextKey = (!!this.controller && !!this.controller.getTextInputKey()) ?
        this.controller.getTextInputKey() : `PasswdTextInputKey_${this.menu?.key}`;
      } else {
        LogUtil.warn(`${this.tag} controller null, ${this.menu.getLogKey()}`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PatternPasswordMenuComponent {
  private TAG: string = 'PatternPasswordMenuComponent: ';
  private patternLockController: PatternLockController = new PatternLockController();
  menu?: SettingsBaseMenu;
  @State controller?: PatternPasswordController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  aboutToAppear(): void {
    if (this.menu) {
      let controller: Controller = this.menu?.createController() as Controller;
      if (controller instanceof PatternPasswordController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.setPatternLockController(this.patternLockController);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${this.TAG} controller null, PatternPasswordMenuComponent`);
      }
    }
  }

  @Builder
  buildContent() {
    Column() {
      PatternLock(this.patternLockController)
        .sideLength(288)
        .circleRadius(6)
        .pathStrokeWidth(12)
        .backgroundColor($r('app.color.transparent'))
        .autoReset(true)
        .onDotConnect((index: number) => {
          this.controller?.onDotConnect(index);
        })
        .onPatternComplete((input: Array<number>) => {
          this.controller?.onPatternComplete(input);
        })
        .margin({ top: 110 })
    }.width('100%')
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  build() {
    this.buildContent();
  }
}

@Component
export struct PasswordUnderLineTextInputMenuComponent {
  tag: string = 'PasswordUnderLineTextInputMenuComponent : ';
  passwordCircleKey: string = 'passwordCircle';
  isRetailVersion: boolean = PreferencesUtil.getSync(this.passwordCircleKey, false) as boolean;
  @State menu: UnderLineTextInputBaseMenu | undefined = undefined;
  @State controller?: TextInputMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isEditing: boolean = false;
  textInputController: TextInputController = new TextInputController();

  build() {
    if (this.uiRefresher.isRender) {
      if (DeviceUtil.isDevicePad()) {
        this.buildTextInputPad();
      } else {
        this.buildTextInputPhone();
      }
    }
  }

  @Builder
  buildTextInputPhone() {
    Column() {
      if (this.menu) {
        Text(this.menu?.summary)
          .visibility(this.menu?.summary ? Visibility.Visible : Visibility.None)
          .textStyle(this.getStyle()?.summaryStyle)
        TextInput({ placeholder: this.menu?.hint, text: this.menu?.title, controller: this.textInputController })
          .defaultFocus(true)
          .enableKeyboardOnFocus(true)
          .enableAutoFill(false)
          .textInputStyle(this.getStyle()?.textInputStyle)
          .key(this.menu.key)
          .enabled(!this.isRetailVersion)
          .onChange((input: string) => {
            if (this.menu) {
              this.menu.title = input;
            }
            this.controller?.onTextInputChange(input);
          })
          .onEditChange((isEditing: boolean) => {
            this.controller?.onEditChange(isEditing);
            this.isEditing = isEditing;
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.controller?.onSubmit(enterKey);
          })
          .onClick((event) => {
            this.controller?.onMenuClick();
          });
        Divider()
          .strokeWidth('1px')
          .color(this.isEditing ? $r('sys.color.ohos_id_color_text_primary') :
          $r('sys.color.ohos_id_color_list_separator'))
          .opacity(this.isEditing ? 0.6 : 1);
      }
    }
    .enabled(this.menu?.enable ? true : false)
    .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0)
    .margin(this.getStyle()?.rootContainer?.margin ?? 0)
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  @Builder
  buildTextInputPad() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Column() {
        if (this.menu) {
          Text(this.menu?.summary)
            .visibility(this.menu?.summary ? Visibility.Visible : Visibility.None)
            .textStyle(this.getStyle()?.summaryStyle)
          TextInput({ placeholder: this.menu?.hint, text: this.menu?.title, controller: this.textInputController })
            .defaultFocus(true)
            .enableKeyboardOnFocus(true)
            .enableAutoFill(false)
            .textInputStyle(this.getStyle()?.textInputStyle)
            .key(this.menu.key)
            .enabled(!this.isRetailVersion)
            .onChange((input: string) => {
              if (this.menu) {
                this.menu.title = input;
              }
              this.controller?.onTextInputChange(input);
            })
            .onEditChange((isEditing: boolean) => {
              this.controller?.onEditChange(isEditing);
              this.isEditing = isEditing;
            })
            .onSubmit((enterKey: EnterKeyType) => {
              this.controller?.onSubmit(enterKey);
            })
            .onClick((event) => {
              this.controller?.onMenuClick();
            });
          Divider()
            .strokeWidth('1px')
            .color(this.isEditing ? $r('sys.color.ohos_id_color_text_primary') :
            $r('sys.color.ohos_id_color_list_separator'))
            .opacity(this.isEditing ? 0.6 : 1);
        }
      }
      .width('75%')
      .enabled(this.menu?.enable ? true : false)
      .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
      .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
      .margin(this.getStyle()?.rootContainer?.margin ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
      .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
  }

  private getMenu(): UnderLineTextInputBaseMenu {
    return this.controller ? this.controller.menu as UnderLineTextInputBaseMenu :
      this.menu as UnderLineTextInputBaseMenu;
  }

  private getStyle(): UnderLineTextInputMenuStyle {
    return this.getMenu().style as UnderLineTextInputMenuStyle;
  }

  aboutToAppear() {
    LogUtil.info(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}, enableKeyboardOnFocus: ${this.isRetailVersion}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as TextInputMenuController;
    this.controller?.setTextInputController(this.textInputController);
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct UnderLineTextInputMenuComponent {
  tag: string = 'UnderLineTextInputMenuComponent : ';
  menu?: UnderLineTextInputBaseMenu;
  @State controller?: DialogChainTextInputController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isEditing: boolean = false;

  build() {
    if (this.uiRefresher.isRender) {
      Column() {
        Text(this.getMenu()?.summary)
          .visibility(this.getMenu()?.summary ? Visibility.Visible : Visibility.None)
          .textStyle(this.getStyle()?.summaryStyle)
        TextInput({ placeholder: this.getMenu()?.hint, text: this.getMenu()?.title })
          .defaultFocus(true)
          .textInputStyle(this.getStyle()?.textInputStyle)
          .type(this.controller?.isChecked ? InputType.Normal : InputType.Number)
          .key(this.menu?.key as string)
          .onChange((input: string) => {
            if (this.menu) {
              this.menu.title = input;
            }
            this.controller?.onTextInputChange(input);
          })
          .onEditChange((isEditing: boolean) => {
            this.controller?.onEditChange(isEditing);
            this.isEditing = isEditing;
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.controller?.onSubmit(enterKey);
          })
          .onClick((event) => {
            this.controller?.onMenuClick();
          });
        Divider()
          .strokeWidth(this.isEditing ? 2 : 1)
          .color(this.isEditing ? $r('sys.color.ohos_id_color_text_primary') :
          $r('sys.color.ohos_id_color_list_separator'))
          .opacity(this.isEditing ? 0.6 : 1);
      }
      .enabled(this.getMenu()?.enable ? true : false)
      .alignItems(this.getStyle()?.rootContainer?.horizontalAlign)
      .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
      .padding(this.getStyle()?.rootContainer?.padding ?? 0)
      .margin(this.getStyle()?.rootContainer?.margin ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
      .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
  }

  private getMenu(): UnderLineTextInputBaseMenu {
    return this.controller ? this.controller.menu as UnderLineTextInputBaseMenu :
      this.menu as UnderLineTextInputBaseMenu;
  }

  private getStyle(): UnderLineTextInputMenuStyle {
    return this.getMenu().style as UnderLineTextInputMenuStyle;
  }

  aboutToAppear() {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as DialogChainTextInputController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SelectEntryMenuComponent {
  tag: string = 'SelectEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: EntryMenuStyle = undefined;
  @State controller?: MenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      SelectEntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher
      });
    }
    .enabled(this.menu?.enable as boolean && !this.menu?.isGrayed as boolean)
    .opacity((this.menu?.enable && !this.menu?.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .onClick(() => {
      this.onEntryClick();
    })
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover as boolean);
    })
    .padding({ left: $r('app.float.padding_4'), right: $r('app.float.padding_4') })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  aboutToAppear(): void {
    if (this.menu) {
      LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu.getLogKey()}`);
      this.style = this.menu?.style as EntryMenuStyle;
      this.controller = this.menu.getControllerInstance(this.uiRefresher) as MenuController;
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SelectImageMenuComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: MultiCheckImageMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;
  style?: SelectImageMenuStyle;

  build() {
    Column() {
      if (this.menu) {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Column() {
            Text(this.menu.title)
              .textStyle(this.style?.title)
            Text(this.menu.summary)
              .visibility(this.menu.summary ? Visibility.Visible : Visibility.None)
              .textStyle(this.style?.summary)
              .padding(this.style?.summary?.padding as Padding);
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Image(this.menu.stateIcon)
              .id(`SelectImageMenuComponent_icon_${this.menu?.key}`)
              .visibility(this.menu.status ? Visibility.Visible : Visibility.None)
              .imageStyle(this.style?.imageIcon)
              .fillColor(this.style?.imageIcon?.imageColor);
          }
          .flexGrow(1)
          .alignItems(HorizontalAlign.End)
        }
        .width(this.style?.size?.width as Length)
        .height(this.style?.size?.height as Length)
        .padding(this.style?.padding as Padding)
        .backgroundColor(this.getBackgroundColor())
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
        .stateStyles({
          normal: normalStateIconStyles,
          pressed: pressedStateIconStyles,
        })
      }
    }
    .padding(this.style?.menuContainerPadding as Padding)
    .onTouch((event) => {
      this.onTouchEvent(event);
    })
    .onClick((event) => {
      this.controller?.onMenuChange(!this.controller?.isSelected);
    });
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey');
    }
    return this.style?.backgroundColor as ResourceColor;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} SelectImageMenuComponent: aboutToAppear`);
    if (this.menu) {
      if (this.menu.style instanceof SelectImageMenuStyle) {
        this.style = this.menu.style;
      }
      if (!this.style) {
        this.style = defaultSelectImageMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof MultiCheckImageMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${TAG} SelectImageMenuComponent: controller null`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} SelectImageMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct MultiCheckboxMenuComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: MultiCheckboxMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;
  style?: CheckboxMenuStyle;

  build() {
    Column() {
      if (this.menu) {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Column() {
            Column() {
              Text(this.menu.title)
                .textStyle(this.style?.title)
            }

            Column() {
              Text(this.menu.summary)
                .visibility(this.menu.summary ? Visibility.Visible : Visibility.None)
                .textStyle(this.style?.summary)
                .padding(this.style?.summary?.padding as Padding);
            }
          }
          .flexGrow(1)
          .alignItems(HorizontalAlign.Start)

          Checkbox({ name: this.menu.getLogKey(), group: 'checkboxGroup' })
            .select(this.controller?.isSelected ? true : false)
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isSelected = isChecked;
              }
            })
            .width(this.style?.rootContainer?.size?.width as Length)
            .height(this.style?.rootContainer?.size?.height as Length)
            .padding(this.style?.rootContainer?.padding as Padding)
            .margin(this.style?.rootContainer?.margin as Padding)
            .responseRegion(this.style?.rootContainer?.responseRegion)
            .selectedColor(this.style?.rootContainer?.selectColor as ResourceColor)
            .unselectedColor(this.style?.rootContainer?.borderColor as ResourceColor)
            .mark(this.style?.mark as MarkStyle)
            .opacity(this.style?.opacity as number | Resource)
            .id(`checkboxmenu_checkbox_${this.menu?.key}`)
            .onClick((event) => {
              this.controller?.onMenuChange(this.controller?.isSelected)
            });
        }
        .width(this.style?.size?.width as Length)
        .height(this.style?.size?.height as Length)
        .padding(this.style?.padding as Padding)
        .backgroundColor(this.getBackgroundColor())
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
        .stateStyles({
          normal: normalStateIconStyles,
          pressed: pressedStateIconStyles,
        })
      }
    }
    .padding(this.style?.menuContainerPadding as Padding)
    .onTouch((event) => {
      this.onTouchEvent(event);
    })
    .onClick((event) => {
      this.controller?.onMenuChange(!this.controller?.isSelected);
    });
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey');
    }
    return this.style?.backgroundColor as ResourceColor;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} CheckboxMenuComponent: aboutToAppear`);
    if (this.menu) {
      if (this.menu.style instanceof CheckboxMenuStyle) {
        this.style = this.menu.style;
      }
      if (!this.style) {
        this.style = defaultCheckboxMenuStyle;
      }
      let controller: Controller = this.menu.createController() as Controller;
      if (controller instanceof MultiCheckboxMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${TAG} CheckboxMenuComponent: controller null`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} CheckboxMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct CheckboxMenuComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: CheckboxMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSelected: boolean = false;
  style?: DefaultEntryMenuStyle;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Checkbox()
          .id('CheckboxMenu_checkbox')
          .width(this.style?.iconImage?.size?.width ?? 20)
          .height(this.style?.iconImage?.size?.height ?? 20)
          .select(this.isSelected)
          .selectedColor($r('sys.color.ohos_id_color_component_activated'))
          .onChange((value: boolean) => {
            if (this.getStyle()?.isTextHotspot) {
              this.isSelected = value;
            }
            this.onEntryChange(value);
            LogUtil.info(`${TAG} CheckboxMenuComponent`);
          })
          .margin({
            top: this.style?.iconImage?.margin?.top ?? 8,
            bottom: this.style?.iconImage?.margin?.bottom ?? 20,
            left: this.style?.iconImage?.margin?.left ?? 14,
            right: this.style?.iconImage?.margin?.right ?? 2,
          });

        Text(this.menu?.summary)
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .constraintSize(this.getStyle()?.summary?.constraintSize)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .maxLines(this.style?.summary?.maxLines)
          .wordBreak(WordBreak.BREAK_WORD)
          .textOverflow({ overflow: this.style?.summary?.overflow ?? TextOverflow.None })
          .onClick(() => {
            if (this.getStyle()?.isTextHotspot) {
              this.isSelected = !this.isSelected;
              this.onEntryChange(this.isSelected);
              LogUtil.info(`${TAG} CheckboxMenuComponent`);
            }
          })
          .margin({
            left: this.style?.summary?.margin?.left ?? 12,
            right: this.style?.summary?.margin?.right ?? 12,
            top: this.style?.summary?.margin?.top ?? 5,
            bottom: this.style?.summary?.margin?.bottom ?? 5
          })
      }
      .width('100%')
    }
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .margin({
      left: this.style?.rootContainer?.margin?.left ?? 12,
      right: this.style?.rootContainer?.margin?.right ?? 12,
      top: this.style?.rootContainer?.margin?.top ?? 8,
      bottom: this.style?.rootContainer?.margin?.bottom ?? 8
    })
  }

  private onEntryChange(value: boolean): void {
    LogUtil.info(`${TAG} CheckboxMenuComponent: onEntryChange`);
    if (this.controller) {
      this.controller.onMenuChange(value);
    }
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): DefaultEntryMenuStyle {
    return this.getMenu().style as DefaultEntryMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToAppear`);
    if (this.menu) {
      if (this.menu?.style instanceof DefaultEntryMenuStyle) {
        this.style = this.menu?.style;
      }
      let controller: Controller | null = this.menu ? this.menu.createController() : null;
      if (controller instanceof CheckboxMenuController) {
        this.controller = controller;
        this.controller.bindUi(this.uiRefresher);
        this.controller.aboutToAppear();
      } else {
        LogUtil.warn(`${TAG} CheckboxMenuComponent: controller null`);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct CheckboxOptionMenuComponent {
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State menu?: SettingsBaseMenu = undefined;
  @State isTouching: boolean = false;
  @State isHover: boolean = false;
  style?: BaseCheckboxOptionStyle = undefined;
  controller?: MenuController = undefined;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
    .borderRadius(this.isHover ? $r('sys.float.corner_radius_level8') : this.style?.borderRadius)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  aboutToAppear() {
    if (this.menu?.style && this.menu?.style instanceof BaseCheckboxOptionStyle) {
      this.style = this.menu?.style as BaseCheckboxOptionStyle;
    }
    this.controller = this.menu?.createController() as MenuController;
    this.controller?.bindUi(this.uiRefresher);
    this.controller?.aboutToAppear();
  }

  aboutToDisappear() {
    this.controller?.aboutToDisappear();
  }

  build() {
    Column() {
      if (this.menu) {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Column() {
            Text(this.menu.title)
              .textStyle(this.style?.titleStyle)
            Text(this.menu.summary)
              .visibility(this.menu.summary ? Visibility.Visible : Visibility.None)
              .textStyle(this.style?.summaryStyle)
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Checkbox()
              .id('checkboxOptionMenu_checkbox')
              .select(true)
              .touchable(false)
              .visibility(this.menu.status ? Visibility.Visible : Visibility.None);
          }
          .flexGrow(1)
          .alignItems(HorizontalAlign.End)
        }
        .width(this.style?.size?.width as Length)
        .height(this.style?.size?.height as Length)
        .padding(this.style?.padding as Padding)
      }
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isTouching ? $r('sys.color.ohos_id_color_click_effect') : this.style?.backgroundColor)
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStateIconStyles,
    })
    .size(this.style?.size)
    .constraintSize(this.style?.constraintSize)
    .padding(this.style?.padding as Padding)
    .margin(this.style?.margin as Margin)
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouching = true;
      } else if (event.type === TouchType.Up) {
        this.isTouching = false;
      }
    })
    .onClick(() => {
      this.controller?.onMenuClick();
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    });
  }
}

@Component
export struct PcCheckboxMenuDiaLogComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: CheckboxMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Checkbox()
          .width('20vp')
          .height('20vp')
          .select(false)
          .selectedColor($r('sys.color.ohos_id_color_component_activated'))
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .onChange((value: boolean) => {
            this.onEntryChange(value);
            this.controller?.publishDataChange(value);
            LogUtil.info(`${TAG} CheckboxMenuComponent`);
          })
          .margin({ left: '16vp', top: '12vp', bottom: '12vp', right: '12vp' });

        Text(this.menu?.summary)
          .width('100%')
          .fontSize('14vp')
          .lineHeight('19vp')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
      }
      .width('100%')
      .height(48)
      .margin({ left: 12, right: 12, top: 0, bottom: 0 })
      .padding({ left: 0, right: 0, top: 0, bottom: 0 })
    }
  }

  private onEntryChange(value: boolean): void {
    LogUtil.info(`${TAG} CheckboxMenuComponent: onEntryChange`);
    if (this.controller) {
      this.controller.onMenuChange(value);
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToAppear`);
    let controller: Controller | null = this.menu ? this.menu.createController() : null;
    if (controller instanceof CheckboxMenuController) {
      this.controller = controller;
      this.controller.bindUi(this.uiRefresher);
      this.controller.aboutToAppear();
    } else {
      LogUtil.warn(`${TAG} CheckboxMenuComponent: controller null`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct PhoneCheckboxMenuDiaLogComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: CheckboxMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Checkbox()
          .id('PhoneCheckboxMenuDiaLog_checkbox')
          .width('19vp')
          .height('19vp')
          .select(false)
          .shape(CheckBoxShape.ROUNDED_SQUARE)
          .selectedColor($r('sys.color.ohos_id_color_component_activated'))
          .onChange((value: boolean) => {
            this.onEntryChange(value);
            this.controller?.publishDataChange(value);
            LogUtil.info(`${TAG} CheckboxMenuComponent`);
          })
          .margin({ left: 0, top: '15vp', bottom: '17vp', right: '13vp' });

        Text(this.menu?.summary)
          .fontSize('16vp')
          .lineHeight('19vp')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .margin({ right: '10vp', top: '17vp', bottom: '17vp' })
      }
      .width('100%')
      .height(56)
      .margin({ left: 0, right: 12, top: 0, bottom: 0 })
      .padding({ left: '6vp', right: 12, top: 0, bottom: 0 })
    }
  }

  private onEntryChange(value: boolean): void {
    LogUtil.info(`${TAG} CheckboxMenuComponent: onEntryChange`);
    if (this.controller) {
      this.controller.onMenuChange(value);
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToAppear`);
    let controller: Controller | null = this.menu ? this.menu.createController() : null;
    if (controller instanceof CheckboxMenuController) {
      this.controller = controller;
      this.controller.bindUi(this.uiRefresher);
      this.controller.aboutToAppear();
    } else {
      LogUtil.warn(`${TAG} CheckboxMenuComponent: controller null`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} CheckboxMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}


@Component
export struct ButtonWithVariableTitleMenuComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: ButtonWithVariableTitleMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State menuTitle: string = '';

  build() {
    GridContainer({
      columns: this.getColumns(),
      sizeType: SizeType.Auto,
      gutter: this.getStyle()?.rootContainer?.gridGutter as string | number ?? '16vp',
      margin: this.getStyle()?.rootContainer?.gridMargin as string | number ?? '4vp',
    }) {
      Row() {
        Column() {
          Button(this.uiRefresher.refreshId ? this.updateMenuTitle() : this.updateMenuTitle())
            .visibility(this.updateMenuTitle() ? Visibility.Visible : Visibility.None)
            .customButtonStyle(this.getStyle()?.buttonStyle as ButtonStyle)
            .opacity(this.controller?.isButtonEnabled() ? 1 : 0.4)
            .enabled(this.controller?.isButtonEnabled() ? true : false)
            .onClick((event) => {
              this.controller?.onButtonClick();
            });
        }
        .gridSpan(this.getButtonSpan())
        .gridOffset(this.getButtonOffset());
      }
      .width('100%');
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private updateMenuTitle(): ResourceStr {
    return this.menu?.title as ResourceStr;
  }

  private getColumns(): number {
    if (this.getStyle()?.rootContainer?.gridColumns) {
      return this.getStyle()?.rootContainer?.gridColumns as number;
    }
    let columns = 0;
    if (this.updateMenuTitle()) {
      columns++;
    }
    return columns;
  }

  private getButtonSpan(): number {
    return (this.updateMenuTitle()) ? (this.getStyle()?.buttonStyle?.gridSpan ?? 1) : 0;
  }

  private getButtonOffset(): number {
    if (!this.updateMenuTitle()) {
      return this.getColumns();
    }
    return this.getStyle()?.buttonStyle?.gridOffset ?? 0;
  }

  private getStyle(): PhoneCommonButtonMenuStyle {
    return this.menu?.style as PhoneCommonButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} ButtonWithVariableTitleMenuComponent: aboutToAppear`);
    let controller: Controller | null = this.menu ? this.menu.createController() : null;
    if (controller instanceof ButtonWithVariableTitleMenuController) {
      this.controller = controller;
      this.controller.bindUi(this.uiRefresher);
      this.controller.aboutToAppear();
    } else {
      LogUtil.warn(`${TAG} ButtonWithVariableTitleMenuComponent: controller null`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} ButtonWithVariableTitleMenuComponent: aboutToDisappear`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct UnderLineEditMenuComponent {
  tag: string = 'UnderLineEditMenuComponent : ';
  menu?: UnderLineEditMenu;
  @State controller?: TextInputMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isShowPasswordIcon: boolean = false;

  build() {
    Column() {
      Column() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(this.getMenu()?.summary)
            .visibility(this.getMenu()?.summary ? Visibility.Visible : Visibility.None)
            .textStyle(this.getStyle()?.summaryStyle);

          TextInput({
            placeholder: this.getMenu()?.hint,
            text: this.uiRefresher.refreshId ? this.getMenu()?.title : this.getMenu()?.title
          })
            .defaultFocus(true)
            .textInputStyle(this.getStyle()?.textInputStyle)
            .showPasswordIcon(this.isShowPasswordIcon)
            .translate({
              x: this.isShowPasswordIcon ? '16vp' : '0vp' // 抵消密码框icon默认内边距
            })
            .id(`underline_title_${this.menu?.key}`)
            .onChange((input: string) => {
              if (this.menu) {
                this.menu.title = input;
              }
              this.controller?.onTextInputChange(input);
            })
            .onEditChange((isEditing: boolean) => {
              if (this.getStyle()?.textInputStyle?.inputType === InputType.Password) {
                this.isShowPasswordIcon = isEditing;
              }
              this.controller?.onEditChange(isEditing);
            })
            .onSubmit((enterKey: EnterKeyType) => {
              this.controller?.onSubmit(enterKey);
            })
            .onClick((event) => {
              this.controller?.onMenuClick();
            });
        }
      }
      .justifyContent(this.getStyle()?.rootContainer?.justifyContent ?? FlexAlign.Center)
      .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
      .padding(this.getStyle()?.rootContainer?.padding ?? 0)
      .margin(this.getStyle()?.rootContainer?.margin ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
      .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
    .padding({ left: $r('app.float.padding_4'), right: $r('app.float.padding_4') });
  }

  private getMenu(): UnderLineEditMenu {
    return this.controller ? this.controller.menu as UnderLineEditMenu : this.menu as UnderLineEditMenu;
  }

  private getStyle(): UnderLineEditMenuStyle {
    return this.getMenu().style as UnderLineEditMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as TextInputMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Extend(Button)
function customButtonStyle(buttonStyle: ButtonStyle) {
  .width(buttonStyle?.size?.width as Length)
  .borderRadius(buttonStyle?.borderRadius ?? $r('sys.float.corner_radius_level10'))
  .constraintSize({ minHeight: buttonStyle?.size?.height as Length })
  .backgroundColor(buttonStyle?.backgroundColor)
  .constraintSize(buttonStyle?.constraintSize)
  .padding(buttonStyle?.padding ? StyleConstant.getLocalizedPadding(buttonStyle?.padding) : 0)
  .margin(buttonStyle?.margin ? StyleConstant.getLocalizedPadding(buttonStyle?.margin) : 0)
  .fontColor(buttonStyle?.fontColor)
}


@Extend(Button)
function buttonDivideStyle(buttonStyle: ButtonStyle) {
  .width(buttonStyle?.size?.width as Length)
  .borderRadius('20vp')
  .constraintSize({minHeight:buttonStyle?.size?.height as Length})
  .backgroundColor(buttonStyle?.backgroundColor)
  .constraintSize(buttonStyle?.constraintSize)
  .padding(buttonStyle?.padding ?? 0)
  .fontColor(buttonStyle?.fontColor)
}

@Extend(Image)
function imageStyle(imageStyle?: ImageStyle) {
  .width(imageStyle?.size?.width as Length)
  .height(imageStyle?.size?.height as Length)
  .constraintSize(imageStyle?.constraintSize)
  .padding(imageStyle?.padding ? StyleConstant.getLocalizedPadding(imageStyle?.padding) : 0)
  .margin(imageStyle?.margin ? StyleConstant.getLocalizedPadding(imageStyle?.margin) : 0)
  .layoutWeight(imageStyle?.layoutWeight ?? 0)
  .objectFit(imageStyle?.imageFit ?? ImageFit.Contain)
  .align(imageStyle?.align)
  .draggable(false)
}

@Extend(SymbolGlyph)
function symbolGlyphStyle(symbolGlyphStyle?: SymbolGlyphStyle) {
  .width(symbolGlyphStyle?.size?.width as Length)
  .height(symbolGlyphStyle?.size?.height as Length)
  .constraintSize(symbolGlyphStyle?.constraintSize)
  .padding(symbolGlyphStyle?.padding ?? 0)
  .margin(symbolGlyphStyle?.margin ?? 0)
  .borderRadius(symbolGlyphStyle?.borderRadius ?? 12)
  .borderWidth(symbolGlyphStyle?.borderWidth ?? 0)
  .borderColor(symbolGlyphStyle?.borderColor ?? 0)
  .layoutWeight(symbolGlyphStyle?.layoutWeight ?? 0)
  .opacity(symbolGlyphStyle?.opacity ?? 1)
  .renderingStrategy(symbolGlyphStyle?.renderingStrategy ?? SymbolRenderingStrategy.SINGLE)
  .draggable(false)
  .fontColor([$r('sys.color.ohos_id_color_primary')])
  .fontWeight(symbolGlyphStyle?.fontWeight)
  .fontSize($r('app.float.length_24'))
}

@Extend(Text)
function textStyle(textStyle?: TextStyle) {
  .width(textStyle?.size?.width as Length)
  .height(textStyle?.size?.height as Length)
  .constraintSize(textStyle?.constraintSize)
  .padding(textStyle?.padding ?? 0)
  .margin(textStyle?.margin ?? 0)
  .layoutWeight(textStyle?.layoutWeight ?? 0)
  .fontColor(textStyle?.fontColor)
  .fontSize(textStyle?.font?.size)
  .fontWeight(textStyle?.font?.weight)
  .fontFamily(textStyle?.font?.family)
  .fontStyle(textStyle?.font?.style)
  .textAlign(textStyle?.textAlign ?? TextAlign.Start)
  .textOverflow({ overflow: textStyle?.overflow ?? TextOverflow.Ellipsis })
  .maxLines(textStyle?.maxLines)
  .align(textStyle?.align)
  .backgroundColor(textStyle?.backgroundColor)
  .borderRadius(textStyle?.borderRadius as Length)
}

@Extend(Toggle)
function toggleStyle(toggleStyle: SwitchToggleStyle) {
  .constraintSize(toggleStyle?.constraintSize)
  .padding(toggleStyle?.padding ?? 0)
  .margin(toggleStyle?.margin ?? 0)
}

@Extend(TextInput)
function textInputStyle(textInputStyle?: TextInputStyle) {
  .type(textInputStyle?.inputType)
  .copyOption(textInputStyle?.inputType === InputType.Password ? CopyOptions.None : CopyOptions.LocalDevice)
  .placeholderColor(textInputStyle?.placeholderColor)
  .placeholderFont(textInputStyle?.placeholderFont)
  .caretColor(textInputStyle?.caretColor)
  .size(textInputStyle?.size)
  .constraintSize(textInputStyle?.constraintSize)
  .borderRadius(textInputStyle?.borderRadius as Length)
  .padding(StyleConstant.getLocalizedPadding(textInputStyle?.padding as Padding))
  .margin(StyleConstant.getLocalizedPadding(textInputStyle?.margin as Padding))
  .maxLength(textInputStyle?.maxLength ?? 1000)
  .backgroundColor(textInputStyle?.backgroundColor)
  .textAlign(textInputStyle?.textAlign)
  .direction(textInputStyle?.direction)
  .fontColor(textInputStyle?.fontColor)
  .fontSize(textInputStyle?.fontSize?.size)
  .fontFamily(textInputStyle?.fontSize?.family)
  .fontWeight(textInputStyle?.fontSize?.weight)
  .showUnderline(textInputStyle?.showUnderline ?? false)
}

@Component
export struct FlatEntryMenuComponent {
  tag: string = 'FlatEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  style?: DefaultEntryMenuStyle = undefined;
  controller?: MenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    TitleSummaryEntryComponent({
      menu: $menu,
      style: this.style,
      controller: this.controller,
      uiRefresher: $uiRefresher,
    });
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as DefaultEntryMenuStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct AppListEntryMenuComponent {
  tag: string = 'AppListEntryMenuComponent : ';
  style?: AppStyle = undefined;
  controller?: MenuController = undefined;
  @State menu?: SettingsBaseMenu = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;

  @Styles
  normalStyles() {
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    Column() {
      AppListEntryComponent({
        menu: $menu,
        style: this.style,
        controller: this.controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      });
    }
    .enabled(true)
    .opacity(OPACITY_PERCENT_FULL)
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover ? true : false);
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .visibility(Visibility.Visible);
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as AppStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SettingHomeEntryMenuComponent {
  tag: string = 'SettingHomeEntryMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: DefaultEntryMenuStyle = undefined;
  @State controller?: MenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isSecondSelected: boolean = false;

  build() {
    SettingHomeEntryComponent({
      menu: $menu,
      style: $style,
      controller: $controller,
      uiRefresher: $uiRefresher,
      isSecondSelected: this.isSecondSelected,
      pathInfos: this.pathInfos,
    });
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style as DefaultEntryMenuStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct SingleChoiceMenuComponent {
  tag: string = 'SingleChoiceMenuComponent : ';
  @State menu?: SingleChoiceEntryMenu = undefined;
  @State style?: SingleChoiceMenuStyle = undefined;
  @State controller?: SingleChoiceListController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
        showSelectedBackColor: false
      }).bindMenu(this.dialogBuilder, { placement: this.style?.placement,
        onAppear: () => {
          this.controller?.onBindMenuAppear();
        }, onDisappear: () => {
          this.controller?.onBindMenuDisAppear();
        }
      });
    }
    .constraintSize(this.style?.singleChoiceRootContainer?.constraintSize)
    .padding({
      top: this.style?.singleChoiceRootContainer?.padding?.top,
      bottom: this.style?.singleChoiceRootContainer?.padding?.bottom
    })
    .enabled(this.menu?.enable as boolean)
    .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_SIXTY)
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover ? true : false);
    })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as SingleChoiceMenuStyle;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SingleChoiceListController;
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }

  isVisible(item: SingleSelectMenuItem): Visibility {
    return item.isSelect ? Visibility.Visible : Visibility.Hidden
  }

  @Builder
  dialogBuilder() {
    Column() {
      ForEach(this.menu?.singleChoiceData, (item: SingleSelectMenuItem, index: number) => {
        Column() {
          Row() {
            Text(item?.title)
              .id(`SingleChoiceMenuItem_title_${this.menu?.key}_${item?.key}`)
              .fontWeight(this.style?.title?.font?.weight)
              .fontFamily(this.style?.title?.font?.family)
              .fontColor(this.style?.title.fontColor)
              .fontSize(this.style?.title?.font?.size)
              .wordBreak(WordBreak.BREAK_WORD)
              .constraintSize({minHeight: this.style?.menuItemHeight})
              .layoutWeight(1)
              .direction(LanguageUtils.isLtrDirection() ? Direction.Ltr : Direction.Rtl)

            Image(this.menu?.selectIcon)
              .id(`SingleChoiceMenuItem_icon_${this.menu?.key}_${item?.key}`)
              .margin({ left: this.style?.menuItemIconMargin })
              .width(this.style?.menuItemIconSize)
              .height(this.style?.menuItemIconSize)
              .visibility(this.uiRefresher.refreshId ? this.isVisible(item) : this.isVisible(item))
              .fillColor((this.style as SingleChoiceMenuOnlyStyle)?.selectIconColor || $r('sys.color.icon_primary'))
          }

          Divider()
            .strokeWidth(this.style?.dividerWidth as string | number)
            .color(this.style?.dividerColor)
            .visibility(this.menu?.singleChoiceData?.length !== undefined &&
              this.menu?.singleChoiceData?.length - 1 === index ? Visibility.Hidden : Visibility.Visible)
        }
        .accessibilityText(((this.uiRefresher.refreshId ? item.isSelect : item.isSelect) ?
          ResourceUtil.getStringSync($r('app.string.be_chosen')) + ' ' : '') +
        ResourceUtil.getStringSync(item?.title as Resource))
        .accessibilityGroup(true)
        .accessibilityDescription((this.uiRefresher.refreshId ? item.isSelect : item.isSelect) ?
          TALKBACK_NOT_SUPPORT_DEFAULT_CLICK_TIPS : TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS)
        .id(`SingleChoiceMenuItem_${this.menu?.key}_${item?.key}`)
        .onClick(() => {
          AccessibilityUtils.announceRadioSelected();
          this.controller?.onSelectMenuChanged(item?.key as number);
        }, px2vp(ONCLICK_DISTANCE_THRESHOLD));
      });
    }.width(this.style?.menuItemWidth)
    .padding({ left: this.style?.menuItemPaddingLeft, right: this.style?.menuItemPaddingRight })
  }
}

@Component
export struct BatterySavingModeSwitchMenuComponent {
  tag: string = 'BatterySavingModeSwitchMenuComponent : ';
  menu?: SettingsBaseMenu;
  controller?: SwitchMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Column() {
        Column() {
          Text(this.getMenu().title)
            .visibility(this.uiRefresher.refreshTitleId ? (this.getStyle()
              .title ? Visibility.Visible : Visibility.None) :
              (this.getMenu().title ? Visibility.Visible : Visibility.None))
            .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.title : this.getStyle()?.title)
        }

        Column() {
          Text(this.getMenu().summary){
            Span(this.getMenu().summary)
            Span(this.getMenu().stateInfo)
              .fontColor($r('app.color.color_0A59F7_blue'))
              .onClick(() => {
                this.controller?.onMenuClick();
              })
          }
            .visibility(this.uiRefresher.refreshTitleId ? (this.getMenu()
              .summary ? Visibility.Visible : Visibility.None) :
              (this.getMenu().summary ? Visibility.Visible : Visibility.None))
            .textStyle(this.uiRefresher.isTitleVisible() ? this.getStyle()?.summary : this.getStyle()?.summary)
        }
        .margin(this.getMenu().summary ? this.getStyle().summary?.margin : 0)
      }
      .opacity((this.menu?.enable) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start);

      Toggle({ type: ToggleType.Switch, isOn: this.uiRefresher.refreshId ?
        (this.controller?.getChecked() ?? false) : (this.controller?.getChecked() ?? false) })
        .id(`entry_toggle_${this.menu?.key}`)
        .onChange((isOn: boolean) => {
          this.controller?.onToggleChange(isOn);
        })
        .switchPointColor((this.menu?.enable && !this.getMenu()?.isGrayed) ?
        $r('sys.color.ohos_id_color_foreground_contrary') : $r('sys.color.ohos_id_color_foreground_contrary_disable'))
        .switchPointColor(this.menu?.enable ? $r('sys.color.ohos_id_color_foreground_contrary') :
          $r('sys.color.ohos_id_color_foreground_contrary_disable'))
        .hoverEffect(HoverEffect.None)
        .selectedColor((this.menu?.enable && !this.getMenu()?.isGrayed) ? this.getStyle()?.toggleStyle?.selectedColor ??
        $r('sys.color.ohos_id_color_emphasize') : '#9ebefd')
        .margin(this.getStyle()?.toggleStyle?.margin ?? 0)// Toggle默认外边距是8vp，此处修改默认0vp
        .enabled(this.uiRefresher.refreshId ?
          ((this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed) :
          (this.controller?.getToggleState() ?? false) && !this.getMenu()?.isGrayed)
        .flexShrink(0)
        .defaultFocus(true)
    }
    .enabled(this.getMenu()?.enable ? true : false)
    .height(this.getStyle()?.rootContainer?.size?.height as Length)
    .width(this.getStyle()?.rootContainer?.size?.width as Length)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .padding(this.getStyle()?.rootContainer?.padding ?? 0)
    .margin(this.getStyle()?.rootContainer?.margin ?? 0)
    .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
    .clip(this.getStyle()?.rootContainer?.clip)
    .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): ProfileSwitchMenuStyle {
    return this.getMenu().style as ProfileSwitchMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SwitchMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct HdcAuthorizationButtonSwitchComponent {
  tag: string = 'HdcAuthorizationButtonSwitchComponent : ';
  menu?: BaseButtonMenu;
  @State controller?: ButtonMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Column() {
      Column(){
        Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle1 as ResourceStr :
          this.getMenu()?.buttonTittle1 as ResourceStr)
          .visibility(this.getMenu()?.buttonTittle1 ? Visibility.Visible : Visibility.None)
          .customButtonStyle(this.getStyle()?.buttonStyle1 as ButtonStyle)
          .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
          .enabled(this.controller?.isButton1Enabled() as boolean)
          .onClick((event) => {
            this.controller?.onButton1Click();
          })
          .margin({bottom: '4vp'})
      }
      .width('100%')
      Column(){
        Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle2 as ResourceStr :
          this.getMenu()?.buttonTittle2 as ResourceStr)
          .visibility(this.getMenu()?.buttonTittle2 ? Visibility.Visible : Visibility.None)
          .customButtonStyle(this.getStyle()?.buttonStyle2 as ButtonStyle)
          .opacity(this.controller?.isButton1Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
          .enabled(this.controller?.isButton1Enabled() as boolean)
          .onClick((event) => {
            this.controller?.onButton2Click();
          })
          .margin({bottom: '4vp'});
      }
      .width('100%')

      Column(){
        Button(this.uiRefresher.refreshId ? this.getMenu()?.buttonTittle3 as ResourceStr :
          this.getMenu()?.buttonTittle3 as ResourceStr)
          .visibility(this.getMenu()?.buttonTittle3 ? Visibility.Visible : Visibility.None)
          .customButtonStyle(this.getStyle()?.buttonStyle3 as ButtonStyle)
          .opacity(this.controller?.isButton3Enabled() ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_FORTY)
          .enabled(this.controller?.isButton3Enabled() as boolean)
          .onClick((event) => {
            this.controller?.onButton3Click();
          });
      }
      .width('100%')

    }
    .width('100%')
    .size(this.getStyle()?.rootContainer?.size)
    .margin(this.getStyle()?.rootContainer?.margin as Padding)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): BaseButtonMenu {
    return this.controller ? this.controller.menu as BaseButtonMenu : this.menu as BaseButtonMenu;
  }

  private getStyle(): ButtonMenuStyle {
    return this.menu?.style as ButtonMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as ButtonMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}