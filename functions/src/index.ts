import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";

admin.initializeApp();

// Configuration - In production use Secret Manager
// firebase functions:secrets:set BKASH_USERNAME
const config = {
    baseUrl: "https://tokenized.sandbox.bka.sh/v1.2.0-beta", // Sandbox URL
    username: process.env.BKASH_USERNAME || "sandboxTokenizedUser02",
    password: process.env.BKASH_PASSWORD || "sandboxTokenizedUser02@12345",
    appKey: process.env.BKASH_APP_KEY || "4f6o0cjiki2rfm34kfdadl1eqq",
    appSecret: process.env.BKASH_APP_SECRET || "2is7hdktrekvrbljjh44ll3d9l1dtl4oa7rf57a16k",
};

// headers for API calls
const getHeaders = async (token?: string) => {
    return {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "username": config.username,
        "password": config.password,
        ...(token ? { "authorization": token, "x-app-key": config.appKey } : {}),
    };
};

/**
 * 1. Grant Token
 * Call this internally to get a token. Logic should cache this.
 */
const grantToken = async (): Promise<string> => {
    try {
        const response = await axios.post(
            `${config.baseUrl}/tokenized/checkout/token/grant`,
            {
                app_key: config.appKey,
                app_secret: config.appSecret,
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "username": config.username,
                    "password": config.password,
                },
            }
        );
        // In a real app, cache this token in Firestore or global variable with expiry check
        return response.data.id_token;
    } catch (error: any) {
        console.error("Grant Token Error", error.response?.data || error);
        throw new functions.https.HttpsError("internal", "Failed to grant payment token");
    }
};

/**
 * 2. Create Payment
 * Callable from App.
 * Data: { amount: number, invoiceId: string }
 */
export const bkashCreatePayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
    }

    const { amount, invoiceId } = data;

    const token = await grantToken();

    try {
        const response = await axios.post(
            `${config.baseUrl}/tokenized/checkout/create`,
            {
                mode: "0011",
                payerReference: context.auth.uid,
                callbackURL: "https://your-app-callback-url.com/payment/callback", // Not strictly used in app-based flow if we intercept, but required by API
                amount: amount.toString(),
                currency: "BDT",
                intent: "sale",
                merchantInvoiceNumber: invoiceId || "Inv-" + Date.now(),
            },
            {
                headers: await getHeaders(token),
            }
        );

        const { paymentID, bkashURL } = response.data;

        // Save initial payment status to Firestore
        await admin.firestore().collection("payments").add({
            paymentId: paymentID,
            invoiceId: invoiceId,
            uid: context.auth.uid,
            amount: amount,
            status: "pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { paymentID, bkashURL };
    } catch (error: any) {
        console.error("Create Payment Error", error.response?.data || error);
        throw new functions.https.HttpsError("internal", "Failed to create payment");
    }
});

/**
 * 3. Execute Payment
 * Callable from App after success redirect.
 * Data: { paymentID: string }
 */
export const bkashExecutePayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
    }

    const { paymentID } = data;
    const token = await grantToken();

    try {
        const response = await axios.post(
            `${config.baseUrl}/tokenized/checkout/execute`,
            { paymentID },
            { headers: await getHeaders(token) }
        );

        const result = response.data;

        // bKash returns status in result (e.g., 'Completed')
        if (result && result.transactionStatus === "Completed") {
            // Update Firestore
            const snapshot = await admin.firestore().collection("payments").where("paymentId", "==", paymentID).limit(1).get();
            if (!snapshot.empty) {
                const doc = snapshot.docs[0];
                await doc.ref.update({
                    status: "paid",
                    trxID: result.trxID,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    bkashData: result,
                });

                // Update associated invoice status
                const invoiceId = doc.data().invoiceId;
                if (invoiceId) {
                    await admin.firestore().collection("invoices").doc(invoiceId).update({
                        status: "paid",
                        paidAt: admin.firestore.FieldValue.serverTimestamp(),
                        lastPaymentId: doc.id
                    });
                }
            }
            return { success: true, trxID: result.trxID };
        } else {
            throw new functions.https.HttpsError("aborted", "Payment execution failed or cancelled", result);
        }

    } catch (error: any) {
        console.error("Execute Payment Error", error.response?.data || error);
        throw new functions.https.HttpsError("internal", "Failed to execute payment");
    }
});
