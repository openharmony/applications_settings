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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { AppInfo } from '../model/bean/AppInfo';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { ListSlideAutoScroller } from './ListSlideAutoScroller';

/* instrument ignore file */
const TAG: string = 'ListSlideSelectController';
// 列表多选状态下,右侧响应滑动多选的热区宽度: CheckBox按钮总宽 + 外右边距
const SLIDE_SELECT_RESPONSE_REGION: number = 20 + 46;

// 滑动多选: 当前滑动方向
export enum SelectSlideType {
  // 未设置状态_默认
  DEFAULT = 0,
  // 下滑
  DOWN = 1,
  // 上滑
  UP = 2,
}

/**
 * 列表滑动多选控制器类
 */
export class ListSlideSelectController {
  // 是否有初始化当前这次滑动的整体选中状态: 是全都选中 / 还是全都非选中(根据第一个触摸的按钮状态来判定)
  private hasInitCurSlideSelectStatus: boolean = false;
  // 本次滑动的整体选中状态: 是全都选中 / 还是全都非选中
  private isOriSelect: boolean = false;
  // 上一次触摸的条目索引
  private lastTouchIndex: number = -1
  // 当前 List列表宽度
  private curListWidth: number = 0;
  // 滑动多选,滑到底部/顶部时: 处理自动滑动
  private autoScroller: ListSlideAutoScroller = new ListSlideAutoScroller();
  private convertPosY: number = 0;
  private lastScrollEnd: number = -1;
  private lastTouchGlobalY: number = -1;
  private curSlideType: number = SelectSlideType.DEFAULT;
  private firstTouchIndex: number = -1;
  // 滑动开始时,页面已选中的条目集合
  private cacheSelectedData: string[] = [];
  // 当前是否循环反向滑动状态
  private isCycleSlidingStatus: boolean = false;
  // 首次触摸的index更改状态后: 是否是选中态
  private isFirstSelectedStatus: boolean = false;
  private appGroups?: AppInfoDataSource;
  private isLtrDirection: boolean = LanguageUtils.isLtrDirection();
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {
  };

  public setListSource(appGroups: AppInfoDataSource): void {
    this.appGroups = appGroups;
  }

  public setTouchListener(onAppItemClicked: (index: number, item: AppInfo) => void): void {
    this.onAppItemClicked = onAppItemClicked;
  }

  public onActionStart(listScroller: ListScroller): (event: GestureEvent) => void {
    return (event: GestureEvent) => {
      event.fingerList = this.filterEmptyList(event.fingerList);
      if (event.fingerList.length <= 0) {
        return;
      }
      this.autoScroller.initIsEntryFromHotAndNotScrolled(event.fingerList[0].localY);
      this.lastTouchGlobalY = event.fingerList[0].globalY;
      this.lastTouchIndex = -1;
      this.hasInitCurSlideSelectStatus = false;
      this.curSlideType = SelectSlideType.DEFAULT;
      this.isFirstSelectedStatus = false;
      this.isCycleSlidingStatus = false;
      this.cacheSelectedData = this.appGroups?.getSelectedAppString() ?? [];
    }
  }

  public onActionUpdate(listScroller: ListScroller): (event: GestureEvent) => void {
    return (event: GestureEvent) => {
      event.fingerList = this.filterEmptyList(event.fingerList);
      if (event.fingerList.length <= 0) {
        return;
      }
      this.autoScroller.autoScrollOrStop(listScroller, event.fingerList[0].globalY - this.convertPosY);
      // 处理滑动状态
      const listDataArr: AppInfo[] = this.appGroups?.getArray() ?? [];
      let curTouchIndex: number = this.getCurTouchItemIndex(listScroller, event?.fingerList[0]);
      if (curTouchIndex < 0 || curTouchIndex >= listDataArr.length || curTouchIndex === this.lastTouchIndex) {
        // 当前触摸索引在item外,无效 || 当前触摸更新的索引重复,无需再更新
        return;
      }
      LogUtil.info(`${TAG} onActionUpdate: curIndex =  ${curTouchIndex}`);
      if (!this.hasInitCurSlideSelectStatus) {
        this.isOriSelect = !listDataArr[curTouchIndex].isSelected;
        this.hasInitCurSlideSelectStatus = true;
        this.firstTouchIndex = curTouchIndex;
        this.isFirstSelectedStatus = this.isOriSelect;
        // 根据当前滑动触摸到的条目: 更新当前列表选中数组数据
        this.updateBatchSelectedInfos(curTouchIndex, this.isOriSelect);
      } else {
        // 处理更新: 来回循环滑动场景 - 条目的选中状态
        this.handleListCycleSlide(event, curTouchIndex);
      }
      // 记录当前触摸的index索引(避免重复更新状态)
      this.lastTouchIndex = curTouchIndex;
      this.lastTouchGlobalY = event.fingerList[0].globalY;
    }
  }

  /*
   *  来回循环滑动场景,处理更新: 条目的选中状态(规则: 来回滑动可撤销，起始项状态不变)
   *
   * 第一次滑动：其他选择项的狀态与第一个条目选择后的状态(已选/末选）保持一致
   * 二次及以上-滑动经过：第一项选择后状态不改变(起始已选项保持已选状态)，其他选择项状态恢复上一次原本状态。
   */
  private handleListCycleSlide(event: GestureEvent, curTouchIndex: number) {
    if (event.fingerList[0].globalY < this.lastTouchGlobalY) {
      // 进入上滑
      if (this.curSlideType === SelectSlideType.DEFAULT) {
        this.curSlideType = SelectSlideType.UP;
      } else if (this.curSlideType === SelectSlideType.DOWN) {
        // 进入反向滑动 -> 之前滑动方向是下滑,现在进入上滑
        this.isCycleSlidingStatus = true;
        this.curSlideType = SelectSlideType.UP;
        this.isOriSelect = !this.isOriSelect;
        // 状态转换节点的item状态也要处理
        this.updateCycleSlideSelectedInfos(this.lastTouchIndex, this.isOriSelect);
      }
    } else {
      // 进入下滑
      if (this.curSlideType === SelectSlideType.DEFAULT) {
        this.curSlideType = SelectSlideType.DOWN;
      } else if (this.curSlideType === SelectSlideType.UP) {
        // 进入反向滑动 -> 之前滑动方向是上滑,现在进入下滑
        this.isCycleSlidingStatus = true;
        this.curSlideType = SelectSlideType.DOWN;
        this.isOriSelect = !this.isOriSelect;
        // 状态转换节点的item状态也要处理
        this.updateCycleSlideSelectedInfos(this.lastTouchIndex, this.isOriSelect);
      }
    }
    this.updateCycleSlideSelectedInfos(curTouchIndex, this.isOriSelect);
  }

  // List列表: onActionEnd
  public onActionEnd(listScroller: ListScroller): (event: GestureEvent) => void {
    return (event: GestureEvent) => {
      this.lastTouchIndex = -1;
      this.hasInitCurSlideSelectStatus = false;
      this.curSlideType = SelectSlideType.DEFAULT;
      this.isCycleSlidingStatus = false;
      this.isFirstSelectedStatus = false;
      // 自动滑动
      this.autoScroller.isEntryFromHotAndNotScrolled = false;
      listScroller?.scrollBy(0, 0);
    }
  }

  // 列表滚动回调: onScrollIndex
  public onScrollIndex(start: number, end: number, mid: number): void {
    // 不处于滑动多选状态时,不处理该逻辑
    if (!this.hasInitCurSlideSelectStatus) {
      return;
    }
    if (this.lastScrollEnd === -1) {
      this.lastScrollEnd = end;
      return;
    }
    if (end > this.lastScrollEnd) {
      // 下滑滚动
      this.handleMissedItemSelectStatus(end)
    } else if (end < this.lastScrollEnd) {
      // 上滑滚动
      this.handleMissedItemSelectStatus(start)
    }
    this.lastScrollEnd = end;
  }

  private handleMissedItemSelectStatus(missedIndex: number): void {
    if (missedIndex === this.lastTouchIndex || missedIndex < 0) {
      // 当前触摸更新的索引重复,无需再更新
      return;
    }
    LogUtil.info(`${TAG} handleMissedItemSelectStatus -> curMissedIndex = ${missedIndex}`);
    // 根据当前滑动触摸到的条目: 更新当前列表选中数组数据
    this.updateBatchSelectedInfos(missedIndex, this.isOriSelect);
    this.lastTouchIndex = missedIndex;
  }

  public onAreaChange(newValue: Area): void {
    this.convertPosY = newValue.globalPosition.y as number;
    let newValueHeight: number = newValue.height as number;
    this.autoScroller.setScrollerHeight(newValueHeight);
  }

  // 更新来回循环滑动场景: 条目选中状态
  private updateCycleSlideSelectedInfos(index: number, isOriSelect: boolean) {
    const listDataArr: AppInfo[] = this.appGroups?.getArray() ?? [];
    if (index < 0 || index >= listDataArr.length) {
      return;
    }
    let appKey: string = `${listDataArr[index].name}_${listDataArr[index].appIndex}`;
    // 当前滑动主状态是取消选中且首次索引是选中态且当前是循环反滑状态:如当前index在已选中缓存中,就不取消
    if (!this.isOriSelect && this.isFirstSelectedStatus && this.isCycleSlidingStatus &&
      this.cacheSelectedData.includes(appKey)) {
      return;
    }
    // 当前滑动主状态是选中状态,但首次索引非选中态:如果当前index不在已选中缓存中的 -> 就不选中
    if (this.isOriSelect && !this.isFirstSelectedStatus && !this.cacheSelectedData.includes(appKey)) {
      return;
    }
    // 来回滑动场景规格: 起始项状态需保持不变,无需更新
    if (index === this.firstTouchIndex && this.firstTouchIndex < listDataArr.length) {
      this.isOriSelect = listDataArr[this.firstTouchIndex].isSelected ?? false;
      return;
    }
    this.updateBatchSelectedInfos(index, isOriSelect);
  }

  // 根据当前滑动触摸到的条目: 更新当前列表选中数组对象
  private updateBatchSelectedInfos(itemIndex: number, isSelect: boolean) {
    if (!this.appGroups) {
      return;
    }
    const listDataArr: AppInfo[] = this.appGroups?.getArray() ?? [];
    if (itemIndex < 0 || itemIndex >= listDataArr.length) {
      return;
    }
    let curTouchItem: AppInfo = this.appGroups.getData(itemIndex);
    curTouchItem.isSelected = isSelect;
    EventBus.getInstance().emit('intelligenceAppInfoRefresh', curTouchItem.name, curTouchItem.label, isSelect);
    this.onAppItemClicked(itemIndex, curTouchItem);
  }

  private getCurTouchItemIndex(listScroller: ListScroller, finger: FingerInfo): number {
    if (!listScroller || !finger || !finger.localX || !finger.localY) {
      return -1;
    }
    return listScroller.getItemIndex(finger.localX, finger.localY);
  }

  public onSizeChange(): SizeChangeCallback {
    return (oldValue: SizeOptions, newValue: SizeOptions) => {
      this.curListWidth = newValue.width as number
    }
  }

  public onGestureRecognizerJudgeBegin(): GestureRecognizerJudgeBeginCallback {
    return (event: BaseGestureEvent, current: GestureRecognizer, recognizers: Array<GestureRecognizer>) => {
      const finger = event.fingerList[0];
      let isInTouchHotArea: boolean = false;
      let localX: number = finger?.localX ?? 0;
      if (this.isLtrDirection) {
        isInTouchHotArea = localX > this.curListWidth - SLIDE_SELECT_RESPONSE_REGION;
      } else {
        isInTouchHotArea = localX > 0 && localX < SLIDE_SELECT_RESPONSE_REGION;
      }
      if (finger && isInTouchHotArea && current.isBuiltIn() &&
        current.getType() === GestureControl.GestureType.PAN_GESTURE) {
        // 平移手势
        return GestureJudgeResult.REJECT;
      }
      return GestureJudgeResult.CONTINUE;
    };
  }

  private filterEmptyList(fingerList: FingerInfo[]): FingerInfo[] {
    fingerList = fingerList.filter((item: FingerInfo) => item !== undefined);
    if (fingerList.length === 0) {
      LogUtil.warn(`${TAG} filterListEmpty: fingerList is empty`);
    }
    return fingerList;
  }
}