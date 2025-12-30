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

/**
 * 4. Auto-Update/Generate Invoice on Flat Update
 * Trigger: flats/{flatId} update
 */
export const onFlatUpdated = functions.firestore
    .document("flats/{flatId}")
    .onUpdate(async (change, context) => {
        const newData = change.after.data();

        // 1. Check if relevant fields changed & validity
        if (!newData || newData.status !== 'occupied' || !newData.residentId) {
            console.log("Flat not occupied or invalid data. Skipping invoice update.");
            return null;
        }

        const flatId = context.params.flatId;
        const residentId = newData.residentId;
        const currentLeaseId = newData.currentLeaseId; // Required for InvoiceModel

        // Calculate new totals
        const rentBase = Number(newData.rentBase) || 0;
        const utilities = newData.utilities || {};
        let utilityTotal = 0;
        const items = [
            { key: "Rent", amount: rentBase }
        ];

        for (const [key, val] of Object.entries(utilities)) {
            const amount = Number(val) || 0;
            if (amount > 0) {
                // Ensure key matches InvoiceItem enum/string expectation
                items.push({ key: key, amount: amount });
                utilityTotal += amount;
            }
        }

        const totalAmount = rentBase + utilityTotal;

        // Current Month Key (YYYY-MM)
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const monthKey = `${year}-${month}`;

        // Query for existing invoice for this month
        const invoicesRef = admin.firestore().collection("invoices");
        const snapshot = await invoicesRef
            .where("flatId", "==", flatId)
            .where("monthKey", "==", monthKey)
            .limit(1)
            .get();

        if (!snapshot.empty) {
            // Invoice Exists - Update it if NOT paid
            const invoiceDoc = snapshot.docs[0];
            const invoiceData = invoiceDoc.data();

            if (invoiceData.status === 'paid') {
                console.log("Invoice already paid. Skipping update.");
                return null;
            }

            console.log(`Updating existing invoice ${invoiceDoc.id} with new totals.`);
            return invoiceDoc.ref.update({
                items: items,
                totalAmount: totalAmount,
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });
        } else {
            // Invoice Does Not Exist - Create it
            // Only if we have necessary IDs
            if (!currentLeaseId) {
                console.log("Missing currentLeaseId. Cannot create invoice.");
                return null;
            }

            console.log(`Creating new invoice for flat ${flatId}, month ${monthKey}.`);

            // Due Date
            const dueDay = newData.dueDay || 5;
            // Create date object for due date of CURRENT month
            // Be careful with month overflow if today is Jan 31 and we set Feb 5.
            const dueDate = new Date(year, now.getMonth(), dueDay);

            const docRef = invoicesRef.doc();

            const newInvoice = {
                id: docRef.id, // IMPORTANT: Store ID in document
                flatId: flatId,
                propertyId: newData.propertyId,
                residentId: residentId,
                ownerId: newData.ownerId,
                leaseId: currentLeaseId,
                monthKey: monthKey,
                items: items,
                totalAmount: totalAmount,
                status: "due",
                dueDate: admin.firestore.Timestamp.fromDate(dueDate),
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                // updatedAt: admin.firestore.FieldValue.serverTimestamp(), // Optional
            };

            return docRef.set(newInvoice);
        }
    });
