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
import { BusinessError } from '@ohos.base';
import connection from '@ohos.net.connection';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNetworkGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_4
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { Constants } from '../constant/Constants';
import { CustomTextInputArea } from './CustomTextInputArea'
import { DialogButton, DialogTitleBar } from './NetworkDialogComponent';
import { IProxySettingParameters } from '../model/IProxySettingParameters';
import { ProxyUtil } from '../util/ProxyUtil';
import { UserTipConfirmDialogView } from './UserTipConfirmDialogView';

const TAG: string = 'ProxyDetailSettingDialogView';
const DEFAULT_PROXY_PORT: number = 8080;

export interface IProxyParam extends SettingItemModel {
  useProxy: boolean;
}

class HttpProxyParam {
  public host: string = '';
  public port: string | number = '';
  public exclusionList: Array<string> = [];

  constructor(host: string, port: string | number, exclusionList: Array<string>) {
    this.host = host;
    this.port = port;
    this.exclusionList = exclusionList;
  }
}

PersistentStorage.persistProp('persistentProxy', new HttpProxyParam('', '', []));

@Component
struct ProxyDetailSettingDialogView {
  @State useProxy: boolean = false;
  @State proxyParametersInfo: IProxySettingParameters = {};
  @State errorInputKeys: string[] = [];
  @State focused: boolean = false;
  // 半模态弹出
  private isProxyDialogShow: boolean = false;
  private portRegExp =
    new RegExp('^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$');
  private whitelistRegExp = new RegExp('^([a-zA-Z0-9\\-.*]+(?:,[a-zA-Z0-9\\-.*]+)*)?$');
  private controller?: CustomDialogController;
  private useProxyBefore: boolean | null = null;
  private globalContext: GlobalContext = GlobalContext.getInstance();
  private isNeedShowProxyTips: boolean = false;
  private rdtUseProxy: boolean = false;
  private proxyDialogShowCallback = (isShow: boolean) => {
    this.isProxyDialogShow = isShow;
    LogUtil.info(`${TAG} ProxyDetailSettingDialogView isProxyDialogShow = ${this.isProxyDialogShow}, useProxy = ${this.useProxy}`);
    // 更新外层设置项内容
    if (!this.isProxyDialogShow) {
      notifyCompStateChange(Constants.PROXY_SETTINGS_DIALOG_ID,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          {
            type: ItemResultType.RESULT_TYPE_TEXT, result: {
            content: this.useProxy ? $r('app.string.projection_state_on') :
            $r('app.string.projection_state_off')
          }
          } as SettingResultState]]));
      AppStorage.setOrCreate('useProxy', this.useProxy);
    }
    // 操作半模态弹框显示
    notifyCompStateChange(Constants.PROXY_SETTINGS_DIALOG_ID,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        {
          state: this.isProxyDialogShow,
        } as SettingCompState]]
      ));
  };

  private onDialogDismissCallback = () => {
    LogUtil.info(`${TAG} onDialogDismissCallback`);
    this.cleanBackUpParameters();
  };

  aboutToAppear(): void {
    this.useProxy = AppStorage.get('useProxy') as boolean;
    LogUtil.info(`${TAG} ProxyDetailSettingDialogView aboutToAppear ${this.useProxy}`);
    LogUtil.debug(`${TAG} ProxyDetailSettingDialogView aboutToAppear ${this.rdtUseProxy} - ${this.errorInputKeys}`);
    this.useProxyBefore = this.useProxy;
    if (this.globalContext.get('backUpHost') as string || this.globalContext.get('backUpHost') as string === '') {
      this.proxyParametersInfo = {
        proxyServerHostName: this.globalContext.get('backUpHost') as string,
        proxyServerHostPort: this.globalContext.get('backUpPort') as string,
        ignoreHostList: this.globalContext.get('backUpExclusion') as string
      };
      this.errorInputKeys = this.globalContext.get('backUpErrorInputKeys') as string[];
    } else if (!this.useProxy) {
      let temp: connection.HttpProxy = AppStorage.get('persistentProxy') as connection.HttpProxy;
      this.proxyParametersInfo = {
        proxyServerHostName: temp['host'],
        proxyServerHostPort: temp['port']?.toString(),
        ignoreHostList: temp['exclusionList']?.join(',')
      };
    } else {
      ProxyUtil.getGlobalHttpProxyInfo()
        .then((data: HttpProxyParam) => {
          data.port = data.port === 0 ? '' : data.port;
          LogUtil.info(`${TAG} proxy data got success!`);
          this.proxyParametersInfo = {
            proxyServerHostName: data.host,
            proxyServerHostPort: data.port?.toString(),
            ignoreHostList: data.exclusionList?.join(',')
          };
        })
        .catch((error: BusinessError) => {
          LogUtil.error(`${TAG} get GlobalHttpProxy Info error: ${error?.code}`);
        })
    }
    this.cleanBackUpParameters();
    // 注册代理弹框显示监听
    EventBus.getInstance().on(Constants.PROXY_DIALOG_SHOW, this.proxyDialogShowCallback);
    EventBus.getInstance().on(Constants.PROXY_DIALOG_DISMISS_EVENT, this.onDialogDismissCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} ProxyDetailSettingDialogView aboutToDisappear`);
    EventBus.getInstance().detach(Constants.PROXY_DIALOG_SHOW, this.proxyDialogShowCallback);
    EventBus.getInstance().detach(Constants.PROXY_DIALOG_DISMISS_EVENT, this.onDialogDismissCallback);
    this.cleanBackUpParameters();
  }

  private showWarningTipDialog(): void {
    let tipController: CustomDialogController = new CustomDialogController({
      builder: UserTipConfirmDialogView({
        tipMessage: $r('app.string.proxy_warn_tip_msg'),
        confirm: () => {
          tipController.close();
          this.isNeedShowProxyTips = false;
        }
      }),
      alignment: DialogAlignment.Default,
      autoCancel: false,
      customStyle: false,
      cornerRadius: DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
      $r('sys.float.corner_radius_level16')
    });
    tipController.open();
    LogUtil.info(`${TAG} showWarningTipDialog`);
  }

  private cancelProxySetting(): void {
    LogUtil.info(`${TAG} cancelProxySetting`);
    this.doResetAfterCancel();
  }

  private doResetAfterCancel(): void {
    ProxyUtil.isHttpProxyEnabled((v: boolean) => {
      LogUtil.info(`${TAG} isHttpProxyEnabled received ${v}`);
      this.useProxy = v;
    });
    this.useProxy = this.useProxyBefore as boolean;
    LogUtil.info(`${TAG} doResetAfterCancel - ${this.controller}`);
    EventBus.getInstance().emit(Constants.PROXY_DIALOG_SHOW, false);
    this.cleanBackUpParameters();
  }

  private doResetAfterSaveFail(): void {
    this.useProxy = this.rdtUseProxy;
    LogUtil.info(`${TAG} doResetAfterSaveFail useProxy: ${this.useProxy}`);
    if (!this.isNeedShowProxyTips) {
      EventBus.getInstance().emit(Constants.PROXY_DIALOG_SHOW, false);
      this.cleanBackUpParameters();
    }
  }

  private backUpInputParameters(): void {
    this.rdtUseProxy = this.useProxy;
    this.globalContext.set('backUpHost',
      this.proxyParametersInfo.proxyServerHostName === undefined ? '' : this.proxyParametersInfo.proxyServerHostName);
    this.globalContext.set('backUpPort',
      this.proxyParametersInfo.proxyServerHostPort === undefined ? '' : this.proxyParametersInfo.proxyServerHostPort);
    this.globalContext.set('backUpExclusion', this.proxyParametersInfo.ignoreHostList);
    this.globalContext.set('backUpErrorInputKeys', this.errorInputKeys);
    LogUtil.info(`${TAG} restoreInputParameters1 - ${this.useProxy}`);
  }

  private cleanBackUpParameters(): void {
    this.globalContext.set('backUpHost', null);
    this.globalContext.set('backUpPort', null);
    this.globalContext.set('backUpExclusion', null);
    this.globalContext.set('backUpErrorInputKeys', null);
  }

  private saveProxySetting(): void {
    LogUtil.info(`${TAG} saveProxySetting`);
    if (!this.validateInput()) {
      this.isNeedShowProxyTips = true;
      this.showWarningTipDialog();
      this.backUpInputParameters();
      this.doResetAfterSaveFail();
      LogUtil.info(`${TAG} saveProxySetting - '${this.errorInputKeys}'`); //debug
      return;
    }

    let httpProxyParam: connection.HttpProxy = {
      host: '',
      port: DEFAULT_PROXY_PORT,
      exclusionList: [] as string[]
    };
    LogUtil.info(`${TAG} this.useProxy ${this.useProxy}`);

    if (this.useProxy) {
      httpProxyParam.host = this.proxyParametersInfo.proxyServerHostName as string;
      httpProxyParam.port = Number(this.proxyParametersInfo.proxyServerHostPort);
      if (this.proxyParametersInfo.ignoreHostList) {
        httpProxyParam.exclusionList = this.proxyParametersInfo.ignoreHostList.split(',');
      }
    }

    AppStorage.setOrCreate('persistentProxy',
      new HttpProxyParam(this.proxyParametersInfo.proxyServerHostName as string,
        this.proxyParametersInfo.proxyServerHostPort as string,
        this.proxyParametersInfo.ignoreHostList ? this.proxyParametersInfo.ignoreHostList.split(',') : []))
    LogUtil.info(`${TAG} this.useProxyBefore ${this.useProxyBefore}`);
    if (this.useProxy == this.useProxyBefore && !this.useProxyBefore) {
      EventBus.getInstance().emit(Constants.PROXY_DIALOG_SHOW, false);
      return;
    }

    this.saveGlobalHttpProxy(httpProxyParam);
  }

  private saveGlobalHttpProxy(httpProxyParam: connection.HttpProxy): void {
    LogUtil.info(`${TAG} saveGlobalHttpProxy`);

    ProxyUtil.setGlobalHttpProxy(httpProxyParam,
      (error: BusinessError) => {
        let setSuccess: boolean = true;
        if (error) {
          setSuccess = false;
          this.isNeedShowProxyTips = true;
          this.showWarningTipDialog();
          this.reportSaveProxyEvent(0, error?.code);
          LogUtil.error(`${TAG} set GlobalHttpProxy error: ${error?.code}`);
        }
        LogUtil.info(`${TAG} setProxySetting result: ${setSuccess}`);
        if (setSuccess) {
          LogUtil.info(`${TAG} setProxySetting Success clean backup parameters!`);
          this.reportSaveProxyEvent(1);
          this.cleanBackUpParameters();
          EventBus.getInstance().emit(Constants.PROXY_DIALOG_SHOW, false);
        }
      });
  }

  private reportSaveProxyEvent(result: number, errorCode?: number): void {
    let params: Record<string, Object> = {};
    params.RESULT = result;
    params.STATUS = this.useProxy ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF;
    if (errorCode) {
      params.ERROR = errorCode;
    }
    HiSysEventUtil.reportBehaviorEventByUE(HiSysNetworkGroup.NETWORK_SET_GLOBAL_PROXY, params);
  }

  private validateInput(): boolean {
    if (!this.useProxy) {
      return true;
    }
    this.errorInputKeys = [];
    let isPassive: boolean = true;
    // 校验Proxy Host
    if (this.proxyParametersInfo.proxyServerHostName === undefined ||
      this.proxyParametersInfo.proxyServerHostName === '' ||
      this.proxyParametersInfo.proxyServerHostName.length > Constants.MAX_HOST_NAME_LEN) {
      this.errorInputKeys.push('proxyServerHostName');
      LogUtil.debug(`${TAG} invalid host length is: ${(this.proxyParametersInfo.proxyServerHostName as string).length}`);
      isPassive = false;
    }

    let errorCode: number = 0;
    if (this.proxyParametersInfo.proxyServerHostName === undefined ||
      this.proxyParametersInfo.proxyServerHostName === '') {
      errorCode = Constants.EC_HOST_IS_NULL;
    } else if (this.proxyParametersInfo.proxyServerHostName.length > Constants.MAX_HOST_NAME_LEN) {
      errorCode = Constants.EC_HOST_LENGTH_EXCEED_LIMIT;
    } else {
      errorCode = 0;
    }
    if (errorCode > Constants.EC_HOST_DEFAULT) {
      this.reportProxySettings(HiSysNetworkGroup.PROXY_SERVER_HOST_INVALID, errorCode);
    }
    // 校验Proxy Port
    if (this.proxyParametersInfo.proxyServerHostPort === '' ||
      !this.portRegExp.test(this.proxyParametersInfo.proxyServerHostPort as string)) {
      this.errorInputKeys.push('proxyServerHostPort');
      LogUtil.info(`${TAG} invalid port`);
      isPassive = false;
      let errorCode: number = Constants.EC_HOST_REGULAR_MISMATCH;
      this.reportProxySettings(HiSysNetworkGroup.PROXY_SERVER_HOST_INVALID, errorCode);
    }

    if (this.proxyParametersInfo.ignoreHostList !== '' &&
      !this.whitelistRegExp.test(this.proxyParametersInfo.ignoreHostList as string)) {
      let errorCode: number = Constants.EC_IGNORE_LIST_REGULAR_MISMATCH;
      this.reportProxySettings(HiSysNetworkGroup.PROXY_SERVER_IGNORE_INVALID, errorCode);
    }

    // 校验Proxy 忽略代理设置最大长度超限
    if (this.proxyParametersInfo.ignoreHostList &&
      (this.proxyParametersInfo.ignoreHostList.length > Constants.MAX_HOST_NAME_LEN)) {
      this.errorInputKeys.push('proxyServerIgnoreHostPort');
      LogUtil.info(`${TAG} invalid ignoreHostList`);
      isPassive = false;
      this.reportProxySettings(HiSysNetworkGroup.PROXY_SERVER_IGNORE_INVALID, Constants.EC_HOST_LENGTH_EXCEED_LIMIT);
    }
    return isPassive;
  }

  private reportProxySettings(eventName: string, errorCode: number): void {
    let params: Record<string, Object> = {};
    params.ERROR = errorCode;
    HiSysEventUtil.reportBehaviorEventByUE(eventName, params);
  }

  build() {
    Column() {
      DialogTitleBar({
        title: $r('app.string.network_proxy_title')
      })

      // 代理设置
      Column() {
        // 使用代理服务器
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text($r('app.string.use_proxy_server_title'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))

          Toggle({ type: ToggleType.Switch, isOn: this.useProxy })
            .onChange((isOn: boolean) => {
              LogUtil.info(`${TAG} Toggle use proxy changed ${isOn} - ${this.useProxy}`);
              this.useProxy = isOn;
              if (this.useProxy) {
                let res: boolean = focusControl.requestFocus('proxyServerHostName');
                LogUtil.info(`${TAG} focusControl.requestFocus proxyServerHostName result1 : ${res}`)
              } else {
                let res: boolean = focusControl.requestFocus('toggle');
                LogUtil.info(`${TAG} focusControl.requestFocus toggle result2 : ${res}`)
              }
            })
            .focusable(this.useProxy === true && (this.errorInputKeys === null || this.errorInputKeys.length === 0) ?
              false : true)
            .key('ProxyDetailSettingDialogView_Toggle')
            .margin({
              end: PADDING_0
            })
        }
        .constraintSize({
          minHeight: $r('app.float.height_48')
        })
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
        $r('sys.float.corner_radius_level10'))
        .padding({
          left: $r('sys.float.padding_level6'),
          right: $r('sys.float.padding_level6'),
          top: FontScaleUtils.getCurrentTopPadding(),
          bottom: FontScaleUtils.getCurrentTopPadding()
        })
        .backgroundColor($r('sys.color.comp_background_list_card'))

        Column() {
          // 服务器主机名
          CustomTextInputArea({
            name: $r('app.string.proxy_server_host_name'),
            inputHint: $r('app.string.proxy_server_host_name_hint'),
            customKey: 'proxyServerHostName',
            type: 'textInput',
            useProxy: $useProxy,
            proxyParametersInfo: $proxyParametersInfo,
            errorInputKeys: $errorInputKeys
          })

          // 端口
          CustomTextInputArea({
            name: $r('app.string.proxy_server_port'),
            inputHint: $r('app.string.proxy_server_port_hint'),
            customKey: 'proxyServerHostPort',
            type: 'textInput',
            useProxy: $useProxy,
            proxyParametersInfo: $proxyParametersInfo,
            errorInputKeys: $errorInputKeys
          })

          // 忽略代理设置
          CustomTextInputArea({
            name: $r('app.string.proxy_setting_ignore_host'),
            customKey: 'proxyServerIgnoreHostPort',
            type: 'textArea',
            useProxy: $useProxy,
            proxyParametersInfo: $proxyParametersInfo,
            errorInputKeys: $errorInputKeys
          })
        }
        .constraintSize({ minHeight: $r('app.float.proxy_dialog_card_height') })
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') :
        $r('sys.float.corner_radius_level10'))
        .padding({
          start: PADDING_12,
          top: PADDING_4,
          bottom: PADDING_12
        })
        .margin({ top: $r('sys.float.padding_level6') })
        .backgroundColor($r('sys.color.comp_background_list_card'))
      }

      // 操作按钮
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        space: { main: PADDING_16 }
      }) {
        DialogButton({
          title: $r('app.string.cancel'),
          buttonWidth: Constants.PERCENT_50_WIDTH,
          isActive: false,
          customKey: 'ProxyDetailSettingDialogView_Button_Cancel',
          clickMethod: () => {
            this.cancelProxySetting();
          }
        })
        DialogButton({
          title: $r('app.string.save'),
          buttonWidth: Constants.PERCENT_50_WIDTH,
          isActive: true,
          customKey: 'ProxyDetailSettingDialogView_Button_Save',
          clickMethod: () => {
            this.saveProxySetting();
          }
        })
      }
      .margin({ top: $r('sys.float.padding_level8') })
    }
    .constraintSize({ minHeight: $r('app.float.proxy_dialog_height') })
    .padding({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
      bottom: $r('sys.float.padding_level12')
    })
    .onFocus(() => {
      this.focused = true;
    })
    .onBlur(() => {
      this.focused = false;
    })
  }
}

export { ProxyDetailSettingDialogView };