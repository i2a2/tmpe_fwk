/**
 * @file fir.h
 * @brief HLS FIR implementation: coefficient tables generated with t-filter.appspot.com
 * @author David Andrino-Izquierdo <david.andrino@upm.es>
 * @copyright Copyright: I2A2-UPM 2026
 * @license Apache-2.0
 * SPDX-License-Identifier: Apache-2.0
 * @date 2025-03-12
 */
#pragma once

/*

FIR filter designed with
 http://t-filter.appspot.com

sampling frequency: 100000 Hz

* 0 Hz - 5000 Hz
  gain = 1
  desired ripple = 1 dB
  actual ripple = 1.0170495015247925 dB

* 10000 Hz - 50000 Hz
  gain = 0
  desired attenuation = -40 dB
  actual attenuation = -37.38237348417459 dB

*/

#include "hls_dsp.h"
#include "hls_stream.h"
#include "ap_axi_sdata.h"

#define FIR_LPFFILTER_TAP_NUM 32

// DSP48E1 slices have 25x18 multipliers
static ap_fixed<25, 1, AP_RND, AP_WRAP> filter_taps[FIR_LPFFILTER_TAP_NUM] = {
    0.006108859412847285,
    -0.002605323801273313,
    -0.0062451173277574415,
    -0.011510507812646715,
    -0.017170968826967187,
    -0.02153234146494143,
    -0.022652396111731542,
    -0.018679705670301708,
    -0.00829571269626522,
    0.008875747297207777,
    0.032016397939266805,
    0.05909097924462758,
    0.08708755945670506,
    0.11245700206595499,
    0.1317082905053255,
    0.14210760007481849,
    0.14210760007481849,
    0.1317082905053255,
    0.11245700206595499,
    0.08708755945670506,
    0.05909097924462758,
    0.032016397939266805,
    0.008875747297207777,
    -0.00829571269626522,
    -0.018679705670301708,
    -0.022652396111731542,
    -0.02153234146494143,
    -0.017170968826967187,
    -0.011510507812646715,
    -0.0062451173277574415,
    -0.002605323801273313,
    0.006108859412847285
};

template<unsigned int N>
void fir(hls::stream<data_t>& in, hls::stream<data_t>& out) {
    static ap_int<16> history[FIR_LPFFILTER_TAP_NUM] = { 0 };
    #pragma HLS reset variable=history
	#pragma HLS array_partition dim=0 type=complete variable=history

    data_t stream_data = in.read();
    ap_int<16> data = stream_data.data;

    delay: for (int i = FIR_LPFFILTER_TAP_NUM - 1; i > 0; i--) {
        #pragma HLS unroll
        history[i] = history[i - 1];
    }
    history[0] = data;

    ap_int<16> sum = 0;
    conv: for (int i = 0; i < FIR_LPFFILTER_TAP_NUM; i++) {
        // #pragma HLS unroll
        sum += history[i] * filter_taps[i];
    }
    stream_data.data = sum;

    out.write(stream_data);
}
