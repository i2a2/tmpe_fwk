/**
 * @file hls_dsp.h
 * @brief Main header for the HLS DSP module: AXI-Stream data types and top-level function declaration
 * @author David Andrino-Izquierdo <david.andrino@upm.es>
 * @copyright Copyright: I2A2-UPM 2026
 * @license Apache-2.0
 * SPDX-License-Identifier: Apache-2.0
 * @date 2025-03-12
 */
#pragma once

#include "ap_axi_sdata.h"
#include "hls_stream.h"

/**
 * @brief Datatype for 16-bit data from AXI-Stream
 */
typedef ap_axis<16, 0, 0, 0> data_t;

/**
 * @brief Datatype for 64-bit data from AXI-Stream
 */
typedef ap_axis<64, 0, 0, 0> pci_data_t;

/**
 * @brief Top level function for the DSP module. Currently implements width adaptation
 * from ADC1 to C2H and H2C to DAC1 and FIR filters for the rest of ADC channels to the
 * corresponding DAC channels.
 * 
 * @param in_adc1 ADC Channel 1 input stream
 * @param in_adc2 ADC Channel 2 input stream
 * @param in_adc3 ADC Channel 3 input stream
 * @param in_adc4 ADC Channel 4 input stream
 * @param out_dac1 DAC Channel 1 output stream
 * @param out_dac2 DAC Channel 2 output stream
 * @param out_dac3 DAC Channel 3 output stream
 * @param out_dac4 DAC Channel 4 output stream
 * @param in_h2c PCI H2C input stream
 * @param out_c2h PCI C2H output stream
 */
void top(
        hls::stream<data_t>& in_adc1, 
        hls::stream<data_t>& in_adc2, 
        hls::stream<data_t>& in_adc3, 
        hls::stream<data_t>& in_adc4, 
        hls::stream<data_t>& out_dac1,
        hls::stream<data_t>& out_dac2,
        hls::stream<data_t>& out_dac3,
        hls::stream<data_t>& out_dac4,
        hls::stream<pci_data_t>& in_h2c,
        hls::stream<pci_data_t>& out_c2h
    );
