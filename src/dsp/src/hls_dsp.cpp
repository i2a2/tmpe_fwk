/**
 * @file hls_dsp.cpp
 * @brief HLS DSP body: AXI-Stream width adaptation and FIR/IIR filtering per channel
 * @author David Andrino-Izquierdo <david.andrino@upm.es>
 * @copyright Copyright: I2A2-UPM 2026
 * @license Apache-2.0
 * SPDX-License-Identifier: Apache-2.0
 * @date 2025-03-12
 */
#include "hls_dsp.h"
#include "width_adapter.h"
#include "fir.h"

/**
 * @brief IIR filter coefficient. Fixed-point of 18 bits
 */
static const ap_fixed<18, 1, AP_RND, AP_WRAP> iir_alpha = 0.25;

/**
 * @brief 1 - IIR Filter coefficient. Fixed-point of 18 bits
 */
static const ap_fixed<18, 1, AP_RND, AP_WRAP> iir_one_minus_alpha = 0.75;

/**
 * @brief IIR Low Pass Filter function
 * 
 * @tparam N Integer to differentiate function calls
 * @param in Input AXI-Stream
 * @param out Output AXI-Stream
 */
template<unsigned int N>
void iir(hls::stream<pci_data_t>& in, hls::stream<pci_data_t>& out) {
    static ap_int<64> prev = 0;
#pragma HLS RESET variable=prev

    pci_data_t tmp = in.read();
    ap_int<64> input = tmp.data;

    prev = input * iir_alpha + prev * iir_one_minus_alpha;

    tmp.data = prev;
    out.write(tmp);
}

/**
 * @brief Passthough function. Performs no processing
 * 
 * @tparam N Integer to differentiate function calls
 * @tparam T Type of data to be transferred
 * @param in Input AXI-Stream
 * @param out Output AXI-Stream
 */
template<unsigned int N, typename T>
void passthrough(hls::stream<T>& in, hls::stream<T>& out) {
	out.write(in.read());
}

void top(
        hls::stream<data_t>& in_adc1,  hls::stream<data_t>& in_adc2, 
        hls::stream<data_t>& in_adc3,  hls::stream<data_t>& in_adc4, 
        hls::stream<data_t>& out_dac1, hls::stream<data_t>& out_dac2,
        hls::stream<data_t>& out_dac3, hls::stream<data_t>& out_dac4,
        hls::stream<pci_data_t>& in_h2c,   hls::stream<pci_data_t>& out_c2h
    ) {
#pragma HLS INTERFACE mode=axis port=in_adc1,in_adc2,in_adc3,in_adc4,out_dac1,out_dac2,out_dac3,out_dac4,in_h2c,out_c2h
#pragma HLS INTERFACE mode=ap_ctrl_none port=return
#pragma HLS dataflow
    adapt_longer<0>(in_adc1, out_c2h);
    adapt_shorter<0>(in_h2c, out_dac1);
	//fir<0>(in_adc1, out_dac1);
	fir<1>(in_adc2, out_dac2);
    fir<2>(in_adc3, out_dac3);
    fir<3>(in_adc4, out_dac4);
    //passthrough<4, pci_data_t>(in_h2c, out_c2h);
    //iir<0>(in_h2c, out_c2h);
}
