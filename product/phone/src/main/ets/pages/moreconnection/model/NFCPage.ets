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

import lottie, { AnimationItem } from '@ohos/lottie'
import { CanvasMenu,
  CardMenuSection,
  DefaultCanvasMenuStyle,
  DefaultStateMenuStyle,
  DEFAULT_PADDING_END,
  DEFAULT_PADDING_START,
  NavigationEntry,
  StateMenu,
  SwitchMenu,
  TitleTextStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { CanvasMenuController,
  EmptyInvisibleController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { CanvasStyle, ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { NFCDefaultPaymentAppController } from '../controller/NFCDefaultPaymentAppController';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { RawFileUtil } from '@ohos/settings.common/src/main/ets/utils/RawFileUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NFCServiceController } from '@ohos/settings.moreconnection/src/main/ets/controller/NFCServiceController';
import { PageUrl } from '../../PageUrl';

/**
 * NFC logo容器
 */
class NFCLogoContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: $r('app.float.height_288'),
  };
  public backgroundColor = Color.Transparent;
}

/**
 * NFC logo样式
 */
class NFCLogoCanvasStyle extends CanvasStyle {
  public size: SizeOptions = {
    width: $r('app.float.width_288'),
    height: $r('app.float.height_288'),
  };
}

/**
 * NFC 整体样式
 */
class NFCLogoStyleMenuStyle extends DefaultCanvasMenuStyle {
  public rootContainer: ContainerStyle = new NFCLogoContainerStyle();
  public canvas: CanvasStyle = new NFCLogoCanvasStyle();
}

/**
 * NFC logo下方提示文字
 */
class NFCTextStyle extends TitleTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Regular,
  };
  public textAlign: TextAlign = TextAlign.Center;
}

/**
 * NFC 下方字体框样式
 */
export class NFCTextContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public padding: Padding = {
    left: DEFAULT_PADDING_START,
    right: DEFAULT_PADDING_END,
  };
  public margin: Margin = {
    top: '24vp',
    bottom: '20vp',
    right: '12vp',
    left: '12vp',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '24vp',
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
}

class NFCMenuStyle extends DefaultStateMenuStyle {
  public rootContainer: ContainerStyle = new NFCTextContainerStyle();
  public title: TextStyle = new NFCTextStyle();
}

export class NFCLottieMenuController extends CanvasMenuController {
  public tag: string = 'NFCLottieMenuController : ';
  public animationItem: AnimationItem | undefined = undefined;
  private nfcLottieResourcePath: string = 'data.json';
  private readonly nfcDarkLottieResourcePath: string = 'dark.json';
  private readonly nfcNormalLottieResourcePath: string = 'data.json';

  static CreateNFCLottieMenuController(menu: SettingsBaseMenu): Controller {
    return new NFCLottieMenuController(menu);
  }

  public getCanvasRenderingContext(): CanvasRenderingContext2D {
    return this.canvasRenderingContext;
  }

  aboutToAppear() {
    if (AppStorage.get<number>('changeMode') === 0) {
      this.nfcLottieResourcePath = this.nfcDarkLottieResourcePath;
    } else {
      this.nfcLottieResourcePath = this.nfcNormalLottieResourcePath;
    }
  }

  async onCanvasReady() {
    const data: object = await RawFileUtil.getJsonRawFile(this.nfcLottieResourcePath);
    this.animationItem = lottie.loadAnimation({
      container: this.getCanvasRenderingContext(),
      renderer: 'canvas',
      name: 'nfc_lottie',
      animationData: data,
    });
    LogUtil.info(`${this.tag} onCanvasReady ${this.animationItem.getDuration()}`);
    this.animationItem.play();
  }

  onCanvasDisappear() {
    LogUtil.info(`${this.tag} nfc destroy lottie.`);
    this.animationItem?.destroy();
  }
}

/**
 * NFC界面
 */
export class NFCPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.NFC_PAGE_URL,
      title: $r('app.string.nfc_quick_toggle_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new CanvasMenu(
        {
          key: 'nfc_logo',
          index: 10,
          style: new NFCLogoStyleMenuStyle(),
          controller: {
            createControllerConstructorInter: NFCLottieMenuController.CreateNFCLottieMenuController,
          },
        }
      ),
      new StateMenu(
        {
          key: 'reset_factory_detail_content',
          index: 20,
          style: new NFCMenuStyle(),
          title: $r('app.string.nfc_how_to_use_description_text'),
        }
      ),
      new CardMenuSection(
        {
          key: 'nfc_access_group',
          index: 30,
          controller: {
            createControllerConstructorInter: EmptyInvisibleController.CreateEmptyInvisibleController,
          },
        },
        [
          new SwitchMenu(
            {
              key: 'nfc_access_enable',
              index: 10,
              tabIndex: 101,
              title: $r('app.string.nfc_quick_toggle_title'),
              controller: {
                createControllerConstructorInter: NFCServiceController.CreateNFCServiceController,
              },
            }
          )
        ]
      ),
      new CardMenuSection(
        {
          key: 'nfc_default_payment_application',
        },
        [
          new NavigationEntry({
            key: 'default_payment_application',
            index: 111,
            tabIndex: 102,
            title: $r('app.string.nfc_default_payment_text'),
            stateIcon: $r('app.media.ic_settings_arrow'),
            controller: {
              createControllerConstructorInter: NFCDefaultPaymentAppController.createNFCDefaultPaymentAppController,
            }
          })
        ]
      )
    ]);
  }
}