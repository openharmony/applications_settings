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
import { componentUtils, CustomContentDialog, display, TipsDialog } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import lottie, { AnimationItem } from '@ohos/lottie';
import { Configuration } from '@ohos.app.ability.Configuration';
import measure from '@ohos.measure';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  WirelessProjectionController
} from '@ohos/settings.moreconnection/src/main/ets/controller/new/WirelessProjectionController';
import { MoreConnectionUtils } from '@ohos/settings.moreconnection/src/main/ets/MoreConnectionUtils';
import { PermissionInfoDialog } from '@ohos/settings.moreconnection/src/main/ets/PermissionInfoDialog';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import { SettingIconType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

const TAG: string = 'WirelessProjectionComponent: ';
const WIDTH_HEIGHT_PROP: number = 0.8;
const ITEM_PADDING_TB: number = 17;
const SING_LINE_HEIGHT_MAX: number = 30;
const LIST_ITEM_TOP_8: number = 8;
const PAD_MARGIN: number = 24;
const PHONE_MARGIN: number = 16;
const HALF: number = 2;
const H_W_RATIO: number = 2 / 3;
const LOTTIE_NAME: string = 'setting_wireless_projection_lottie';
const LOTTIE_PATH: string =
  DeviceUtil.isDevicePad() ? 'wireless_projection_pad.json' : 'wireless_projection_phone.json';
const BO_TEXT_BODY_S_HEIGHT: number = 20;
const BO_TEXT_BODY_L_HEIGHT: number = 28;
const GRID_COUNT_4: number = 4
const DIALOG_IMAGE_MARGIN: number = 8;
const DIALOG_IMAGE_HEIGHT: number = 180;
const DIALOG_IMAGE_WIDTH: number = 368;
const LANGUAGE_ZH: string = 'zh-Han';

@Component
export struct WirelessProjectionComponent {
  @State isOpen: boolean = false;
  @State plateVisibility: Visibility = Visibility.Hidden;
  @State plateWidth: number = 288;
  @State plateHeight: number = 192;
  @State isHideBack: boolean = false;
  @State listItemPadding: Length = 0;
  @State isNeedNewLine: boolean = false;
  @State wirelessProjectionSwitch: boolean = false;
  @State controller: WirelessProjectionController = WirelessProjectionController.getInstance();
  @State toggleTextHeight: Length = 0;
  @State bindTextHeight: Length = 0;
  @State isHover: boolean = false;
  @StorageLink('isWirelessBackPress') isWirelessBackPress: boolean = false;
  @State privacyDesc: string[] = ResourceUtil.getStringSync($r('app.string.wireless_projection_statement')).split('%s');
  @State privacyTextAlign: TextAlign = TextAlign.JUSTIFY;
  @StorageProp('envConfig') @Watch('onEnvConfig') envConfig: Configuration | undefined =
    AppStorage.get<Configuration>('envConfig');
  @State privacyWant: Want = {
    bundleName: 'com.ohos.cast',
    abilityName: 'PermissionDescribeAbility',
    parameters: {
      'ability.want.params.uiExtensionType': 'sys/commonUI',
      'type': 'wirelessPermissionStatement'
    }
  }
  private leftRightMargin: number = DeviceUtil.isDevicePad() ? PAD_MARGIN : PHONE_MARGIN;
  private lottieItem?: AnimationItem;
  private currentLanguage: string = LanguageUtils.getLanguage();
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private alertProjectionController?: CustomDialogController = undefined;
  public permissionInfoDialogController: CustomDialogController = new CustomDialogController({
    builder: PermissionInfoDialog({
      privacyWant: this.privacyWant,
    }),
    customStyle: true,
    cancel: () => {
      this.permissionInfoDialogController.close();
    },
    gridCount: GRID_COUNT_4
  });

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.isWirelessBackPress = false;
    lottie.destroy(LOTTIE_NAME);
    this.privacyTextAlign = this.currentLanguage.startsWith(LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
    this.controller.registerSwitch((switchState) => {
      this.wirelessProjectionSwitch = switchState;
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear ${this.isWirelessBackPress}`);
    if (this.isWirelessBackPress) {
      lottie.destroy(LOTTIE_NAME);
      this.controller.unregisterSwitch();
    }
  }

  private async initWirelessLottie(): Promise<void> {
    if (this.lottieItem) {
      LogUtil.info(`${TAG} lottieItem exist resize`);
      this.lottieItem.resize();
      return;
    }
    LogUtil.info(`${TAG} initWirelessLottie`);
    const data: object = await RawFileUtil.getJsonRawFile(LOTTIE_PATH);
    this.lottieItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      name: LOTTIE_NAME,
      loop: true,
      autoplay: true,
      animationData: data,
    });
    this.lottieItem.play();
  }

  build() {
    Scroll() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        this.headView();
        this.checkBoxRow();
        this.privacyView();
        if (this.wirelessProjectionSwitch) {
          this.trustedDeviceView();
        }
      }
      .id('contentView')
      .onAreaChange(() => {
        this.measureText();
      })
      .margin({ bottom: $r('app.float.margin_16') })
    }
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
    .onAreaChange((_, newValue: Area) => {
      this.measureLottie(newValue);
    })
  }

  private measureLottie(newValue: Area): void {
    if (typeof newValue.width === 'number' && typeof newValue.height === 'number') {
      let width = newValue.width as number;
      let halfHeight: number = 0
      try {
        let displayInfo: display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
        if (displayInfo) {
          halfHeight = px2vp(displayInfo.height / HALF);
        }
      } catch (error) {
        LogUtil.error(`${TAG} getDisplay error, code:${error?.code} message:${error?.message}`);
      }
      if (halfHeight === 0) {
        halfHeight = (newValue.height as number) / HALF;
      }
      if (width > halfHeight) {
        this.plateWidth = Math.round(halfHeight * WIDTH_HEIGHT_PROP);
        this.plateHeight = Math.round(this.plateWidth * H_W_RATIO);
      } else {
        this.plateWidth = Math.round(width * WIDTH_HEIGHT_PROP);
        this.plateHeight = Math.round(this.plateWidth * H_W_RATIO);
      }
      this.plateVisibility = Visibility.Visible;
    }
  }

  @Builder
  privacyView() {
    Row() {
      if (this.privacyDesc.length > 1) {
        this.privacyContentView();
      }
    }.padding({ left: $r('app.float.padding_12'), right: $r('app.float.padding_12') })
    .margin({ top: $r('app.float.margin_8'), left: this.leftRightMargin, right: this.leftRightMargin });
  }

  @Builder
  privacyContentView() {
    Text() {
      Span(this.privacyDesc[0])
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
      Span($r('app.string.permission_notice'))
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.permissionInfoDialogController.open();
        })
      Span(this.privacyDesc[1])
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    .textAlign(this.privacyTextAlign)
    .align(Alignment.Start)
    .layoutWeight(1)
    .lineHeight(MoreConnectionUtils.adapterBoLineHeight(BO_TEXT_BODY_S_HEIGHT))
  }

  @Builder
  headView() {
    Canvas(this.canvasRenderingContext)
      .width(this.plateWidth)
      .height(this.plateHeight)
      .onReady(() => {
        LogUtil.info(`${TAG} Canvas onReady`);
        this.initWirelessLottie();
      })
      .onVisibleAreaChange([0, 1], (isVisible: boolean, _: number) => {
        if (isVisible) {
          this.lottieItem?.play();
        } else {
          this.lottieItem?.pause();
        }
      })
      .visibility(this.plateVisibility)

    Text() {
      Span(DeviceUtil.isDevicePad() ?
      $r('app.string.wireless_projection_setting_hint_tablet', '') :
      $r('app.string.wireless_projection_setting_hint', ''))
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
      this.learnMoreView();
    }
    .lineHeight(MoreConnectionUtils.adapterBoLineHeight())
    .width('100%')
    .textAlign(TextAlign.Center)
    .padding({ left: this.leftRightMargin, right: this.leftRightMargin })
    .margin({ top: $r('app.float.margin_24') });
  }

  @Builder
  learnMoreView() {
    if (this.isNeedNewLine) {
      Span('\n')
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    Span($r('app.string.Learn_more'))
      .fontFamily('HarmonyHeiTi')
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_emphasize'))
      .fontWeight(FontWeight.Medium)
      .onClick(() => {
        LogUtil.info(`${TAG} click to learn more`);
        this.controller.jumpTips(getContext(this) as common.UIAbilityContext);
      })
  }

  @Builder
  checkBoxRow() {
    Row() {
      Text($r('app.string.projection_toggle_title'))
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .align(Alignment.Start)
        .layoutWeight(1)
        .lineHeight(MoreConnectionUtils.adapterBoLineHeight(BO_TEXT_BODY_L_HEIGHT))
        .padding({
          top: this.updateItemPadding(this.toggleTextHeight),
          bottom: this.updateItemPadding(this.toggleTextHeight)
        })
        .onAreaChange((_, newValue) => {
          this.toggleTextHeight = newValue.height;
        })

      Toggle({ type: ToggleType.Switch, isOn: this.wirelessProjectionSwitch })
        .width($r('app.float.wh_value_36'))
        .height($r('app.float.wh_value_20'))
        .align(Alignment.End)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .switchPointColor($r('sys.color.comp_background_primary_contrary'))
        .onChange((isOpen: boolean) => {
          this.controller.setSwitchState(isOpen);
          if (isOpen) {
            this.showGuideDialog();
          }
        })
    }
    .padding({ left: $r('app.float.padding_12'), right: $r('app.float.padding_12') })
    .constraintSize({
      minHeight: $r('app.float.height_56'),
    })
    .margin({ top: $r('app.float.margin_32'), left: this.leftRightMargin, right: this.leftRightMargin })
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .borderRadius($r('sys.float.corner_radius_level10'))
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  trustedDeviceView() {
    List() {
      ListItem() {
        this.bindTextItemView()
      }
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor(this.isHover ? $r('sys.color.ohos_id_color_hover') : $r('app.color.transparent'))
      .onClick(() => {
        PageRouter.push(NavEntryKey.WIRELESS_TRUSTED_DEVICE_ENTRY);
      })
      .margin($r('app.float.margin_4'))
      .onHover((isHover, _) => {
        this.isHover = isHover;
      })
    }
    .margin({
      left: this.leftRightMargin,
      right: this.leftRightMargin,
      top: $r('app.float.margin_12')
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
  }

  @Builder
  bindTextItemView() {
    Row() {
      Text($r('app.string.bind_devices'))
        .textAlign(TextAlign.Start)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .align(Alignment.Start)
        .layoutWeight(1)
        .padding({
          top: this.updateItemPadding(this.bindTextHeight),
          bottom: this.updateItemPadding(this.bindTextHeight)
        })
        .onAreaChange((_, newValue) => {
          this.bindTextHeight = newValue.height;
        })
      Image($r('app.media.ic_settings_arrow'))
        .width(DefaultPageConfig.getInstance().getDefaultIconStyle(SettingIconType.ICON_TYPE_ARROW).width)
        .height(DefaultPageConfig.getInstance().getDefaultIconStyle(SettingIconType.ICON_TYPE_ARROW).height)
        .align(Alignment.End)
        .matchTextDirection(true)
        .margin({
          left: LanguageUtils.isLtrDirection() ? $r('app.float.margin_4') : 0,
          right: LanguageUtils.isLtrDirection() ? 0 : $r('app.float.margin_4')
        })
    }
    .padding({ left: $r('app.float.padding_8'), right: $r('app.float.padding_8') })
    .alignItems(VerticalAlign.Center)
    .constraintSize({ minHeight: $r('app.float.height_48') })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .stateStyles({
      pressed: {
        .backgroundColor($r('sys.color.interactive_click'))
      }, normal: {
        .backgroundColor($r('app.color.transparent'))
      }
    });
  }

  showGuideDialog(): void {
    if (DeviceUtil.isPcMode()) {
      this.alertProjectionController = new CustomDialogController({
        builder: TipsDialog({
          imageRes: $r('app.media.wireless_projection_guide_pc'),
          imageSize: {
            height: DIALOG_IMAGE_HEIGHT,
            width: DIALOG_IMAGE_WIDTH
          },
          title: $r('app.string.wireless_entry_guide'),
          content: $r('app.string.wireless_entry_guide_message'),
          primaryButton: {
            value: $r('app.string.dialog_know'),
            action: () => {
              this.alertProjectionController?.close();
              this.alertProjectionController = undefined;
            }
          }
        }),
        autoCancel: true,
        cancel: () => {
          this.alertProjectionController?.close();
          this.alertProjectionController = undefined;
        },
        alignment: DialogAlignment.Center,
      });
    } else {
      this.alertProjectionController = new CustomDialogController({
        builder: CustomContentDialog({
          primaryTitle: $r('app.string.wireless_entry_guide'),
          contentBuilder: () => {
            this.alertDialogContentView()
          },
          buttons: [{
            value: $r('app.string.dialog_know'),
            action: () => {
              this.alertProjectionController?.close();
              this.alertProjectionController = undefined;
            }
          }],
          contentAreaPadding: {
            left: 0,
            right: 0,
            bottom: 0,
            top: 0
          },
        }),
        autoCancel: true,
        cancel: () => {
          this.alertProjectionController?.close();
          this.alertProjectionController = undefined;
        },
        alignment: DialogAlignment.Center,
      });
    }
    this.alertProjectionController?.open();
  }

  @Builder
  alertDialogContentView() {
    Scroll() {
      Column() {
        Text($r('app.string.wireless_entry_guide_message'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Center)
          .width('100%')
        Image(DeviceUtil.isDevicePad() ? $r('app.media.wireless_projection_guide_pad') :
          $r('app.media.wireless_projection_guide_phone'))
          .height(DIALOG_IMAGE_HEIGHT)
          .margin({ top: DIALOG_IMAGE_MARGIN })
          .align(Alignment.Center)
      }
    }.width('100%')
    .scrollBar(BarState.Auto)
    .padding({ left: $r('app.float.margin_24'), right: $r('app.float.margin_24') })
  }

  private measureText(): void {
    let contentText: string = ResourceUtil.getFormatStringByNameSync('wireless_projection_setting_hint', '');
    let learnMoreText = ResourceUtil.getFormatStringByName('Learn_more');
    let contentSize: SizeOptions = measure.measureTextSize({
      textContent: contentText,
      fontSize: $r('sys.float.Body_M'),
      fontWeight: FontWeight.Regular,
      fontFamily: 'HarmonyHeiTi'
    });
    let learnMoreSize: SizeOptions = measure.measureTextSize({
      textContent: learnMoreText,
      fontSize: $r('sys.float.Body_M'),
      fontWeight: FontWeight.Medium,
      fontFamily: 'HarmonyHeiTi'
    });
    let maxWidth: number = componentUtils.getRectangleById('contentView').size.width - vp2px(this.leftRightMargin * 2);
    if ((Number(contentSize.width) + Number(learnMoreSize.width)) % maxWidth < Number(learnMoreSize.width)) {
      this.isNeedNewLine = true;
    } else {
      this.isNeedNewLine = false;
    }
  }

  private updateItemPadding(titleHeight: Length): number {
    if (FontScaleUtils.getFontScaleSize() >= FontScaleUtils.EXTRA_LARGE_FONT_1) {
      return FontScaleUtils.getCurrentTopPadding();
    } else {
      if (Number(titleHeight) > SING_LINE_HEIGHT_MAX) {
        return LIST_ITEM_TOP_8;
      } else {
        return ITEM_PADDING_TB;
      }
    }
  }

  private onEnvConfig(): void {
    if (this.envConfig?.language && this.currentLanguage !== this.envConfig?.language) {
      this.privacyTextAlign = this.envConfig.language.startsWith(LANGUAGE_ZH) ? TextAlign.JUSTIFY : TextAlign.Start;
      this.privacyDesc = ResourceUtil.getStringSync($r('app.string.wireless_projection_statement')).split('%s');
    }
  }
}