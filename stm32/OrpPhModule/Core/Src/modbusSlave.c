/*
 * modbusSlave.c
 *
 *  Created on: Oct 27, 2022
 *      Author: controllerstech.com
 */

#include "modbusSlave.h"
#include "main.h"


extern uint8_t RxData[256];
extern uint8_t TxData[256];
extern UART_HandleTypeDef huart1;

uint16_t Holding_Registers_Database[50]={
		0000,  1111,  2222,  3333,  4444,  5555,  6666,  7777,  8888,  9999,   // 0-9   40001-40010
		12345, 15432, 15535, 10234, 19876, 13579, 10293, 19827, 13456, 14567,  // 10-19 40011-40020
		21345, 22345, 24567, 25678, 26789, 24680, 20394, 29384, 26937, 27654,  // 20-29 40021-40030
		31245, 31456, 34567, 35678, 36789, 37890, 30948, 34958, 35867, 36092,  // 30-39 40031-40040
		45678, 46789, 47890, 41235, 42356, 43567, 40596, 49586, 48765, 41029,  // 40-49 40041-40050
};

void writeToHolding(uint16_t address, uint16_t value) {
	Holding_Registers_Database[address] = value;
}

void sendData (uint8_t *data, int size)
{
	// we will calculate the CRC in this function itself
	uint16_t crc = crc16(data, size);
	data[size] = crc&0xFF;   // CRC LOW
	data[size+1] = (crc>>8)&0xFF;  // CRC HIGH

	HAL_GPIO_WritePin(Rs485_control_GPIO_Port,Rs485_control_Pin,GPIO_PIN_SET);
	HAL_GPIO_WritePin(Led_blue_GPIO_Port,Led_blue_Pin,GPIO_PIN_SET);
	HAL_UART_Transmit(&huart1, data, size+2, 1000);
	HAL_GPIO_WritePin(Rs485_control_GPIO_Port,Rs485_control_Pin,GPIO_PIN_RESET);
	HAL_GPIO_WritePin(Led_blue_GPIO_Port,Led_blue_Pin,GPIO_PIN_RESET);
}

void modbusException (uint8_t exceptioncode)
{
	//| SLAVE_ID | FUNCTION_CODE | Exception code | CRC     |
	//| 1 BYTE   |  1 BYTE       |    1 BYTE      | 2 BYTES |

	TxData[0] = RxData[0];       // slave ID
	TxData[1] = RxData[1]|0x80;  // adding 1 to the MSB of the function code
	TxData[2] = exceptioncode;   // Load the Exception code
	sendData(TxData, 3);         // send Data... CRC will be calculated in the function
}


uint8_t readHoldingRegs (void)
{
	uint16_t startAddr = ((RxData[2]<<8)|RxData[3]);  // start Register Address

	uint16_t numRegs = ((RxData[4]<<8)|RxData[5]);   // number to registers master has requested
	if ((numRegs<1)||(numRegs>125))  // maximum no. of Registers as per the PDF
	{
		modbusException (ILLEGAL_DATA_VALUE);  // send an exception
		return 0;
	}

	uint16_t endAddr = startAddr+numRegs-1;  // end Register
	if (endAddr>49)  // end Register can not be more than 49 as we only have record of 50 Registers in total
	{
		modbusException(ILLEGAL_DATA_ADDRESS);   // send an exception
		return 0;
	}

	// Prepare TxData buffer

	//| SLAVE_ID | FUNCTION_CODE | BYTE COUNT | DATA      | CRC     |
	//| 1 BYTE   |  1 BYTE       |  1 BYTE    | N*2 BYTES | 2 BYTES |

	TxData[0] = SLAVE_ID;  // slave ID
	TxData[1] = RxData[1];  // function code
	TxData[2] = numRegs*2;  // Byte count
	int indx = 3;  // we need to keep track of how many bytes has been stored in TxData Buffer

	for (int i=0; i<numRegs; i++)   // Load the actual data into TxData buffer
	{
		TxData[indx++] = (Holding_Registers_Database[startAddr]>>8)&0xFF;  // extract the higher byte
		TxData[indx++] = (Holding_Registers_Database[startAddr])&0xFF;   // extract the lower byte
		startAddr++;  // increment the register address
	}

	sendData(TxData, indx);  // send data... CRC will be calculated in the function itself
	return 1;   // success
}

uint8_t readInputRegs (void)
{
	uint16_t startAddr = ((RxData[2]<<8)|RxData[3]);  // start Register Address

	uint16_t numRegs = ((RxData[4]<<8)|RxData[5]);   // number to registers master has requested
	if ((numRegs<1)||(numRegs>125))  // maximum no. of Registers as per the PDF
	{
		modbusException (ILLEGAL_DATA_VALUE);  // send an exception
		return 0;
	}

	uint16_t endAddr = startAddr+numRegs-1;  // end Register
	if (endAddr>49)  // end Register can not be more than 49 as we only have record of 50 Registers in total
	{
		modbusException(ILLEGAL_DATA_ADDRESS);   // send an exception
		return 0;
	}

	// Prepare TxData buffer

	//| SLAVE_ID | FUNCTION_CODE | BYTE COUNT | DATA      | CRC     |
	//| 1 BYTE   |  1 BYTE       |  1 BYTE    | N*2 BYTES | 2 BYTES |

	TxData[0] = SLAVE_ID;  // slave ID
	TxData[1] = RxData[1];  // function code
	TxData[2] = numRegs*2;  // Byte count
	int indx = 3;  // we need to keep track of how many bytes has been stored in TxData Buffer

	for (int i=0; i<numRegs; i++)   // Load the actual data into TxData buffer
	{
		TxData[indx++] = (Input_Registers_Database[startAddr]>>8)&0xFF;  // extract the higher byte
		TxData[indx++] = (Input_Registers_Database[startAddr])&0xFF;   // extract the lower byte
		startAddr++;  // increment the register address
	}

	sendData(TxData, indx);  // send data... CRC will be calculated in the function itself
	return 1;   // success
}
