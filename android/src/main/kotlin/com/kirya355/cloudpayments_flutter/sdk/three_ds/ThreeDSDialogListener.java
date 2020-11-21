package com.kirya355.cloudpayments_flutter.sdk.three_ds;

public interface ThreeDSDialogListener {

    void onAuthorizationCompleted(final String md, final String paRes);

    void onAuthorizationFailed(final String html);
    
    void onCancel();
}