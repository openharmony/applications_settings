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
import { EditableLeftIconType, EditableTitleBar } from '@kit.ArkUI';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  SettingModalState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  DefaultSettingPageModel,
  SettingPageModel,
  SettingSheetPageContext
} from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { FunctionSelectMenuController } from '../controller/FunctionSelectMenuController';
import { FunctionSelectItemController } from '../controller/FunctionSelectItemController';
import { ScreenReaderConfirmDialogComponent } from '../view/ScreenReaderConfirmDialogComponent';
import {
  ACCESSIBILITY_SHORTCUT_TARGETS_SERVICE,
  FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT,
  FunctionSelectOriginNameValue,
  FunctionSelectTargetNameValue,
  FUNCTION_SELECT_TARGET_NAME_ARRAY
} from '../constant/Constants';

const MORE_CLICK_TIMEOUT: number = 40;

@Styles
function normalStateIconStyles() {
  .backgroundColor(Color.Transparent)
  .borderRadius(0)
}

@Styles
function pressedStateIconStyles() {
  .backgroundColor((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad())
    ? $r('sys.color.interactive_click') : null)
  .borderRadius($r('sys.float.corner_radius_level4'))
}

@Component
export struct FunctionSelectListModelComponent {
  tag: string = 'FunctionSelectListModelComponent: ';
  item?: object;
  pageParam?: PageParams;
  scroller: Scroller = new Scroller();
  private isCheckmarkClick?: boolean = false;
  private sheetPageCtx?: SettingSheetPageContext;
  private controller: FunctionSelectMenuController = new FunctionSelectMenuController();
  @State pathStack: NavPathStack = new NavPathStack();
  pageInfo: SettingPageModel = DefaultSettingPageModel.get();

  @Builder
  sheetTitle(): void {
    Row() {
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Cancel,
        title: $r('app.string.function_select'),
        onCancel: () => {
          LogUtil.info(`${this.tag} sheetTitleCloseView`);
          FunctionSelectMenuController.setTargetsInfoList();
          HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
            HiSysAccessibilityEventGroup.CLICK_SELECT_FUNCTION, '', 'Cancel');
          this.closePage();
        },
        onSave: () => {
          LogUtil.info(`${this.tag} sheetTitleOkView`);
          this.isCheckmarkClick = true;
          this.controller.getNewExtensionService();
          this.closePage();
        }
      })
    }
  }

  build() {
    Column() {
      this.sheetTitle();
      List({ scroller: this.scroller }) {
        ListItemGroup({ style: ListItemGroupStyle.CARD }) {
          ForEach(FUNCTION_SELECT_TARGET_NAME_ARRAY, (item: string, index: number) => {
            ListItem({ style: ListItemStyle.NONE }) {
              ItemContentComponent({
                item: item,
                index: index += 10,
                isSelected: FunctionSelectMenuController.shortKeyTargetsIdListCache.includes(
                  item),
              })
            }
          }, (item: string, index: number) => item + index)
        }
        .margin({})
        .divider({
          strokeWidth: px2vp(1),
          color: $r('sys.color.comp_divider'),
          startMargin: $r('sys.float.padding_level4'),
          endMargin: $r('sys.float.padding_level4'),
        })
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('sys.float.corner_radius_level10'))
      }
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .scrollBar(BarState.Off)
      .alignSelf(ItemAlign.Start)
      .clip(true)
      .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
      .visibility(Visibility.Visible);
    }
    .margin({ top: $r('sys.float.padding_level4') })
  }

  private closePage(): void {
    let item: SettingItemModel = this.sheetPageCtx?.itemComp as SettingItemModel;
    item?.onItemEvent?.(new Map([[
      SettingStateType.STATE_TYPE_ITEM_SHEET, { state: false } as SettingModalState
    ]]));
  }

  private onShowModelCallBack: EventCb = (isShow: boolean) => {
    LogUtil.info(`${this.tag} onShowModelCallBack isShow: ${isShow}`);
    if (!isShow) {
      this.closePage();
    }
  };

  async aboutToAppear(): Promise<void> {
    this.sheetPageCtx = this.pageParam?.param as SettingSheetPageContext;
    if (!this.sheetPageCtx.pathStack) {
      this.sheetPageCtx.pathStack = this.pathStack;
    }
    let item = this.sheetPageCtx.itemComp as SettingItemModel;
    await this.controller.init();
    EventBus.getInstance().on(FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT, this.onShowModelCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    if (!this.isCheckmarkClick) {
      FunctionSelectMenuController.setTargetsInfoList();
    }
    this.controller.destroy();
    EventBus.getInstance().detach(FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT, this.onShowModelCallBack);
  }
}

@Component
export struct ItemContentComponent {
  private tag: string = 'ItemContentComponent: '
  @State item: string = '';
  @State index: number = 0;
  @State isSelected: boolean = false;
  private timeoutId: number | undefined = undefined;
  private controller: FunctionSelectItemController = new FunctionSelectItemController();
  private dialogController: CustomDialogController | undefined = undefined;

  private onConfirmClick(): void {
    this.dialogController?.close();
    this.controller?.onMenuChange(true);
    LogUtil.info(`${this.tag} add screen reader item finished.`);
  }

  private onCancelClick(): void {
    this.isSelected = false;
    this.dialogController?.close();
    LogUtil.info(`${this.tag} cancel add screen reader item.`);
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(FunctionSelectMenuController.getFromStrToResourceStr(this.item))
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .wordBreak(WordBreak.HYPHENATION)
            .constraintSize({
              minHeight: $r('app.float.length_21'),
            })
        }
        .flexGrow(1)
        .alignItems(HorizontalAlign.Start)

        Checkbox({ group: 'checkboxGroup' })
          .select(this.isSelected)
          .onChange((isChecked: boolean) => {
            if (this.controller) {
              this.isSelected = isChecked;
              this.filterMenuChange(isChecked);
            }
          })
          .width($r('app.float.length_20'))
          .height($r('app.float.length_20'))
          .accessibilityText(' ')
          .id(`function_select_checkboxmenu_${this.index}`)
      }
      .width('100%')
      .height('auto')
    }
    .stateStyles({
      normal: normalStateIconStyles,
      pressed: pressedStateIconStyles,
    })
    .padding({
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
      top: $r('sys.float.padding_level6'),
      bottom: $r('sys.float.padding_level6'),
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .accessibilityText(ResourceUtil.getStringSync(FunctionSelectMenuController.getFromStrToResourceStr(this.item)))
    .constraintSize({
      minHeight: '48vp'
    })
    .justifyContent(FlexAlign.Center)
    .onAccessibilityActionIntercept(
      (action: AccessibilityAction) => {
        if (action === AccessibilityAction.ACCESSIBILITY_CLICK) {
          this.isSelected = !this.isSelected;
          this.filterMenuChange(this.isSelected);
          AccessibilityUtils.announceText(
            this.isSelected ? $r('app.string.be_chosen') : $r('app.string.not_be_chosen'));
          return AccessibilityActionInterceptResult.ACTION_INTERCEPT;
        } else {
          return AccessibilityActionInterceptResult.ACTION_CONTINUE;
        }
      }
    )
    .onClick((event) => {
      this.isSelected = !this.isSelected;
      this.filterMenuChange(this.isSelected);
    });
  }

  private filterMenuChange(isChecked: boolean): void {
    if (this.timeoutId !== undefined) {
      return;
    }
    this.timeoutId = setTimeout(() => {
      this.controller?.onMenuChange(isChecked);
      this.timeoutId = undefined;
    }, MORE_CLICK_TIMEOUT);
  }

  async checkItemState(): Promise<void> {
    let currentAbilityName: string = this.controller.checkItemName(this.item);
    let selectExtensionServiceList: string =
      SettingsDataUtils.getSecureValue(ACCESSIBILITY_SHORTCUT_TARGETS_SERVICE, '');
    if (selectExtensionServiceList.includes(currentAbilityName)) {
      this.isSelected = true;
    } else {
      this.isSelected = false;
    }
    LogUtil.info(`${this.tag} checkItemState currentAbilityName: ${currentAbilityName},
     selectExtensionServiceList: ${selectExtensionServiceList}`);
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.controller.init(this.controller.checkItemName(this.item));
    await this.checkItemState();
    this.controller.isSelected = this.isSelected;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.dialogController?.close();
    this.controller?.destroy();
  }
}