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

import { PromptAction } from '@kit.ArkUI';
import {
  DefaultSettingGroupModel,
  GroupType,
  SettingGroupLayout,
  SettingGroupModel,
} from '../model/SettingGroupModel'
import { ItemPos, SettingDialogModel, SettingItemModel } from '../model/SettingItemModel';
import { DataVerify } from '../common/DataVerify';
import { SettingItemStandard } from './SettingItemStandard';
import { BaseDataSource } from '../model/BaseDataSource';
import { OrderedDataSource } from '../model/OrderedDataSource';
import { DynamicDataSource } from '../model/DynamicDataSource';
import { SettingGroupEventHandler, SettingGroupVM } from './SettingGroupVM';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { settingDialog } from './SettingDialog';
import { SettingSheetPageContext } from '../model/SettingPageModel';

const TAG: string = 'SettingGroup';

@Component
export struct SettingGroup {
  groupInfo: SettingGroupModel = DefaultSettingGroupModel.get();
  compId: string = '';
  fixed: boolean = false;
  pageCached: boolean = false;
  layout?: SettingGroupLayout;
  sheetPageCtx?: SettingSheetPageContext;
  private dialogId: number = 0;
  private isCircleScreen: boolean = PageConfig.getInstance().isCircleScreen();
  @State dataSource: BaseDataSource<SettingItemModel> = [];
  @State groupVM: SettingGroupVM = new SettingGroupVM();
  private eventHandler: SettingGroupEventHandler = new SettingGroupEventHandler(this.groupVM);
  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  private closeDialog(item: SettingItemModel): void {
    if (this.dialogId === 0) {
      LogHelper.info(TAG, `dialog has been closed, group: ${this.compId}`);
      return;
    }

    LogHelper.info(TAG, `close dialog , group: ${this.compId}, dialogId: ${this.dialogId}`);
    try {
      this.promptAction.closeCustomDialog(this.dialogId);
      this.dialogId = 0;
    } catch (error) {
      LogHelper.error(TAG, `closeCustomDialog failed, dialogId: ${this.dialogId}, error: ${error?.message}`);
    }
  }

  private openDialog(item: SettingItemModel, dialog: SettingDialogModel): void {
    // Close existing dialog first if dialog exists.
    this.closeDialog(item);
    let dialogLayout = PageConfig.getInstance().getDialogStyle(dialog);
    this.promptAction.openCustomDialog({
      builder: settingDialog.bind(this, item, dialog, () => {
        this.closeDialog(item);
      }),
      width: dialogLayout.width,
      height: dialogLayout.height,
      backgroundColor: dialogLayout.backgroundColor,
      cornerRadius: dialogLayout.cornerRadius,
      alignment: dialogLayout.alignment,
      autoCancel: dialogLayout.autoCancel,
      maskColor: dialogLayout.maskColor,
      showInSubWindow: dialog?.showInSubWindow ?? false,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        LogHelper.info(TAG, `dialog dismiss, group ${this.compId}`);
        if (dialog?.onWillDismiss) {
          dialog.onWillDismiss();
        }
        dismissDialogAction.dismiss();
        this.dialogId = 0;
      },
    }).then((dialogId: number) => {
      LogHelper.info(TAG, `dialog opened, group ${this.compId} dialogId: ${dialogId}`);
      this.dialogId = dialogId;
    }).catch((reason: Error) => {
      LogHelper.error(TAG, `open dialog failed, group: ${this.compId}, reason: ${reason.message}`);
    });
  }

  private createDataSource(): BaseDataSource<SettingItemModel> {
    if (this.groupInfo.type === GroupType.GROUP_TYPE_DYNAMIC_LAZY) {
      return new OrderedDataSource();
    }
    return new DynamicDataSource();
  }

  private getItems(): SettingItemModel[] | BaseDataSource<SettingItemModel> {
    if (this.fixed) {
      return this.groupInfo.items ?? [];
    } else {
      return this.dataSource;
    }
  }

  private getItemPos(index: number, itemCnt: number): number {
    if (!DataVerify.checkArray(this.getItems())) {
      return 0;
    }

    let itemPos: number = 0;
    if (index === 0) {
      itemPos |= ItemPos.ITEM_POS_START;
    }
    if (index > 0 && index < itemCnt - 1) {
      itemPos |= ItemPos.ITEM_POS_CENTER;
    }
    if (index === itemCnt - 1) {
      itemPos |= ItemPos.ITEM_POS_END;
    }

    return itemPos;
  }

  private initTabIndex(item: SettingItemModel, index: number): SettingItemModel {
    item.tabIndex = this.groupInfo.tabIndex;
    return item;
  }

  @Builder groupItemBuilder(item: SettingItemModel, index: number): void {
    SettingItemStandard({
      itemInfo: this.initTabIndex(item, index),
      itemPos: this.getItemPos(index, this.getItems().length),
      compId: `${this.compId}.${item.id}`,
      parentId: this.compId,
      sheetPageCtx: this.sheetPageCtx ?? undefined,
      isVisible: item.visible ?? true,
      openDialog: (item: SettingItemModel, dialog: SettingDialogModel) => {
        this.openDialog(item, dialog);
      },
      closeDialog: () => {
        this.closeDialog(item);
      }
    });
  }

  @Styles groupCommon() {
    .id(this.compId)
    .width('100%')
    .backgroundColor(this.layout?.backgroupColor)
    .borderRadius(this.layout?.borderRadius)
    .padding(this.isCircleScreen ? undefined : this.layout?.padding)
    .margin(this.layout?.margin)
    .visibility((this.groupVM.visible && this.getItems().length > 0) ? Visibility.Visible : Visibility.None)
  }

  @Builder fixedGroupBuilder(): void {
    Column() {
      ForEach(this.groupInfo.items, (item: SettingItemModel, index: number) => {
        this.groupItemBuilder(item, index)
      }, (item: SettingItemModel) => item?.id + '_' + item?.subId)
    }
    .groupCommon()
  }

  @Builder listGroupBuilder(): void {
    ListItemGroup() {
      ForEach(this.getItems(), (item: SettingItemModel, index: number) => {
        ListItem() {
          this.groupItemBuilder(item, index)
        }
      }, (item: SettingItemModel, index: number) => item.id + '_' + item?.subId)
    }
    .groupCommon()
    .divider(PageConfig.getInstance().getGroupDividerStyle(this.layout?.dividerStyle))
  }

  @Builder lazyGroupBuilder(): void {
    ListItemGroup() {
      LazyForEach(this.getItems() as OrderedDataSource, (item: SettingItemModel, index: number) => {
        ListItem() {
          this.groupItemBuilder(item, index)
        }
      }, ((item: SettingItemModel) => item?.id + '_' + item?.subId))
    }
    .groupCommon()
    .divider(PageConfig.getInstance().getGroupDividerStyle(this.layout?.dividerStyle))
  }

  aboutToAppear(): void {
    LogHelper.info(TAG, `setting group ${this.compId} appear.`);
    this.dataSource = this.createDataSource();
    this.eventHandler.init(this.groupInfo, this.compId, (this.groupInfo.type === GroupType.GROUP_TYPE_STANDARD) ?
      (this.dataSource as DynamicDataSource) : undefined);

    // 标准类型，将配置模型转换为VM
    if (this.groupInfo.type === GroupType.GROUP_TYPE_STANDARD) {
      this.dataSource.push(...(this.groupInfo.items ?? []));
    }

    if (this.groupInfo.compControl) {
      this.groupInfo.compControl.init({
        compId: this.compId,
        component: this.groupInfo,
        dataSource: this.getItems()
      });
    }
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `setting group ${this.compId} disappear.`);
    this.eventHandler.destroy();

    if (this.dialogId !== 0) {
      this.promptAction.closeCustomDialog(this.dialogId);
      this.dialogId = 0;
    }

    if (this.groupInfo.compControl) {
      this.groupInfo.compControl.destroy();
    }
  }

  build() {
    if (!this.groupInfo.needHide) {
      if (this.groupInfo.type === GroupType.GROUP_TYPE_STANDARD) {
        if (this.groupInfo.items && this.groupInfo.items.length > 0) {
          if (this.fixed) {
            this.fixedGroupBuilder()
          } else {
            this.listGroupBuilder()
          }
        }
      } else if (this.groupInfo.type === GroupType.GROUP_TYPE_DYNAMIC) {
        this.listGroupBuilder()
      } else if (this.groupInfo.type === GroupType.GROUP_TYPE_DYNAMIC_LAZY) {
        this.lazyGroupBuilder()
      }
    }
  }
}