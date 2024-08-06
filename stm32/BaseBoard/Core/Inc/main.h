/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f1xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */
void sendData(uint8_t *data);
void Modbus(uint8_t slave, uint8_t function, uint16_t address, uint16_t data);
void RecievedModbusData(uint8_t *RxData);
/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define Relay0_Pin GPIO_PIN_0
#define Relay0_GPIO_Port GPIOC
#define Relay1_Pin GPIO_PIN_1
#define Relay1_GPIO_Port GPIOC
#define Relay2_Pin GPIO_PIN_2
#define Relay2_GPIO_Port GPIOC
#define Relay3_Pin GPIO_PIN_3
#define Relay3_GPIO_Port GPIOC
#define led2_Pin GPIO_PIN_6
#define led2_GPIO_Port GPIOC
#define led1_Pin GPIO_PIN_7
#define led1_GPIO_Port GPIOC
#define Rs485Control_Pin GPIO_PIN_12
#define Rs485Control_GPIO_Port GPIOA

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
