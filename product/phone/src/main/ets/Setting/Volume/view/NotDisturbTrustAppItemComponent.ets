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
import emitter from '@ohos.events.emitter';
import {
  PADDING_16,
  PADDING_2,
  PADDING_32,
  PADDING_4,
  PADDING_64,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EVENT_ID_NOT_DISTURB_ALPHABET_INDEX_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import { AppInfoData, AppInfoDataGroups, AppInfoDataSource } from '../model/bean/AppInfoDataSource';

export const alphabets = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

@Component
export struct AppDataInfoComponent {
  @ObjectLink item: AppInfoData;
  @State index: number = 0;
  count: number = -1;
  private onAppChildItemClicked: (selected: boolean, item: AppInfoData,
    index: number, indexChild: number) => void = () => {
  };

  aboutToAppear(): void {
  }

  @Builder
  toggleView(): void {
    Toggle({
      type: ToggleType.Checkbox,
      isOn: this.item.isSelected
    })
      .width(20)
      .height(20)
      .margin({ start: PADDING_8 })
      .selectedColor($r('sys.color.comp_background_emphasize'))
      .onChange((isOn: boolean) => {
        this.item.isSelected = isOn;
        this.onAppChildItemClicked(isOn, this.item, this.item.index, this.index);
      })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.item.appIconBase64 == undefined ? $r('app.media.notification_icon') : this.item.appIconBase64)
            .width('48vp')
            .height('48vp')
            .objectFit(ImageFit.Contain)
            .borderRadius($r('sys.float.corner_radius_level6'))
            .draggable(false)
        }
        .width('48vp')
        .height('48vp')

        Column() {
          Text(this.item.appName)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ start: PADDING_16, bottom: PADDING_2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)

        this.toggleView();
      }
      .width('100%')
      .constraintSize({
        minHeight: '64vp'
      })
      .onClick(() => {
        this.item.isSelected = !this.item.isSelected;
        this.onAppChildItemClicked(this.item.isSelected, this.item, this.item.index, this.index);
      })

      if (this.index !== this.count - 1) {
        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
          .margin({
            start: PADDING_64,
            end: PADDING_8
          })
      }
    }
  }
}

@Component
export struct AppListDataInfoComponent {
  @ObjectLink item: AppInfoData;
  @State index: number = 0;
  private selectAppInfoArray: AppInfoData[] = [];
  @State appInfoArray: AppInfoData[] = [];
  @Link selectCountChild: number;
  private onClickRemoveItem: boolean = false;
  @Link data: AppInfoDataGroups;
  private onAppItemClicked: (index: number, indexChild: number, item: AppInfoData) => void = () => {
  };

  private toggleStateOnChange(isOn: boolean, item: AppInfoData): void {
    if (this.onClickRemoveItem) {
      this.data.appInfoDataGroups.forEach(element => {
        if (element.bundleName === item.bundleName && element.uid === item.uid) {
          this.data.deleteData(this.data.appInfoDataGroups.indexOf(element));
        }
      })
    }
    if (isOn) {
      if (this.selectAppInfoArray.indexOf(item) < 0) {
        this.selectAppInfoArray.push(item);
      }
    } else {
      this.updateSelectApp(item);
    }
    this.selectCountChild = this.selectAppInfoArray.length;
  }

  private updateSelectApp(item: AppInfoData) {
    this.selectAppInfoArray.forEach(element => {
      if (element.bundleName === item.bundleName && element.uid === item.uid) {
        const index = this.selectAppInfoArray.indexOf(element);
        if (index > -1) {
          this.selectAppInfoArray.splice(index, 1)
        }
      }
    })
  }

  @Builder
  toggleView(): void {
    Toggle({
      type: ToggleType.Checkbox,
      isOn: this.item.isSelected
    })
      .width(20)
      .height(20)
      .margin({ start: PADDING_8 })
      .selectedColor($r('sys.color.comp_background_emphasize'))
      .onChange((isOn: boolean) => {
        this.item.isSelected = isOn;
        this.toggleStateOnChange(isOn, this.item);
        this.onAppItemClicked(this.item.index, this.index, this.item);
      })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.item.appIconBase64 == undefined ? $r('app.media.notification_icon') : this.item.appIconBase64)
            .width('48vp')
            .height('48vp')
            .objectFit(ImageFit.Contain)
            .borderRadius($r('sys.float.corner_radius_level6'))
            .draggable(false)
            .border({
              color: '#99808080',
              width: '1px'
            })
        }
        .width('48vp')
        .height('48vp')

        Column() {
          Text(this.item.appName)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ start: PADDING_16, bottom: PADDING_2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)

        this.toggleView();
      }
      .width('100%')
      .constraintSize({
        minHeight: '64vp'
      })
      .onClick(() => {
        this.item.isSelected = !this.item.isSelected;
        this.toggleStateOnChange(this.item.isSelected, this.item);
        this.onAppItemClicked(this.item.index, this.index, this.item);
      })

      if (!this.item.isLastItem) {
        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
          .margin({
            start: PADDING_64,
            end: PADDING_8
          })
      }
    }
  }
}

@Component
export default struct NotDisturbTrustAppItemComponent {
  @State private data: AppInfoDataGroups = new AppInfoDataGroups('');
  private selectAppInfoArray: AppInfoData[] = [];
  appInfoArray: AppInfoData[] = [];
  @Link selectCountChild: number;
  private onClickRemoveItem: boolean = false;
  private onAppItemClicked: (index: number, indexChild: number, item: AppInfoData) => void = () => {
  };

  aboutToAppear(): void {
    this.appInfoArray = this.data.appInfoDataGroups;
  }

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        LazyForEach(this.data, (item: AppInfoData, index: number) => {
          ListItem() {
            AppListDataInfoComponent({
              data: this.data,
              item: item,
              index: index,
              selectAppInfoArray: this.selectAppInfoArray,
              appInfoArray: this.appInfoArray,
              selectCountChild: this.selectCountChild,
              onAppItemClicked: this.onAppItemClicked,
              onClickRemoveItem: this.onClickRemoveItem
            })
          }
        }, (item: AppInfoData) => (item.bundleName + item.uid))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
export struct AppGroupsComponent {
  private scroller: Scroller = new Scroller();
  private appGroups?: AppInfoDataSource;
  private selectAppInfoArray: AppInfoData[] = [];
  @Link selectCount: number;
  selectList: string[] = [];
  @State private alphabetIndex: number | undefined = 0;

  @Builder
  appInfoDataGroupsView(item: AppInfoDataGroups): void {
    Column() {
      Column() {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.End,
          alignItems: ItemAlign.Start
        }) {
          Text(item.prefix)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Subtitle_S'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
        }
        .padding({ bottom: '8vp' })
        .width('100%')
        .height('48vp')
      }

      NotDisturbTrustAppItemComponent({
        data: item,
        selectAppInfoArray: this.selectAppInfoArray,
        selectCountChild: this.selectCount
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      List({ scroller: this.scroller }) {
        LazyForEach(this.appGroups, (item: AppInfoDataGroups, index: number) => {
          ListItem() {
            this.appInfoDataGroupsView(item);
          }
        }, (item: AppInfoDataGroups) => (item.prefix + item.index))
      }
      .width('100%')
      .padding({
        start: PADDING_16,
        end: PADDING_32
      })
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .onScrollIndex((firstIndex: number, lastIndex: number) => {
        this.alphabetIndex = this.appGroups?.getPrefixIndex(firstIndex);
      })
      .onScrollStart(() => {
        emitter.emit(AlphabetIndexerComponent.innerEvent);
      })
      .onScrollStop(() => {
      })

      AlphabetIndexerComponent({
        appInfoGroups: this.appGroups,
        scroller: this.scroller,
        selectedIndex: this.alphabetIndex
      })
        .margin({ top: -40 })
        .offset({
          x: 0,
          y: 0
        })
    }
    .width('100%')
  }
}

@Component
export struct AlphabetIndexerComponent {
  @Prop selectedIndex: number = 0;
  private appInfoGroups: AppInfoDataSource = new AppInfoDataSource();
  scroller: Scroller = new Scroller();
  @State isPop: boolean = false;
  static innerEvent: emitter.InnerEvent = {
    eventId: EVENT_ID_NOT_DISTURB_ALPHABET_INDEX_UPDATE,
    priority: emitter.EventPriority.HIGH
  };

  aboutToAppear(): void {
    emitter.on(AlphabetIndexerComponent.innerEvent, () => {
      if (this.isPop) {
        this.isPop = false;
      }
    })
  }

  aboutToDisappear() {
    emitter.off(EVENT_ID_NOT_DISTURB_ALPHABET_INDEX_UPDATE)
  }

  build() {
    Column() {
      AlphabetIndexer({
        arrayValue: alphabets,
        selected: this.selectedIndex
      })
        .autoCollapse(true)
        .selectedColor($r('sys.color.font_emphasize'))
        .popupColor($r('sys.color.font_emphasize'))
        .selectedBackgroundColor($r('sys.color.comp_emphasize_tertiary'))
        .popupBackground($r('sys.color.comp_emphasize_tertiary'))
        .usingPopup(this.isPop)
        .selectedFont({ size: '10vp', weight: FontWeight.Medium })
        .popupFont({ size: $r('sys.float.Title_M') })
        .popupPosition({ x: '60vp' })
        .alignStyle(IndexerAlign.END, 48)
        .onSelect((index: number) => {
          let scrollIndex = this.appInfoGroups.getListScrollIndex(index);
          if (scrollIndex >= 0) {
            this.scroller.scrollToIndex(scrollIndex);
          }
        })
        .onRequestPopupData((index: number) => {
          return this.appInfoGroups.getPrefixList(index);
        })
        .onPopupSelect((index: number) => {
        })
    }
    .padding({ end: PADDING_4 })
    .height('90%')
    .width('24vp')
    .onTouch((event) => {
      if (event?.type === TouchType.Down) {
        this.isPop = true;
      }
    })
  }
}