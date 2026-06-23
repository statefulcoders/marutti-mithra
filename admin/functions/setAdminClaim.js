// setAdminClaim.js
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(), // Or use service account
});

const uid = "N9xwvBu7RcOPxnI042g7lFySATz2";

admin.auth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`✅ Admin claim set for user ${uid}`);
    process.exit();
  })
  .catch((error) => {
    console.error("❌ Error setting admin claim:", error);
    process.exit(1);
  });