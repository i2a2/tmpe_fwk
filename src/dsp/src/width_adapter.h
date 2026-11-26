/**
 * @file width_adapter.h
 * @brief Functions for AXI-Stream width adaptation between the 16-bit sample and 64-bit PCIe stream types
 * @author David Andrino-Izquierdo <david.andrino@upm.es>
 * @copyright Copyright: I2A2-UPM 2026
 * @license Apache-2.0
 * SPDX-License-Identifier: Apache-2.0
 * @date 2025-03-12
 */
#include "hls_dsp.h"
#include "hls_stream.h"
#include "ap_axi_sdata.h"

/**
 * @brief Adapt data from the data_t to the pci_data_t (longer) format
 * 
 * @tparam N Integer to differentiate function calls
 * @param in Input data stream
 * @param out Output data stream
 */
template <unsigned int N>
void adapt_longer(hls::stream<data_t>& in, hls::stream<pci_data_t>& out) {
	data_t input;
	pci_data_t output;
	output.keep = -1;
	output.strb = 1;

	input = in.read();
	ap_int<16> data = input.data;
	ap_int<64> data_long = (static_cast<ap_int<64>>(data) << (64 - 16));

	output.data = data_long;

	out.write(output);
}

/**
 * @brief Adapt data from the pci_data_t to the data_t (shorter) format
 * 
 * @tparam N Integer to differentiate function calls
 * @param in Input data stream
 * @param out Output data stream
 */
template <unsigned int N>
void adapt_shorter(hls::stream<pci_data_t>& in, hls::stream<data_t>& out) {
	pci_data_t input;
	data_t output;
	output.keep = -1;
	output.strb = 1;

	input = in.read();
	ap_int<64> data = input.data;
	ap_int<16> data_long = data >> (64 - 16);

	output.data = data_long;

	out.write(output);
}
