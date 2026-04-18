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

export class PasswordRiskDialogManager {
  public static readonly PRELOAD_RISK_DIALOG_OPEN: string = 'preloadRiskDialogOpen';
  public static readonly DESKTOP_RISK_DIALOG_OPEN: string = 'desktopRiskDialogOpen';
  public static readonly EXTERNAL_RISK_DIALOG_OPEN: string = 'externalRiskDialogOpen';
  private static isRiskDialogOpen: boolean = true;
  private static isSupportNinetySixHoursReset: boolean = false;

  public static getRiskDialogOpen(): boolean {
    const preloadRiskDialogOpen = !!AppStorage.get(PasswordRiskDialogManager.PRELOAD_RISK_DIALOG_OPEN);
    const desktopRiskDialogOpen = !!AppStorage.get(PasswordRiskDialogManager.DESKTOP_RISK_DIALOG_OPEN);
    return PasswordRiskDialogManager.isRiskDialogOpen && !preloadRiskDialogOpen && !desktopRiskDialogOpen;
  }

  public static getExternalRiskDialogOpen(): boolean {
    return !!AppStorage.get(PasswordRiskDialogManager.EXTERNAL_RISK_DIALOG_OPEN);
  }

  public static setRiskDialogOpen(riskDialogOpen: boolean): void {
    PasswordRiskDialogManager.isRiskDialogOpen = riskDialogOpen;
  }

  public static setNinetySixHoursMode(supportNinetySixHoursReset: boolean): void {
    PasswordRiskDialogManager.isSupportNinetySixHoursReset = supportNinetySixHoursReset;
  }

  public static getNinetySixHoursMode(): boolean {
    return PasswordRiskDialogManager.isSupportNinetySixHoursReset;
  }
}