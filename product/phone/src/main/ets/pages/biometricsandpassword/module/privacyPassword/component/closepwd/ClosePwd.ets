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
import { LengthMetrics, LengthUnit } from '@kit.ArkUI';
import { DeviceUtil, NavEntryKey, PasswordUtil, ResourceUtil } from '@ohos/settings.common';
import MixAndNumberPasswordPageButton from '../MixAndNumberPasswordPageButton';
import { CommonConstants } from '../../common/constants/CommonConstants';
import Log from '../../common/utils/Log';
import { PasswordUtils } from '../../common/utils/PasswordUtils';
import { getCredentials, setUnableToAppLock, usePinProtection } from '../../common/PrivacyPassword';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import FontScaleUtils from '../../common/utils/FontScaleUtils';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { common } from '@kit.AbilityKit';
import { checkScreenLock } from '../../common/ScreenLockCheck';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';

const TAG: string = 'ClosePrivacyPassword';
const DELETE_WITH_PIN: number = 1;
const DELETE_WITHOUT_PIN: number = 0;

/**
 * 关闭隐私密码界面
 *
 * @since 2024-11-27
 */
@Component
export struct ClosePwd {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link credentialId?: Uint8Array;
  @State index: number = 0;
  @State iconSize: number = getContext().resourceManager.getNumber($r('sys.float.Body_M'));
  @State buttonAreaWidth: number = 0;
  @State currentSaveDistance: number = 8;
  @State isExtraLargeFontMode: boolean = false;
  @Provide containerHeight: number = 0;

  columnResize(event: Area) {
    this.containerHeight = event.height as number;
  }

  menuText: string[] = [
    ResourceUtil.getStringSync($r('app.string.pin_protection')),
    ResourceUtil.getStringSync($r('app.string.stop_protection'))
  ];
  canClick: boolean = true;
  innerPathInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    Log.info(TAG, 'aboutToAppear')
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE,
      HiSysEventConstants.USER_OPERATION_BEGIN);
    try {
      this.currentSaveDistance = FontScaleUtils.getSaveDistance(getContext() as common.UIAbilityContext);
      this.isExtraLargeFontMode = FontScaleUtils.isExtraLargeFontMode(getContext() as common.UIAbilityContext);
    } catch (e) {
      Log.error(TAG, 'get resource error');
    }
  }

  aboutToDisappear(): void {
    PasswordUtils.unregisterInputer();
    PasswordUtils.closeSession(TAG);
    this.clearResource();
  }

  private clearResource(): void {
    this.credentialId = undefined;
  }

  async deleteAndReport(deleteMode: number): Promise<void> {
    const credentials = await getCredentials();
    const deleteList = [HiSysEventConstants.DELETE_LIST];
    const deleteWay = [deleteMode];
    const deleteResult = await PasswordUtils.deletePassword();
    if (deleteResult) {
      PasswordUtils.clearQuestionInDb(getContext(this));
      credentials.forEach((cred) => {
        HiSysEventUtil.reportDeleteEvent(cred.credentialId, cred.templateId, cred.authSubType, deleteList,
          deleteWay);
      })
    }
  }

  build() {
    NavDestination() {
      this.buildPageContent()
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .title($r('app.string.close_privacy_password'))
    // .titleMode(HdsNavDestinationTitleMode.MINI)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.close_privacy_password')
    //     },
    //     divider: {
    //       showType: DividerShowType.OFF
    //     }
    //   },
    //   style: {
    //     originalStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //     scrollEffectStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //   },
    //   padding: {
    //     start: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //     end: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //   }
    // })
    .onBackPressed(() => {
      Log.info(TAG, `onBackPressed`);
      this.pathInfos.pop();
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE,
        HiSysEventConstants.USER_OPERATION_CANCEL);
      return true;
    })
    .onReady((ctx: NavDestinationContext) => {
      this.innerPathInfos = ctx.pathStack;
    })
  }

  @Builder
  buildPageContent() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Scroll() {
        this.buildContent()
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.TopStart)
      .height('100%')
      .flexGrow(1)

      this.builderBottomBtn()
    }
    .padding({
      left: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
      right: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8')
    })
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.columnResize(newValue)
      this.buttonAreaWidth = Math.min(CommonConstants.MAX_BUTTON_WIDTH,
        newValue.width as number - 2 * 16)
    })
  }

  @Builder
  PrivacyMenu() {
    Menu() {
      ForEach(this.menuText, (text: string, index) => {
        MenuItem() {
          Flex({
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Center
          }) {
            Text(text)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontSize($r('app.float.font_16'))
              .fontWeight(FontWeight.Medium)
            if (this.index === index) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize('24vp')
                .fontColor([$r('sys.color.ohos_id_color_text_primary')])
                .fontWeight(FontWeight.Regular)
            } else {
              Row().width('24vp')
            }
          }
          .padding(12)
          .constraintSize({ minHeight: $r('app.float.wh_48') })
        }
        .onClick(() => {
          this.index = index;
        })
      })
    }
    .width(224)
    .menuItemDivider({
      strokeWidth: new LengthMetrics(1, LengthUnit.PX),
      color: $r('sys.color.comp_divider'),
      startMargin: new LengthMetrics(12),
      endMargin: new LengthMetrics(12),
    })
  }

  @Builder
  buildContent() {
    Column() {
      Text($r('app.string.close_privacy_password_description'))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
        .padding({
          top: $r('sys.float.padding_level12'),
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6')
        })
        .width('100%')
      List() {
        ListItemGroup() {
          if (this.isExtraLargeFontMode) {
            this.largeItem();
          } else {
            this.normalItem();
          }
        }
        .padding({ top: 4, bottom: 4 })
        .margin({
          top: 24,
        })
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .divider({
          strokeWidth: px2vp(1),
          color: $r('sys.color.comp_divider'),
          startMargin: $r('sys.float.padding_level6'),
          endMargin: $r('sys.float.padding_level6')
        })
      }
    }
  }

  @Builder
  largeItem() {
    ListItem() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Start,
        direction: FlexDirection.Column
      }) {
        Column({ space: 4 }) {
          Text($r('app.string.application_lock'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text($r('app.string.application_lock_desc'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
        }
        .accessibilityGroup(true)
        .padding({
          top: 4,
          bottom: 4
        })
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.menuText[this.index])
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .constraintSize({ maxWidth: `calc(100% - 24vp)` })
          Row() {
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .fontSize('16vp')
              .fontColor([$r('sys.color.font_secondary')])
              .fontWeight(FontWeight.Regular)
          }
          .width(`24vp`)
          .height(`24vp`)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .padding({
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2')
        })
        .justifyContent(FlexAlign.Start)
        .bindMenu(this.PrivacyMenu(), { placement: Placement.BottomRight })
        .padding({ top: 16 })
      }
    }
    .padding({
      top: this.currentSaveDistance,
      bottom: this.currentSaveDistance,
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
  }

  @Builder
  normalItem() {
    ListItem() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        direction: FlexDirection.Row
      }) {
        Column({ space: 4 }) {
          Text($r('app.string.application_lock'))
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text($r('app.string.application_lock_desc'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
        }
        .accessibilityGroup(true)
        .padding({
          top: 4,
          bottom: 4
        })
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(this.menuText[this.index])
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .constraintSize({ maxWidth: `calc(100% - 24vp)` })
          Row() {
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .fontSize('16vp')
              .fontColor([$r('sys.color.font_secondary')])
              .fontWeight(FontWeight.Regular)
          }
          .width(`24vp`)
          .height(`24vp`)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
        .width('40%')
        .padding({
          top: $r('sys.float.padding_level2'),
          bottom: $r('sys.float.padding_level2')
        })
        .justifyContent(FlexAlign.End)
        .bindMenu(this.PrivacyMenu(), { placement: Placement.BottomRight })
      }
    }
    .padding({
      top: this.currentSaveDistance,
      bottom: this.currentSaveDistance,
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
  }

  @Builder
  builderBottomBtn() {
    MixAndNumberPasswordPageButton({
      resourceLeft: $r('app.string.dialog_cancel'),
      resourceRight: $r('app.string.button_tittle_yes'),
      buttonAreaWidth: this.buttonAreaWidth,
      cancelClicked: () => {
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
      },
      continueClicked: async () => {
        if (!this.canClick) {
          return;
        }
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE_PWD_NEXT,
          HiSysEventConstants.USER_OPERATION_CLICK);
        this.canClick = false;
        try {
          if (this.index === 1 && this.credentialId) {
            await setUnableToAppLock();
            await this.deleteAndReport(DELETE_WITHOUT_PIN);
            HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE,
              HiSysEventConstants.USER_OPERATION_END);
            this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
          } else if (this.index === 0) {
            PasswordUtil.hasPinPassword(async (hasPinPassword) => {
              Log.warn(TAG, 'hasPinPassword :' + hasPinPassword)
              if (hasPinPassword) {
                if (await checkScreenLock(' ', getContext())) {
                  await usePinProtection();
                  await this.deleteAndReport(DELETE_WITH_PIN);
                  HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_DELETE,
                    HiSysEventConstants.USER_OPERATION_END);
                  this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
                }
              } else {
                this.innerPathInfos.pushPathByName('setLockPin', null);
              }
            })
          }
        } catch (e) {
          Log.error(TAG, 'deletePassword error: ' + e.code);
        } finally {
          this.canClick = true;
        }
      }
    })
  }
}
