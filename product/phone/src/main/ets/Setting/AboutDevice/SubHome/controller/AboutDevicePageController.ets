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
import { curves } from '@kit.ArkUI';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl,
  SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { IAboutDevicePageCtrl } from '@ohos/settings.aboutdevice/src/main/ets/controller/IAboutDevicePageCtrl';
import {
  AboutDeviceCardAction,
  AboutDeviceOucPublishData,
  AnimateType,
  OucAboutDeviceViewModel
} from '@ohos/settings.aboutdevice/src/main/ets/model/OucAboutDeviceViewModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE,
  EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW
} from '@ohos/settings.aboutdevice/src/main/ets/const/AboutDeviceConst';
import { AboutDevicePageModel, LogoImageMenuContainerStyle } from '../model/AboutDevicePageModel';

const SPRING_CURVE = curves.interpolatingSpring(0, 1, 439, 48);
const TIME_MS_1000 = 1000;
const TIME_MS_383 = 383;
const TIME_MS_100 = 100;

/**
 * 关于页面Controller
 *
 * @since 2024-06-22
 */
export class AboutDevicePageController implements ComponentControl, IAboutDevicePageCtrl {
  public tag: string = 'AboutDevicePageController : ';
  private pageModel?: AboutDevicePageModel;
  private isInAboutDevicePage: boolean = true;

  init(compParam: CompCtrlParam): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel?.init();
    this.initOucOffsetY();
    this.adjustListPosition();
    if (OucAboutDeviceViewModel.isToOUCLikePhone(compParam.param as PushParam) &&
      !this.pageModel?.isEmulator) {
      LogUtil.info(`${this.tag} jump ouc directly`);
      this.pageModel.oucAboutDeviceCardModel.isOucPreloadImgShow = false;
      this.cardAreaExpand();
    }

    let pageInfo: SettingPageModel = this.pageModel.aboutDevicePage;
    if (!pageInfo.groups) {
      LogUtil.showInfo(this.tag, 'Init failed, page group is empty');
      return;
    }

    let groupLen: number = pageInfo.groups.length;
    for (let groupIndex: number = 0; groupIndex < groupLen; groupIndex++) {
      const group: SettingGroupModel = pageInfo.groups[groupIndex];
      if (!group.items) {
        continue;
      }
      for (let itemIndex: number = 0; itemIndex < group.items.length; itemIndex++) {
        const item: SettingItemModel = group.items[itemIndex];
        if (PreferencesUtil.hasSync(item.id)) {
          item.enabled = !PreferencesUtil.getSync(item.id, true) as boolean;
          LogUtil.showInfo(this.tag, `disable item:${item.id}, enabled: ${item.enabled}`);
        }
      }
    }
  }

  onPageShow(component: SettingBaseModel): void {
    EventBus.getInstance().emit(EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW);
  }

  onPageHide(component: SettingBaseModel): void {
    EventBus.getInstance().emit(EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE);
  }

  destroy(): void {
  }

  public setPageModel(pageModel: AboutDevicePageModel): void {
    this.pageModel = pageModel;
  }

  public adjustListPosition(): void {
    LogUtil.info(`${this.tag} adjustListPosition`);
    if (!this.pageModel) {
      return;
    }
    this.pageModel.listColumnMarginTop = OucAboutDeviceViewModel.getListColumnMarginTop();
    if (this.pageModel?.isEmulator) {
      this.changeEmulatorImgHeight();
      return;
    }
    if (this.pageModel?.oucAboutDeviceCardModel?.isOucPreloadImgShow) {
      this.changeOucPreloadImgHeight();
      this.changeOucUIExtensionCompHeightPercent();
      return;
    }
    this.changeOucUIExtensionCompHeightPercent();
  }

  /**
   * 改变模拟器图片高度
   */
  public changeEmulatorImgHeight(): void {
    let cardModel = this.pageModel?.oucAboutDeviceEmulatorCardModel;
    if (cardModel && cardModel.rootContainerStyle) {
      let rootContainerStyle: ContainerStyle = new LogoImageMenuContainerStyle();
      rootContainerStyle.size = {
        height: OucAboutDeviceViewModel.getReallyFoldCardHeight(),
      };
      cardModel.rootContainerStyle = rootContainerStyle;
    }
  }

  /**
   * 改变ouc预加载图片高度
   */
  public changeOucPreloadImgHeight(): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.oucAboutDeviceCardModel.oucPreloadImgSize = {
      height: OucAboutDeviceViewModel.getReallyFoldCardHeight(),
      width: 'undefined',
    };
  }

  /**
   * 改变ouc UIExtension组件的高度
   *
   * @returns 是否更改
   */
  public changeOucUIExtensionCompHeightPercent(): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.oucAboutDeviceCardModel.size = {
      height: this.isInAboutDevicePage ? OucAboutDeviceViewModel.getOucColumnPercent() : '100%'
    };
  }

  private animateToOuc(animateType?: AnimateType): void {
    LogUtil.info(`${this.tag} animateToOuc animateType: ${animateType}`);
    // 展开无动效
    if (!animateType) {
      this.doExpand();
      return;
    }
    // 设置动效
    switch (animateType) {
      case AnimateType.CHECKING:
        animateTo({ curve: Curve.Friction, duration: TIME_MS_383 }, () => {
          this.doExpand();
        })
        break;
      case AnimateType.NO_VERSION:
        animateTo({ duration: TIME_MS_1000, curve: SPRING_CURVE }, () => {
          this.doExpand();
        });
        break;
      case AnimateType.HAS_VERSION:
        animateTo({ duration: TIME_MS_1000, curve: SPRING_CURVE }, () => {
          this.doExpand();
        });
        break;
      default:
        break;
    }
  }

  private doExpand(): void {
    this.setTitleVisible(false);
    this.setMenuListVisible(false);
    this.setPageScrollEdgeEffect(EdgeEffect.None);
    this.initOucOffsetY();
    this.changeOucUIExtensionCompHeightPercent();
  }

  private initOucOffsetY() {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.oucOffsetYPixel = 0;
  }

  private getOucOffsetY(): number {
    return px2vp(this.pageModel?.oucOffsetYPixel ?? 0);
  }

  private animateOucBack(animateType?: AnimateType): void {
    LogUtil.info(`${this.tag} animateOucBack animateType: ${animateType}`);
    // 折叠无动效
    if (!animateType) {
      this.setBarStateOff(false);
      this.doFold();
      return;
    }
    // 设置动效
    switch (animateType) {
      case AnimateType.CHECKING:
        animateTo({ curve: Curve.Friction, duration: TIME_MS_383, onFinish: () => {
          if (this.isInAboutDevicePage) {
            this.setBarStateOff(false);
          }
        }}, () => {
          this.doFold();
        });
        break;
      case AnimateType.NO_VERSION:
        animateTo({ duration: TIME_MS_1000, curve: SPRING_CURVE, onFinish: () => {
          if (this.isInAboutDevicePage) {
            this.setBarStateOff(false);
          }
        }}, () => {
          this.doFold();
        });
        break;
      case AnimateType.HAS_VERSION:
        animateTo({ duration: TIME_MS_1000, curve: SPRING_CURVE, onFinish: () => {
          if (this.isInAboutDevicePage) {
            this.setBarStateOff(false);
          }
        }}, () => {
          this.doFold();
        });
        break;
      default:
        break;
    }
  }

  private doFold(): void {
    this.setTitleVisible(true);
    this.setMenuListVisible(true);
    this.setPageScrollEdgeEffect(EdgeEffect.Spring);
    this.changeOucUIExtensionCompHeightPercent();
  }

  private checkAnimateType(animateType: AnimateType): boolean {
    return animateType === AnimateType.CHECKING ||
      animateType === AnimateType.NO_VERSION ||
      animateType === AnimateType.HAS_VERSION;
  }

  private cardAreaExpand(animateType?: AnimateType, extraInfo?: object): void {
    let oucSmallCardAspect = extraInfo?.['oucSmallCardAspect'] as Object;
    if (animateType && !this.checkAnimateType(animateType)) {
      LogUtil.error(`${this.tag} cardAreaExpand animateType error.`);
      return;
    }
    this.scrollEnable(false);
    this.setBarStateOff(true);
    this.isInAboutDevicePage = false;
    AppStorage.setOrCreate<boolean>('isInAboutDevicePage', false);
    this.setTransitionToMenuList(animateType, oucSmallCardAspect);
    this.animateToOuc(animateType);
  }

  private cardAreaFold(animateType?: AnimateType, extraInfo?: object): void {
    let oucSmallCardAspect = extraInfo?.['oucSmallCardAspect'] as Object;
    if (animateType && !this.checkAnimateType(animateType)) {
      LogUtil.error(`${this.tag} cardAreaFold animateType error.`);
      return;
    }
    this.isInAboutDevicePage = true;
    AppStorage.setOrCreate<boolean>('isInAboutDevicePage', true);
    this.scrollEnable(true);
    this.setTransitionToMenuList(animateType, oucSmallCardAspect);
    this.animateOucBack(animateType);
  }

  private cardAreaInitAgain(extraInfo?: object): void {
    if (!this.pageModel) {
      return;
    }
    let uriTargetSubRouter = extraInfo?.['uriTargetSubRouter'] as Object;
    let isToOUC = OucAboutDeviceViewModel.isUriToOUCLikePhone(uriTargetSubRouter?.toString());
    if (isToOUC && this.isInAboutDevicePage) {
      LogUtil.info(`${this.tag} cardAreaInitAgain expand`);
      this.pageModel.oucAboutDeviceCardModel.isOucPreloadImgShow = false;
      this.cardAreaExpand();
    }
    if (!isToOUC && !this.isInAboutDevicePage) {
      LogUtil.info(`${this.tag} cardAreaInitAgain fold`);
      this.pageModel.oucAboutDeviceCardModel.isOucPreloadImgShow = true;
      this.cardAreaFold();
    }
  }

  private scrollEnable(isEnable: boolean) {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.isScrollEnable = isEnable;
  }

  private setBarStateOff(isAboutDeviceBarStateOff: boolean) {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.isAboutDeviceBarStateOff = isAboutDeviceBarStateOff;
  }

  private setTitleVisible(show: boolean): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.isAboutDeviceTitleShow = show;
  }

  private setTransitionToMenuList(animateType?: AnimateType, oucSmallCardAspect?: Object): void {
    if (!this.pageModel) {
      return;
    }
    if (animateType === AnimateType.CHECKING) {
      let moveY = OucAboutDeviceViewModel.getListMoveBottomLength() - this.getOucOffsetY();
      this.pageModel.menuListTransitionEffect = TransitionEffect.translate({y: moveY});
    }

    if (animateType === AnimateType.NO_VERSION) {
      let moveY = OucAboutDeviceViewModel.getListMoveBottomLength() - this.getOucOffsetY();
      this.pageModel.menuListTransitionEffect = TransitionEffect.translate({y: moveY}).animation({
        duration: TIME_MS_1000,
        curve: SPRING_CURVE,
      });
    }

    if (animateType === AnimateType.HAS_VERSION) {
      let moveY = OucAboutDeviceViewModel.getListToOucNewVersionMoveLength(
        Number.parseFloat(oucSmallCardAspect?.toString() ?? '')) - this.getOucOffsetY();
      this.pageModel.menuListTransitionEffect = TransitionEffect.translate({y: moveY}).animation({
        duration: TIME_MS_1000,
        curve: SPRING_CURVE,
      }).combine(TransitionEffect.OPACITY.animation({
        duration: TIME_MS_100,
        curve: Curve.Friction
      }));
    }
  }

  private setMenuListVisible(show: boolean): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.menuListShow = show;
  }

  private setPageScrollEdgeEffect(edgeEffect: EdgeEffect): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel.scrollEdgeEffect = edgeEffect;
  }

  /**
   * 当前页其他Controller的数据变化回调
   *
   * @param fromKey 消息发送的Controller的Key
   * @param data 消息内容
   */
  publishDataChange(fromKey: string, data: Object): void {
    if (data === null || data === undefined || !this.pageModel) {
      return;
    }
    if (fromKey !== 'about_device_ouc_card') {
      LogUtil.error(`${this.tag} illegal fromKey:${fromKey}`);
      return;
    }
    let aboutDeviceOucPublishData = data as AboutDeviceOucPublishData;
    let oucCardAction = aboutDeviceOucPublishData.aboutDeviceCardAction;
    let animateType = aboutDeviceOucPublishData.animateType;
    let extraInfo = aboutDeviceOucPublishData.extraInfo;
    LogUtil.info(`${this.tag} oucCardAction:${oucCardAction}, animateType:${animateType},
      extraInfo:${JSON.stringify(extraInfo)}`);
    if (oucCardAction === AboutDeviceCardAction.EXPAND) {
      this.cardAreaExpand(animateType as AnimateType, extraInfo);
    }

    if (oucCardAction === AboutDeviceCardAction.FOLD) {
      this.cardAreaFold(animateType as AnimateType, extraInfo);
    }

    if (oucCardAction === AboutDeviceCardAction.POP) {
      this.pageModel?.onBackPressed?.();
    }

    if (oucCardAction === AboutDeviceCardAction.PRELOAD_IMG_HIDE) {
      this.pageModel.oucAboutDeviceCardModel.isOucPreloadImgShow = false;
    }

    if (oucCardAction === AboutDeviceCardAction.INIT_AGAIN) {
      this.cardAreaInitAgain(extraInfo);
    }
  }
}