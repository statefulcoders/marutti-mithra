    /****
     * Import function triggers from their respective submodules:
     *
     * const {onCall} = require("firebase-functions/v2/https");
     * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
     *
     * See a full list of supported triggers at https://firebase.google.com/docs/functions
     */

    const logger = require("firebase-functions/logger");
    const admin = require("firebase-admin");
    const { onDocumentCreated } = require("firebase-functions/v2/firestore");

    admin.initializeApp();

    // Create and deploy your first functions
    // https://firebase.google.com/docs/functions/get-started

    const { onDocumentDeleted } = require("firebase-functions/v2/firestore");


    // Ensure parent message doc exists when subcollection item is created
    exports.ensureParentMessageDoc = onDocumentCreated("messages/{userId}/{subcol}/{docId}", async (event) => {
      const { userId, subcol } = event.params;
      const db = admin.firestore();

      try {
      // Convert Firestore event to DocumentSnapshot
        const snapshot = event.data;

        // Extract field values
        const payload = snapshot.data()
        const content = payload.content || 'Media File';
        const orderFrom = payload.orderFrom;

        let level;
        let currentType;

        if (subcol === 'orders') {
            currentType = orderFrom;
            if (orderFrom === 'Marutti Aluminiums') {
                level = 2;
            } else if (orderFrom === 'MWholesales') {
                level = 3;
            } else if (orderFrom === 'Vinlam Concepts') {
                level = 4;
            } else if (orderFrom === 'Hardware Palace') {
                level = 5;
            } else {
                level = 1;
                currentType = subcol;
            }
        } else if (subcol) {
            currentType = subcol;
            level = 0;
        }

        const docRef = db.collection("messages").doc(userId);
        const doc = await docRef.get();
        const currentLevel = doc.exists ? doc.data().level || 0 : 0;
        const newLevel = Math.max(currentLevel, level);

        await docRef.set({
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          level: newLevel,
          [currentType]: {
            lastContent: content,
            unreads: payload.sender === 'admin' ? 0 : admin.firestore.FieldValue.increment(1)
          },
          [subcol]: {
            lastContent: content,
            unreads: payload.sender === 'admin' ? 0 : admin.firestore.FieldValue.increment(1)
          }
        }, { merge: true });
        logger.info(`Ensured parent doc for user ${userId} exists in messages collection`);
      } catch (error) {
        logger.error(`Error ensuring parent doc for user ${userId}:`, error);
        throw error;
      }c
    });

exports.onUserDeleted = onDocumentDeleted("users/{userId}", async (event) => {
  const userId = event.params.userId;
  const db = admin.firestore();

  try {
    logger.info(`Deleting user from Firebase Auth: ${userId}`);
    await admin.auth().deleteUser(userId);
    logger.info(`Successfully deleted user from Firebase Auth: ${userId}`);

    // Helper function to delete subcollections
    const deleteSubcollection = async (parentPath, subcollectionName) => {
      const subcollectionRef = db.collection(`${parentPath}/${subcollectionName}`);
      const snapshot = await subcollectionRef.get();

      const deletePromises = [];
      snapshot.forEach(doc => {
        deletePromises.push(doc.ref.delete());
      });

      await Promise.all(deletePromises);
      logger.info(`Deleted all documents in ${parentPath}/${subcollectionName}`);
    };

    const userDocPath = `messages/${userId}`;

    // 1. Delete subcollections (orders, feedbacks)
    await deleteSubcollection(userDocPath, "orders");
    await deleteSubcollection(userDocPath, "feedbacks");
await db.collection("messages").doc(userId).delete();

    // 2. Delete the parent user message document
    await db.doc(userDocPath).delete();
    logger.info(`Deleted user document at ${userDocPath}`);

    // 3. NEW: Delete documents from 'rewarded_users' collection
    const rewardsQuery = db.collection("rewarded_users").where("uid", "==", userId);
    const rewardsSnapshot = await rewardsQuery.get();

    const rewardDeletePromises = [];
    rewardsSnapshot.forEach(doc => {
      rewardDeletePromises.push(doc.ref.delete());
    });

    await Promise.all(rewardDeletePromises);
    logger.info(`Deleted ${rewardsSnapshot.size} reward documents for user ${userId}`);

    logger.info(`Deleted related documents for user ${userId}`);
  } catch (error) {
    logger.error(`Error during cleanup for user ${userId}:`, error);
    // We log the error but re-throw it so Cloud Functions knows it failed
    throw error;
  }
});

    exports.onAdminDeleted = onDocumentDeleted("admins/{uid}", async (event) => {
      const uid = event.params.uid;
      const db = admin.firestore();

      try {
        logger.info(`Deleting admin user from Firebase Auth: ${uid}`);
        await admin.auth().deleteUser(uid);
        logger.info(`Successfully deleted admin user from Firebase Auth: ${uid}`);
      } catch (error) {
        logger.error(`Error deleting admin user ${uid}:`, error);
        throw error;
      }
    });

    // Function to send notification using Firebase Cloud Messaging

    const { onRequest } = require("firebase-functions/v2/https");

    // Single token notification
    exports.sendNotification = onRequest(async (req, res) => {
      res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
      if (req.method === 'OPTIONS') return res.status(200).end();

      const { title, body, token } = req.body;
      if (!title || !body || !token) {
        return res.status(400).json({ success: false, error: "Missing title, body, or token" });
      }

      const message = {
        notification: { title, body },
        android: { priority: "high", notification: { sound: "default" } },
        apns: { payload: { aps: { sound: "default" } } },
        token
      };

      try {
        const response = await admin.messaging().send(message);
        res.status(200).json({ success: true, sent: 1, failed: 0, response });
      } catch (error) {
        res.status(500).json({ success: false, sent: 0, failed: 1, error: error.message });
      }
    });

    // Category / multiple token notification
    exports.sendNotificationByCategory = onRequest(async (req, res) => {
      res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
      res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
      if (req.method === 'OPTIONS') return res.status(200).end();

      const { title, body, category } = req.body;
      if (!title || !body) return res.status(400).json({ success: false, error: "Missing title or body" });

      try {
        const db = admin.firestore();
        let usersQuery = db.collection("users");
        if (category) usersQuery = usersQuery.where("buyerCategory", "==", category);

        const usersSnapshot = await usersQuery.get();
        if (usersSnapshot.empty) return res.status(404).json({ success: false, error: "No users found" });

        const tokens = usersSnapshot.docs
          .map(doc => doc.data().firebaseToken)
          .filter(token => !!token);

        const notificationsRef = db.collection("notifications");
        const batch = db.batch();

        usersSnapshot.forEach(doc => {
          const notifDoc = notificationsRef.doc();
          batch.set(notifDoc, {
            title,
            body,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            receiver: doc.id,
            sender: "admin"
          });
        });

        await batch.commit();

        let totalSent = 0, totalFailed = 0;

        while (tokens.length > 0) {
          const batchTokens = tokens.splice(0, 500);
          const message = {
            notification: { title, body },
            android: { priority: "high", notification: { sound: "default" } },
            apns: { payload: { aps: { sound: "default" } } },
            tokens: batchTokens
          };

          const response = await admin.messaging().sendEachForMulticast(message);
          totalSent += response.successCount;
          totalFailed += response.failureCount;

          response.responses.forEach((resp, idx) => {
            if (!resp.success) logger.error(`Failed token: ${batchTokens[idx]}`, resp.error);
          });
        }

        res.status(200).json({
          success: true,
          sent: totalSent,
          failed: totalFailed,
          totalUsers: usersSnapshot.size
        });

      } catch (error) {
        res.status(500).json({ success: false, error: error.message });
      }
    });

    exports.createAdminUser = onRequest(async (req, res) => {
      res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
      if (req.method === 'OPTIONS') return res.status(200).end();

      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ success: false, error: "Missing email or password" });
      }

      try {
        const userRecord = await admin.auth().createUser({ email, password });
        const uid = userRecord.uid;

        await admin.auth().setCustomUserClaims(uid, { admin: true });
        console.log(`✅ Admin claim set for user ${uid}`);

        res.status(200).json({ success: true, uid });
      } catch (error) {
        console.error("❌ Error creating admin user:", error);
        res.status(500).json({ success: false, error: error.message });
      }
    });

    exports.markUserUnread = onDocumentCreated("notifications/{docId}", async (event) => {
      const snapshot = event.data;
      if (!snapshot) return;

      const notif = snapshot.data();
      const receiverId = notif.receiver;
      if (!receiverId) return;

      const db = admin.firestore();
      const userRef = db.collection("users").doc(receiverId);

      try {
        await userRef.set(
          { unread: true },
          { merge: true }
        );
        logger.info(`Marked user ${receiverId} as unread due to new notification`);
      } catch (error) {
        logger.error(`Error updating unread for user ${receiverId}:`, error);
        throw error;
      }
    });

    exports.createNewUserHttp = onRequest(async (req, res) => {
      // --- 1. CORS Headers ---
      res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
      res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
      res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

      if (req.method === 'OPTIONS') {
        return res.status(204).send('');
      }

      try {
        // --- 2. Auth & Admin Verification ---
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
          return res.status(401).json({ success: false, error: "Unauthorized: Missing Bearer Token" });
        }

        const idToken = authHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);

        if (!decodedToken.admin) {
          return res.status(403).json({ success: false, error: "Permission Denied: Admins only." });
        }

        // --- 3. Data Parsing & Phone Validation ---
        const userData = req.body;

        // Ensure phone exists and is a string (remove whitespace for safety)
        let phone = userData.phone ? String(userData.phone).trim() : "";

        if (!phone) {
          return res.status(400).json({ success: false, error: "Missing required field: phone" });
        }

        // PHONE LOGIC:
        // 1. Check if starts with +91
        // 2. If NOT, check if it is exactly 10 digits -> Add +91
        // 3. Else -> Error

        if (phone.startsWith("+91")) {
          // It has the code, we assume it's valid for now (Firebase Auth will do final validation)
        } else if (/^\d{10}$/.test(phone)) {
          // It does not have +91, but is exactly 10 digits
          phone = "+91" + phone;
        } else {
          // Neither starts with +91 nor is 10 digits
          return res.status(400).json({
            success: false,
            error: "Invalid Phone Number. Must start with +91 or be exactly 10 digits."
          });
        }

        // Update the userData object with the formatted phone
        userData.phone = phone;


        // --- 4. Create User in Firebase Auth ---
        const userRecord = await admin.auth().createUser({
          phoneNumber: userData.phone,
          displayName: "address-level",
          ...(userData.email && { email: userData.email }),
          ...(userData.password && { password: userData.password }),
        });


        // --- 5. Prepare Firestore Data ---
        const newUserDetails = {
          ...userData,
          uid: userRecord.uid,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          unread: false,
        };

        // Convert Date Strings to Timestamps
        if (newUserDetails.dateOfBirth) {
          const dateObj = new Date(newUserDetails.dateOfBirth);
          if (!isNaN(dateObj.getTime())) {
            newUserDetails.dateOfBirth = admin.firestore.Timestamp.fromDate(dateObj);
          } else {
            delete newUserDetails.dateOfBirth;
          }
        }

        delete newUserDetails.password; // Don't save password to Firestore

        // Save to Firestore
        const db = admin.firestore();
        await db.collection("users").doc(userRecord.uid).set(newUserDetails);

        logger.info(`Admin ${decodedToken.uid} created user ${userRecord.uid} (${userData.phone}) via HTTP`);

        return res.status(200).json({
          success: true,
          uid: userRecord.uid,
        });

      } catch (error) {
        logger.error("Error creating user:", error);

        if (error.code === 'auth/phone-number-already-exists') {
          return res.status(409).json({ success: false, error: "This phone number is already registered." });
        }
        if (error.code === 'auth/email-already-exists') {
          return res.status(409).json({ success: false, error: "This email is already registered." });
        }
        if (error.code === 'auth/invalid-phone-number') {
          return res.status(400).json({ success: false, error: "The formatted phone number is invalid." });
        }

        return res.status(500).json({ success: false, error: error.message });
      }
    });


exports.distributeRewardsHttp = onRequest(async (req, res) => {
  // 1. CORS Headers
  res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === 'OPTIONS') return res.status(204).send('');

  try {
    // 2. Auth Verification
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, error: "Unauthorized" });
    }
    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (!decodedToken.admin) {
      return res.status(403).json({ success: false, error: "Admins only." });
    }

    // 3. Inputs
    const { uid, rewardId, quantity } = req.body;
    const qty = parseInt(quantity);

    if (!uid || !rewardId || !qty || qty < 1) {
      return res.status(400).json({ success: false, error: "Invalid parameters" });
    }

    const db = admin.firestore();
    const rewardRef = db.collection("reward-coupons").doc(rewardId);
    const userRef = db.collection("users").doc(uid);
    const rewardedUsersRef = db.collection("rewarded_users");
    const couponTypesCollection = db.collection("reward-coupons-types");

    // Variables needed outside transaction for notification
    let userToken = "";
    let durationDays = 365; // Default

    // 4. Run Transaction
    await db.runTransaction(async (t) => {
      // --- A. Initial Reads ---
      const rewardDoc = await t.get(rewardRef);
      const userDoc = await t.get(userRef);

      if (!rewardDoc.exists) throw new Error("Reward not found");
      if (!userDoc.exists) throw new Error("User not found");

      const rewardData = rewardDoc.data();
      const userData = userDoc.data();
      userToken = userData.firebaseToken;

      // --- B. Stock Logic ---
      const typesMap = rewardData.types || {};
      let totalStock = 0;
      let inventory = [];

      Object.keys(typesMap).forEach(key => {
        const count = parseInt(typesMap[key] || 0);
        totalStock += count;
        for (let i = 0; i < count; i++) {
          inventory.push(key);
        }
      });

      const currentDistributed = parseInt(rewardData.distributed || 0);
      const remaining = totalStock - currentDistributed;

      if (remaining < qty) {
        throw new Error(`Insufficient stock. Requested: ${qty}, Remaining: ${remaining}`);
      }

      // --- C. Random Selection ---
      for (let i = inventory.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [inventory[i], inventory[j]] = [inventory[j], inventory[i]];
      }
      const selectedTypes = inventory.slice(0, qty);

      // --- D. Time Calculation ---
      durationDays = parseInt(rewardData.duration || 365);
      const now = new Date();
      const expirationDate = new Date(now);
      expirationDate.setDate(expirationDate.getDate() + durationDays);

      // --- E. NEW: Fetch Coupon Type Data (Must happen before any writes) ---
      // 1. Identify unique types selected to avoid duplicate reads
      const uniqueSubRewards = [...new Set(selectedTypes)];
      const typeDetailsMap = {};

      // 2. Create queries for each unique type
      const typeQueries = uniqueSubRewards.map(name => {
        const q = couponTypesCollection.where("name", "==", name).limit(1);
        return t.get(q).then(snap => ({ name, snap }));
      });

      // 3. Execute all reads in parallel
      const typeResults = await Promise.all(typeQueries);

      // 4. Store results in a map
      typeResults.forEach(({ name, snap }) => {
        if (!snap.empty) {
          typeDetailsMap[name] = snap.docs[0].data();
        }
      });

      // --- F. Writes ---

      // 1. Update Reward distributed count
      t.update(rewardRef, {
        distributed: admin.firestore.FieldValue.increment(qty)
      });

      // 2. Add to rewarded_users
      selectedTypes.forEach(subRewardName => {
        // Retrieve specific data from our map
        const specificTypeData = typeDetailsMap[subRewardName];

        // Logic: Use data from 'reward-coupons-types' if found.
        // If not found, use null (explicitly ignoring rewardData as requested).
        const finalImage = specificTypeData ? (specificTypeData.image || null) : null;
        const finalDescription = specificTypeData ? (specificTypeData.description || null) : null;

        const newRecordRef = rewardedUsersRef.doc(); // Auto-ID
        t.set(newRecordRef, {
            uid: uid,
            phone: userData.phone || '',
            shopName: userData.shopName || '',
            firstName: userData.firstName || '',
            lastName: userData.lastName || '',
            buyerCategory: userData.buyerCategory || '',
            district: userData.district || '',

            rewardId: rewardId,
            rewardName: rewardData.name,
            couponType: subRewardName,

            // UPDATED: Using specific data, not rewardData
            image: finalImage,
            description: finalDescription,

            status: 'assigned',
            redeemed: false,
            pointsCost: rewardData.points || 0,

            distributedAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: admin.firestore.Timestamp.fromDate(expirationDate),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
    });

    // 5. Send Notification with Duration
    if (userToken) {
        try {
            const message = {
                notification: {
                    title: "Rewards Unlocked! 🎉",
                    body: `You received ${qty} new reward${qty > 1 ? 's' : ''}! Scratch within ${durationDays} days to win.`
                },
                token: userToken,
                android: { priority: "high", notification: { sound: "default" } },
                apns: { payload: { aps: { sound: "default" } } },
            };
            await admin.messaging().send(message);
        } catch (notifError) {
            console.error("Notification failed:", notifError);
        }
    }

    return res.status(200).json({ success: true, message: "Distributed successfully" });

  } catch (error) {
    console.error("Distribute Error:", error);
    const msg = error.message || "Internal Server Error";
    const code = (msg.includes("Insufficient") || msg.includes("inactive")) ? 400 : 500;
    return res.status(code).json({ success: false, error: msg });
  }
});

exports.redeemAllRewardsHttp = onRequest(async (req, res) => {
  // 1. CORS Headers
  res.set("Access-Control-Allow-Origin", "https://marutti-mitra-admin.web.app");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === 'OPTIONS') return res.status(204).send('');

  try {
    // 2. Auth Verification (Admin Only)
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, error: "Unauthorized" });
    }
    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (!decodedToken.admin) {
      return res.status(403).json({ success: false, error: "Admins only." });
    }

    const db = admin.firestore();

    // 3. Query ALL 'scratched' rewards in the entire system
    // UPDATED: Changed status check to 'scratched'
    const snapshot = await db.collection("rewarded_users")
      .where("status", "==", "scratched")
      .get();

    if (snapshot.empty) {
      return res.status(200).json({ success: true, count: 0, message: "No scratched rewards found." });
    }

    // 4. Batch Update Logic (Handling Firestore 500 limit)
    const batches = [];
    let batch = db.batch();
    let operationCounter = 0;
    const now = admin.firestore.FieldValue.serverTimestamp();

    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'redeemed',
        redeemedAt: now,
        updatedAt: now
      });
      operationCounter++;

      if (operationCounter === 500) {
        batches.push(batch.commit());
        batch = db.batch();
        operationCounter = 0;
      }
    });

    if (operationCounter > 0) {
      batches.push(batch.commit());
    }

    await Promise.all(batches);

    return res.status(200).json({
      success: true,
      count: snapshot.size,
      message: `Successfully redeemed ${snapshot.size} scratched rewards.`
    });

  } catch (error) {
    console.error("Global Redeem Error:", error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ---------------------------------------------------------
// NEW FUNCTION: Check and expire rewards via Cron Job
// ---------------------------------------------------------
exports.expireRewards = onRequest(async (req, res) => {
  // 1. Basic Security (Optional but recommended if triggered via public URL)
  // Even with Cloud Scheduler, it's good practice to log invocation
  logger.info("Starting scheduled reward expiration check.");

  try {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // 2. Query for expired rewards
    // Criteria: status is 'assigned' AND expiresAt is in the past
    const snapshot = await db.collection("rewarded_users")
      .where("status", "==", "assigned")
      .where("expiresAt", "<", now)
      .get();

    if (snapshot.empty) {
      logger.info("No expired rewards found.");
      return res.status(200).send("No expired rewards found.");
    }

    // 3. Batch Update
    // Firestore batches can hold up to 500 operations.
    const batches = [];
    let batch = db.batch();
    let operationCounter = 0;

    snapshot.docs.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'expired',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      operationCounter++;

      // If batch is full (500 ops), push to array and start new batch
      if (operationCounter === 500) {
        batches.push(batch.commit());
        batch = db.batch();
        operationCounter = 0;
      }
    });

    // Commit any remaining operations
    if (operationCounter > 0) {
      batches.push(batch.commit());
    }

    // 4. Await all batches
    await Promise.all(batches);

    logger.info(`Successfully expired ${snapshot.size} rewards.`);
    return res.status(200).send(`Successfully expired ${snapshot.size} rewards.`);

  } catch (error) {
    logger.error("Error expiring rewards:", error);
    return res.status(500).send(`Internal server error: ${error}`);
  }
});